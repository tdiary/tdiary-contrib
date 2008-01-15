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
      def referer_filter( referer )
        a,b,c,d = @cgi.remote_addr.split(/\./)
        @conf['rblcheck.list'].each {|rbl|
          addr = "#{d}.#{c}.#{b}.#{a}.#{rbl}"
          begin
            host = Socket.getaddrinfo(addr,"http")[0][3]
            case host
            when "127.0.0.2"
              return false
            end
          rescue SocketError
          end
        }
        true
      end
      
      def comment_filter( diary, comment )
        a,b,c,d = @cgi.remote_addr.split(/\./)
        @conf['rblcheck.list'].each {|rbl|
          addr = "#{d}.#{c}.#{b}.#{a}.#{rbl}"
          begin
            host = Socket.getaddrinfo(addr,"http")[0][3]
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
