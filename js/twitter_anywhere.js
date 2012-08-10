/*
 * twitter_anywhere.js : use Twitter@Anywhere
 *
 * Copyright (C) 2012 by tamoot <tamoot+tdiary@gmail.com>
 * You can distribute it under GPL.
 */

$( function() {
   
   // load config from tDiary plugin (twitter_anywhere.rb)
   var config = $tDiary.plugin.twitter_anywhere;

   // hovarcards
   var expand = config.hovercards.expand_default;
   $.each(config.selectors, function(i, css){
      twttr.anywhere(function(twitter) {
         twitter(css).hovercards(expand);
      });
   });

});

// tweet box
function showTweetBox(option) {
   twttr.anywhere(function (T) {
      T("#tweetbox").tweetBox(option);
   });
}
