
// trees
// v6.4.3 Take out old editing functions as now built into dnd tree
/*
trees.cellEdit = function(evtObj:Object) : Void {
}
// v0.8.1, DL: event listeners for cellEditor in dataGrids
trees.keyDown = function(evtObj:Object) : Void {
	var tree = evtObj.target;
	if (Key.isDown(Key.ESCAPE)) {
		_global.myTrace("ESC down");
	}
}
trees.enter = function(evtObj:Object) : Void {
	var tree = evtObj.target;
}

// for drag & drop on dataGrids for items reordering by user 
// create dragname
if (_root.dragname==undefined) {
	_root.attachMovie("dragname", "dragname", _root.getNextHighestDepth());
	_root.dragname._visible = false;
}
trees.dragRow = new Object();
trees.cellPress = function(evtObj:Object) : Void {
	var thisIndex = evtObj.itemIndex;
	var thisItem = evtObj.target.getItemAt(thisIndex);
	this.dragRow.index = thisIndex;
	this.dragRow.exUnit = this.getSelectedIndex("Unit");
	this.dragRow.parent = evtObj.target._name;
	if (thisItem.label!=undefined && this.Item.label!="") {
		// clicked on item list
		NNW.control.onSingleClickingItemOnList(evtObj.target);
		// show dragname
		if (evtObj.target._name!="treeOption") {	// v0.14.0, DL: don't show dragname for options
			_root.dragname.gotoAndStop(1);
			_root.dragname.setLabel(thisItem.label);
			_root.dragname._visible = true;
		}
	} else {
		this.dragRow.index = -1;
	}
}
*/
trees.change=  function(evtObj:Object) {
	var tree = evtObj.target;
	var thisIndex = tree.selectedIndex;
	var thisItem = tree.selectedNode;
	// v6.4.3 make sure that you don't have any preset next events. I just don't understand how addCourseShowMenu is set here!
	//thisItem.attributes.nextEvent = undefined;
	
	_global.myTrace("click on tree index " + thisIndex + " next event=" + tree.nextEvent);	

	// v6.4.3 Based on what you click on, we will make changes to dnd tree functions
	if (tree.getIsBranch(thisItem)) {
		//_global.myTrace("paste into as this is a branch");
		tree.addLeafPastePosition = tree.PASTE_INTO;
		tree.addBranchPastePosition = tree.PASTE_INTO;
		// v6.5.1 Yiu disable right click menu
		tree.cm.customItems[2].caption = "";
		//tree.cm.customItems[2].caption = "Delete this folder";
		// End v6.5.1 Yiu disable right click menu
	} else { 
		tree.addLeafPastePosition = tree.PASTE_AFTER;
		tree.addBranchPastePosition = tree.PASTE_AFTER;
		// v6.5.1 Yiu disable right click menu
		tree.cm.customItems[2].caption = "";
		//tree.cm.customItems[2].caption = "Delete this course";
		// End v6.5.1 Yiu disable right click menu
	}
	//var thisItem = tree.getItemAt(thisIndex);

	// v6.4.3 We want to open/close branches if you click on them. This works, but maybe a double click is better.
	//if (evtObj.target.getIsOpen(evtObj.target.selectedNode)) {
	//	// it is open, so close it
	//	evtObj.target.setIsOpen(evtObj.target.selectedNode, false, true);
	//} else {
	//	// it is closed, so open it
	//	evtObj.target.setIsOpen(evtObj.target.selectedNode, true, true);
	//}

	/*
	tree.editable = false;
	
	// it's a drag & drop motion
	var dragIndex = this.dragRow.index;
	if (this.treeUnit.hitTest(_root._xmouse, _root._ymouse, false) && this.dragRow.parent=="treeExercise" && tree._name=="treeExercise") {
		var targetIndex = this.dragRow.targetIndex;
		if (targetIndex>=0 && targetIndex<this.treeUnit.length) {
			NNW.control.moveExerciseToUnit(dragIndex, this.dragRow.exUnit, targetIndex);
		}
		
	} else if (dragIndex!=thisIndex) {
		if (dragIndex!=-1) {
			switch (tree._name) {
			case "treeCourse" :
				if (this.dragRow.parent=="treeCourse") {
					NNW.control.moveCourse(dragIndex, thisIndex);
				}
				break;
			}
		}
		this.firstClick = undefined;
	// it's a click 
	} else {
	*/
	// v6.4.3 Take out old functions as now built into dnd tree
	/*
		// it's a double click
		if (getTimer() - this.firstClick < 500 && thisIndex==this.clickIndex) {
			//_global.myTrace("dbl click on tree item");
			//NNW.control.onDoubleClickingItemOnList(tree);
			NNW.control.onDoubleClickingOnTree(thisItem);
		// it's a single click
		} else {
			// v0.5.2, DL: debug - moved to cellPress
			//NNW.control.onSingleClickingItemOnList(tree);
		}
	//}
	this.firstClick = getTimer();
	this.clickIndex = thisIndex;
	// hide dragname
	_root.dragname.gotoAndStop(1);
	_root.dragname.setLabel("");
	_root.dragname._visible = false;
	*/
}

// v6.4.3 Add events from dnd tree
trees.doubleClick = function(evtObj:Object) : Void {
	var thisTree = evtObj.target;
	var thisItem = thisTree.selectedNode;
	//_global.myTrace("double click on " + thisItem);
	// v6.4.3 We want to open/close branches if you click on them. This works, but maybe a double click is better.
	if (thisTree.getIsBranch(thisItem)) {
		if (thisTree.getIsOpen(thisItem)) {
			// it is open, so close it
			thisTree.setIsOpen(thisItem, false, true);
		} else {
			// it is closed, so open it
			thisTree.setIsOpen(thisItem, true, true);
		}
	} else {
		NNW.control.onDoubleClickingOnTree(thisItem);	
	}
}
// v6.4.3 Just use to get information about which node we are on. Not enabled from screens. addEventListener at the moment as no need.
trees.singleClick = function(evtObj:Object) : Void {
	var thisTree = evtObj.target;
	//_global.myTrace("single click on selectedIndex=" + thisTree.selectedIndex + " absRowIndex="+evtObj.absRowIndex + " rowIndex="+evtObj.rowIndex);
}

trees.drop = function(evtObj:Object) : Void {
	var thisTree = evtObj.target;
	_global.myTrace("on tree drop with " + thisTree.selectedNodes);
	NNW.control.moveCourse();
}
trees.addBranchNode = function(evtObj:Object) : Void {
	var thisTree = evtObj.target;
	_global.myTrace("on tree add folder with " + thisTree.selectedNode);
	thisTree.setIsBranch(thisTree.selectedNode, true)
	//NNW.control.moveCourse();
}
// We really need to catch this before dnd tree does it and use our own method
// See the example "permissions" in the dnd examples folder to see how they 'overload' a function to do some preprocessing
// that might help.
// I am triggering this function correctly for context menu clicks, but not for direct calls to the addLeafNode method.
// That is because if you call from a button or something you are actually pasting the default node in. So need to duplicate
// this code in pasteNode
trees.addLeafNode = function(evtObj:Object) : Void {
	var thisTree = evtObj.target;
	_global.myTrace("on tree add course at " + thisTree.selectedIndex + ":" + thisTree.selectedNode);
	// This will have added the node to the tree with id='0'. The node will be currently selected, so if
	// we call the control.addCourse function now, we can tell it which node to set the id for once it has done
	// it's stuff. Use the add course method for once we know that the course xml hasn't been updated by another.
	NNW.control.addCourse();
	
	// Once you have come out of rename, you ideally want to go directly into the course.
	// Try putting the nextEvent onto the node - not a good idea as it ends up written to the XML
	//thisTree.selectedNode.attributes.nextEvent = "addCourseShowMenu";
	// try the tree itself
	thisTree.nextEvent = "addCourseShowMenu";
	
	// automatically open the node rename functions. This isn't quite right, but sort of works
	// thisTree.showRenameNode(thisTree.selectedIndex);
	// Need to get the new node nicely displayed before going into rename 
	// Always move down one so that if you are off the bottom it will show. Makes it not quite perfect at the top, but it is OK.
	thisTree.vPosition++;
	thisTree.refresh();
	this.renameSelectedNode("Course");
	//NNW.control.addCourse();
}
// v6.4.3 This comes from calling addLeafNode function from an external object. Forward it to the same method
// that the menu function comes to.
trees.pasteNode = function(evtObj:Object) : Void {
	//_global.myTrace("pasteNode to " + evtObj.target.selectedItem.attributes.name);
	// I want to first make the selected node current and open and visible, then make sure that I am going to insert inside it.
	// If nothing is selected I want to put at the very end if possible
	this.addLeafNode(evtObj);
	//var thisTree = evtObj.target;
	//_global.myTrace("on tree paste course at " + thisTree.selectedIndex + ":" + thisTree.selectedNode);
	// automatically open the node rename functions. This isn't quite right, but sort of works
	// thisTree.showRenameNode(thisTree.selectedIndex);
	// Try to get the new node nicely displayed before going into rename 
	//thisTree.refresh();
	//this.renameSelectedNode("Course");
	//NNW.control.addCourse();
}
trees.renameNode= function(evtObj:Object) : Void {
	var thisTree = evtObj.target;
	_global.myTrace("The renamed node="+evtObj.node.attributes.name + ", next event " + thisTree.nextEvent);
	if (evtObj.node.attributes.id == undefined) {
		NNW.control.renameCourseFolder();
	} else {
		
		// First thing is to make this the currentCourse
		NNW.control.data.setCurrentCourse(evtObj.node.attributes.id);
		
		// Then I want to rename it in the model
		NNW.control.renameCourse(evtObj.node.attributes.name);

		// Finally save the changed course object
		// v6.4.3 If we added a next event to the tree, use and clear it
		//var nextEvent = evtObj.node.attributes.nextEvent;
		var nextEvent = thisTree.nextEvent;
		NNW.control.saveCourse(nextEvent);
		//evtObj.node.attributes.nextEvent = undefined;
		thisTree.nextEvent = undefined;
	}
}
trees.renameSelectedNode = function(treeName:String):Void {
	var tree = this["tree"+treeName];
	//_global.myTrace("rSN.next event=" + tree.nextEvent);
	// We have to calculate the node index as it refers to the relative one, not absolute.
	//_global.myTrace("renameSelectedNode selectedIndex=" + tree.selectedIndex + " vPosition=" + tree.vPosition);
	var thisIndex = tree.selectedIndex - tree.vPosition;
	//tree.showRenameNode(tree.selectedIndex);
	tree.showRenameNode(thisIndex);
}

// This will update the currently selected node to have a new ID
trees.setSelectedID = function(treeName:String, newID:String) : Void {
	var tree = this["tree"+treeName];
	_global.myTrace("setSelectedID to " + newID);
	tree.selectedNode.attributes.id = newID;
}
trees.getSelectedID = function(treeName:String) : String {
	var tree = this["tree"+treeName];
	// v6.4.3
	//return tree.selectedNode.id;
	return tree.selectedNode.attributes.id;
}
trees.getSelectedLabel = function(treeName:String) : String {
	var tree = this["tree"+treeName];
	// v6.4.3
	//return tree.selectedINode.label;
	return tree.selectedINode.attributes.label;
}
trees.getItemByIndex = function(treeName:String, index:Number) : Object {
	var tree = this["tree"+treeName];
	return tree.getTreeNodeAt(index);
}

trees.clearList = function(treeName:String) : Void {
	var tree = this["tree"+treeName];
	//_global.myTrace("trees.clearList from " + tree);
	tree.removeAll();
	//_global.myTrace("trees.item0=" + tree.getTreeNodeAt(0));
}
// v6.4.3 Don't think this is used anymore
trees.addItemToList = function(treeName:String, item:Object) : Void {
	var tree = this["tree"+treeName];
	if (item!=undefined) {
		//var itemXML = new XML('<course name="' + item.name + '" id="'+ item.id + '" />');
		var itemXML = new XML("<course name='" + item.name + "' id='"+ item.id + "' />");
		//tree.addTreeNode(item);
		//_global.myTrace("trees.addTreeNode " + itemXML.toString());
		//_global.myTrace("tree=" + tree);
		//_global.myTrace("trees.dp " + tree.getDataProvider().toString());
		//_global.myTrace("trees.addTreeNode " + tree.addTreeNode(itemXML.firstChild).toString());
		tree.addTreeNode(itemXML.firstChild);
		
		// You might be able to add to a selected node with addTreeNodeAt
		//tree.addTreeNodeAt(1,itemXML.firstChild);
	}
	//_global.myTrace("trees.item0=" + tree.getTreeNodeAt(0));
}
// v6.4.3 Don't think this is used anymore
trees.promptForNewItem = function(treeName:String) : Void {
	var tree = this["tree"+treeName];
	tree.selectedIndex = tree.length - 1;
	this.renameSelectedItem(treeName);
}
// v6.4.3 Don't think this is used anymore
trees.renameSelectedItem = function(treeName:String) : Void {
	var tree = this["tree"+treeName];
	var index = tree.selectedIndex;
	if (index!=undefined && tree.length>0) {
		// v6.4.3
		// Put an edit box over the tree item for renaming.
		// But for now just pretend we have done it
		NNW.control.onFinishRename(tree, index);
	}
}

// v6.4.3 Since a node might be more than one group, need better checking before doing this.
// This is called from control. Need to stop it being called from right click, which must go through control.
trees.removeSelectedItem = function(treeName:String) : Void {
	var tree = this["tree"+treeName];
	var index = tree.selectedIndex;
	//_global.myTrace("trees.removeSelectedItem("+index+") " + tree.selectedNode.toString());
	// v6.4.3 I don't fully understand the difference between methods on the dp and the tree itself
	// but after much experimenting, this works.
	var rc = tree.selectedNode.removeTreeNode();
	//_global.myTrace("trees.removedSelectedItem " + rc.toString());
}
// v6.4.3 Function added triggered by event listener for menu right click
trees.cutNode= function(evtObj:Object) : Void {
	var thisTree = evtObj.target;
	_global.myTrace("trees.cutNode="+evtObj.node.attributes.name);
}

// v6.4.3 Don't think this is used anymore
trees.moveUpSelectedItem = function(treeName:String) : Void {
	this.moveSelectedItem(treeName, "up");
}

// v6.4.3 Don't think this is used anymore
trees.moveDownSelectedItem = function(treeName:String) : Void {
	this.moveSelectedItem(treeName, "down");
}

// v6.4.3 Don't think this is used anymore
trees.moveSelectedItem = function(treeName:String, dir:String) : Void {
	var tree = this["tree"+treeName];
	var index = tree.selectedIndex;
	if (index!=undefined && tree.length>0) {
		var newIndex = (dir=="up") ? index - 1 : index + 1;
		if ((dir == "up" && index > 0) || (dir == "down" && index < tree.length - 1)) {
			var t = this.getItemByIndex(treeName, newIndex);
			tree.replaceItemAt(newIndex, {label:tree.selectedItem.label, id:tree.selectedItem.id, unit:tree.selectedItem.unit});
			tree.replaceItemAt(index, {label:t.label, id:t.id, unit:t.unit});
			tree.selectedIndex = newIndex;
		}
	}
}

trees.setSelectedItem = function(treeName:String, n:Number) : Void {
	var tree = this["tree"+treeName];
	tree.selectedIndex = n;
}

trees.getSelectedIndex = function(treeName:String) : Number {
	var tree = this["tree"+treeName];
	return tree.selectedIndex;
}

trees.setSelectedItemByField = function(treeName:String, f:String, v:String) : Void {
	var tree = this["tree"+treeName];
	for (var i=0; i<tree.length; i++) {
		var item = tree.getTreeNodeAt(i);
		if (item[f]==v) {
			tree.selectedIndex = i;
		}
	}
}

// v6.4.3 Get/Set the data provider
trees.setDataProvider = function(treeName:String, dp:XML) : Void {
	myTrace("set the data provider for the tree");
	var tree = this["tree"+treeName];
	tree.dataProvider = dp;
}
trees.getDataProvider = function(treeName:String) : XML {
	myTrace("get the data provider for the tree");
	var tree = this["tree"+treeName];
	return tree.dataProvider;
}
// v6.4.3 Open all nodes in the tree
trees.openAllNodes = function(treeName:String, level:Number):Void {
	this.openNodesToLevel(treeName, 99); // for all practical purposes this will be all
}
trees.openNodesToLevel = function(treeName:String, level:Number):Void {
	var tree = this["tree"+treeName];
	// start recursion
	//myTrace("open nodes, limit " + level);
	this.openNodes(treeName, tree.dataProvider, level, 0);
}
trees.openNodes = function(treeName:String, xmlNode:XML, targetLevel:Number, currentLevel:Number) {
	var tree = this["tree"+treeName];
	//myTrace("open nodes for level " + currentLevel + " target " + targetLevel);
	//currentLevel = (currentLevel!=undefined) ? currentLevel : 0;
	if (xmlNode.hasChildNodes() && targetLevel!=currentLevel) {
		tree.setIsOpen(xmlNode, true);
		currentLevel++;
		for (var c in xmlNode.childNodes) {
			this.openNodes(treeName, xmlNode.childNodes[c], targetLevel, currentLevel);
		}
	}
}