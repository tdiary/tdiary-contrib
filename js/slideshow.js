/*
 * slideshow.js : show slides
 *
 * Copyright (C) 2016 by TADA Tadashi <t@tdtds.jp>
 * Distributed under the GPL2 or any later version.
 */

$(function(){
	function isFullscreenEnabled(doc) {
		return(
			doc.fullscreenEnabled ||
			doc.webkitFullscreenEnabled ||
			doc.mozFullScreenEnabled ||
			doc.msFullscreenEnabled ||
			false
		);
	};

	function requestFullscreen(element) {
		var funcs = [
			'requestFullscreen',
			'webkitRequestFullscreen',
			'mozRequestFullScreen',
			'msRequestFullscreen',
		];
		$.each(funcs, function(idx, func) {
			if (element[func]) {
				element[func]();
				return false;
			}
		});
	};

	function isFullscreen() {
		if (document.fullscreenElement ||
				document.webkitFullscreenElement ||
				document.mozFullScreenElement ||
				document.msFullscreenElement ) {
			return true;
		}
		return false;
	};

	function startSlideShow(content) {
		if (!isFullscreenEnabled(document)) {
			return false;
		}

		var slides = [];
		$.each(content.children(), function(i, elem) {
			var e = $(elem).clone();
			if (e.prop('tagName') == 'H3') { // main title
				$('a', e).remove(); // section anchor
				$('span', e).remove(); // hatena start etc...
				$('button.slideshow', e).remove();
				slides.push([$('<div class="slide-title">').append(e)]);
			} else if (e.prop('tagName') == 'H4') { // page title
				slides.push([e, $('<div class="slide-body">')]);
			} else {
				var last = slides[slides.length-1];
				last[last.length-1].append(e);
			}
		});

		var screen = window.screen;
		var slide = $('<div>').
			         addClass('slide').
	               css('width', screen.width).
		            css('height', screen.height);
		var current_page = 0;
		var firstClick = true;

		$('body').append(slide);
		slide.append(slides[current_page]);
		requestFullscreen(slide[current_page]);

		$(document).on({
			'keydown': function(e) {
				if (e.keyCode == 13 || e.keyCode == 34 || e.keyCode == 39) { // next page
					if (slides.length - 1 > current_page) {
						e.preventDefault();
						slide.empty().append(slides[++current_page]);
					}
				} else if (e.keyCode == 37 || e.keyCode == 33) { // prev page
					if (current_page > 0) {
						e.preventDefault();
						slide.empty().append(slides[--current_page]);
					}
				} else if (e.keyCode == 36) { // [Home] to top page
					e.preventDefault();
					slide.empty().append(slides[current_page = 0]);
				} else if (e.keyCode == 35) { // [End] to bottom page
					e.preventDefault();
					slide.empty().append(slides[current_page = slides.length-1]);
				}
			},
			'click': function() {
				if (!firstClick && slides.length - 1 > current_page) {
					slide.empty().append(slides[++current_page]);
				}
				firstClick = false;
			},
			'fullscreenchange webkitfullscreenchange mozfullscreenchange msfullscreenchange': function() {
				if (!isFullscreen()) { // fullscreen was closed
					$(document).off('keydown').off('click');
					slide.remove();
				}
			}
		});

		return true;
	};

	$('.slideshow').on('click', function(e){
		var section = $(this).parent().parent();
		e.preventDefault();
		if (!startSlideShow(section)) {
			alert("couldn't start slideshow.")
			return;
		}
	});
});

