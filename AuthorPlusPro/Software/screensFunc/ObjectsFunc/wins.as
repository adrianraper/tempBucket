var nWindowWidth:Number	= 758;
//var nWindowHeight:Number = 504;
var nWindowHeight:Number = 640;

// window
/* it's found that the complete event is broadcasted
   before the MC is fully loaded in a window
   (no idea on how much has been loaded!)
   so it's useless to do it with a complete event listener!
*/
/*wins.complete = function(evtObj:Object) : Void {
	NNW.screens.onScreenLoaded(evtObj.target.content);
}*/

wins.setTitle = function(n:String, s:String) : Void {
	this[n].title = s;
}

wins.centerToScreen = function() : Void {
	var w:Array = new Array("winExType", "winPopup", "winSettings", "winEmail", "winBrowse", "winFeedback");
	for (var i in w) {
		this[w[i]]._x = (nWindowWidth - this[w[i]]._width) / 2;
		this[w[i]]._y = (nWindowHeight - this[w[i]]._height) / 2;
	}
}

