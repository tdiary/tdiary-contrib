$:.unshift(File.dirname(__FILE__))
require 'spec_helper'
require 'time'

describe "twitter_js plugin" do
	def setup_twitter_js_plugin(mode, user_id)
		fake_plugin(:twitter_js) { |plugin|
			plugin.mode = mode
			plugin.conf['twitter.user'] = user_id
			plugin.date = Time.parse("20080124")
		}
	end

	describe "should render javascript and div tag in day" do
		before do
			@plugin = setup_twitter_js_plugin("day", "123456789")
		end

		it "for header" do
			snippet = @plugin.header_proc
			snippet.should == expected_html_header_snippet("123456789")
		end

		it "for body leave" do
			snippet = @plugin.body_leave_proc(Time.parse("20080124"))
			snippet.should == expected_html_body_snippet
		end
	end

	describe "should render javascript and div tag in latest" do
		before do
			@plugin = setup_twitter_js_plugin("latest", "123456789")
		end

		it "for header" do
			snippet = @plugin.header_proc
			snippet.should == expected_html_header_snippet("123456789")
		end

		it "for body leave" do
			snippet = @plugin.body_leave_proc(Time.parse("20080124"))
			snippet.should == expected_html_body_snippet
		end
	end

	describe "should not render in edit" do
		before do
			@plugin = setup_twitter_js_plugin("edit", "123456789")
		end

		it "for header" do
			snippet = @plugin.header_proc
			snippet.should be_empty
		end

		it "for body leave" do
			snippet = @plugin.body_leave_proc(Time.parse("20080124"))
			snippet.should be_empty
		end
	end

	describe "should not render when user_id is empty" do
		before do
			@plugin = setup_twitter_js_plugin("edit", "")
		end

		it "for header" do
			snippet = @plugin.header_proc
			snippet.should be_empty
		end

		it "for body leave" do
			snippet = @plugin.body_leave_proc(Time.parse("20080124"))
			snippet.should be_empty
		end
	end

	def expected_html_header_snippet(user_id)
		expected = <<-EXPECTED
		<script type="text/javascript"><!--
		function twitter_cb(a){
			var f=function(n){return (n<10?'0':'')+n};
			for(var i=0,l=a.length;i<l;i++){
				var d=new Date(a[i]['created_at'].replace('+0000','UTC'));
				var id='twitter_statuses_'+f(d.getFullYear())+f(d.getMonth()+1)+f(d.getDate());
				var e=document.getElementById(id);
				if(!e) continue;
				if(!e.innerHTML) e.innerHTML='<h3><a href="http://twitter.com/#{user_id}">Twitter statuses</a></h3>';
				e.innerHTML+='<p><strong>'+a[i]['text']+'</strong> ('+f(d.getHours())+':'+f(d.getMinutes())+':'+f(d.getSeconds())+')</p>';
			}
		}
		function twitter_js(){
			var e=document.createElement('script');
			e.type='text/javascript';
			e.src='http://twitter.com/statuses/user_timeline/#{user_id}.json?callback=twitter_cb&amp;count=20';
			document.documentElement.appendChild(e);
		}
		if(window.addEventListener){
			window.addEventListener('load',twitter_js,false);
		}else if(window.attachEvent){
			window.attachEvent('onload',twitter_js);
		}else{
			window.onload=twitter_js;
		}
		// --></script>
		EXPECTED
		expected.gsub(/^\t/, '').chomp
	end

	def expected_html_body_snippet
		expected = <<-HTML
		<div id="twitter_statuses_20080124" class="section"></div>
		HTML
		expected.gsub( /^\t/, '' ).chomp
	end
end
