# prettify.rb

if /\A(?:latest|day|month|nyear)\z/ =~ @mode then
	add_header_proc do
		<<-HTML
		<link href="https://google-code-prettify.googlecode.com/svn/trunk/src/prettify.css" type="text/css" rel="stylesheet">
		<script type="text/javascript" src="https://google-code-prettify.googlecode.com/svn/trunk/src/prettify.js"></script>
		<script type="text/javascript"><!--
			if(window.addEventListener){
				window.addEventListener("load", prettyPrint, false);
			}else if(window.attachEvent){
				window.attachEvent("onload", prettyPrint);
			}else{
				window.onload=prettyPrint;
			}
		// --></script>
		HTML
	end
end
