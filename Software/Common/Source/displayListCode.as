// This is a Yiu hack for loading an AS2 class into an AS1 program

// common code for each AP module to report back to loading controller
#include "D:/Projectbench/myTrace.as"
// Required for big numbers
#include "src/js/bigint.js"

var displayListNS	= new Object();
displayListNS.moduleName  = "displayListModule";
displayListNS.depth = 1; 

_parent.controlNS.remoteOnData(displayListNS.moduleName, true);
//myTrace("displayList loading");
_global.myTrace = myTrace;

// Clas creation and linking
import src.DisplayList;

displayListNS.checkDisplay = function(message:String, checkDisplay:String):Boolean{
	//myTrace("_global.ORCHID.root.displayListHolder.mont_=" + _global.ORCHID.root.displayListHolder.mont_);
	//myTrace("displayListCode.checkDisplay");
	var displayList:DisplayList;
	displayList = new DisplayList();
	//myTrace("displayListCode.call to createLeafs");
	displayList.createLeafs();
	//myTrace("displayListCode.call to checkDisplay");
	return displayList.checkDisplay(message, checkDisplay);
}

stop();

