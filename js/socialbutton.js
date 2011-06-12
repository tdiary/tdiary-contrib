/**
 * socialbutton.js - 
 *
 * Copyright (C) 2011 by MATSUOKA Kohei <kmachu@gmail.com>
 * You can distribute it under GPL.
 */

/**
 * SYNOPSIS
 * 
 * you can set options at socialbutton.rb
 *
 * $tDiary.plugin.socialbutton.enables = 
 *   ['twitter', 'hatena', 'facebook_like', 'evernote'];
 *
 * $tDiary.plugin.socialbutton.options = {
 *    twitter: { via: 'machu' }
 * };
 *
 */

$(function() {
  $('.socialbuttons').css('height', '1em')

  // load config from tDiary plugin (socialbutton.rb)
  var config = $tDiary.plugin.socialbutton;

  // set options for jQuery.socialbutton
  var callbacks = {
    twitter: function(url, title) {
      return {
        url: url,
        text: title,
        button: 'horizontal'
      };
    },

    hatena: function(url, title) {
      return {
        url: url,
        title: title,
        button: 'standard'
      };
    },

    facebook_like: function(url, title) {
      return {
        url: url,
        button: 'button_count'
      };
    },

    evernote: function(url, title) {
      return { 
        url: url,
        title: title,
        button: 'article-clipper-jp'
      };
    }
  };

  $('.section').each(function() {
    var url = $(this).children('h3').children('a').get(0).href;
    var title = $(this).children('h3').children('a').attr('title');
    var socialbuttons = $(this).find('.socialbuttons');
    /*
    var socialbuttons = $('<div class="socialbuttons"></div>')
      .css("float", "right")
      .css("margin-left", "1em")
      .appendTo($(this).find('.tags'));
     */

    $.each(config.enables, function(i, service) {
      var options = callbacks[service](url, title);
      $.extend(options, config.options[service]);
      $('<div class="socialbutton"></div>')
        .css("float", "left")
        .css("margin-right", "0.5em")
        .appendTo(socialbuttons)
        .socialbutton(service, options);
    });
  });
});
