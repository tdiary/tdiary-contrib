#
# iplookup.rb: included TDiary::Filter::IplookupFilter class
#
#
# Copyright (c) 2008 SHIBATA Hiroshi <shibata.hiroshi@gmail.com>
# Distributed under the GPL2
#

require 'resolv'

module TDiary
   module Filter
      class IplookupFilter < Filter
         def iplookup_init
            if @conf.options.include?('iplookup.ip.list')
               @iplookup_ip_list = @conf.options['iplookup.ip.list']
            else
               @iplookup_ip_list = "bsb.spamlookup.net\nopm.blitzed.org\n" +
                                   "niku.2ch.net\ndnsbl.spam-champuru.livedoor.com"
            end
         end

         def black_ip?( address )
            chance = 2
            ip = address.gsub(/^(\d+)\.(\d+)\.(\d+)\.(\d+)$/, '\4.\3.\2.\1')
            @iplookup_ip_list.split(/\n+/).each do |dnsbl|
               begin
                  address = Resolv.getaddress( "#{ip}.#{dnsbl}" )
                  return true
                  rescue Resolv::ResolvTimeout
                     if chance > 0
                        chance -= 1
                        retry
                     end
                  rescue Resolv::ResolvError
                  rescue Exception
               end
            end
            return false
         end

         def comment_filter( diary, comment )
            iplookup_init
            return false if black_ip?( @cgi.remote_addr )
            return true
         end

         def referer_filter( referer )
            iplookup_init
            return false if black_ip?( @cgi.remote_addr )
            return true
         end
      end
   end
end
