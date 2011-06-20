/*
 picasa.js: javascript for picasa.rb plugin of tDiary
 
 Copyright (C) 2011 by hb <smallstyle@gmail.com>
 You can redistribute it and/or modify it under GPL2.
 */
$(function () {
	var CanvasLoadingImage = function (rgb) {
			this.canvas = null;
			this.ctx = null;
			this.width = 200;
			this.height = 32;
			this.rgb = rgb || '0, 0, 0';
			this.initialize();
		}

	CanvasLoadingImage.prototype = {
		initialize: function () {
			this.canvas = $('<canvas>', {
				text: 'loading...'
			}).attr({
				'width': this.width,
				'height': this.height
			});
			if (this.canvas.get(0).getContext) {
				this.ctx = this.canvas.get(0).getContext('2d');
			}
		},

		draw: function (idx) {
			var ctx = this.ctx;
			ctx.clearRect(0, 0, this.width, this.height);
			for (i = 0; i < 10; i++) {
				ctx.fillStyle = i > idx ? 'rgba(' + this.rgb + ', 0.25)' : 'rgb(' + this.rgb + ')';
				ctx.fillRect(i * (this.width / 10), 0, (this.width / 10) - 4, this.height);
			}
			return idx < 10 ? idx + 1 : 0;
		},

		start: function () {
			var self = this;
			var idx = 0;
			this.timer = setInterval(function () {
				idx = self.draw(idx);
			}, 100)
		},

		stop: function () {
			clearInterval(this.timer);
		}
	}

	var PicasaService = function (userId, imgMax) {
			this.userId = userId;
			this.imgMax = imgMax || 400;
		};

	PicasaService.prototype = {
		getAlbums: function (fn) {
			var timerId = this.setErrorHandler();
			$.ajax({
				url: 'http://picasaweb.google.com/data/feed/api/user/' + this.userId,
				data: 'alt=json-in-script&max-results=10&thumbsize=128c',
				dataType: 'jsonp',
				success: function (data) {
					clearTimeout(timerId);
					fn(data.feed.entry);
				}
			});
		},

		getPhotos: function (albumId, fn) {
			var timerId = this.setErrorHandler();
			$.ajax({
				url: 'http://picasaweb.google.com/data/feed/api/user/' + this.userId + '/albumid/' + albumId,
				data: 'alt=json-in-script&imgmax=' + this.imgMax + '&thumbsize=200',
				dataType: 'jsonp',
				success: function (data) {
					clearTimeout(timerId);
					fn(data.feed.entry);
				}
			});
		},

		setErrorHandler: function () {
			var timerId = setTimeout(function () {
				clearTimeout(timerId);
				$('#plugin_picasa canvas').hide();
				$('#plugin_picasa').append(
				$('<span>', {
					text: 'Picasa Web Serviceの呼び出しに失敗しました'
				}).css('color', 'red'));
			}, 10000);
			return timerId;
		}
	};
	
	$('<input>').attr({
		'id': 'plugin_picasa_btn',
		'type': 'button',
		'value': 'Get Picasa Web Albums List'
	}).appendTo('#plugin_picasa');

	$('#plugin_picasa_btn').click(function () {
		$('#plugin_picasa').empty();
		var service = new PicasaService($tDiary.plugin.picasa.userId, $tDiary.plugin.picasa.imgMax);
		var loading = new CanvasLoadingImage();
		$('<h3>').append($('<span>', {
			text: 'Picasa Web Album'
		})).appendTo('#plugin_picasa');
		$('#plugin_picasa').css({
			'height': '350px'
		});
		$(loading.canvas).appendTo($('#plugin_picasa'));
		loading.start();
		$('<ul>').css({
			'overflow': 'auto'
		}).attr('id', 'albums').addClass('album').appendTo('#plugin_picasa');
		service.getAlbums(function (albums) {
			$(loading.canvas).hide();
			loading.stop();
			$.each(albums, function (i, album) {
				$('<li>').attr('title', album.title.$t + 'の写真一覧を表示する').css({
					'cursor': 'pointer',
					'list-style': 'none',
					'float': 'left',
					'width': '128px',
					'height': '128px',
					'background-image': 'url(' + album.media$group.media$thumbnail[0].url + ')',
					'margin': '5px',
					'border': 'solid 1px #aaaaaa',
					'overflow': 'hidden'
				}).click(function () {
					$('#plugin_picasa h3 span').css('cursor', 'pointer').attr('title', 'アルバム一覧を表示する').click(function () {
						$('#plugin_picasa h3 span.title').remove();
						$('.photo').remove();
						$('.album').show();
					});
					$('<span>', {
						text: ' > ' + album.title.$t
					}).addClass('title').appendTo('#plugin_picasa h3');
					$('<div>').css({
						'overflow': 'auto',
						'height': '300px'
					}).attr('id', 'photos').addClass('photo').appendTo('#plugin_picasa');
					$('.album').hide();
					$(loading.canvas).show();
					loading.start();
					service.getPhotos(album.gphoto$id.$t, function (photos) {
						$(loading.canvas).hide();
						loading.stop();
						$.each(photos, function (j, photo) {
							$('<img>').click(function () {
								$('#body').insertAtCaret($.makePluginTag('picasa', [photo.content.src, $.trim(photo.summary.$t)]));
							}).attr({
								src: photo.media$group.media$thumbnail[0].url,
								title: $.trim(photo.summary.$t),
								alt: $.trim(photo.summary.$t)
							}).css({
								'cursor': 'pointer',
								'margin': '5px',
								'border': 'solid 1px #aaa'
							}).appendTo('#photos');
						});
					});
				}).append(
				$('<span>', {
					text: album.title.$t
				}).css({
					'display': 'block',
					'text-align': 'center',
					'color': '#fff',
					'background-color': 'rgba(0, 0, 0, 0.5)'
				})).appendTo('#albums');
			});
		});
	});
});
