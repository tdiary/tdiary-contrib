/**
 * editor.js - support writing using wiki/gfm notation.
 *
 * Copyright (C) 2012 by MATSUOKA Kohei <kmachu@gmail.com>
 * You can distribute it under GPL.
 */

/*
	utility functions
 */
$.fn.extend({
	insertAtCaret2: function(beforeText, afterText){
		var elem = this.get(0);
		elem.focus();

		if(jQuery.browser.msie){
      this.insertAtCaret(beforeText + afterText);
		}else{
			var orig = elem.value;
			var posStart = elem.selectionStart;
			var posEnd = posStart + beforeText.length;
			elem.value = orig.substr(0, posStart) + beforeText + afterText + orig.substr(posStart);
			elem.setSelectionRange(posEnd, posEnd);
		}
	}
});

$(function() {
  var form = $("textarea");
  var targetArea = $("div.update > div.form").first();
  var notations = {
    wiki: {
      h3: function(){ form.insertAtCaret("! ") },
      h4: function(){ form.insertAtCaret("!! ") },
      a: function(){ form.insertAtCaret2("", "[[|]]") },
      em: function(){ form.insertAtCaret2("''", "''") },
      strong: function(){ form.insertAtCaret2("'''", "'''") },
      del: function(){ form.insertAtCaret2("==", "=='") },
      pre: function(){ form.insertAtCaret2("\n<<<\n", "\n>>>\n") },
      bq: function(){ form.insertAtCaret("\"\" ") },
      ul: function(){ form.insertAtCaret("* ") },
      ol: function(){ form.insertAtCaret("# ") },
      table: function(){ form.insertAtCaret(
        "\n||body1||body2\n||body3||body4\n") },
      plugin: function(){ form.insertAtCaret2(
        "", $.makePluginTag("plugin_name")) }
    },

    gfm: {
      h3: function(){ form.insertAtCaret("# ") },
      h4: function(){ form.insertAtCaret("## ") },
      a: function(){ form.insertAtCaret2("", "[]()") },
      em: function(){ form.insertAtCaret2("*", "*") },
      strong: function(){ form.insertAtCaret2("**", "**") },
      pre: function(){ form.insertAtCaret2("\n```\n", "\n```\n") },
      code: function(){ form.insertAtCaret2("`", "`") },
      bq: function(){ form.insertAtCaret("> ") },
      ul: function(){ form.insertAtCaret("* ") },
      ol: function(){ form.insertAtCaret("1. ") },
      table: function(){ form.insertAtCaret(
        "\nhead1|head2\n---------\nbody1|body2\nbody3|body4\n") },
      plugin: function(){ form.insertAtCaret2(
        "", $.makePluginTag("plugin_name")) }
    }
  };

  var toolbox = $("<ul></ul>");
  $.each(notations[$tDiary.style], function(key, callback) {
    var button = $("<button>")
      .attr("type", "button")
      .attr("name", key)
      .css("margin", "3px")
      .css("padding", "5px")
      .append(key)
      .click(callback);
    $("<li></li>")
      .css("display", "inline")
      .append(button)
      .appendTo(toolbox);
  });
  form.before(toolbox);
});
