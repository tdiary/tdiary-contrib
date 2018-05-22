#
# everytrail.rb: everytrail plugin is obsoleted
#
def everytrail_obsoleted(label = nil)
	if label
		"<div>(EveryTrail is obsoleted. [#{h label}])</div>"
	else
		"<div>(EveryTrail is obsoleted.)</div>"
	end
end

def everytrail( trip_id, label = nil, size = [400, 300] )
	everytrail_obsoleted(label)
end

def everytrail_flash( trip_id, label = nil, size = [400, 300] )
	everytrail_obsoleted(label)
end

def everytrail_widget( trip_id, latitude = nil, longtitude = nil, label = nil, size = [400, 300] )
	everytrail_obsoleted()
end

