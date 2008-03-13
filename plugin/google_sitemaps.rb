# google_sitemap.rb
# Copyright (c) 2006 http://d.bulkitem.com/
# Distributed under the GPL

add_update_proc do
  require 'time'

  headers = Array.new
  header = Hash.new
  
  Dir.glob(@conf.data_path + '/????/*.td2') { |data_file|
    File.open(data_file) { |buffer|
      buffer.each { |line|
        line.strip!
        if line == "." then
          if  header['visible'] then
            headers.push(header.clone)
          end
          header.clear
        end
        if %r|^Date: ([0-9]+)$| =~ line then
          header['loc'] = sprintf(@conf['google_sitemaps.uri_format'], $1)
        end
        if %r|^Last\-Modified: ([0-9]+)$| =~ line then
          header['lastmod'] = Time.at($1.to_i).iso8601
        end
        if %r|^Visible: (.+)$| =~ line then
          if $1.upcase == "TRUE" then
            header['visible'] = true
          else
            header['visible'] = false
          end
        end
      }
    }
  }
  
  headers.sort! { |a, b| b['loc'] <=> a['loc']}

  top_page_uri = File::dirname(@conf['google_sitemaps.uri_format']) + '/'
  now_datetime = Time.now.iso8601

  File.open(@conf['google_sitemaps.output_file'], 'w') do |fp|
	  fp.write %Q[<?xml version="1.0" encoding="UTF-8"?>\n]
	  fp.write %Q[<urlset xmlns="http://www.google.com/schemas/sitemap/0.84">\n]
    fp.write %Q[<url><loc>#{CGI::escapeHTML(top_page_uri)}</loc><lastmod>#{now_datetime}</lastmod></url>\n]
	  headers.each { |entry|
	    fp.write %Q[<url><loc>#{CGI::escapeHTML(entry['loc'])}</loc><lastmod>#{entry['lastmod']}</lastmod></url>\n]
	  }
	  fp.write %Q[</urlset>\n]
  end
end

def saveconf_google_sitemaps
  if @mode == 'saveconf' then
    @conf['google_sitemaps.uri_format'] = @cgi.params['google_sitemaps.uri_format'][0]
    @conf['google_sitemaps.output_file'] = @cgi.params['google_sitemaps.output_file'][0]
  end
end

