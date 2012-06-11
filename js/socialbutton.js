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
    },
    
    google_plusone: function(url, title) {
      return {
        href: url,
        size: 'medium',
        lang: $('html').attr('lang')
      };
    },

    pinterest: function(url, title) {
      return { 
        url: url,
		  media: $('p img:first', $('div.section h3 a[name=' + url.substr(-3) + ']').parent().parent()).attr('src'),
        description: title,
        button: 'horizontal',
      };
    },
    
  };

  function socialbutton(target) {
    $('.socialbuttons').css('height', '1em')
    var bottom = $(window).height() + $(window).scrollTop();

    $($tDiary.blogkit ? '.day' : '.section')
      .filter(function() {
        return bottom > $(this).offset().top;
      })
      .filter(function() {
        return $(this).find('.socialbutton').size() == 0
      })
      .each(function() {
        if ($tDiary.blogkit) {
          var link = $(this).children('h2').find('a:first').get(0);
          var url = link ? link.href : document.URL;
          var title = $(this).children('h2').find('.title').text();
        } else {
          var url = $(this).children('h3').children('a').get(0).href;
          var title = $(this).children('h3').children('a').attr('title');
        }
        if (url && title) {
          // console.debug('loading socialbutton: ' + title);
          var socialbuttons = $(this).find('.socialbuttons');
          append_button(url, title, socialbuttons);
        }
      });
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

  $(window).bind('scroll', function(event) {
    socialbutton(document);
  });

  socialbutton(document);
});
