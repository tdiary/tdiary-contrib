/**
 * History.Routing
 *
 * @version		2.0
 *
 * @license		MIT License
 * @author		Harald Kirschner <mail [at] digitarald.de>
 * @copyright	2008 Author
 */

History.implement(new Options());

History.implement({

	options: {
		separator: ';'
	},

	routes: [],

	register: function(route) {
		if (this.routes.push(route) == 1) this.addEvent('changed', this.match);
	},

	unregister: function(route) {
		this.routes.remove(route);
	},

	match: function(state, previous, manual) {
		if (!manual) this.routes.each(Function.methodize('match', this.state));
	},

	generate: function() {
		return this.routes.map(Function.methodize('generate')).clean().join(this.options.separator);
	},

	update: function() {
		return this.setState(this.generate());
	}

});

History.Route = new Class({

	Implements: [Events, Options],

	/**
	 * pattern:				Regular expression that matches the string updated from onGenerate
	 * defaults:			Default values array, initially empty.
	 * flags:				When regexp is a String, this is the second argument for new RegExp.
	 * skipDefaults:		default true; generate is not called when current values are similar to the default values.
	 * generate:			Should return the string for the state string, values are first argument
	 * onMatch:				Will be called when the regexp matches, with the new values as argument.
	 */
	options: {
		skipDefaults: true,
		defaults: [],
		pattern: null,
		flags: '',
		generate: function(values) {
			return values[0];
		},
		onMatch: $empty
	},

	initialize: function(options){
		this.setOptions(options);
		this.pattern = this.options.pattern || '(.*)';
		if ($type(this.pattern) == 'string') this.pattern = new RegExp(this.pattern, this.options.flags);
		this.values = this.defaults = this.options.defaults.slice();
		History.register(this);
		return this;
	},

	setValues: function(values) {
		if (this.values.toString() == values.toString()) return this;
		this.values = values;
		History.update();
		return this;
	},

	setValue: function(index, value) {
		if (this.values[index] == value) return this;
		this.values[index] = value;
		History.update();
		return this;
	},

	build: function(values) {
		var tmp = this.values.slice();
		this.values = values;
		var state = History.generate();
		this.values = tmp;
		return state;
	},

	destroy: function() {
		History.unregister(this);
	},

	generate: function() {
		if (this.options.skipDefaultMatch && (String(this.values) == String(this.defaults))) return null;
		return this.options.generate.call(this, this.values);
	},

	match: function(state) {
		var bits = state.match(this.pattern);
		var defaults = this.defaults;
		if (bits) {
			bits.splice(0, 1);
			for (var i = 0, j = bits.length; i < j; i++) bits[i] = $pick(bits[i], defaults[i] || null);
			if (String(bits) != String(defaults)) this.values = bits;
		} else {
			this.values = this.defaults.slice();
		}
		this.fireEvent('onMatch', [this.values, this.defaults]);
	}

});

Function.methodize = function(name) {
	var args = Array.slice(arguments, 1);
	return function(obj) {
		return obj[name].apply(obj, args);
	};
};
