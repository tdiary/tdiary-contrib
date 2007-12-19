# twitter_js.rb $Revision: 1.1 $
# Copyright (C) 2007 Michitaka Ohno <elpeo@mars.dti.ne.jp>
# You can redistribute it and/or modify it under GPL2.

@twitter_user = '' # <= Your Username.

if /^(latest|day)$/ =~ @mode then
	add_header_proc do
		<<-HTML
		<script type="text/javascript"><!--
		function twitter_cb(a){
			var f=function(n){return (n<10?"0":"")+n};
			for(var i=0;i<a.length;i++){
				var d=new Date(a[i]['created_at'].replace('+0000','UTC'));
				var id="twitter_statuses_"+f(d.getFullYear())+f(d.getMonth()+1)+f(d.getDate());
				var e=document.getElementById(id);
				if(!e) continue;
				if(!e.innerHTML) e.innerHTML='<h3><a href="http://twitter.com/#{@twitter_user}">Twitter statuses</a></h3>';
				e.innerHTML+='<p><strong>'+a[i]['text']+'</strong> ('+f(d.getHours())+':'+f(d.getMinutes())+':'+f(d.getSeconds())+')</p>';
			}
		}
		function twitter_js(){
			var e=document.createElement("script");
			e.type="text/javascript";
			e.src="http://twitter.com/statuses/user_timeline/#{@twitter_user}.json?callback=twitter_cb&amp;count=20";
			document.body.appendChild(e);
		}
		if(window.addEventListener){
			window.addEventListener('load',twitter_js,false);
		}else if(window.attachEvent){
			window.attachEvent('onload',twitter_js);
		}else{
			window.onload=twitter_js;
		}
		// --></script>
		HTML
	end

	add_body_leave_proc do |date|
		<<-HTML
		<div id="twitter_statuses_#{date.strftime( "%Y%m%d" )}" class="section"></div>
		HTML
	end
end

