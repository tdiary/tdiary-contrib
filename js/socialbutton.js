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

  function socialbutton(target) {
    $('.socialbuttons').css('height', '1em')
    if ($tDiary.blogkit) { // blogkit
      $('.day', target).each(function() {
        var link = $(this).children('h2').find('a:first').get(0);
        var url = link ? link.href : document.URL;
        var title = $(this).children('h2').find('.title').text();
        var socialbuttons = $(this).find('.socialbuttons');

        append_button(url, title, socialbuttons);
      });
    } else { // diary
      $('.section', target).each(function() {
        var url = $(this).children('h3').children('a').get(0).href;
        var title = $(this).children('h3').children('a').attr('title');
        var socialbuttons = $(this).find('.socialbuttons');

        append_button(url, title, socialbuttons);
      });
    }
  }

  function append_button(url, title, socialbuttons) {
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

  // for AutoPagerize
  $(window).bind('AutoPagerize_DOMNodeInserted', function(event) {
    socialbutton(event.target);
  });

  // for AuthPatchWork
  // NOTE: jQuery.bind() cannot handle an event that include a dot charactor.
  // see http://todayspython.blogspot.com/2011/06/autopager-autopagerize.html
  window.addEventListener('AutoPatchWork.DOMNodeInserted', function(event) {
    socialbutton(event.target);
  }, false);

  socialbutton(document);
});
