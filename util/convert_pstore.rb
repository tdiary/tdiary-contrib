#
# convert utf-8 in pstore.
#

def convert_pstore( file )
	require "pstore"

	db = PStore.new( file )
	begin
		roots = db.transaction{ db.roots }
	rescue ArgumentError
		if /\Aundefined class\/module (.+?)(::)?\z/ =~ $!.message
			klass = $1
			if /EmptdiaryString\z/ =~ klass
				eval( "class #{klass} < String; end" )
			else
				eval( "class #{ klass}; end" )
			end
			retry
		end
	end
	db.transaction do
		roots.each do |root|
			convert_element( db[root] )
		end
	end
end

def convert_element( data )
	case data
	when Hash, Array
		data.each_with_index do |e, i|
			if String === e
				data[i] = @conf.migrate_to_utf8( e )
			else
				convert_element( e )
			end
		end
	else
		data.instance_variables.each do |e|
			var = data.instance_variable_get( e )
			if String === var
				data.instance_variable_set( e, @conf.migrate_to_utf8( var ) )
			else
				convert_element( var )
			end
		end
	end
end

convert_pstore(ARGV[0])
