

var exec = require('cordova/exec');

var LowLatencyAudio = {

	getCapabilities : function( success, fail ) {
		return exec(success, fail || this._emptyError, "LowLatencyAudio", "getCapabilities", []);
	},

	preloadFX: function ( id, assetPath, success, fail) {
		return exec(success || this._emptyCallback, fail || this._emptyError, "LowLatencyAudio", "preloadFX", [id, assetPath]);
	},    

	preloadAudio: function ( id, assetPath, voices, success, fail) {
		return exec(success || this._emptyCallback, fail || this._emptyError, "LowLatencyAudio", "preloadAudio", [id, assetPath, voices]);
	},

	play: function (id, success, fail) {
		return exec(success || this._emptyCallback, fail || this._emptyError, "LowLatencyAudio", "play", [id]);
	},

	stop: function (id, index, success, fail) {
		return exec(success || this._emptyCallback, fail || this._emptyError, "LowLatencyAudio", "stop", [id, index]);
	},

	loop: function (id, success, fail) {
		return exec(success || this._emptyCallback, fail || this._emptyError, "LowLatencyAudio", "loop", [id]);
	},

	unload: function (id, success, fail) {
		return exec(success || this._emptyCallback, fail || this._emptyError, "LowLatencyAudio", "unload", [id]);
	},

	setVolume: function(id, index, volume, success, fail) {
		return exec(success || this._emptyCallback, fail || this._emptyError, "LowLatencyAudio", "setVolume", [id, index, volume]);    
	},

	unpause: function(id, index, success, fail) {
		return exec(success || this._emptyCallback, fail || this._emptyError, "LowLatencyAudio", "unpause", [id, index]);        
	},
	
	pause: function(id, index, success, fail) {
		return exec(success || this._emptyCallback, fail || this._emptyError, "LowLatencyAudio", "pause", [id, index]);        
	},

	getDuration: function(id, success, fail) {
		return exec(success, fail || this._emptyError, "LowLatencyAudio", "getDuration", [id]);    
	},

	getPosition: function(id, index, success, fail) {
		return exec(success, fail || this._emptyError, "LowLatencyAudio", "getPosition", [id, index]);    
	},

	_emptyCallback: function(){},

	_emptyError: function(message){ console.error(message); }

};

module.exports = LowLatencyAudio;
