/**
 * History
 *
 * @version		1.0
 *
 * @license		MIT License
 * @author		Harald Kirschner <mail [at] digitarald.de>
 * @copyright	2008 Author
 */

var History = $extend(history, {

	implement: function(obj) {
		return $extend(this, obj);
	}

});

History.implement(new Events($empty));

History.implement({

	state: null,

	start: function() {
		if (this.started) return this;
		this.state = this.getHash();
		if (Browser.Engine.trident) {
			var iframe = new Element('iframe', {
				'src': "javascript:'<html></html>'",
				'styles': {
					'position': 'absolute',
					'top': '-1000px'
				}
			}).inject(document.body).contentWindow;
			var writeState = function(state) {
				iframe.document.write('<html><body onload="top.History.$listener(\'', encodeURIComponent(state) ,'\');">Moo!</body></html>');
				iframe.document.close();
			};
			$extend(this, {
				'$listener': function(state) {
					state = decodeURIComponent(state);
					if (this.state != state) this.setHash(state).changeState(state);
				}.bind(this),
				'setState': function(state, force) {
					if (this.state != state || force) {
						if (!force) this.setHash(state).changeState(state, true);
						writeState(state);
					}
					return this;
				},
				'trace': function() {
					var state = this.getHash();
					if (state != this.state) writeState(state);
				}
			});
			var check = (function() {
				if (iframe.document && iframe.document.body) {
					check = $clear(check);
					if (!iframe.document.body.innerHTML) this.setState(this.state);
				}
			}).periodical(50, this);
		} else {
			if (Browser.Engine.presto915) {
				new Element('img', {
					'src': "javascript:location.href='javascript:History.trace();';",
					'styles': {
						'position': 'absolute',
						'top': '-1000px'
					}
				}).inject(document.body);
			}
		}
		this.trace.periodical(150, this);
		this.started = true;
		return this;
	},

	changeState: function(state, manual) {
		var stateOld = this.state;
		this.state = state;
		this.fireEvent('changed', [state, stateOld, manual]);
	},

	trace: function() {
		var state = this.getHash();
		if (state != this.state) this.changeState(state);
	},

	getHash: function() {
		var href = location.href, pos = href.indexOf('#') + 1;
		return (pos) ? href.substr(pos) : '';
	},

	setHash: function(state) {
		location.hash = '#' + state;
		return this;
	},

	setState: function(state) {
		if (this.state !== state) this.setHash(state).changeState(state, true);
		return this;
	},

	getState: function() {
		return this.state;
	}

});
