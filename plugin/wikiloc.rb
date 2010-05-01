#
# wikiloc.rb: plugin embedding trip map on wikiloc.
#
# Copyright (C) 2008 MUNEDA Takahiro <mux03@panda64.net>
# You can redistribute it and/or modify it under GPL2.
#
# derived from everytrail.rb, Copyright (C) 2008 TADA Tadashi <sho@spc.gr.jp>
#
# Parameters:
#  @trip_id  : your trip id
#  @measures : on/off
#  @maptype  : M/S/H/T
#  @size     : [width,height]
#
#  Please see the following address about the details:
#   http://www.wikiloc.com/forum/posts/list/14.page
#
# ChangeLog:
#	20080706: Initial release
#	20080713: Change default parameters
#
def wikiloc( trip_id, measures = "off", maptype = "M", size = [500,400] )
	size.collect! {|i| i.to_i }
	size[0] = 500 if size[0] == 0
	size[1] = 400 if size[1] == 0
	%Q|<iframe frameBorder="0" src="http://www.wikiloc.com/wikiloc/spatialArtifacts.do?event=view&amp;id=#{h trip_id}&amp;measures=#{h measures}&amp;title=on&amp;near=on&amp;images=on&amp;maptype=#{maptype}" width="#{size[0]}px" height="#{size[1]}px"></iframe>|
end
