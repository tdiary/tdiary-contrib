#!/usr/bin/env ruby
#
# posttdiary-ex: update tDiary via e-mail. $Revision: 1.2 $
#
# Copyright (C) 2002, All right reserved by TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#
# 2010.10.19: v.1.71: Modified by K.Sakurai (http://ks.nwr.jp)
#  Acknowledgements:
#   * Based on posttdiary.rb & tdiary.rb by TADA.
#   * Some codes partially imported from Enikki Plugin Ex. : 
#     http://shimoi.s26.xrea.com/hiki/hiki.cgi?TdiaryEnikkiEx
#   * Thanks to taketori for image size detection method.
#   * Thanks to NOB for debugging.
#   * Thanks to tamo (http://tamo.tdiary.net) for image-POSTing codes & testing.
#

# language setup for tdiary.conf (for both @data_path & @tdiary_dirname)
@tdencoding = 'UTF-8'
# @tdencoding = 'US-ASCII'
# @tdencoding = 'EUC-JP'
# @tdencoding = 'Big5'

#----------------------------------------------

def usage( detailed_help )
	# (if "!" is at the head of the line, it is to be shown only when detailed_help == true (-h option) )
	text = <<-TEXT
		#{File::basename __FILE__}: update tDiary via e-mail (v1.64).
		usage: ruby posttdiary-ex.rb [options (without -d)] <url> <user> <passwd>
		       ruby posttdiary-ex.rb [options (with -d)]
		arguments:
		  url:    update.rb's URL of your diary
		  user:   username for your tDiary system
		  passwd: password for your tDiary system
!		          If the To: field is  formatted as "user-passwd@example.com",
!		          you can omit user and passwd arguments.
		options:
!		  ============ for automatic configuration ==========
		  --read-conffile,   -a dirname: read settings from (dirname)/tdiary.conf
!		          Reads configuration parameters of image_ex plugin as well.
!		          (The default values of -i, -u, -t, -z, -o, -y, -C can be imported.)
!		          Specify the localtion (or fullpathname) of tDiary conf file.
!		          ex. -a /home/hoge/htdocs/diary/tdiary.conf
!
!		  ============ basic options ==============
		  --image-path,      -i dirname: directory to store the image(s) in.
		  --image-url,       -u URL: URL of the image directory.
!		          You must specify both -i and -u options
!		          (unless they are available from tdiary.conf + image_ex plugin)
!		          When using --remote-mode or --use-image-ex, -u is not required.
		  --use-subject,     -s: use mail subject as subtitle
!		          Also inserts attached image(s) between subtitle and body.
		  --make-thumbnail,  -t size: Create thumbnail with a link to the original image
!		          Works only when the original image is larger than the specified size
!		          (see --threshold-size also)
!		          ex. -t 80x80
		  --image-geometry,  -g size: resize image(s).
!		          The original image would be overwritten.
!		          Does not change the image size when the original image is smaller.
!		          ex. -g 800x800 (change the image size to "fit in" to 800x800 pixels)
		  --use-image-ex,    -e: Recognize & auto-generate tags for image.rb (Enikki)
		          or image_ex.rb (Enikki ex.) plugin
!		          Tag format: <%=image (serialno),"(alt text)"%>
!		          Serialno starts from 0. Will be automatically increased to match
!		          the real filename.
!		          Overrides -f option.
		  --wiki-style,      -w: output image tags in Wiki style
!		          Suppress adding a whitespace before each tag
!		          Adds "!" to subject when -s option is given
!		          Recognize Wiki style tags and rewrite
!		          Must be used with image.rb or image_ex.rb plugin.
		  --blog-style,      -B: do not specify date to append unless specified
!			  Suitable for use with blogkit
		  --read-exif,       -c: read "User Comment" tag from EXIF and use as ALT text
!		          If not specified, filename would be used as ALT text.
!		          Requires libexif and "exif" command.
		  --hour-offset,     -o offset: hour_offset of tDiary
!		          (ex. -o +4  (do not change date until 28:00))
		  --yearly-dir,      -y: put images in yearly separated directories
!		                         ( 2004/ , 2005/ , ...)
		  --help,            -h: show detailed help & advanced options
!
!		  ============ advanced options ==============
!		  --convert-path,    -C fullpath_of_convert: location of "convert" command
!		          Use this option when ImageMagick's commands are not path-reachable.
!		          Assumes the same location for "identify" command as well.
!		  --exif-path,       -E fullpath_of_exif: location of "exif" command
!		          Enables --read-exif command as well.
!		          Use this option when "exif" command is not path-reachable.
!		  --remote-mode,     -R: upload images via update.rb using HTTP POST.
!		          Allows user to separate the mailserver and the webserver.
!		          Note: Thumbnails would not be posted.
!		  --remote-image-path,-D remote_dirname:
!		          Specify the image directory of the remote webserver.
!		          Required when using image_ex.rb with --remote-mode option.
!		  --remote-yearly-dir,-Y switch:
!		          Specify whether to put images in yearly separated directories
!		          at the remote webserver.
!		          Required when image_ex.rb with --remote-mode option.
!		          0: do not separate,  1: separate
!		  --preserve-local-images,   -P:
!		          Do not delete local image files.
!		          Effective only when --remote-mode is enabled.
!		  --upload-only,     -U:
!		          Upload the attached images to server, but do not update the diary.
!		          Also possible by adding "_UPLONLY#" to mail body.
!		  --group-id,        -G: specify the group name (or GID) of the image file.
!		          Also makes the file group writable (chmod 664).
!		          ex1. -G www
!		          ex2. -G 67
!		  --class-name,      -n class_name:
!		          Class name for each photo (default: photo)
!		          Invalid when --use-image-ex or --wiki-style option is enabled.
!		  --add-div,         -v number_of_images:
!		          Encapsule all attached images with <div class="photos">...</div>
!		          When specified number of (or more) images are attached.
!		          Set to 2 when not given. Specify 0 to disable.
!		          Automatically set to 0 when --wiki-style is enabled.
!		          ex. -v 3 (works only when 3 or more images are attached)
!		  --threshold-size,  -z threshold_image_size:
!		          Make thumbnail if image size is larger.
!		          ex1. -z 120x140
!		          ex2. -z 140   (same to 140x140)
! 		  --image-format,    -f format string:
!		          Specify the format string of the image tag
!		          These variables can be used in the format string: 
!		              $0 : image serial number
!		              $1 : image url
!		              $2 : thumbnail image url (when -t is specified)
!		              $3 : class name
!		              $4 : ALT text (filename, or EXIF comment when -c is specified)
!			  ex. -f \\\"{{image \\\$0}}\\\"
!		  --use-original-name, -r:
!		          use original filename as ALT text when not specified
!		  --pass-filename,   -p:
!		          Pass real filename (instead of serialno) to image_ex plugin
!		          (EXPERIMENTAL: Has no meanings so far)
!		          Effective only with -e option.
!		  --filter-mode,    -d: print to stdout (does not call update.rb)
!		  --write-to-file,  -b filename: writeout to file (does not call update.rb)
!		  --date-margin,    -j date_margin: avoid writing diaries for future dates
!		          ex. -j 30 (default=7, 0=disabled)
!		  --rotate, -T LEFT or RIGHT: rotate images
!			  ex. -T RIGHT (rotate 90degrees clockwise)
!		          Also possible by adding "_ROT_LEFT#" or "_ROT_RIGHT#"to mail body.
!
!		Output format:
!		  without -e/f, without -t: <img src="$1" class="photo" alt="$4" title="$4">
!		  without -e/f, with -t: <A HREF="$1"><img src="$2" class="photo" alt="$4" title="$4"></a>
!		  with -e: <%=image $0,'$4'%>
!		  with -w: {{image $0,'$4'}}  (overrides -e)
!		  with -f: (specified format) (overrides -e, -w)
!
!		Date specification format in mail body text:
!		  ex. when you want to append this mail to "2005 Feb 15" 's diary,
!                     add this line to mail body:
!
!		_Date#2005-2-15
!
		Examples:
		  posttdiary-ex.rb -a /home/hoge/htdocs/diary/tdiary.conf http://yoursite.jp/~hoge/diary/update.rb (tDiary username) (passwd)
		  posttdiary-ex.rb -w -i /home/hoge/htdocs/diary-images/ -y -t 120x120 -s -g 800x800 http://yoursite.jp/~hoge/diary/update.rb (tDiary username) (passwd)
!		  posttdiary-ex.rb -i /home/hoge/htdocs/diary-images/ -u http://yoursite.jp/~hoge/diary-images/ -t 120x120 -s -g 800x800 http://yoursite.jp/~hoge/diary/update.rb (tDiary username) (passwd)
!		  posttdiary-ex.rb -R -i /home/hoge/tmp -D /home/hoge/htdocs/diary-images -Y 1 -s -g 800x800 http://yoursite.jp/~hoge/diary/update.rb (tDiary username) (passwd)

  TEXT
  if( detailed_help )
	text.gsub!( /\!/, '' )
  else
	text.gsub!( /\![^\r\n]*[\r\n]+/, '' )
  end
  text.delete("\t")
end

#--- override functions in the original tdiary.rb
def base_url
	return ''
end

def TDiaryError( msg )
	print msg + "\n"
	exit 0
end

def load_cgi_conf
	raise TDiaryError, 'posttdiary-ex: No @data_path variable.' unless @data_path
	@data_path = add_delimiter( @data_path )
	raise TDiaryError, 'posttdiary-ex: Do not set @data_path as same as tDiary system directory.' if @data_path == @tdiary_dirname
	def_vars1 = ''
	def_vars2 = ''
	variables = [:author_name, :author_mail, :index_page, :hour_offset]
	variables.each do |var|
		def_vars1 << "#{var} = nil\n"
		def_vars2 << "@#{var} = #{var} unless #{var} == nil\n"
	end

	begin
		cgi_conf = File::open( "#{@data_path}tdiary.conf" ){|f| f.read }
		cgi_conf.untaint unless @secure
		cgi_conf.force_encoding( @tdencoding )
		b = binding.taint
		eval( cgi_conf, b, "(cgi_conf)", 1 )
		eval( def_vars2, b )
		rescue IOError, Errno::ENOENT
	end
end

#--- read tdiary.conf
def read_tdiary_conf( dfname )
	if test( ?d , dfname ) then
		@tdiary_dirname = dfname
		@tdiary_conf_file = 'tdiary.conf'
	elsif test( ?f , dfname ) then
		dfname =~ /(.*)[\/\\]([^\/\\]+)/
		@tdiary_dirname = $1
		@tdiary_conf_file = $2
	end
	@tdiary_dirname = add_delimiter( @tdiary_dirname )
	orgdir = Dir.pwd
	Dir.chdir( @tdiary_dirname )

	@secure = false
	@options = {}
	# evaluate tdiary.conf  (load_cgi_conf() would be called as well, via tdiary.conf)

	f = File::open( @tdiary_dirname + @tdiary_conf_file ){|f| f.read }.untaint.force_encoding(@tdencoding)
	eval( f, binding, "(tdiary.conf)", 1 )

	Dir.chdir( orgdir )
	true;

	rescue IOError, Errno::ENOENT
	raise 'posttdiary-ex: failed to read tdiary configuration file'
end

def check_local_images( date, path )
	available_list = []
	exist_list = []
	maxnum = -1
	Dir.foreach( path ) do |file|
		if file =~ /(\d{8,})_(\d+)\.([^\.]*)/ then
			if $1 == date then
				serial = $2.to_i
				maxnum = serial if serial > maxnum
				exist_list[serial]=true
			end
		end
	end

	num = 0
	for i in 0 .. 200
		if !exist_list[i] then
			available_list[num] = i
			num += 1
		end
	end

	maxnum += 1
	[maxnum, available_list]
end

def bmp_to_png( bmp )
	png = bmp.sub( /\.bmp$/, '.png' )
	stat = system( "#{@convertpath} #{bmp} #{png}" )
	raise "posttdiary-ex: could not run convert command (#{@convertpath})" if !stat
	if FileTest::exist?( png )
		File::delete( bmp )
		png
	else
		bmp
	end
end

def check_command( cmdname )
	raise 'posttdiary-ex: program bug found in check_command() (call the programmer!)' unless cmdname

	if @pt_exist_cmd then
		for priv in @pt_exist_cmd
			if priv == cmdname then
				 return true
			end
		end
	end

	stat = false
	if ( test( ?x , cmdname ) ) then
		 stat = true
	else
		require 'shell'
		sh = Shell.new
		searchdir = sh.system_path
		for dir in searchdir
			fullpath = add_delimiter( dir ) + cmdname
			if sh.executable?(fullpath) then
				stat = true
				break
			end
		end
	end
	if stat then
		@pt_exist_cmd = [] unless @pt_exist_cmd
		@pt_exist_cmd << cmdname
	else
		raise "posttdiary-ex: execution failed: #{cmdname} not found"
	end
	stat
end

def check_image_size( name, geo )
	cmdstr = @magickpath + "identify"
	check_command( cmdstr )
	return false if !FileTest::exist?( name )
	begin
		imgsize = %x[#{cmdstr} '#{name}'].sub(/#{name}/, '').split[1][/\d+x\d+/]
		i = imgsize.split(/x/)
		j = geo.split(/x/)
		return false if !i[1] or !j[1]
		return false if i[0].to_i < j[0].to_i and i[1].to_i < j[1].to_i

		rescue
		return false
	end
	true
end

def change_image_size( org, geo )
	check_command( @convertpath )
	system( "#{@convertpath} -size #{geo}\\\> #{org} -geometry #{geo}\\\> #{org}" )
	if FileTest::exist?( org )
		org
	else
		""
	end
end

def read_exif_comment( fullpath_imgname )
	require 'nkf'
	v = ""
	check_command( @exifpath )
	return "" if !FileTest::exist?( fullpath_imgname )
	open( "| #{@exifpath} -t \"User Comment\" #{fullpath_imgname}", "r" ) do |f|
		s = f.readlines
		s.each do |t|
			t.gsub!( /.*Value:/, '' )
			v = NKF::nkf( '-m0 -Xwd', t ).gsub!( /^\s+/, '' ).chomp! if $&
		end
	end
	v = '' if v =~ /^\(null\)$/i
	v
end

def read_exif_orientation( fullpath_imgname )
	# returns orientaion value
	#  top-left : 1
	#  right-top : 6
	#  left-bottom : 8
	#  bottom-right : 3
	val = 1
	v = ''
	check_command( @exifpath )
	return 1 if !FileTest::exist?( fullpath_imgname )
	open( "| #{@exifpath} -t \"Orientation\" #{fullpath_imgname}", "r" ) do |f|
		s = f.readlines
		s.each do |t|
			t.gsub!( /.*Value:/, '' )
			if $& then
				v = t
				break
			end
		end
	end
	val = 6 if v =~ /right.+top/i
	val = 8 if v =~ /left.+bottom/i
	val = 3 if v =~ /bottom.+right/i
	val
end

def rotation_degree( ori )
	deg = 0
	deg = 90 if ori == 6
	deg = -90 if ori == 8
	deg = 180 if ori == 3
	deg
end

def rotate_image( org, deg )
	if FileTest::exist?( org ) then
		check_command( @convertpath )
		system( "#{@convertpath} -rotate #{deg} #{org} #{org}" )
	end
	if FileTest::exist?( org )
		org
	else
		""
	end
end

def make_thumbnail( idir, iname , newsize , gid )
	org_full = idir + iname
	tb_name = "s" + iname
	tb_full = idir + tb_name
	begin
		check_command( @convertpath )
		# only for imagemagick 6 and later!!
		system( "#{@convertpath} -thumbnail #{newsize}\\\> #{org_full} #{tb_full}" )
	end
	if FileTest::exist?( tb_full )
		if gid then
			require 'shell'
			sh = Shell.new
			sh.chown( nil , gid , tb_full )
			sh.chmod( 00664 , tb_full )
		end
		tb_name
	else
		iname
	end
end

def add_body_text( prev, sub_head , sub_body )
	addtext = prev
	if prev.size > 0 and !(prev =~ /\n$/) then 
		addtext += "\n"
	end
	if sub_head =~ %r[^Content-Transfer-Encoding:\s*base64]i then
		addtext += NKF::nkf( '-wXd -mB', sub_body )
	elsif
		addtext += sub_body
	end
	addtext
end

def add_delimiter( orgpath )
	if !orgpath or orgpath.size < 1 then
		newpath = ""
	else
		if !(orgpath =~ /[\/\\]$/) then
			if !(orgpath =~ /\//) and orgpath =~ /\\/ then
				newpath = orgpath + "\\"
			else
				newpath = orgpath + "/"
			end
		else
			newpath = orgpath.dup
		end
	end
	newpath
end

def make_image_body( imgdata , imgname , remotedir , now , image_boundary, protection_key )
	fname = ""
	extension = ""
	image_body = ""
        if imgname =~ /^(.*)(\.jpg|\.jpeg|\.gif|\.png)\z/i
	        extension = $2.downcase
		fname = $1 + extension
	else
		return nil
	end
	typestr = "image/jpeg" if extension =~ /jpe??g/i
	typestr = "image/bmp"  if extension =~ /bmp/i
	typestr = "image/gif"  if extension =~ /gif/i
	typestr = "image/png"  if extension =~ /png/i

	if remotedir and remotedir.length > 0 then
image_body.concat <<END
--#{image_boundary}\r
content-disposition: form-data; name="plugin_image_dir"\r
\r
#{add_delimiter(remotedir)}\r
END
	end
	if protection_key and protection_key.length > 0 then
image_body.concat <<END
--#{image_boundary}\r
content-disposition: form-data; name="csrf_protection_key"\r
\r
#{protection_key}\r
END
	end

image_body.concat <<END
--#{image_boundary}\r
content-disposition: form-data; name="plugin_image_add"\r
\r
true\r
--#{image_boundary}\r
content-disposition: form-data; name="plugin_image_addimage"\r
\r
true\r
--#{image_boundary}\r
content-disposition: form-data; name="date"\r
\r
#{now.strftime( "%Y%m%d" )}\r
END

image_body.concat <<END
--#{image_boundary}\r
content-disposition: form-data; name="plugin_image_file"; filename="#{fname}"\r
Content-Type: #{typestr}\r
\r
#{imgdata}\r
END

image_body.concat <<END
--#{image_boundary}\r
content-disposition: form-data; name="plugin"\r
\r
image\r
--#{image_boundary}--\r
END
	image_body
end

def check_remote_images( http, cgi, user, pass, now )
	available_list = []
	maxnum = -1

	str = cgi + '?edit=true;year=' + now.strftime( "%Y" ) + ';month=' + now.strftime( "%m").gsub(/^0/, "") + ';day=' + now.strftime( "%d").gsub(/^0/, "")
	req = Net::HTTP::Get.new( str )
	req.basic_auth user, pass
	response, = http.request(req)
	body = response.body
	date = now.strftime( "%Y%m%d" )
	imglist = []
	num = 0
	for i in 0 .. 200
		if body =~ /\<img [^\<\>]*src=\"[^\"]*(#{date}_#{i}\.[^\"]*)\"/ then
			maxnum = i
		else
			available_list[num] = i
			num += 1
		end
	end

	maxnum += 1
	[maxnum, available_list]
end

def post_image( http, cgi, user, pass, image_dir , imgname, remote_image_dir, now, protection_key, refurl )
	auth = ["#{user}:#{pass}"].pack( 'm' ).strip
	image_boundary = "PosttdiaryMainBoundary"
	image_data = ( File.open( image_dir + imgname ) { |f| f.read } )
	image_body = make_image_body(image_data, imgname, remote_image_dir, now , image_boundary, protection_key ) if image_data
	if image_body then
		image_header = {
		    'Authorization' => "Basic #{auth}",
		    'Content-Length' => image_body.length.to_s,
		    'Content-Type' => "multipart/form-data; boundary=#{image_boundary}",
		    'Referer' => refurl,
		}
		response, = http.post( cgi, image_body, image_header )
		raise "posttdiary-ex: failed to upload image (#{imgname}) to remote server" if response.code.to_i < 200 or response.code.to_i > 202
	end

	(image_body ? true : false)
end

def get_date_to_append( http, cgi, user, pass, now )
	# call update.rb via HTTP and get the date to append
	str = cgi
	req = Net::HTTP::Get.new( str )
	req.basic_auth user, pass
	response, = http.request(req)
	body = response.body

	year = now.strftime( "%Y" )
	month = now.strftime( "%m" )
	day = now.strftime( "%d" )
	bodytmp = body.split(/$/);
	bodytmp.each do |oneline|
		if oneline =~ /\<input\s.*\sname=\"year\"([^\>]*)\>/ then
			if $1 =~ /value=\"(\d\d\d\d)"/ then
				year = $1
			end
		end
		if oneline =~ /\<input\s.*\sname=\"month\"([^\>]*)\>/ then
			if $1 =~ /value=\"(\d+)\"/ then
				month = $1
			end
		end
		if oneline =~ /\<input\s.*\sname=\"day\"([^\>]*)\>/ then
			if $1 =~ /value=\"(\d+)\"/ then
				day = $1
			end
		end
	end

	Time::local( year, month, day )
end

def parse_mail( head, body , image_dir )
	imglist = []
	orglist = []
	textbody = ""
	imgnum = -1
	imgdir = add_delimiter( image_dir )

	if   head =~ /Content-Type:\s*Multipart\/Mixed.*boundary=\"*([^\"\r\n]*)\"*/im or head =~ /Content-Type:\s*Multipart\/Related.*boundary=\"*([^\"\r\n]*)\"*/im then
		bound = "--" + $1
		body_sub = body.split( Regexp.compile( Regexp.escape( bound ) ) )
		body_sub.each do |b|
			sub_head, sub_body = b.split( /(?:\r\n){2}|\r\r|\n\n/, 2 )
			sub_body = "" unless sub_body

			next unless sub_head =~ /Content-Type/i

			if sub_head =~ %r[^Content-Type:\s*text/plain]i then
				textbody = add_body_text( textbody , sub_head, sub_body )
			elsif sub_head =~ %r[^Content-Type:\s*(image\/|application\/octet-stream).*name=\"*(.*)(\.[^\"\r\n]*)\"*]im
				imgnum += 1
				orgname = $2
				orgname = "" if !orgname
				image_ext = $3.downcase
				image_name = "_tmp" + Process.pid.to_s + "_" + imgnum.to_s + image_ext
				File::umask( 022 )
				open( imgdir + image_name, "wb" ) do |s|
					begin
						s.print Base64::decode64( sub_body.strip )
					rescue NameError
						s.print decode64( sub_body.strip )
					end
				end
				if /\.bmp$/i =~ image_name then
					bmp_to_png( imgdir + image_name )
					image_name.sub!( /\.bmp$/, '.png' )
				end
				imglist[imgnum] = imgdir + image_name
				orglist[imgnum] = orgname
			end
		end
	elsif head =~ /^Content-Type:\s*text\/plain/i 
		textbody = add_body_text( textbody , head, body )
	else
		raise "posttdiary-ex: can not read this mail (illegal format)"
	end

	addr = nil
	if /^To:(.*)$/ =~ head then
		to = $1.strip
		if /.*?\s*<(.*)>/ =~ to then
			addr = $1
		elsif /(.*?)\s*\(.*\)/ =~ to
			addr = $1
		else
			addr = to
		end
	end

	subject = ''
	nextline = false
	headlines = head.split( /[\r\n]+/ )
	for n in 0 .. headlines.size-1
		if nextline then
			if /^[ \t]/ =~ headlines[n] then
				s = headlines[n].sub( /^[ \t]/, '' )
				subject += NKF::nkf( '-wXd', s )
			else
				break
			end
		end
		if /^Subject:(.*)$/ =~ headlines[n] then
			s = $1.sub( /^\s+/, '' )
			subject = NKF::nkf( '-wXd', s )
			nextline = true
		end
	end

	[addr, subject, imglist, orglist, textbody]
end

begin
	raise usage(false) if ARGV.length < 1

	require 'getoptlong'
	parser = GetoptLong::new

	conf_df_name = nil
	image_dir = nil
	image_url = nil
	use_subject = false
	thumbnail_size = nil
	image_geometry = nil
	use_image_ex = false
	hour_offset = nil
	@hour_offset = nil
	yearly_dir = false
	thumbnail_name = Hash.new("")
	exif_comment = Hash.new("")
	exif_orientation = Hash.new(1)
	image_orgname = Hash.new("")

	remote_mode = false
	remote_image_dir = nil
	remote_yearly_dir = false
	preserve_local_images = false
	upload_only = false
	class_name = 'photo'
	group_id = nil
	add_div_imgnum = 2
	add_div_imgnum_specified = nil
	threshold_size = nil
	pass_filename = false
	filter_mode = false
	writeout_filename = nil
	read_exif = false
	image_format = ' <img class="$3" src="$1" alt="$4" title="$4">'
	image_format_with_thumbnail = ' <A HREF="$1"><img class="$3" src="$2" alt="$4" title="$4"></a>'
	image_format_specified = nil
	wiki_style = false
	blog_style = false
	use_original_name = false
	date_margin = 7
	convertpath_specified = nil
	@convertpath = "convert"
	@magickpath = ""
	exifpath_specified = nil
	@exifpath = "exif"
	rotation_degree_specified = nil

	parser.set_options(
		['--read-conffile', '-a', GetoptLong::REQUIRED_ARGUMENT],
		['--image-path', '-i', GetoptLong::REQUIRED_ARGUMENT],
		['--image-url', '-u', GetoptLong::REQUIRED_ARGUMENT],
		['--use-subject', '-s', GetoptLong::NO_ARGUMENT],
		['--make-thumbnail', '-t', GetoptLong::REQUIRED_ARGUMENT],
		['--image-geometry', '-g', GetoptLong::REQUIRED_ARGUMENT],
		['--use-image-ex', '-e', GetoptLong::NO_ARGUMENT],
		['--hour-offset', '-o', GetoptLong::REQUIRED_ARGUMENT],
		['--yearly-dir', '-y', GetoptLong::NO_ARGUMENT],
		['--help', '-h', GetoptLong::NO_ARGUMENT],
		['--convert-path', '-C', GetoptLong::REQUIRED_ARGUMENT],
		['--exif-path', '-E', GetoptLong::REQUIRED_ARGUMENT],
		['--remote-mode', '-R', GetoptLong::NO_ARGUMENT],
		['--remote-image-path', '-D', GetoptLong::REQUIRED_ARGUMENT],
		['--remote-yearly-dir', '-Y', GetoptLong::REQUIRED_ARGUMENT],
		['--preserve-local-images', '-P', GetoptLong::NO_ARGUMENT],
		['--upload-only', '-U', GetoptLong::NO_ARGUMENT],
		['--group-id', '-G', GetoptLong::REQUIRED_ARGUMENT],
		['--class-name', '-n', GetoptLong::REQUIRED_ARGUMENT],
		['--add-div', '-v', GetoptLong::REQUIRED_ARGUMENT],
		['--threshold-size', '-z', GetoptLong::REQUIRED_ARGUMENT],
		['--image-format', '-f', GetoptLong::REQUIRED_ARGUMENT],
		['--use-original-name', '-r', GetoptLong::NO_ARGUMENT],
		['--wiki-style', '-w', GetoptLong::NO_ARGUMENT],
		['--blog-style', '-B', GetoptLong::NO_ARGUMENT],
		['--read-exif', '-c', GetoptLong::NO_ARGUMENT],
		['--margin-time', '-m', GetoptLong::REQUIRED_ARGUMENT],
		['--pass-filename', '-p', GetoptLong::NO_ARGUMENT],
		['--filter-mode', '-d', GetoptLong::NO_ARGUMENT],
		['--write-to-file', '-b', GetoptLong::REQUIRED_ARGUMENT],
		['--date-margin', '-j', GetoptLong::REQUIRED_ARGUMENT],
		['--rotate', '-T', GetoptLong::REQUIRED_ARGUMENT]
	)
	begin
		parser.each do |opt, arg|
			case opt
			when '--read-conffile'
				conf_df_name = arg.dup
			when '--image-path'
				image_dir = arg.dup
			when '--image-url'
				image_url = arg.dup
			when '--use-subject'
				use_subject = true
			when '--make-thumbnail'
				thumbnail_size = arg.dup
			when '--image-geometry'
				image_geometry = arg.dup
			when '--use-image-ex'
				use_image_ex = true
			when '--hour-offset'
				hour_offset = arg.to_i
			when '--yearly-dir'
				yearly_dir = true
			when '--help'
				print usage(true)
				exit 0

			when '--convert-path'
				convertpath_specified = arg.dup
			when '--exif-path'
				exifpath_specified = arg.dup
				read_exif = true
			when '--remote-mode'
				remote_mode = true
			when '--remote-image-path'
				remote_image_dir = add_delimiter(arg.dup)
			when '--remote-yearly-dir'
				remote_yearly_dir = (arg.dup =~ /[1yt]/i)
			when '--preserve-local-images'
				preserve_local_images = true
			when '--upload-only'
				upload_only = true
				filter_mode = true
			when '--group-id'
				if arg =~ /\D/ then
					require 'etc'
					group_id = Etc.getgrnam( arg.dup )['gid']
				else
					group_id = arg.to_i
				end
				group_id = nil if group_id <= 0 or group_id > 65535
			when '--add-div'
				add_div_imgnum_specified = arg.to_i
			when '--threshold-size'
				threshold_size = arg.dup
			when '--image-format'
				image_format_specified = arg.dup
			when '--use-original-name'
				use_original_name = true
			when '--wiki-style'
				wiki_style = true
				use_image_ex = true
			when '--blog-style'
				blog_style = true
			when '--read-exif'
				read_exif = true
			when '--pass-filename'
				pass_filename = true
			when '--filter-mode'
				filter_mode = true
			when '--write-to-file'
				filter_mode = true
				writeout_filename = arg.dup
			when '--date-margin'
				date_margin = arg.to_i
			when '--rotate'
				rotation_degree_specified = 0
				rotation_degree_specified = 90 if arg =~ /right/i
				rotation_degree_specified = -90 if arg =~ /left/i
			end
		end
	rescue
		raise usage(false)
	end
	if conf_df_name then
		if read_tdiary_conf( conf_df_name ) then
			image_dir = @options['image.dir'] if @options['image.dir'] and !image_dir
			image_url = @options['image.url'] if @options['image.url'] and !image_url
			yearly_dir = true if @options['image_ex.yearlydir'] and @options['image_ex.yearlydir'] == 1
			thumbnail_size = @options['image_ex.convertedwidth'].to_s + "x" + @options['image_ex.convertedheight'].to_s if @options['image_ex.convertedwidth'] and @options['image_ex.convertedheight'] and thumbnail_size == nil
			threshold_size = @options['image_ex.thresholdsize'].to_s if @options['image_ex.thresholdsize'] and !threshold_size
			@convertpath= @options['image_ex.convertpath'] if @options['image_ex.convertpath'] and !convertpath_specified
			@exifpath = @options['image_ex.exifpath'] if @options['image_ex.exifpath'] and !exifpath_specified
		else
			conf_df_name = ''
		end
	end
	image_url = "" if use_image_ex and !image_url
	raise 'posttdiary-ex: image-path (-i) or image-url (-u) missing...' if (!image_url and image_dir) or (!image_dir and image_url)
	if image_dir then
		image_dir = add_delimiter( image_dir )
	end
	if image_url then
		image_url += '/' unless %r[/$] =~ image_url
	end
	if thumbnail_size then
		thumbnail_size.gsub!(/[\>\\\s]/, '')
		thumbnail_size = thumbnail_size + 'x' + thumbnail_size if !(thumbnail_size =~ /x/ )
		raise usage if !(thumbnail_size =~ /^\d+x\d+/)
	end
	threshold_size = thumbnail_size if !threshold_size
	if threshold_size and threshold_size.size > 0 then
		threshold_size.gsub!(/[\>\\\s]/, '')
		threshold_size = threshold_size + 'x' + threshold_size if !(threshold_size =~ /x/ )
		raise usage if !(threshold_size =~ /^\d+x\d+/)
	end
	if image_geometry then
		image_geometry.gsub!(/[\>\\\s]/, '')
		image_geometry = image_geometry + 'x' + image_geometry if !(image_geometry =~ /x/ )
		raise usage if !(image_geometry =~ /^\d+x\d+/)
	end
	hour_offset = @hour_offset if !hour_offset
	hour_offset = 0 if !hour_offset
	if image_format_specified then
		image_format = image_format_specified
		image_format_with_thumbnail = image_format
	else
		if use_image_ex then
			image_format = '<%=image $0,\'$4\'%>'
			image_format_with_thumbnail = image_format
		end
		if wiki_style then
			image_format = '{{image $0,\'$4\'}}'
			image_format_with_thumbnail = image_format
		end
	end
	if wiki_style then
		add_div_imgnum = 0
	else
		add_div_imgnum = add_div_imgnum_specified if add_div_imgnum_specified
	end
	@convertpath = convertpath_specified 	if convertpath_specified
	@convertpath = add_delimiter( @convertpath ) + "convert" if test( ?d , @convertpath )
	@magickpath = $1 if @convertpath =~ /(.*[\/\\])[^\/\\]+$/
	@exifpath = exifpath_specified 	if exifpath_specified
	@exifpath = add_delimiter( @exifpath ) + "exif" if test( ?d , @exifpath )

	if filter_mode == false then
		url = ARGV.shift.dup
		if %r|http://([^:/]*):?(\d*)(/.*)| =~ url then
			host = $1
			port = $2.to_i
			cgi = $3
			raise 'posttdiary-ex: invalid url for update.rb.' if not host or not cgi
			port = 80 if port == 0
		else
			raise 'posttdiary-ex: invalid url for update.rb.'
		end
		user = ARGV.shift.dup
		pass = ARGV.shift.dup
	end
	
	require 'base64'
	require 'nkf'
	require 'net/http'
	require 'shell'
	Net::HTTP.version_1_2

	mail = NKF::nkf( '-m0 -Xwd', ARGF.read )
	raise "posttdiary-ex: no mail text." if not mail or mail.length == 0
	
	head, body = mail.split( /(?:\r\n){2}|\r\r|\n\n/, 2 )
	body = "" unless body
	addr, subject, tmpimglist, orglist, @body = parse_mail( head, body, image_dir )

	if /([^-]+)-(.*)@/ =~ addr then
		user = $1 unless user
		pass = $2 unless pass
	end
	raise "posttdiary-ex: please specify the username for your tdiary system." unless user or filter_mode
	if tmpimglist.length > 0 and ( !image_dir or !image_url ) then
		raise "posttdiary-ex: please specify image-path (-i) and/or image-url (-u)"
	end

	now = Time::now + hour_offset * 3600
	tmp = Time::now + hour_offset * 3600
	if @body.gsub!( /^\_date\#([\d\-\/\.]+)[^\r\n]*[\r\n]+/i , '' ) then
		t = $1
		if /(\d\d\d\d)[^\d]*(\d\d)[^\d]*(\d\d)/ =~ t then
			tmp = Time::local( $1.to_i, $2.to_i, $3.to_i );
		end
		if /(\d\d\d\d)[^\d]+(\d+)[^\d]+(\d+)/ =~ t then
			tmp = Time::local( $1.to_i, $2.to_i, $3.to_i );
		end
	else
		if blog_style and !filter_mode then
			Net::HTTP.start( host, port ) do |http|
				tmp = get_date_to_append( http, cgi, user, pass, now )
			end
		end
	end
	if @body.gsub!( /^\_up[ld]+only\#[ \t]*[\r\n]+/i , '' ) then
		upload_only = true
	end
	if @body.gsub!( /^\_rot[ate]*\_right\#[ \t]*[\r\n]+/i , '' ) then
		rotation_degree_specified = 90
	end
	if @body.gsub!( /^\_rot[ate]*\_left\#[ \t]*[\r\n]+/i , '' ) then
		rotation_degree_specified = -90
	end
	if @body.gsub!( /^\_rot[ate]*\_none\#[ \t]*[\r\n]+/i , '' ) then
		rotation_degree_specified = 0
	end

	if date_margin != 0 and (tmp - now).abs >= date_margin * 24 * 3600 then
#		raise "posttdiary-ex: specified date is too far from today"
#		# use current date (now) instead of specified date(tmp)..
	else
		now = tmp
	end
	
	topic_year = now.strftime( "%Y" )
	topic_month = now.strftime( "%m" )
	topic_date = now.strftime( "%d" )

	if image_dir then
		image_dir = add_delimiter( image_dir + now.strftime( "%Y" ) ) if yearly_dir
		Dir.mkdir( image_dir ) if !test( ?d , image_dir )
		if remote_mode then
			image_url += topic_year + "/" if remote_yearly_dir
		else
			image_url += topic_year + "/" if yearly_dir
		end
	end
	nextnum = -1
	av_list = []
	if remote_mode then
		if !remote_image_dir or remote_image_dir.length < 1 then
#			needed when using image_ex.rb, but not when using image.rb...
#			raise 'posttdiary-ex: please specify --remote-image-path'
			remote_image_dir = ""
		else
			if remote_yearly_dir then
				remote_image_dir = add_delimiter( remote_image_dir + topic_year )
			end
		end
		Net::HTTP.start( host, port ) do |http|
			nextnum,av_list = check_remote_images( http, cgi, user, pass, now)
		end
	else
		nextnum,av_list = check_local_images( now.strftime( "%Y%m%d" ), image_dir )
	end
	@image_name = nil
	sh = Shell.new
	for i in 0 .. (tmpimglist.length-1)
		tmpimgname = tmpimglist[i]
		raise "posttdiary-ex: program bug found: no extension in tmpimgname" if !(tmpimgname =~ /(\.[^\.]*?)$/)
		image_ext = $1.downcase
		image_name = now.strftime( "%Y%m%d" ) + "_" + nextnum.to_s + image_ext
		nextnum += 1
		sh.rename( tmpimgname , image_dir + image_name )
		exif_comment[image_name] = (read_exif ? read_exif_comment(image_dir + image_name) : "" )
		exif_orientation[image_name] = (read_exif ? read_exif_orientation(image_dir + image_name) : "" )
		image_orgname[image_name] = orglist[i]
		change_image_size( image_dir + image_name , image_geometry ) if image_geometry
		if rotation_degree_specified then
			if rotation_degree_specified != 0 then
				rotate_image( image_dir + image_name , rotation_degree_specified )
			end
		elsif read_exif and exif_orientation[image_name] != 1 then
			rotate_image( image_dir + image_name , rotation_degree( exif_orientation[image_name] ) )
		end
		if group_id then
			sh.chown( nil , group_id , image_dir + image_name )
			sh.chmod( 00664 , image_dir + image_name )
		end
		thumbnail_name[image_name] = ""
		thumbnail_name[image_name] = make_thumbnail( image_dir, image_name , thumbnail_size , group_id ) if thumbnail_size and check_image_size( image_dir + image_name, threshold_size)
		@image_name = [] unless @image_name
		@image_name << image_name
	end

	if @image_name then
		img_src = ""
		marker = "_posttdiary_ex_temporary_marker_"
		img_in_div = 0
		for j in 0 .. @image_name.size-1
			i = @image_name[j]
			serial = i.sub( /^\d+_(\d+)\.[^\.]*?$/, '\1' )
			serial = i if use_image_ex and pass_filename
			cm = ""
			cm = exif_comment[i] if read_exif and exif_comment[i] and exif_comment[i].size > 0
			cm = image_orgname[i] if use_original_name and (!cm or cm.size == 0)
			cm = i.gsub(/\.[^\.]*?$/, '') if !cm or cm.size == 0
			if use_image_ex then
				# modify <%=image (num),'comment'%> or <%=image (num)%> tags
				if @body =~ /\<\%\=image[^\s]*\s+#{j}\s*\,\s*[\"\'](.*)[\"\']\s*\%*\>/i then
					alttext = $1;
					alttext = cm if alttext.length < 1
					@body.gsub!( /\<\%\=(image[^\s]*)\s+#{j}\s*\,\s*[\"\'].*[\"\']\s*\%*\>/i, '<%=\1 '+marker+serial.to_s+',\''+alttext+'\'%>' )
					next
				elsif @body =~ /\<\%\=image[^\s]*\s+#{j}\s*\%*\>/i then
					alttext = cm
					@body.gsub!( /\<\%\=(image[^\s]*)\s+#{j}\s*\%*\>/i, '<%=\1 '+marker+serial.to_s+',\''+alttext+'\'%>' )
					next
				end
			end
			if wiki_style then
				# modify {{image (num),"comment"}} or {{image (num)}} tags (also recognizes image_left, image_right)
				if @body =~ /\{\{image[^\s]*\s+#{j}\s*\,\s*[\"\'](.*)[\"\']\s*\}\}/i then
					alttext = $1;
					alttext = cm if alttext.length < 1
					@body.gsub!( /\{\{(image[^\s]*)\s+#{j}\s*\,\s*[\"\'].*[\"\']\s*\}\}/i, '{{\1 '+marker+serial.to_s+',\''+alttext+'\'}}' )
					next
				elsif @body =~ /\{\{image[^\s]*\s+#{j}\s*\}\}/i then
					alttext = cm
					@body.gsub!( /\{\{(image[^\s]*)\s+#{j}\s*\}\}/i, '{{\1 '+marker+serial.to_s+',\''+alttext+'\'}}' )
					next
				end
			end
			img_in_div+=1
			if thumbnail_size and thumbnail_name[i].size > 0 then
				t = thumbnail_name[i]
				img_src += image_format_with_thumbnail.gsub( /\$0/, serial ).gsub( /\$1/, image_url + i ).gsub( /\$2/, image_url + t ).gsub( /\$3/, class_name ).gsub( /\$4/, cm )
			else
				img_src += image_format.gsub( /\$0/, serial ).gsub( /\$1/, image_url + i ).gsub( /\$3/, class_name ).gsub( /\$4/, cm )
			end
		end
		@body.gsub!( /#{marker}/ , '' )
		if img_src =~ /^\s+$/ then
			img_src = ''
		else
			if add_div_imgnum <= img_in_div and add_div_imgnum > 0 then
				img_src = "<div class=\"photos\">" + img_src + "</div>"
			end
		end
		img_src.sub!( /^/ , ' ' ) if ! wiki_style
		if use_subject then
			img_src = img_src + "\n" if !(img_src =~ /^\s*$/)
			@body = "#{img_src}#{@body.sub( /\n+\z/, '' )}"
		else
			@body = "#{@body.sub( /\n+\z/, '' )}\n#{img_src}"
		end
	end

	if use_subject then
		title = ''
		@body = "#{subject}\n#{@body}"
		@body = "!" + @body if wiki_style
	else
		title = subject
	end

	if upload_only then
		exit 0
	end
	require 'cgi'
	require 'nkf'
	if filter_mode then
		data = title + "\n";
		data << @body + "\n";
		if writeout_filename then
			open( writeout_filename, "wb" ) do |s|
				s.print data
			end
		else
			print data
		end
	else
		data = "title=#{CGI::escape title}"
		data << "&body=#{CGI::escape @body}"
		data << "&append=true"
		data << "&year=#{topic_year}"
		data << "&month=#{topic_month}"
		data << "&day=#{topic_date}"
		auth = ["#{user}:#{pass}"].pack( 'm' ).strip
		Net::HTTP.start( host, port ) do |http|
			protection_key = nil
			res = http.get( cgi,
	                               'Authorization' => "Basic #{auth}",
	                               'Referer' => url )
			if %r|<input type="hidden" name="csrf_protection_key" value="([^"]+)">| =~ res.body then
				protection_key = $1
				data << "&csrf_protection_key=#{CGI::escape( CGI::unescapeHTML( protection_key ) )}"
			end
			if remote_mode and @image_name then
				for i in 0 .. (@image_name.length - 1)
					imagename = @image_name[i]
					thumbnailname = thumbnail_name[imagename]
					post_image( http, cgi, user, pass, image_dir, imagename, remote_image_dir, now, protection_key, url )
					File.delete( image_dir + imagename ) if !preserve_local_images
					File.delete( image_dir + thumbnailname ) if !preserve_local_images and test( ?f , image_dir + thumbnailname )
				end
			end
			response = http.post( cgi, data, 'Authorization' => "Basic #{auth}", 'Referer' => url )
		end
	end

rescue
	$stderr.puts $!
	exit 1
end
