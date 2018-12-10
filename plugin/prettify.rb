# prettify.rb

if /\A(?:latest|day|month|nyear)\z/ =~ @mode then
	add_header_proc do
		<<-HTML
		<script type="text/javascript" src="https://cdn.jsdelivr.net/gh/google/code-prettify/loader/run_prettify.js"></script>
		<script type="text/javascript"><!--
			var initPrettyPrint = function() {
				var pres = document.querySelectorAll("div.body > div.section > pre");
				Array.prototype.slice.call(pres).forEach(function(pre) {
					pre.setAttribute("class", "prettyprint");
				});
				PR.prettyPrint();
			};
			if(window.addEventListener){
				window.addEventListener("load", initPrettyPrint, false);
			}else if(window.attachEvent){
				window.attachEvent("onload", initPrettyPrint);
			}else{
				window.onload=initPrettyPrint;
			}
		// --></script>
		HTML
	end
end
