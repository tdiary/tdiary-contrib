# prettify.rb

if /^(latest|day)$/ =~ @mode then
add_header_proc do
  <<-HTML
  <link href="prettify.css" type="text/css" rel="stylesheet" />
  <script type="text/javascript" src="prettify.js"></script>
  <script type="text/javascript"><!--
  function google_prettify(){
    var divs=document.getElementsByTagName("div");
    for(var i=divs.length;i-->0;){
      if(divs[i].className!="body") continue;
      var pres=divs[i].getElementsByTagName("pre");
      for(var j=pres.length;j-->0;){
        pres[j].className="prettyprint";
      }
    }
    prettyPrint();
  }
  if(window.addEventListener){
    window.addEventListener('load',google_prettify,false);
  }else if(window.attachEvent){
    window.attachEvent('onload',google_prettify);
  }else{
    window.onload=google_prettify;
  }
  // --></script>
  HTML
end
end
