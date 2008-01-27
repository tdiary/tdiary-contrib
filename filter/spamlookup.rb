#
# spamlookup.rb: included TDiary::Filter::SpamlookupFilter class
#

require 'resolv'

module TDiary
  module Filter
    class SpamlookupFilter < Filter
      def black_domain?( domain )
        begin
          Resolv.getaddress( "#{domain}.rbl.bulkfeeds.jp" )
          return true
        rescue
        end
        false
      end

      def black_url?( body )
        body.scan( %r|http://([^/]+)/| ) do |s|
          return true if black_domain?( s[0] )
        end
        false
      end

      def comment_filter( diary, comment )
        !black_url?( comment.body )
      end

      def referer_filter( referer )
        !black_url?( referer )
      end
    end
  end
end
