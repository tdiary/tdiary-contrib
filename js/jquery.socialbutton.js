/**
 * jquery.socialbutton - jQuery plugin for social networking websites
 * https://itra.jp/jquery_socialbutton_plugin/
 *
 * Copyright 2010, Itrans, Inc. http://itra.jp/
 *
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * https://jquery.org/license
 *
 * Version: 1.9.1
 */

/**
 * SYNOPSIS
 *
 *
 * mixi_check
 * https://developer.mixi.co.jp/connect/mixi_plugin/mixi_check/spec_mixi_check
 *
 * $('#mixi_check').socialbutton('mixi_check', {
 *     key: 'mixi-check-key'
 * });
 *
 * $('#mixi_check').socialbutton('mixi_check', {
 *     key: 'mixi-check-key',
 *     button: 'button-1',
 *     url: 'https://itra.jp/'
 * });
 *
 *
 * mixi_like
 * https://developer.mixi.co.jp/connect/mixi_plugin/favorite_button/spec
 *
 * $('#mixi_like').socialbutton('mixi_like', {
 *     key: 'mixi-check-key',
 * });
 *
 * $('#mixi_like').socialbutton('mixi_like', {
 *     key: 'mixi-check-key',
 *     url: 'https://itra.jp/',
 *     width: 450,
 *     height: 80,
 *     show_faces: true,
 *     style: 'additional-style-here'
 * });
 *
 *
 * facebook_like
 * https://developers.facebook.com/docs/reference/plugins/like
 *
 * $('#facebook_like').socialbutton('facebook_like');
 *
 * $('#facebook_like').socialbutton('facebook_like', {
 *     button: 'standard', // synonym 'layout'
 *     url: 'https://itra.jp',
 *     show_faces: true,
 *     width: 450,
 *     height: 80,
 *     action: 'like',
 *     locale: 'en_US',
 *     font: 'arial',
 *     colorscheme: 'light'
 * });
 *
 *
 * facebook_share
 * https://developers.facebook.com/docs/share
 *
 * $('#facebook_share').socialbutton('facebook_share');
 *
 * $('#facebook_share').socialbutton('facebook_share', {
 *     button: 'button_count', // synonym 'type'
 *     url: 'https://itra.jp',
 *     text: 'Share'
 * });
 *
 *
 * Twitter
 * https://developer.twitter.com/en/docs/twitter-for-websites/tweet-button/overview.html
 *
 * $('#twitter').socialbutton('twitter');
 *
 * $('#twitter').socialbutton('twitter', {
 *     button: 'vertical', // synonym 'count'
 *     url: 'https://itra.jp/',
 *     text: 'tweet text',
 *     lang: 'ja',
 *     via: 'ishiiyoshinori',
 *     related: 'twitter'
 * });
 *
 *
 * Hatena Bookmark
 * http://b.hatena.ne.jp/guide/bbutton
 *
 * $('#hatena').socialbutton('hatena');
 *
 * $('#hatena').socialbutton('hatena', {
 *     button: 'standard',
 *     url: 'https://itra.jp/',
 *     title: 'page-title'
 * });
 *
 *
 * Pintarest Button
 * https://developers.pinterest.com/docs/widgets/save/?
 *
 * $('#pinterest').socialbutton('pintarest', {
 *     button: 'horizontal', // or 'vertical', 'none'
 *     url: 'https://itra.jp',
 *     media: 'https://itra.jp/image.jpg',
 *     description: 'This is an image.'
 * });
 */
(function($) {

$.fn.socialbutton = function(service, options) {

	options = options || {};

	var defaults = {
		mixi_check: {
			key: '',
			button: 'button-1', // button-1,button-2,button-3,button-4,button-5
			url: '' // document.URL
		},
		mixi_like: {
			key: '',
			url: document.URL,
			width: 0, // auto
			height: 0, // auto
			show_faces: true,
			style: '',

			sizes: {
				width: {
					with_faces: 450,
					without_faces: 140
				},
				height: {
					with_faces_minimum: 80,
					without_faces_minimum: 20
				}
			}
		},
		facebook_like: {
			button: 'standard', // standard / button_count / box_count
			url: document.URL,

			show_faces: true,
			width: 0, // auto
			height: 0, // auto

			width_standard_default: 450, // orig: 450
			width_standard_minimum: 225,
			height_standard_without_photo: 35,
			height_standard_with_photo: 80,

			width_button_count_default: 120, // orig: 90, jp_min: 114
			width_button_count_minimum: 90,
			height_button_count: 25, // orig:20, jp_min: 21

			width_box_count_default: 80, // orig:55, jp_min: 75
			width_box_count_minimum: 55,
			height_box_count: 70, // orig: 65, jp_min: 66

			action: 'like', // like / recommend
			locale: '', // auto
			font: '',
			colorscheme: 'light' // light / dark
		},
		facebook_share: {
			button: 'button_count', // box_count / button / icon_link / icon
			url: '', //document.URL
			text: '' //Share
		},
		twitter: {
			button: 'vertical', // vertical / horizontal / none
			url: '', // document.URL
			text: '',
			lang: 'ja', // ja / en /de / fr / es
			via: '',
			related: ''
		},
		hatena: {
			button: 'standard', // standard, vertical, simple
			url: document.URL,
			title: document.title
		},
		pinterest: {
			button: 'horizontal', // horizontal, vertical, none
			url: document.URL,
			media: '',
			description: ''
		}
	};

	var max_index = this.length - 1;

	return this.each(function(index) {

		switch (service) {
			case 'mixi_check':
				socialbutton_mixi_check(this, options, defaults.mixi_check, index, max_index);
				break;

			case 'mixi_like':
				socialbutton_mixi_like(this, options, defaults.mixi_like, index, max_index);
				break;

			case 'facebook_like':
				socialbutton_facebook_like(this, options, defaults.facebook_like, index, max_index);
				break;

			case 'facebook_share':
				socialbutton_facebook_share(this, options, defaults.facebook_share, index, max_index);
				break;

			case 'twitter':
				socialbutton_twitter(this, options, defaults.twitter, index, max_index);
				break;

			case 'hatena':
				socialbutton_hatena(this, options, defaults.hatena, index, max_index);
				break;

			case 'pinterest':
				socialbutton_pinterest(this, options, defaults.pinterest, index, max_index);
				break;

			default:
				break;
		}

		return true;
	});
}

function socialbutton_mixi_check(target, options, defaults, index, max_index)
{
	var key = options.key || defaults.key;
	var button = options.button || defaults.button;
	var url = options.url || defaults.url;

	if (key == '') {
		return;
	}

	var attr = merge_attributes({
		'data-key': key,
		'data-url': htmlspecialchars(url),
		'data-button': button
	});

	var tag = '<a href="https://mixi.jp/share.pl" class="mixi-check-button"' + attr + '>Check</a>';

	$(target).html(tag);

	if (index == max_index) {
		$('body').append('<script type="text/javascript" src="https://static.mixi.jp/js/share.js"></script>');
	}
}

function socialbutton_mixi_like(target, options, defaults, index, max_index)
{
	var key = options.key || defaults.key;
	var url = options.url || defaults.url;
	var width = options.width != undefined ? options.width : defaults.width;
	var height = options.height != undefined ? options.height : defaults.height;
	var show_faces = options.show_faces != undefined ? options.show_faces : defaults.show_faces;
	var style = options.style || defaults.style;

	if (key == '') {
		return;
	}

	if (options.url) {
		url = decodeURIComponent(url);
	}
	url = url_encode_rfc3986(url);

	if (width == 0) {
		width = show_faces ? defaults.sizes.width.with_faces : defaults.sizes.width.without_faces;
	}

	if (height == 0) {
		height = show_faces ? defaults.sizes.height.with_faces_minimum : defaults.sizes.height.without_faces_minimum;
	} else {
		if (show_faces && height < defaults.sizes.height.with_faces_minimum) {
			height = defaults.sizes.height.with_faces_minimum;
		} else if (!show_faces && height < defaults.sizes.height.without_faces_minimum) {
			height = defaults.sizes.height.without_faces_minimum;
		}
	}

	var params = merge_parameters({
		'href': url,
		'service_key': key,
		'width': width,
		'show_faces': show_faces ? 'true' : 'false'
	});

	var attr = merge_attributes({
		src: 'https://plugins.mixi.jp/favorite.pl?' + params,
		scrolling: 'no',
		frameborder: '0',
		allowTransparency: 'true',
		style: 'border:0; overflow:hidden; width:' + width + 'px; height:' + height + 'px; ' + style
	});

	var tag = '<iframe' + attr + '></iframe>';

	$(target).html(tag);
}

function socialbutton_facebook_like(target, options, defaults, index, max_index)
{
	var layout = options.layout || options.button || defaults.button;
	var url = options.url || defaults.url;

	var show_faces = options.show_faces != undefined ? options.show_faces : defaults.show_faces;
	var width = options.width != undefined ? options.width : defaults.width;
	var height = options.height != undefined ? options.height : defaults.height;
	var action = options.action || defaults.action;
	var locale = options.locale || defaults.locale;
	var font = options.font || defaults.font;
	var colorscheme = options.colorscheme || defaults.colorscheme;

	if (options.url) {
		url = decodeURIComponent(url);
	}
	url = url_encode_rfc3986(url);

	switch (layout) {
		case 'standard':
			if (width == 0) {
				width = defaults.width_standard_default;
			} else if (width < defaults.width_standard_minimum) {
				width = defaults.width_standard_minimum;
			}
			if (height == 0) {
				height = show_faces ? defaults.height_standard_with_photo : defaults.height_standard_without_photo;
			} else if (height < defaults.height_standard_without_photo) {
				height = defaults.height_standard_without_photo;
			}
			break;
		case 'button_count':
			if (width == 0) {
				width = defaults.width_button_count_default;
			} else if (width < defaults.width_button_count_minimum) {
				width = defaults.width_button_count_minimum;
			}
			if (height == 0) {
				height = defaults.height_button_count;
			} else if (height < defaults.height_button_count) {
				height = defaults.height_button_count;
			}
			break;
		case 'box_count':
			if (width == 0) {
				width = defaults.width_box_count_default;
			} else if (width < defaults.width_box_count_minimum) {
				width = defaults.width_box_count_minimum;
			}
			if (height == 0) {
				height = defaults.height_box_count;
			} else if (height < defaults.height_box_count) {
				height = defaults.height_box_count;
			}
			break;
	}

	var params = merge_parameters({
		'href': url,
		'layout': layout,
		'show_faces': show_faces ? 'true' : 'false',
		'width': width,
		'action': action,
		'locale': locale,
		'font': font,
		'colorscheme': colorscheme,
		'height': height
	});

	var tag = '<iframe src="https://www.facebook.com/plugins/like.php?' + params + '" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:' + width + 'px; height:' + height + 'px;" allowTransparency="true"></iframe>';

	$(target).html(tag);
}

function socialbutton_facebook_share(target, options, defaults, index, max_index)
{
	var type = options.type || options.button || defaults.button;
	var url = options.url || defaults.url;
	var text = options.text || defaults.text;

	var attr = merge_attributes({
		'type': type,
		'share_url': htmlspecialchars(url)
	});

	var tag = '<a name="fb_share"' + attr + '>' + text + '</a>';

	if(index == 0) {
		tag += '<script type="text/javascript" src="https://static.ak.fbcdn.net/connect.php/js/FB.Share"></script>';
	}

	$(target).html(tag);
}

function socialbutton_twitter(target, options, defaults, index, max_index)
{
	var count = options.count || options.button || defaults.button;
	var url = options.url || defaults.url;

	var text = options.text || defaults.text;
	var lang = options.lang || defaults.lang;
	var via = options.via || defaults.via;
	var related = options.related || defaults.related;

	var attr = merge_attributes({
		'data-count': count,
		'data-url': htmlspecialchars(url),
		'data-text': text,
		'data-lang': lang,
		'data-via': via,
		'data-related': related
	});

	var tag = '<a href="https://twitter.com/share" class="twitter-share-button"' + attr + '>Tweet</a>';

	$(target).html(tag);

	if (index == max_index) {
		$('body').append('<script type="text/javascript" src="https://platform.twitter.com/widgets.js"></script>');
	}
}

function socialbutton_hatena(target, options, defaults, index, max_index)
{
	var layout = options.layout || options.button || defaults.button;
	var url = options.url || defaults.url;
	var title = options.title || defaults.title;

	url = htmlspecialchars(url);
	title = htmlspecialchars(title);

	var attr = merge_attributes({
		'href': 'https://b.hatena.ne.jp/entry/' + url,
		'class': 'hatena-bookmark-button',
		'data-hatena-bookmark-url': url,
		'data-hatena-bookmark-title': title,
		'data-hatena-bookmark-layout': layout,
		'title': 'このエントリーをはてなブックマークに追加'
	});

	var tag = '<a' + attr + '><img src="https://b.st-hatena.com/images/entry-button/button-only.gif" alt="このエントリーをはてなブックマークに追加" width="20" height="20" style="border: none;" /></a>'
			+ '<script type="text/javascript" src="https://b.st-hatena.com/js/bookmark_button.js" charset="utf-8" async="async"></script>';

	$(target).html(tag);
}

function socialbutton_pinterest(target, options, defaults, index, max_index)
{
	var url = options.url || defaults.url;
	var button = options.button || defaults.button;
	var media = options.media != undefined ? options.media : defaults.media;
	var description = options.description != undefined ? options.description : defaults.description;

	url = url_encode_rfc3986(decodeURIComponent(url));
	media = url_encode_rfc3986(decodeURIComponent(media));
	description = decodeURIComponent(description);

	var params = merge_parameters({
		'url': url,
		'media': media,
		'description': description
	});

	var tag = '<a href="https://pinterest.com/pin/create/button/?' + params + '" class="pin-it-button" count-layout="' + button +'"><img border="0" src="//assets.pinterest.com/images/PinExt.png" title="Pin It" /></a>'

	$(target).html(tag);

	if (index == max_index) {
		$('body').append('<script type="text/javascript" src="//assets.pinterest.com/js/pinit.js"></script>');
	}
}

function merge_attributes(attr)
{
	var merged = '';

	for (var i in attr) {
		if (attr[i] == '') {
			continue;
		}
		merged += ' ' + i + '="' + attr[i] + '"';
	}

	return merged;
}

function merge_parameters(params)
{
	var merged = '';

	for (var i in params) {
		if (params[i] == '') {
			continue;
		}
		merged += merged != '' ? '&amp;' : '';
		merged += i + '=' + params[i] + '';
	}

	return merged;
}

function htmlspecialchars(string)
{
	var table = [
		[/&/g, '&amp;'],
		[/</g, '&lt;'],
		[/>/g, '&gt;'],
		[/"/g, '&quot;'],
		[/'/g, '&#039;']
	];

	for (var i in table) {
		string = string.replace(table[i][0], table[i][1]);
	}

	return string;
}

function url_encode_rfc3986(url)
{
	return encodeURIComponent(url).replace(/[!*'()]/g, function(p) {
		return "%" + p.charCodeAt(0).toString(16);
	});
}

})(jQuery);
