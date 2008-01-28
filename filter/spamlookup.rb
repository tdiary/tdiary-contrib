#
# spamlookup.rb: included TDiary::Filter::SpamlookupFilter class
#

require 'resolv'
require 'uri'

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
        URI.extract( body, %w[http] ) do |url|
          domain = URI.parse( url ).host.sub( /\.$/, '' )
          return true if black_domain?( domain )
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
