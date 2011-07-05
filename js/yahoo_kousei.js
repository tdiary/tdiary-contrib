$( function() {
	$( '.plugin_yahoo_search_result_raw' ).each( function( index ) {
		$(this).click( function() {
			var pos = $($('td', $(this)).get(3)).text().split(',');
			sp = parseInt(pos[0]);
			ep = parseInt(pos[1]);
			var o = $( 'textarea[name="body"]' ).get( 0 );
			o.focus();
			if ( jQuery.browser.msie ) {
				var range = document.selection.createRange();
				range.collapse();
				range.moveStart( 'character', sp );
				range.moveEnd( 'character', ep );
				range.select();
			} else {
				o.setSelectionRange( sp , sp + ep );
			}
		} );
	} );
} );

