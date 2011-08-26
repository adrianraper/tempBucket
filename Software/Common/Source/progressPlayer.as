// v6.4.3 Since any movies published for different Flash players will not share the same
//_global space, I need to pass this object through to them.
if (_global.ORCHID == undefined) {
	_global.ORCHID = this._parent.sharedGlobal;
} 
this.depth=0;
this.margin=0;

this.sendData = function(myXML, everyoneXML) {
	myTrace("progressPlayer.sendData everyoneXML=" + everyoneXML);
	this.testing.text = everyoneXML;
}
