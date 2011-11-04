/*
 * show_and_hide.js : javascript for show_and_hide.rb plugin of tDiary
 *
 * Copyright (C) 2011 by tamoot <tamoot+tdiary@gmail.com>
 * You can distribute it under GPL.
 */

$( function() {
	
	function show_and_hide(target) {
		$('.show_and_hide_toggle', target).each( function() {
			$(this).click( function() {
				$('.show_and_hide#'+$(this).attr('data-showandhideid')).slideToggle(400);
			});
		});
	};
	
	// for AutoPagerize
	$(window).bind('AutoPagerize_DOMNodeInserted', function(event) {
		show_and_hide(event.target);
	});
	
	// for AuthPatchWork
	// NOTE: jQuery.bind() cannot handle an event that include a dot charactor.
	// see http://todayspython.blogspot.com/2011/06/autopager-autopagerize.html
	if(window.addEventListener) {
		window.addEventListener('AutoPatchWork.DOMNodeInserted', function(event) {
			show_and_hide(event.target);
		}, false);
	} else if(window.attachEvent) {
		window.attachEvent('onAutoPatchWork.DOMNodeInserted', function(event) {
			show_and_hide(event.target);
		});
	};
	
	show_and_hide(document)
	$('.show_and_hide').hide();
});

