/*
 * gyazo.js: gyazo plugin for tDiary
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
$(function() {
	$('.gyazo-images img')
	.on({
		'mouseenter': function(){
			$(this).css('cursor', 'pointer');
		},
		'mouseleave': function(){
			$(this).css('cursor', 'default');
		},
		'click': function(){
			var url = $(this).attr('data-url');
			var text = $.makePluginTag('gyazo', function(){
				return ["'" + url + "'", "'[description]'"]
			})
			$('#body').insertAtCaret(text);
		}
	})
})
