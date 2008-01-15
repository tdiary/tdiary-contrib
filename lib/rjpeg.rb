#
# rjpeg.rb
#  -- jpeg handling library
#
#  NISHI Takao <zophos@koka-in.org>
#  $Id: rjpeg.rb,v 1.4 2005/07/25 12:48:13 tadatadashi Exp $
#
class Jpeg
    class ParseError<StandardError
    end
    
    #
    # Jpeg Maker Handling Class
    #
    class Segment
	DELIM ="\xff"
	IMG   ="\x00" # Not a Segment

	TEM   ="\x01" # Temporary Marker
	SOF0  ="\xc0" # Baseline DCT (Huffman)
	SOF1  ="\xc1" # Extended sequential DCT (Huffman)
	SOF2  ="\xc2" # Progressive DCT (Huffman)
	SOF3  ="\xc3" # Spatial DCT (Huffman)
	DHT   ="\xc4" # Definition Huffman Table
	SOF5  ="\xc5" # Differential sequential DCT (Huffman)
	SOF6  ="\xc6" # Differential progressive DCT (Huffman)
	SOF7  ="\xc7" # Differential spatial (Huffman)
	JPG   ="\xc8" # Reserved
	SOF9  ="\xc9" # Extended sequential DCT (arithmetic)
	SOF10 ="\xca" # Progressive DCT (arithmetic)
	SOF11 ="\xcb" # Spatial lossless DCT (arithmetic)
	DAC   ="\xcc" # Definition Arithmetic Compress
	SOF12 ="\xcd" # Differential sequential DCT (arithmetic)
	SOF13 ="\xce" # DIfferential progressive DCT (arithmetic)
	SOF14 ="\xcf" # Differential spatial (arithmetic)
	RST0  ="\xd0" # Restart Marker 0
	RST1  ="\xd1" # Restart Marker 1
	RST2  ="\xd2" # Restart Marker 2
	RST3  ="\xd3" # Restart Marker 3
	RST4  ="\xd4" # Restart Marker 4
	RST5  ="\xd5" # Restart Marker 5
	RST6  ="\xd6" # Restart Marker 6
	RST7  ="\xd7" # Restart Marker 7
	SOI   ="\xd8" # Start Of Image
	EOI   ="\xd9" # End Of Image
	SOS   ="\xda" # Start Of Scan
	DQT   ="\xdb" # Definition Quontom Table
	DNL   ="\xdc" # Definition Number of Line
	DRI   ="\xdd" # Definition Restart Interval
	DHP   ="\xde" # Definition Haffman P?
	EXP   ="\xdf" # Expand segmant
	APP0  ="\xe0" # Application Marker Segmant 0
	APP1  ="\xe1" # Application Marker Segmant 1
	APP2  ="\xe2" # Application Marker Segmant 2
	APP3  ="\xe3" # Application Marker Segmant 3
	APP4  ="\xe4" # Application Marker Segmant 4
	APP5  ="\xe5" # Application Marker Segmant 5
	APP6  ="\xe6" # Application Marker Segmant 6
	APP7  ="\xe7" # Application Marker Segmant 7
	APP8  ="\xe8" # Application Marker Segmant 8
	APP9  ="\xe9" # Application Marker Segmant 9
	APP10 ="\xea" # Application Marker Segmant 10
	APP11 ="\xeb" # Application Marker Segmant 11
	APP12 ="\xec" # Application Marker Segmant 12
	APP13 ="\xed" # Application Marker Segmant 13
	APP14 ="\xee" # Application Marker Segmant 14
	APP15 ="\xef" # Application Marker Segmant 15
	JPG0  ="\xf0" # Reserved
	JPG1  ="\xf1" # Reserved
	JPG2  ="\xf2" # Reserved
	JPG3  ="\xf3" # Reserved
	JPG4  ="\xf4" # Reserved
	JPG5  ="\xf5" # Reserved
	JPG6  ="\xf6" # Reserved
	JPG7  ="\xf7" # Reserved
	JPG8  ="\xf8" # Reserved
	JPG9  ="\xf9" # Reserved
	JPG10 ="\xfa" # Reserved
	JPG11 ="\xfb" # Reserved
	JPG12 ="\xfc" # Reserved
	JPG13 ="\xfd" # Reserved
	COM   ="\xfe" # Comment

	MARKER_NAME={
	    "\x00"=>"IMG",
	    "\x01"=>"TEM",
	    "\xc0"=>"SOF0",
	    "\xc1"=>"SOF1",
	    "\xc2"=>"SOF2",
	    "\xc3"=>"SOF3",
	    "\xc4"=>"DHT",
	    "\xc5"=>"SOF5",
	    "\xc6"=>"SOF6",
	    "\xc7"=>"SOF7",
	    "\xc8"=>"JPG",
	    "\xc9"=>"SOF9",
	    "\xca"=>"SOF10",
	    "\xcb"=>"SOF11",
	    "\xcc"=>"DAC",
	    "\xcd"=>"SOF12",
	    "\xce"=>"SOF13",
	    "\xcf"=>"SOF14",
	    "\xd0"=>"RST0",
	    "\xd1"=>"RST1",
	    "\xd2"=>"RST2",
	    "\xd3"=>"RST3",
	    "\xd4"=>"RST4",
	    "\xd5"=>"RST5",
	    "\xd6"=>"RST6",
	    "\xd7"=>"RST7",
	    "\xd8"=>"SOI",
	    "\xd9"=>"EOI",
	    "\xda"=>"SOS",
	    "\xdb"=>"DQT",
	    "\xdc"=>"DNL",
	    "\xdd"=>"DRI",
	    "\xde"=>"DHP",
	    "\xdf"=>"EXP",
	    "\xe0"=>"APP0",
	    "\xe1"=>"APP1",
	    "\xe2"=>"APP2",
	    "\xe3"=>"APP3",
	    "\xe4"=>"APP4",
	    "\xe5"=>"APP5",
	    "\xe6"=>"APP6",
	    "\xe7"=>"APP7",
	    "\xe8"=>"APP8",
	    "\xe9"=>"APP9",
	    "\xea"=>"APP10",
	    "\xeb"=>"APP11",
	    "\xec"=>"APP12",
	    "\xed"=>"APP13",
	    "\xee"=>"APP14",
	    "\xef"=>"APP15",
	    "\xf0"=>"JPG0",
	    "\xf1"=>"JPG1",
	    "\xf2"=>"JPG2",
	    "\xf3"=>"JPG3",
	    "\xf4"=>"JPG4",
	    "\xf5"=>"JPG5",
	    "\xf6"=>"JPG6",
	    "\xf7"=>"JPG7",
	    "\xf8"=>"JPG8",
	    "\xf9"=>"JPG9",
	    "\xfa"=>"JPG10",
	    "\xfb"=>"JPG11",
	    "\xfc"=>"JPG12",
	    "\xfd"=>"JPG13",
	    "\xfe"=>"COM"
	}
	MARKER_NAME.freeze

	#
	# Format I Segments group
	# These segments have NO data.
	#
	FORMAT_I=[SOI,EOI,RST0,RST1,RST2,RST3,RST4,RST5,RST6,RST7]
	FORMAT_I.freeze

	#
	# Jpeg::Segment constructor
	#
	def initialize(marker,data=nil,read_size=nil,&block)
	    @marker=marker            # 1byte
	    #size                     # 2 bytes
	    @byte_data=nil            # 
	    
	    begin
		unless(data.nil?)
		    parse(data,read_size,&block)
		end
	    rescue ParseError
	    end
	end

	attr_reader :marker,:byte_data

	def =~(x)
	    self.marker_name=~x
	end

	def ===(x)
	    (self.marker_name===x)||(@marker===x)
	end

	def size
	    if(@byte_data.nil?)
		0
	    else
		if(@marker==IMG)
		    @byte_data.size
		else
		    @byte_data.size+2 # data_size
		end
	    end
	end

	def data=(x)
	    if(FORMAT_I.member?(@marker))
		raise TypeError,
		    "#{MARKER_NAME[@marker]} must not have no data"
	    else
		parse(x)
	    end
	end

	def dump
	    if(@marker==IMG)
		self.byte_data.to_s
	    else
		if(@byte_data.nil?)
		    DELIM+@marker
		else
		    DELIM+@marker+[self.size].pack('n')+self.byte_data.to_s
		end
	    end
	end

	def marker_name
	    MARKER_NAME[@marker]
	end

	def parse(data,read_size=nil,&block)
	    if(@marker==IMG)
		@byte_data=data
	    else
		unless(data.respond_to?('read'))
		    data=StringIO.new(data.to_s)
		end
		if(read_size.nil?)
		    @byte_data=data.read
		else
		    @byte_data=data.read(read_size)
		end
	    end
	end
    end
    
    class StringIO<String
	def initialize(x)
	    @cur=0
	    super
	end
	def read(x=nil)
	    sp=@cur
	    if(x.nil?)
		@cur=self.size
	    else
		@cur+=x
	    end
	    String.new(self[sp..@cur-1])
	end
	def rewind
	    @cur=0
	end
	def seek(x,whence=IO::SEEK_SET)
	    case whence
	    when IO::SEEK_SET
		@cur=x
	    when IO::SEEK_CUR
	    @cur+=x
	    when IO::SEEK_END
		@cur=self.size+x
	    end
	end
    end

    #
    # Jpeg Handling Class
    #
    include Enumerable

    PARSE_HEADER_ONLY=true
    PARSE_FULL_IMAGE=false

    @@segment_class=Hash.new(Segment)
    def initialize(file=nil,parse_header_only=PARSE_FULL_IMAGE,&block)
	@segment_class=@@segment_class.dup

	@segments=[Segment.new(Segment::SOI),Segment.new(Segment::EOI)]

	unless(file.nil?)
	    self.parse(file,parse_header_only,&block)
	end
    end

    def Jpeg.load(file,parse_header_only=false,&block)
	File.open(file){|f|
	    Jpeg.new(f,parse_header_only,&block)
	}
    end
    def Jpeg.open(file,parse_header_only=false,&block)
	File.open(file){|f|
	    Jpeg.new(f,parse_header_only,&block)
	}
    end
    
    def parse(f,header_only=PARSE_FULL_IMAGE,&block)
	unless(f.kind_of?(IO))
	    f=StringIO.new(f)
	end
	
	@segments.clear
	
	#
	# SOI check
	#
	f.rewind
	x=f.read(2)
	unless(x==Segment::DELIM+Segment::SOI)
	    raise ParseError,
		'Not Jpeg File (SOI Not found)'
	end

	unless(block.nil?)
	    yield Segment.new(Segment::SOI)
	end
	@segments.push(Segment.new(Segment::SOI))

	begin
	    segment=read_segment(f,&block)
	    marker=segment.marker
	    unless(block.nil?)
		segment=yield(segment)
		unless(segment.kind_of?(Segment))
		    segment=Segment.new(Segment::IMG,segment)
		end
	    end
	    @segments.push(segment)
	end until(marker==Segment::SOS)
	
	if(header_only)
	    unless(block.nil?)
		yield(Segment.new(Segment::IMG))
		yield(Segment.new(Segment::EOI))
	    end
	    @segments.push(Segment.new(Segment::IMG))
	    @segments.push(Segment.new(Segment::EOI))

	    _set_segment_method
	    return self
	end
	
	i=f.read
	#
	# EOI check
	#
	eoi=i.index(Segment::DELIM+Segment::EOI)
	if(eoi.nil?)
	    raise ParseError,
		'Broken Jpeg File (EOI Not found)'
	end

	segment=Segment.new(Segment::IMG,i[0..eoi-1])
	unless(block.nil?)
	    segment=yield(segment)
	    unless(segment.kind_of?(Segment))
		segment=Segment.new(Segment::IMG,segment)
	    end
	end
	@segments.push(segment)
	@segments.push(Segment.new(Segment::EOI))


	segment=i[eoi+2..-1]
	if(segment.empty?)
	    segment=nil
	else
	    segment=Segment.new(Segment::IMG,segment)
	end
	unless(segment.nil?)
	    unless(block.nil?)
		segment=yield(segment)
		unless(segment.kind_of?(Segment))
		    image=Segment.new(Segment::IMG,segment)
		end
	    end
	    @segments.push(segment)
	end

	_set_segment_method
	return self
    end

    def imagestream
	begin
	    i=@segments.index(self.sos)
	    @segments[i+1]
	rescue NameError
	    nil
	end
    end

    def garbage
	begin
	    i=@segments.index(self.eoi)
	    @segments[i+1]
	rescue NameError
	    nil
	end
    end

    def dump
	buf=''
	@segments.compact.each{|s|
	    begin
		buf+=s.dump
	    rescue NameError
		buf+=s.to_s
	    end
	}
	buf
    end

    undef max,min,sort

    def each(&block)
	@segments.each(&block)
    end

    alias segments to_a

    def index(seg)
	if(seg.kind_of?(String))
	    @segments.each_index{|i|
		if(@segments[i]===seg)
		    return i
		end
	    }
	    nil
	else
	    super
	end
    end

    def has_segment?(seg)
	!self.index(seg).nil?
    end
    alias include? has_segment?
    alias member? has_segment?

    def [](*args)
	if(args[0].kind_of?(Regexp))
	    @segments.find_all{|seg|
		seg=~args[0]
	    }
	elsif(args[0].kind_of?(String))
	    @segments.find{|seg|
		seg===args[0]
	    }
	else
	    if(args[0].kind_of?(Range))
		if(args[0].first.kind_of?(String))
		    f=self.index(args[0].first)
		    l=self.index(args[0].last)
		    if(f.nil?||l.nil?)
			return []
		    end
		    args[0]=Range.new(f,l)
		end
	    end
	    @segments[*args]
	end
    end

    def []=(*args)
	value=args.pop
	unless(value.kind_of?(Segment))
	    value=Segment.new(Segment::IMG,value)
	end
	if(args[0].kind_of?(String))
	    args[0]=@segments.index(self[args[0]])
	elsif(args[0].kind_of?(Segment))
	    args[0]=@segments.index(args[0])
	elsif(args[0].kind_of?(Range))
	    if(args[0].first.kind_of?(String))
		f=self.index(args[0].first)
		l=self.index(args[0].last)
		begin
		    args[0]=Range.new(f,l)
		rescue ArgumentError
		    raise $!.to_s
		    return nil
		end
	    end
	end

	ret=@segments[*args]=value

	_set_segment_method
	ret
    end

    def insert_at(pos,x)
	self[pos,0]=x
    end

    def insert_after_soi(x)
	self[self.index(Segment::SOI)+1,0]=x
    end
    
    def insert_befor_sos(x)
	self[self.index(Segment::SOS),0]=x
    end
    alias insert insert_befor_sos

    def insert_after_eoi(x)
	self[self.index(Segment::EOI)+1,0]=x
    end
    alias garbage= insert_after_eoi

    def delete(seg,&block)
	ret=nil
	if(seg.kind_of?(Regexp))
	    @segments.delete_if{|s|
		if(s=~seg)
		    ret=seg
		    true
		else
		    false
		end
	    }
	elsif(seg.kind_of?(String))
	    @segments.delete_if{|s|
		if(s===seg)
		    ret=seg
		else
		    false
		end
	    }
	else
	    ret=@segments.delete(seg)
	end

	if(ret.nil?)
	    @segments.each(&block)
	else
	    _set_segment_method
	    ret
	end
    end

    def delete_at(pos)
	ret=@segments.delete_at(pos)
	unless(ret.nil?)
	    _set_segment_method
	end
	ret
    end

    def delete_if(&block)
	ret=@segments.delete_if(&block)
	_set_segment_method
	ret
    end

    def compact
	@segments.delete_if{|s|
	    s.nil?||((s.marker==Segment::IMG)&&s.byte_data.nil?)
	}
	@segments.dup
    end

    def delete_garbage
	ret=nil
	pos=self.index(Segment::EOI)
	unless(pos.nil?)
	    ret=@segments[pos+1..-1]
	    @segments=@segments[0..pos]
	end
	ret
    end
    alias trim_garbage delete_garbage

    def use_class_for(segment,data_class,force_replace=false)
	if((data_class.class==Class)&&
	   (data_class.ancestors.include?(Segment)))
	    @segment_class[segment]=data_class

	    #
	    # re-parse
	    #
	    if(force_replace)
		i=@segments.each_index{|i|
		    if(s.marker==segment)
			return i
		    end
		}
		@segments[i]=data_class.new(@segments[i].marker,
					    @segments[i].byte_data)
	    end
	else
	    raise TypeError,
		'Must be descendants of Jpeg::Segment Class'
	end
    end

    def Jpeg.use_class_for(segment,data_class)
	if((data_class.class==Class)&&
	   (data_class.ancestors.include?(Segment)))
	    @@segment_class[segment]=data_class
	else
	    raise TypeError, 
		'Must be descendants of Jpeg::Segment Class'
	end
    end

    private
    def read_ushort(f)
	f.read(2).unpack('n').first
    end
    def read_ulong(f)
	f.read(4).unpack('N').first
    end
    def read_segment(f,&block)
	m=f.read(2)
	unless(m[0..0]==Segment::DELIM)
	    raise "Irregular Segment"
	end
	m=m[1..1]
	s=read_ushort(f)-2
	@segment_class[m].new(m,f,s,&block)
    end

    def _set_segment_method
	# get self singular methods list
	singular_methods=self.methods-self.class.new.methods

	# create methods without SOI and EOI
	#
	@segments.each_index{|i|
	    begin
		unless(@segments[i+1].marker==Segment::IMG)
		    name=@segments[i+1].marker_name.downcase
		    self.instance_eval("def #{name};@segments[#{i+1}];end")
		    singular_methods.delete(name)
		end
	    rescue NameError
	    end
	}

	# delete not difined singular methods
	singular_methods.each{|m|
	    self.instance_eval("undef #{m}")
	}
    end
end

class Jpeg
    class SOFData<Segment
	def initialize(marker,io,size)
	    @width=0
	    @height=0
	    super
	end
	attr_reader :width,:height
	
	def parse(io,size)
	    super
	    (@height,@width)=@byte_data.unpack('xnn')
	end
    end
    
    Jpeg.use_class_for(Segment::SOF0,SOFData)
    Jpeg.use_class_for(Segment::SOF1,SOFData)
    Jpeg.use_class_for(Segment::SOF2,SOFData)
    Jpeg.use_class_for(Segment::SOF3,SOFData)
    Jpeg.use_class_for(Segment::SOF5,SOFData)
    Jpeg.use_class_for(Segment::SOF6,SOFData)
    Jpeg.use_class_for(Segment::SOF7,SOFData)
    Jpeg.use_class_for(Segment::SOF9,SOFData)
    Jpeg.use_class_for(Segment::SOF10,SOFData)
    Jpeg.use_class_for(Segment::SOF11,SOFData)
    Jpeg.use_class_for(Segment::SOF12,SOFData)
    Jpeg.use_class_for(Segment::SOF13,SOFData)
    Jpeg.use_class_for(Segment::SOF14,SOFData)
end
