$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "..", "plugin")))
require 'erb'

# FIXME PluginFake in under construction.
class PluginFake
	include ERB::Util

	attr_reader :conf
	attr_accessor :mode

	def initialize
		@conf = {}
		@mode = ""
		@header_procs = []
	end

	def add_conf_proc( key, label, genre=nil, &block )
		# XXX Do we need to verify add_* called??
	end

	def add_header_proc( block = Proc::new )
		@header_procs << block
	end

	def header_proc
		r = []
		@header_procs.each do |proc|
			r << proc.call
		end
		r.join.chomp
	end

end
def fake_plugin( name_sym, base=nil, &block )
	plugin = PluginFake.new
	yield plugin if block_given?

	file_path = plugin_path( name_sym, base )
	plugin_name = File.basename( file_path, ".rb" )

	plugin.instance_eval do
		eval( File.read( file_path ), binding,
			"(#{File.basename(file_path)})", 1 )
	end
	plugin_sym = plugin_name.to_sym
	if plugin.class.private_method_defined?( plugin_sym )
		plugin.__send__( :public, plugin_sym )
	end

	plugin
end

def plugin_path( plugin_sym, base=nil )
	paths = []
	paths << ( base ? base : "plugin" )
	paths << "#{plugin_sym.to_s}.rb"
	File.expand_path( File.join( paths ))
end
