# rblcheck.rb
# Copyright (c) 2004 MoonWolf <moonwolf@moonwolf.com>
# Distributed under the GPL
#
# options:
#   @options['rblcheck.list'] = [
#     'bl.moonwollf.com', # RBL list
#   ]
require 'socket'

module TDiary
  module Filter
    class RblcheckFilter < Filter
      alias :_filter :referer_filter
      alias :_filter :comment_filter

      private

      def _filter( *args )
        rev_addr = @cgi.remote_addr.split(".").reverse.join(".")
        @conf['rblcheck.list'].each {|rbl|
          addr = "#{rev_addr}.#{rbl}"
          begin
            host = Socket.getaddrinfo(addr, "http")[0][3]
            case host
            when "127.0.0.2"
              return false
            end
          rescue SocketError
          end
        }
        true
      end
    end
  end
end
