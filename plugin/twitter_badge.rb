#
# twitter_badge.rb: insert 'Follow me' badge of Twitter.
#
# Copyright (C) 2010 TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2.
#

def twitter_badge( account, opt = {} )
	return '' unless account
	@twitter_badge_setting = {
		:account => account,
		:label => (opt[:label] || 'follow-me'),
		:color => (opt[:color] || '#35ccff'),
		:side => (opt[:side] || 'right')[0,1],
		:top => (opt[:top] || 136).to_i,
		:delay => (opt[:delay] || 5).to_i * 1000,
	}
	'' # do nothing in this method.
end

add_footer_proc do
	if @twitter_badge_setting then
		t = @twitter_badge_setting
		<<-TEXT
		<!-- Twitter follow badge by go2web20 -->
		<script src="http://files.go2web20.net/twitterbadge/1.0/badge.js" type="text/javascript" charset="utf-8"></script>
		<script type="text/javascript"><!--
		tfb.account = '#{t[:account]}';
		tfb.label = '#{t[:label]}';
		tfb.color = '#{t[:color]}';
		tfb.side = '#{t[:side]}';
		tfb.top = #{t[:top]};
		setTimeout( tfb.showbadge, #{t[:delay]} );
		//-->
		</script>
		<!-- end of Twitter follow badge -->
		TEXT
	else
		''
	end
end

