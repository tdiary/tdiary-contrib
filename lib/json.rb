# = json - JSON library for Ruby
#
# == Description
#
# == Author
#
# Florian Frank <mailto:flori@ping.de>
#
# == License
#
# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License Version 2 as published by the Free
# Software Foundation: www.gnu.org/copyleft/gpl.html
#
# == Download
#
# The latest version of this library can be downloaded at
#
# * http://rubyforge.org/frs?group_id=953
#
# Online Documentation should be located at
#
# * http://json.rubyforge.org
#
# == Examples
#
# To create a JSON string from a ruby data structure, you
# can call JSON.unparse (or JSON.generate) like that:
#
#  json = JSON.unparse [1, 2, {"a"=>3.141}, false, true, nil, 4..10]
#  # => "[1,2,{\"a\":3.141},false,true,null,\"4..10\"]"
#
# It's also possible to call the #to_json method directly.
#
#  json = [1, 2, {"a"=>3.141}, false, true, nil, 4..10].to_json
#  # => "[1,2,{\"a\":3.141},false,true,null,\"4..10\"]"
#
# To get back a ruby data structure, you have to call
# JSON.parse on the JSON string:
#
#  JSON.parse json
#  # => [1, 2, {"a"=>3.141}, false, true, nil, "4..10"]
# 
# Note, that the range from the original data structure is a simple
# string now. The reason for this is, that JSON doesn't support ranges
# or arbitrary classes. In this case the json library falls back to call
# Object#to_json, which is the same as #to_s.to_json.
#
# It's possible to extend JSON to support serialization of arbitray classes by
# simply implementing a more specialized version of the #to_json method, that
# should return a JSON object (a hash converted to JSON with #to_json)
# like this (don't forget the *a for all the arguments):
#
#  class Range
#    def to_json(*a)
#      {
#        'json_class'   => self.class.name,
#        'data'         => [ first, last, exclude_end? ]
#      }.to_json(*a)
#    end
#  end
#
# The hash key 'json_class' is the class, that will be asked to deserialize the
# JSON representation later. In this case it's 'Range', but any namespace of
# the form 'A::B' or '::A::B' will do. All other keys are arbitrary and can be
# used to store the necessary data to configure the object to be deserialized.
#
# If a the key 'json_class' is found in a JSON object, the JSON parser checks
# if the given class responds to the json_create class method. If so, it is
# called with the JSON object converted to a Ruby hash. So a range can
# be deserialized by implementing Range.json_create like this:
# 
#  class Range
#    def self.json_create(o)
#      new(*o['data'])
#    end
#  end
#
# Now it possible to serialize/deserialize ranges as well:
#
#  json = JSON.unparse [1, 2, {"a"=>3.141}, false, true, nil, 4..10]
#  # => "[1,2,{\"a\":3.141},false,true,null,{\"json_class\":\"Range\",\"data\":[4,10,false]}]"
#  JSON.parse json
#  # => [1, 2, {"a"=>3.141}, false, true, nil, 4..10]
#
# JSON.unparse always creates the shortes possible string representation of a
# ruby data structure in one line. This good for data storage or network
# protocols, but not so good for humans to read. Fortunately there's
# also JSON.pretty_unparse (or JSON.pretty_generate) that creates a more
# readable output:
#
#  puts JSON.pretty_unparse([1, 2, {"a"=>3.141}, false, true, nil, 4..10])
#  [
#    1,
#    2,
#    {
#      "a": 3.141
#    },
#    false,
#    true,
#    null,
#    {
#      "json_class": "Range",
#      "data": [
#        4,
#        10,
#        false
#      ]
#    }
#  ]
#
# There are also the methods Kernel#j for unparse, and Kernel#jj for
# pretty_unparse output to the console, that work analogous to Kernel#p and
# Kernel#pp.
#

require 'strscan'

# This module is the namespace for all the JSON related classes. It also 
# defines some module functions to expose a nicer API to users, instead
# of using the parser and other classes directly.
module JSON
  # The base exception for JSON errors.
  JSONError             = Class.new StandardError

  # This exception is raise, if a parser error occurs.
  ParserError           = Class.new JSONError

  # This exception is raise, if a unparser error occurs.
  UnparserError         = Class.new JSONError

  # If a circular data structure is encountered while unparsing
  # this exception is raised.
  CircularDatastructure = Class.new UnparserError

  class << self
    # Switches on Unicode support, if _enable_ is _true_. Otherwise switches
    # Unicode support off.
    def support_unicode=(enable)
      @support_unicode = enable
    end

    # Returns _true_ if JSON supports unicode, otherwise _false_ is returned.
    #
    # If loading of the iconv library fails, or it doesn't support utf8/utf16
    # encoding, this will be set to false, as a fallback.
    def support_unicode?
      !!@support_unicode
    end
  end
  JSON.support_unicode = true # default, however it's possible to switch off
                              # full unicode support, if non-ascii bytes should be
                              # just passed through.

  begin
    require 'iconv'
    # An iconv instance to convert from UTF8 to UTF16 Big Endian.
    UTF16toUTF8 = Iconv.new('utf-8', 'utf-16be')
    # An iconv instance to convert from UTF16 Big Endian to UTF8.
    UTF8toUTF16 = Iconv.new('utf-16be', 'utf-8'); UTF8toUTF16.iconv('no bom')
  rescue Errno::EINVAL, Iconv::InvalidEncoding
    # Iconv doesn't support big endian utf-16. Let's try to hack this manually
    # into the converters.
    begin
      old_verbose = $VERBOSE
      $VERBOSE = nil
      # An iconv instance to convert from UTF8 to UTF16 Big Endian.
      UTF16toUTF8 = Iconv.new('utf-8', 'utf-16')
      # An iconv instance to convert from UTF16 Big Endian to UTF8.
      UTF8toUTF16 = Iconv.new('utf-16', 'utf-8'); UTF8toUTF16.iconv('no bom')
      if UTF8toUTF16.iconv("\xe2\x82\xac") == "\xac\x20"
        swapper = Class.new do
          def initialize(iconv)
            @iconv = iconv
          end

          def iconv(string)
            result = @iconv.iconv(string)
            JSON.swap!(result)
          end
        end
        UTF8toUTF16 = swapper.new(UTF8toUTF16)
      end
      if UTF16toUTF8.iconv("\xac\x20") == "\xe2\x82\xac"
        swapper = Class.new do
          def initialize(iconv)
            @iconv = iconv
          end

          def iconv(string)
            string = JSON.swap!(string.dup)
            @iconv.iconv(string)
          end
        end
        UTF16toUTF8 = swapper.new(UTF16toUTF8)
      end
    rescue Errno::EINVAL, Iconv::InvalidEncoding
      # Enforce disabling of unicode support, if iconv doesn't support
      # UTF8/UTF16 at all.
      JSON.support_unicode = false
    ensure
      $VERBOSE = old_verbose
    end
  rescue LoadError
    # Enforce disabling of unicode support, if iconv doesn't exist.
    JSON.support_unicode = false
  end

  # Swap consecutive bytes in string in place.
  def self.swap!(string)
    0.upto(string.size / 2) do |i|
      break unless string[2 * i + 1]
      string[2 * i], string[2 * i + 1] = string[2 * i + 1], string[2 * i]
    end
    string
  end

  # This class implements the JSON parser that is used to parse a JSON string
  # into a Ruby data structure.
  class Parser < StringScanner
    STRING                = /"((?:[^"\\]|\\.)*)"/
    INTEGER               = /-?(?:0|[1-9]\d*)/
    FLOAT                 = /-?(?:0|[1-9]\d*)\.(\d+)(?i:e[+-]?\d+)?/
    OBJECT_OPEN           = /\{/
    OBJECT_CLOSE          = /\}/
    ARRAY_OPEN            = /\[/
    ARRAY_CLOSE           = /\]/
    PAIR_DELIMITER        = /:/
    COLLECTION_DELIMITER  = /,/
    TRUE                  = /true/
    FALSE                 = /false/
    NULL                  = /null/
    IGNORE                = %r(
      (?:
        //[^\n\r]*[\n\r]| # line comments
        /\*               # c-style comments
          (?:
            [^*/]|        # normal chars
            /[^*]|        # slashes that do not start a nested comment
            \*[^/]|       # asterisks that do not end this comment
            /(?=\*/)      # single slash before this comment's end 
          )*
        \*/               # the end of this comment
        |[ \t\r\n]+       # whitespaces: space, horicontal tab, lf, cr
      )+
    )mx

    UNPARSED = Object.new

    # Parses the current JSON string and returns the complete data structure
    # as a result.
    def parse
      reset
      obj = nil
      until eos?
        case
        when scan(OBJECT_OPEN)
          obj and raise ParserError, "source '#{peek(20)}' not in JSON!"
          obj = parse_object
        when scan(ARRAY_OPEN)
          obj and raise ParserError, "source '#{peek(20)}' not in JSON!"
          obj = parse_array
        when skip(IGNORE)
          ;
        else
          raise ParserError, "source '#{peek(20)}' not in JSON!"
        end
      end
      obj or raise ParserError, "source did not contain any JSON!"
      obj
    end

    private

    def parse_string
      if scan(STRING)
        return '' if self[1].empty?
        self[1].gsub(%r(\\(?:[\\bfnrt"/]|u([A-Fa-f\d]{4})))) do
          case $~[0]
          when '\\"'  then '"'
          when '\\\\' then '\\'
          when '\\/'  then '/'
          when '\\b'  then "\b"
          when '\\f'  then "\f"
          when '\\n'  then "\n"
          when '\\r'  then "\r"
          when '\\t'  then "\t"
          else
            if JSON.support_unicode? and $KCODE == 'UTF8'
              JSON.utf16_to_utf8($~[1])
            else
              # if utf8 mode is switched off or unicode not supported, try to
              # transform unicode \u-notation to bytes directly:
              $~[1].to_i(16).chr
            end
          end
        end
      else
        UNPARSED
      end
    end

    def parse_value
      case
      when scan(FLOAT)
        Float(self[0].sub(/\.([eE])/, '.0\1'))
      when scan(INTEGER)
        Integer(self[0])
      when scan(TRUE)
        true
      when scan(FALSE)
        false
      when scan(NULL)
        nil
      when (string = parse_string) != UNPARSED
        string
      when scan(ARRAY_OPEN)
        parse_array
      when scan(OBJECT_OPEN)
        parse_object
      else
        UNPARSED
      end
    end

    def parse_array
      result = []
      until eos?
        case
        when (value = parse_value) != UNPARSED
          result << value
          skip(IGNORE)
          unless scan(COLLECTION_DELIMITER) or match?(ARRAY_CLOSE)
            raise ParserError, "expected ',' or ']' in array at '#{peek(20)}'!"
          end
        when scan(ARRAY_CLOSE)
          break
        when skip(IGNORE)
          ;
        else
          raise ParserError, "unexpected token in array at '#{peek(20)}'!"
        end
      end
      result
    end

    def parse_object
      result = {}
      until eos?
        case
        when (string = parse_string) != UNPARSED
          skip(IGNORE)
          unless scan(PAIR_DELIMITER)
            raise ParserError, "expected ':' in object at '#{peek(20)}'!"
          end
          skip(IGNORE)
          unless (value = parse_value).equal? UNPARSED
            result[string] = value
            skip(IGNORE)
            unless scan(COLLECTION_DELIMITER) or match?(OBJECT_CLOSE)
              raise ParserError,
                "expected ',' or '}' in object at '#{peek(20)}'!"
            end
          else
            raise ParserError, "expected value in object at '#{peek(20)}'!"
          end
        when scan(OBJECT_CLOSE)
          if klassname = result['json_class']
            klass = klassname.sub(/^:+/, '').split(/::/).inject(Object) do |p,k|
              p.const_get(k) rescue nil
            end
            break unless klass and klass.json_creatable?
            result = klass.json_create(result)
          end
          break
        when skip(IGNORE)
          ;
        else
          raise ParserError, "unexpected token in object at '#{peek(20)}'!"
        end
      end
      result
    end
  end

  # This class is used to create State instances, that are use to hold data
  # while unparsing a Ruby data structure into a JSON string.
  class State
    # Creates a State object from _opts_, which ought to be Hash to create a
    # new State instance configured by opts, something else to create an
    # unconfigured instance. If _opts_ is a State object, it is just returned.
    def self.from_state(opts)
      case opts
      when self
        opts
      when Hash
        new(opts)
      else
        new
      end
    end

    # Instantiates a new State object, configured by _opts_.
    def initialize(opts = {})
      @indent     = opts[:indent]     || ''
      @space      = opts[:space]      || ''
      @object_nl  = opts[:object_nl]  || ''
      @array_nl   = opts[:array_nl]   || ''
      @seen       = {}
    end

    # This string is used to indent levels in the JSON string.
    attr_accessor :indent

    # This string is used to include a space between the tokens in a JSON
    # string.
    attr_accessor :space

    # This string is put at the end of a line that holds a JSON object (or
    # Hash).
    attr_accessor :object_nl

    # This string is put at the end of a line that holds a JSON array.
    attr_accessor :array_nl

    # Returns _true_, if _object_ was already seen during this Unparsing run. 
    def seen?(object)
      @seen.key?(object.__id__)
    end

    # Remember _object_, to find out if it was already encountered (to find out
    # if a cyclic data structure is unparsed). 
    def remember(object)
      @seen[object.__id__] = true
    end

    # Forget _object_ for this Unparsing run.
    def forget(object)
      @seen.delete object.__id__
    end
  end

  module_function

  # Convert _string_ from UTF8 encoding to UTF16 (big endian) encoding and
  # return it.
  def utf8_to_utf16(string)
    JSON::UTF8toUTF16.iconv(string).unpack('H*')[0]
  end

  # Convert _string_ from UTF16 (big endian) encoding to UTF8 encoding and
  # return it.
  def utf16_to_utf8(string)
    bytes = '' << string[0, 2].to_i(16) << string[2, 2].to_i(16)
    JSON::UTF16toUTF8.iconv(bytes)
  end

  # Convert a UTF8 encoded Ruby string _string_ to a JSON string, encoded with
  # UTF16 big endian characters as \u????, and return it.
  def utf8_to_json(string)
    i, n, result = 0, string.size, ''
    while i < n
      char = string[i]
      case
      when char == ?\b then result << '\b'
      when char == ?\t then result << '\t'
      when char == ?\n then result << '\n'
      when char == ?\f then result << '\f'
      when char == ?\r then result << '\r'
      when char == ?"  then result << '\"'
      when char == ?\\ then result << '\\\\'
      when char == ?/ then result << '\/'
      when char.between?(0x0, 0x1f) then result << "\\u%04x" % char
      when char.between?(0x20, 0x7f) then result << char
      when !(JSON.support_unicode? && $KCODE == 'UTF8')
        # if utf8 mode is switched off or unicode not supported, just pass
        # bytes through:
        result << char
      when char & 0xe0 == 0xc0
        result << '\u' << utf8_to_utf16(string[i, 2])
        i += 1
      when char & 0xf0 == 0xe0
        result << '\u' << utf8_to_utf16(string[i, 3])
        i += 2
      when char & 0xf8 == 0xf0
        result << '\u' << utf8_to_utf16(string[i, 4])
        i += 3
      when char & 0xfc == 0xf8
        result << '\u' << utf8_to_utf16(string[i, 5])
        i += 4
      when char & 0xfe == 0xfc
        result << '\u' << utf8_to_utf16(string[i, 6])
        i += 5
      else
        raise JSON::UnparserError, "Encountered unknown UTF-8 byte: %x!" % char
      end
      i += 1
    end
    result
  end

  # Parse the JSON string _source_ into a Ruby data structure and return it.
  def parse(source)
    Parser.new(source).parse
  end

  # Unparse the Ruby data structure _obj_ into a single line JSON string and
  # return it. _state_ is a JSON::State object, that can be used to configure
  # the output further.
  def unparse(obj, state = nil)
    obj.to_json(JSON::State.from_state(state))
  end

  alias generate unparse

  # Unparse the Ruby data structure _obj_ into a JSON string and return it.
  # The returned string is a prettier form of the string returned by #unparse.
  def pretty_unparse(obj)
    state = JSON::State.new(
      :indent     => '  ',
      :space      => ' ',
      :object_nl  => "\n",
      :array_nl   => "\n"
    )
    obj.to_json(state)
  end

  alias pretty_generate pretty_unparse
end

class Object
  # Converts this object to a string (calling #to_s), converts
  # it to a JSON string, and returns the result. This is a fallback, if no
  # special method #to_json was defined for some object.
  # _state_ is a JSON::State object, that can also be used
  # to configure the produced JSON string output further.

  def to_json(*) to_s.to_json end
end

class Hash
  # Returns a JSON string containing a JSON object, that is unparsed from
  # this Hash instance.
  # _state_ is a JSON::State object, that can also be used to configure the
  # produced JSON string output further.
  # _depth_ is used to find out nesting depth, to indent accordingly.
  def to_json(state = nil, depth = 0)
    state = JSON::State.from_state(state)
    json_check_circular(state) { json_transform(state, depth) }
  end

  private

  def json_check_circular(state)
    if state
      state.seen?(self) and raise JSON::CircularDatastructure,
          "circular data structures not supported!"
      state.remember self
    end
    yield
  ensure
    state and state.forget self
  end

  def json_shift(state, depth)
    state and not state.object_nl.empty? or return ''
    state.indent * depth
  end

  def json_transform(state, depth)
    delim = ','
    delim << state.object_nl if state
    result = '{'
    result << state.object_nl if state
    result << map { |key,value|
      json_shift(state, depth + 1) <<
        key.to_s.to_json(state, depth + 1) <<
        ':' << state.space << value.to_json(state, depth + 1)
    }.join(delim)
    result << state.object_nl if state
    result << json_shift(state, depth)
    result << '}'
    result
  end
end

class Array
  # Returns a JSON string containing a JSON array, that is unparsed from
  # this Array instance.
  # _state_ is a JSON::State object, that can also be used to configure the
  # produced JSON string output further.
  # _depth_ is used to find out nesting depth, to indent accordingly.
  def to_json(state = nil, depth = 0)
    state = JSON::State.from_state(state)
    json_check_circular(state) { json_transform(state, depth) }
  end

  private

  def json_check_circular(state)
    if state
      state.seen?(self) and raise JSON::CircularDatastructure,
        "circular data structures not supported!"
      state.remember self
    end
    yield
  ensure
    state and state.forget self
  end

  def json_shift(state, depth)
    state and not state.array_nl.empty? or return ''
    state.indent * depth
  end

  def json_transform(state, depth)
    delim = ','
    delim << state.array_nl if state
    result = '['
    result << state.array_nl if state
    result << map { |value|
      json_shift(state, depth + 1) << value.to_json(state, depth + 1)
    }.join(delim)
    result << state.array_nl if state
    result << json_shift(state, depth) 
    result << ']'
    result
  end
end

class Integer
  # Returns a JSON string representation for this Integer number.
  def to_json(*) to_s end
end

class Float
  # Returns a JSON string representation for this Float number.
  def to_json(*) to_s end
end

class String
  # This string should be encoded with UTF-8 (if JSON unicode support is
  # enabled). A call to this method returns a JSON string
  # encoded with UTF16 big endian characters as \u????. If
  # JSON.support_unicode? is false only control characters are encoded this
  # way, all 8-bit bytes are just passed through.
  def to_json(*)
    '"' << JSON::utf8_to_json(self) << '"'
  end

  # Raw Strings are JSON Objects (the raw bytes are stored in an array for the
  # key "raw"). The Ruby String can be created by this class method.
  def self.json_create(o)
    o['raw'].pack('C*')
  end

  # This method creates a raw object, that can be nested into other data
  # structures and will be unparsed as a raw string.
  def to_json_raw_object
    {
      'json_class'  => self.class.name,
      'raw'         => self.unpack('C*'),
    }
  end

  # This method should be used, if you want to convert raw strings to JSON
  # instead of UTF-8 strings, e. g. binary data (and JSON Unicode support is
  # enabled).
  def to_json_raw(*args)
    to_json_raw_object.to_json(*args)
  end
end

class TrueClass
  # Returns a JSON string for true: 'true'.
  def to_json(*) to_s end
end

class FalseClass
  # Returns a JSON string for false: 'false'.
  def to_json(*) to_s end
end

class NilClass
  # Returns a JSON string for nil: 'null'.
  def to_json(*) 'null' end
end

module Kernel
  # Outputs _objs_ to STDOUT as JSON strings in the shortest form, that is in
  # one line.
  def j(*objs)
    objs.each do |obj|
      puts JSON::generate(obj)
    end
    nil
  end

  # Ouputs _objs_ to STDOUT as JSON strings in a pretty format, with
  # indentation and over many lines.
  def jj(*objs)
    objs.each do |obj|
      puts JSON::pretty_generate(obj)
    end
    nil
  end
end

class Class
  # Returns true, if this class can be used to create an instance
  # from a serialised JSON string. The class has to implement a class
  # method _json_create_ that expects a hash as first parameter, which includes
  # the required data.
  def json_creatable?
    respond_to?(:json_create)
  end
end
  # vim: set et sw=2 ts=2:
