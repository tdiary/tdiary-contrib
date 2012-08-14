/*
 * datepicker.js : datepicker using jQuery-UI
 * http://jqueryui.com/demos/datepicker/
 *
 * Copyright (C) 2012 by tamoot <tamoot+tdiary@gmail.com>
 * You can redistribute it and/or modify it under GPL.
*/


$( function() {
   
   function setDateText(date) {
      var dates = date.split("/");
      $("#year" ).val(dates[0]);
      $("#month").val(dates[1]);
      $("#day"  ).val(dates[2]);
   }
   
   function dateTextFromField() {
      var y = parseInt( $("#year" ).val() );
      var m = parseInt( $("#month").val() );
      var d = parseInt( $("#day"  ).val() );
      if( y > 0 && 13 > m && m > 0 && 32 > d && d > 0 ){
         $("#datepicker-input").val(y + "/" + m + "/" + d);
      }
   }
   
   var datepicker_dom = $("<span>");
   
   var datepicker_trigger = $("<span>")
      .addClass("ui-icon")
      .addClass("ui-icon-calendar")
      .addClass("datepicker-trigger");
   
   var datepicker_input = $("<input>", {
         id:    "datepicker-input",
         name:  "datepicker",
         style: "display: none;",
         type:  "text"
      }
   );
   
   datepicker_dom.append(datepicker_input);
   datepicker_dom.append(datepicker_trigger);
   datepicker_dom.insertAfter("span.day");
   
   $("#datepicker-input").datepicker({
      onSelect: function(dateText, inst){
         setDateText(dateText);
      },
      beforeShow: function(input ,inst){
         dateTextFromField();
      },
      dateFormat: "yy/m/d"
   });
   
   $(".datepicker-trigger").click(function() {
      $("#datepicker-input").datepicker("show");
   });
   
   
   var icon = $(".ui-icon-calendar");
   icon.css({"display":"inline","position":"absolute","margin-top":"5px"});
   icon.after($("<span></span>").css({"margin-left":"16px"}));
   icon.hover(function(){
      $(this).css({"cursor":"pointer"});
   });
});

