
// dataGrids (outside NNW.screens they are called lists 'coz they act as lists)
// i used dataGrids instead 'coz it has a input field implemented
dgs.cellEdit = function(evtObj:Object) : Void {
	var dg = evtObj.target;
	var index = (dg.focusedCell.itemIndex!=undefined) ? dg.focusedCell.itemIndex : dg.length - 1;
	if (_global.trim(dg.cellEditor.text)!="") {
		dg.replaceItemAt(index, {label:dg.cellEditor.text, id:dg.selectedItem.id, unit:dg.selectedItem.unit, correct:dg.selectedItem.correct});
	}
	dg.cellEditor.removeEventListener("keyDown", this);
	dg.cellEditor.removeEventListener("enter", this);
	dg.editable = false;
	//_global.myTrace("on cell edit");
	NNW.control.onFinishRename(dg, index);
}
dgs.cellFocusOut = function(evtObj:Object) : Void {
	// v0.16.1, DL: cellFocusOut is dispatched after cellEdit
	// what to do if I just want one event to be dispatched?
	// is cellEdit enough to do the job? let's see
	/*var dg = evtObj.target;
	var index = (dg.focusedCell.itemIndex!=undefined) ? dg.focusedCell.itemIndex : dg.length - 1;
	if (_global.trim(dg.cellEditor.text)!="") {
		dg.replaceItemAt(index, {label: dg.cellEditor.text, id:dg.selectedItem.id, unit:dg.selectedItem.unit, correct:dg.selectedItem.correct});
	}
	dg.cellEditor.removeEventListener("keyDown", this);
	dg.cellEditor.removeEventListener("enter", this);
	dg.editable = false;
	_global.myTrace("on cell focus out");
	NNW.control.onFinishRename(dg, index);*/
}
// v0.8.1, DL: event listeners for cellEditor in dataGrids
dgs.keyDown = function(evtObj:Object) : Void {
	var dg = evtObj.target;
	if (Key.isDown(Key.ESCAPE)) {
		_global.myTrace("ESC down");
		dg.listOwner.disposeEditor();
	}
}
dgs.enter = function(evtObj:Object) : Void {
	var dg = evtObj.target;
	dg.listOwner.editCell();
	dg.listOwner.findNextEnterCell();
}

/* for drag & drop on dataGrids for items reordering by user */
/* create dragname */
if (_root.dragname==undefined) {
	_root.attachMovie("dragname", "dragname", _root.getNextHighestDepth());
	_root.dragname._visible = false;
}
dgs.dragRow = new Object();
dgs.cellPress = function(evtObj:Object) : Void {
	var thisIndex = evtObj.itemIndex;
	var thisItem = evtObj.target.getItemAt(thisIndex);
	this.dragRow.index = thisIndex;
	this.dragRow.exUnit = this.getSelectedIndex("Unit");
	this.dragRow.parent = evtObj.target._name;
	if (thisItem.label!=undefined && this.Item.label!="") {
		// clicked on item list
		NNW.control.onSingleClickingItemOnList(evtObj.target);
		/* show dragname */
		if (evtObj.target._name!="dgOption") {	// v0.14.0, DL: don't show dragname for options
			_root.dragname.gotoAndStop(1);
			_root.dragname.setLabel(thisItem.label);
			_root.dragname._visible = true;
		}
	} else {
		this.dragRow.index = -1;
	}
}
dgs.change=  function(evtObj:Object) {
	var dg = evtObj.target;
	var thisIndex = dg.selectedIndex;
	//var thisItem = dg.getItemAt(thisIndex);
	
	dg.editable = false;
	
	/* it's a drag & drop motion */
	var dragIndex = this.dragRow.index;
	if (this.dgUnit.hitTest(_root._xmouse, _root._ymouse, false) && this.dragRow.parent=="dgExercise" && dg._name=="dgExercise") {
		var targetIndex = this.dragRow.targetIndex;
		if (targetIndex>=0 && targetIndex<this.dgUnit.length) {
			NNW.control.moveExerciseToUnit(dragIndex, this.dragRow.exUnit, targetIndex);
		}
		
	} else if (dragIndex!=thisIndex) {
		if (dragIndex!=-1) {
			switch (dg._name) {
			case "dgCourse" :
				if (this.dragRow.parent=="dgCourse") {
					NNW.control.moveCourse(dragIndex, thisIndex);
				}
				break;
			case "dgUnit" :
				if (this.dragRow.parent=="dgUnit") {
					NNW.control.moveUnit(dragIndex, thisIndex);
				}
				break;
			case "dgExercise" :
				if (this.dragRow.parent=="dgExercise") {
					NNW.control.moveExercise(dragIndex, thisIndex);
				}
				break;
			}
		}
		this.firstClick = undefined;
	/* it's a click */
	} else {
		/* it's a double click */
		if (getTimer() - this.firstClick < 500 && thisIndex==this.clickIndex) {
			NNW.control.onDoubleClickingItemOnList(dg);
		/* it's a single click */
		} else {
			// v0.5.2, DL: debug - moved to cellPress
			//NNW.control.onSingleClickingItemOnList(dg);
		}
	}
	this.firstClick = getTimer();
	this.clickIndex = thisIndex;
	/* hide dragname */
	_root.dragname.gotoAndStop(1);
	_root.dragname.setLabel("");
	_root.dragname._visible = false;
}

dgs.getSelectedID = function(dgName:String) : String {
	var dg = this["dg"+dgName];
	return dg.selectedItem.id;
}

dgs.getSelectedUnit = function(dgName:String) : String {
	var dg = this["dg"+dgName];
	return dg.selectedItem.unit;
}

dgs.getSelectedLabel = function(dgName:String) : String {
	var dg = this["dg"+dgName];
	return dg.selectedItem.label;
}

dgs.getItemByIndex = function(dgName:String, index:Number) : Object {
	var dg = this["dg"+dgName];
	return dg.getItemAt(index);
}

dgs.clearList = function(dgName:String) : Void {
	var dg = this["dg"+dgName];
	dg.removeAll();
}

dgs.addItemToList = function(dgName:String, item:Object) : Void {
	var dg = this["dg"+dgName];
	if (item!=undefined) {
		dg.addItem(item);
	}
}

// v0.16.1, DL: remove all columns in a datagrid
dgs.removeAllColumns = function(dgName:String) : Void {
	var dg = this["dg"+dgName];
	var c = dg.columnCount;
	if (c>0) {
		for (var i=0; i<c; i++) {
			dg.removeColumnAt(0);
		}
	}
}

dgs.removeExtraColumns = function(dgName:String) : Void {
	var dg = this["dg"+dgName];
	var c = dg.columnCount;
	if (c>1) {
		for (var i=1; i<c; i++) {
			dg.removeColumnAt(1);
		}
	}
}

dgs.promptForNewItem = function(dgName:String) : Void {
	var dg = this["dg"+dgName];
	dg.selectedIndex = dg.length - 1;
	this.renameSelectedItem(dgName);
}

dgs.renameSelectedItem = function(dgName:String) : Void {
	var dg = this["dg"+dgName];
	var index = dg.selectedIndex;
	if (index!=undefined && dg.length>0) {
		dg.editable = true;
		dg.focusedCell = {itemIndex:index, columnIndex:"label"};
		// v0.8.1, DL: remove key listener to ESC & ENTER keys (this doesn't work with some East Asian input methods like New ChangJie)
		dg.cellEditor.removeEventListener("keyDown", dg.editorKeyDown);
		// v0.8.1, DL: add our own key listener to capture ESC & ENTER keys
		dg.cellEditor.addEventListener("keyDown", this);
		dg.cellEditor.addEventListener("enter", this);
		// v4.6.2.2, RL: add DragOn and DragAndDrop to the rename item.
		// v0.4.3, DL: no idea why the cellEditor isn't properly set in DataGrid.setFocusedCell()
		// v0.16.1, DL: for Dropdown, dgOption has 2 columns, so we've to set the editor in first column only
		if  (dgName=="Option") {
			// v6.4.3 Item based drop down
			//if (NNW.control.data.currentExercise.exerciseType=="Dropdown"||NNW.control.data.currentExercise.exerciseType=="DragOn"||NNW.control.data.currentExercise.exerciseType=="DragAndDrop") {
			if (NNW.control.data.currentExercise.exerciseType=="Dropdown"||NNW.control.data.currentExercise.exerciseType=="Stopdrop"||
				NNW.control.data.currentExercise.exerciseType=="DragOn"||NNW.control.data.currentExercise.exerciseType=="DragAndDrop") {
			//if (NNW.control.data.currentExercise.exerciseType=="Dropdown") {
				dg.cellEditor.setSize(dg.columns[0].__width, dg.__rowHeight+3);
			} else {
				//dg.cellEditor.setSize(dg.totColW+1, dg.__rowHeight+3);
				dg.cellEditor.setSize(223, dg.__rowHeight+3);
			}
		} else {
			dg.cellEditor.setSize(dg.totColW+1, dg.__rowHeight+3);
		}
		dg.cellEditor.maxChars = 35;
		dg.cellEditor.text = dg.selectedItem.label;
		dg.cellEditor._x += 1;
		dg.cellEditor._y -= 1;
		Selection.setFocus(dg.cellEditor);
		Selection.setSelection(0, dg.cellEditor.text.length);
	}
}

dgs.removeSelectedItem = function(dgName:String) : Void {
	var dg = this["dg"+dgName];
	var index = dg.selectedIndex;
	if (index!=undefined && dg.length>0) {
		dg.removeItemAt(index);
	}
}

dgs.moveUpSelectedItem = function(dgName:String) : Void {
	this.moveSelectedItem(dgName, "up");
}

dgs.moveDownSelectedItem = function(dgName:String) : Void {
	this.moveSelectedItem(dgName, "down");
}

dgs.moveSelectedItem = function(dgName:String, dir:String) : Void {
	var dg = this["dg"+dgName];
	var index = dg.selectedIndex;
	if (index!=undefined && dg.length>0) {
		var newIndex = (dir=="up") ? index - 1 : index + 1;
		if ((dir == "up" && index > 0) || (dir == "down" && index < dg.length - 1)) {
			var t = this.getItemByIndex(dgName, newIndex);
			dg.replaceItemAt(newIndex, {label:dg.selectedItem.label, id:dg.selectedItem.id, unit:dg.selectedItem.unit});
			dg.replaceItemAt(index, {label:t.label, id:t.id, unit:t.unit});
			dg.selectedIndex = newIndex;
		}
	}
}

dgs.setSelectedItem = function(dgName:String, n:Number) : Void {
	var dg = this["dg"+dgName];
	dg.selectedIndex = n;
}

dgs.getSelectedIndex = function(dgName:String) : Number {
	var dg = this["dg"+dgName];
	return dg.selectedIndex;
}

dgs.setSelectedItemByField = function(dgName:String, f:String, v:String) : Void {
	var dg = this["dg"+dgName];
	for (var i=0; i<dg.length; i++) {
		var item = dg.getItemAt(i);
		if (item[f]==v) {
			dg.selectedIndex = i;
		}
	}
}

/*dgs.getMaxID = function(dgName:String) : Number {
	var dg = this["dg"+dgName];
	if (dgName=="Unit") {
		var idName = "unit";
	} else {
		var idName = "id";
	}
	var maxID:Number = 0;
	for (var i=0; i<dg.length; i++) {
		if (Number(dg.getItemAt(i)[idName]) > maxID) {
			maxID = Number(dg.getItemAt(i)[idName]);
		}
	}
	return maxID;
}*/
