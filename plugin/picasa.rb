# show photo image on Picasa Web Album
#
# usage:
#   picasa( src[, title[, place]] )
#     - src: The url of the photo to show.
#     - title: title of photo. (optional)
#     - place: class name of img element. default is 'picasa'.
#
#   picasa_left( src[, title] )
#
#   picasa_right( src[, title] )
#
# options configurable through settings:
#   @conf['picasa.user'] : picasa username
#   @conf['picasa.default_size'] : default image size
#
# Copyright (c) hb <http://www.smallstyle.com>
# Distributed under the GPL.
#

def picasa_script

	# this code was from image.rb
	case @conf.style.downcase.sub( /\Ablog/, '' )
	when "wiki", "markdown"
	  ptag1 = "{{"
	  ptag2 = "}}"
	when "rd"
	  ptag1 = "((%"
	  ptag2 = "%))"
	else
	  ptag1 = "&lt;%="
	  ptag2 = "%&gt;"
	end

	size ||= @conf[ 'picasa.default_size'] || 400

	<<-SCRIPT
<script type="text/javascript">
<!--
$( function() {
	var uid = "#{@conf[ 'picasa.user' ]}";
	var imgsize = #{size};

	$( "#plugin_picasa_init" ).click(
		function(){
			$( "#plugin_picasa h2" ).remove();
			$( "#plugin_picasa_result" ).remove();
			$.ajax( {
				url: "http://picasaweb.google.com/data/feed/api/user/" + uid,
				data: "alt=json-in-script&max-results=10&thumbsize=32",
				dataType: 'jsonp',
				jsonp: 'callback',
				success: function( data, status ) {
					$( "#plugin_picasa" ).append( $( '<h2>', { text: "Picasa Web Album" } ) );
					$( "#plugin_picasa" ).append( '<div id="plugin_picasa_result">' ); 
					if ( data.feed.entry ) {
						$( "#plugin_picasa_result" ).append( $( '<ul id="plugin_picasa_album_list">' ) );
						$.each( data.feed.entry, function( i, album ) {
							$( "#plugin_picasa_album_list" ).append( $( '<li>' ).append( $( '<a>' ).text( album.title.$t ).attr( 'href', '' ).click( 
								function( e ) {
									e.preventDefault();
									$( '#plugin_picasa h2' ).append( ': ' ).append( album.title.$t ); 
									$.ajax( {
										url: "http://picasaweb.google.com/data/feed/api/user/" + uid + "/albumid/" + album.gphoto$id.$t,
										data: "alt=json-in-script&imgmax=" + imgsize +"&thumbsize=200",
										dataType: "jsonp",
										jsonp: "callback",
										success: function( data2, status2 ) {
											if ( data2.feed.entry ) {
												$( "#plugin_picasa_result" ).empty();
												$.each( data2.feed.entry, function( i2, photo ) {
													$( "#plugin_picasa_result" ).append( $( '<img>' ).attr( {
														src: photo.media$group.media$thumbnail[0].url,
														title: photo.summary.$t,
														alt: photo.summary.$t
													} ).click(
														function() {
															$( 'textarea[name="body"]' ).val( $( 'textarea[name="body"]' ).val() + '\\n#{ptag1}picasa "' + photo.content.src  + '", "' + photo.summary.$t + '"#{ptag2}' );
														}
													).css( {
														cursor: "hand",
														margin: "1px",
													} ) );
												} );
											}
										}	
									} );
								}
							) ) );
						} );
					}
				}
			});
		}
	)
});
//-->	
</script>
	SCRIPT
end

def picasa( src, alt = "photo", place = 'picasa' )
	src.sub( %r|/s\d+/|, "/s200/" ) if @conf.iphone?
	
	if @cgi.mobile_agent?
		body = %Q|<a href="#{src}">#{alt}</a>|
	else
		body = %Q|<img title="#{alt}" alt="#{alt}" src="#{src}" class="#{place}">|
	end
	body
end

def picasa_left( src, alt = "photo" )
	picasa( src, alt, 'left' )
end

def picasa_right( src, alt = "photo" )
	picasa( src, alt, 'right' )
end

add_header_proc do
	if /\A(form|edit|preview|showcomment)\z/ === @mode then
		picasa_script
	else	
		''
	end
end

add_edit_proc do |date|
	unless @conf[ 'picasa.user' ] 
		'[ERROR] picasa.rb: Picasa username is not specified.'
	else
		<<-HTML
			<div id="plugin_picasa">
			<input id="plugin_picasa_init" type="button" name="plugin_picasa_add" value="Get Picasa Album List">
			</div>
		HTML
	end
end
