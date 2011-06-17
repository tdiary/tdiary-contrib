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
 * if you use tdiary-blogkit, set below
 * $tDiary.style = 'blogkit'
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
        button: 'horizontal',
        lang: $('html').attr('lang').substr(0,2)
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
        button: 'button_count',
        locale: $('html').attr('lang').replace('-', '_')
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

  if ($tDiary.style == 'blogkit') { // blogkit
    $('.day').each(function() {
      var link = $(this).children('h2').find('a:first').get(0);
      var url = link ? link.href : document.URL;
      var title = $(this).children('h2').find('.title').text();
      var socialbuttons = $(this).find('.socialbuttons');

      append_buttion(url, title, socialbuttons);
    });
  } else { // diary
    $('.section').each(function() {
      var url = $(this).children('h3').children('a').get(0).href;
      var title = $(this).children('h3').children('a').attr('title');
      var socialbuttons = $(this).find('.socialbuttons');

      append_buttion(url, title, socialbuttons);
    });
  }

  function append_buttion(url, title, socialbuttons) {
    $.each(config.enables, function(i, service) {
      var options = callbacks[service](url, title.replace(/"/g, '&quot;'));
      $.extend(options, config.options[service]);
      $('<div class="socialbutton"></div>')
        .css("float", "left")
        .css("margin-right", "0.5em")
        .appendTo(socialbuttons)
        .socialbutton(service, options);
    });
  }
});
