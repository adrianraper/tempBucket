// ActionScript Document
//var fbAllowance = 50; // moves window edge away from text - shouldn't be done here

// callback from component for rollOver on a field
// 'this' will be the field cover - the mc that reacts to the mouse events
// 'this._parent' is the component
// .fieldType, .fieldID, .fieldIDX, .fieldURL are all available from this
_global.ORCHID.fieldRollOver = function() {
	// one option is to change the text format of the field (the easy approach)
	//myTrace("you rolled over " + this.fieldID);
	//this._parent.setFieldTextFormat(this.fieldID, _global.ORCHID.underlineOn);
	
	// another option is to display a MC behind the text as a highlight
	// So twf has a canvas layer on which anything can go behind the fields
	// this might be dependent on the type of field - for now limit it to targets 
	// Note: should also check the mode so that you don't give the game away in proof reading
	// v6.3.4 Add in targetGaps, you do want to highlight these when you mouseOver
	// v6.3. no you don't!
	if (this.fieldType == "i:target" || this.fieldType == "i:drag") { 
							//|| this.fieldType == "i:targetGap") {
		//trace("rollOver a " + this.fieldType);
		// attach a MC to a special canvas MC that is available in the component behind the text
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			this._parent.setFieldBackground(this.fieldID, "markerEGU");
		} else {
			this._parent.setFieldBackground(this.fieldID, "markerAPO");
		}
	// v6.2 For special "highlight" fields, use underline to show you are over them???
	} else if (this.fieldType == "i:highlight") {
		this._parent.setFieldFormat(this.fieldID, _global.ORCHID.underlineOn);
	// v6.3.5 How about a different highlighter for dropdowns to show that they are not gaps?
	} else if (this.fieldType == "i:dropdown") {
		//myTrace("show dropdown marker");
		var markProps = {stretch:false, align:"right", oneLine:true};
		//myTrace("add dropdown for field " + this.fieldID);
		this._parent.setFieldBackground(this.fieldID, "dropdownMarker", markProps);
	}
}
// callback from component for rollOut from a field
_global.ORCHID.fieldRollOut = function() {
	//undo the highlighting that you did (if any) with the rollOver function
	//trace("you rolled out of " + this.fieldID);
	//this._parent.setFieldTextFormat(this.fieldID, _global.ORCHID.underlineOff);
	
	// or remove the marker blob
	// v6.3.4 Add in targetGaps, you do want to highlight these when you mouseOver
	// v6.3. no you don't!
	if (this.fieldType == "i:target" || this.fieldType == "i:dropdown"
							|| this.fieldType == "i:drag") {
							//|| this.fieldType == "i:targetGap") {
		this._parent.clearFieldBackground(this.fieldID);
		//myTrace("clear dropdown for field " + this.fieldID);
	// v6.2 For special "highlight" fields, use underline to show you are over them???
	} else if (this.fieldType == "i:highlight") {
		this._parent.setFieldFormat(this.fieldID, _global.ORCHID.underlineOff);
	}
}

// callback from component for starting of dragging a field
_global.ORCHID.fieldDrag = function() {
	//
	// in this function, THIS is the field cover that is over the drag/drop field you started to drag from
	//
	var me = _global.ORCHID.LoadedExercises[0];
	var thisField = me.getField(this.fieldID);
	
	// v6.2 Now this event will be fired from drags AND drops, so first see if there is anything
	// in the drop to make it worth/allowed to drag.
	//myTrace("fieldDrag")
	// v6.3.4 i:dropInsert - whilst I would like to drag away from a dropInsert, how would I pick up the drag out
	// of the whole field?
	if ((this.fieldType == "i:drop" || this.fieldType == "i:dropInsert") && thisField.linkedField == undefined) {
		// maybe you want to put up a message about how to do drag and drop here
		// then quit as nothing to drag.
		//myTrace("just clear myDrag");
		//v6.4.1 If you click on an empty drop (for a hint), then linkedField is empty so you will
		// come here. But that leaves myDrag as true. Screws things up.
		// I don't know what this does to dragInsert. Not tested.
		this.myDrag = false;
		return;
	}

	//v6.2 Now this function will have to create a mc that is actually dragged (copy props from this)
	// v6.3.3 Move exercise panels to the buttons holder
	//var realDrag = _root.exerciseHolder.attachMovie("fieldCover","realDrag", _global.ORCHID.selectDepth);
	var realDrag = _global.ORCHID.root.buttonsHolder.ExerciseScreen.attachMovie("fieldCover","realDrag", _global.ORCHID.selectDepth);
	// first find the global coordinates of the fieldCover
	//var coord = {x:this._x, y:this._y};
	//trace("after localToGlobal x=" + coord.x);
	// then convert these to local for the exercise
	// this seems to have no effect, why not?
	//_root.exerciseHolder.globalToLocal(coord);
	//trace("after globalToLocal x=" + coord.x);
	realDrag.linkedField = thisField.linkedField;
	// if you are dragging from a dropInsert, the coords and width, height are NOT from the current cover
	if (this.fieldType == "i:dropInsert") {
		// v6.4.2 rootless
		var coord = {x:_root._xmouse, y:_root._ymouse};
		//var coord = {x:_global.ORCHID.root._xmouse, y:_global.ORCHID.root._ymouse};
		//this.localToGlobal(coord);
		//var theDragField = me.getField(thisField.linkedField);
		//myTrace("base on linked field width =" + theDragField.answer[0].coords[0].w);
		//realDrag._width = theDragField.answer[0].coords[0].w;
		//realDrag._height = theDragField.answer[0].coords[0].h;
		// v6.3.4 This does not solve the problem of the coords of the drag to pick up, it just puts it at
		// top left corner. Not really satisfactory, but kind of OK for short drags.
		realDrag._x = coord.x; // - (realDrag._width/2);
		realDrag._y = coord.y - 8; // - (realDrag._height/2);
	} else {
		var coord = {x:0, y:0};
		this.localToGlobal(coord);
		// v6.4.2 Since we might be off the zero, need to realign to match proxy root
		//myTrace("global x=" + coord.x + " proxy offset=" + _global.ORCHID.root._x);
		var rootXOffset = _global.ORCHID.root._x;
		var rootYOffset = _global.ORCHID.root._y;
		realDrag._x = coord.x - rootXOffset;
		realDrag._y = coord.y - rootYOffset;
		realDrag._width = this._width;
		realDrag._height = this._height;
	}
	realDrag._alpha = 100; //IE10+Win8 fix gh#390
	// link the single dragger back to the cover that it is currently working with
	realDrag.cover = this;
	//myTrace("drag with " + realDrag + " w=" + realDrag._width + ",h=" + realDrag._height + " from " + this);
	realDrag.startDrag();
	realDrag.onMouseUp = function() {
		//myTrace("realDrag.onMouseUp");
		this.stopDrag();
		// this is used in the twf
		this.cover.myDrag = false;

		//myTrace("dragging=" + this + " dropping=" + this._droptarget);
		myDrop = eval(this._droptarget);
		//myTrace("rD: you dropped over mc " + myDrop);
		//trace("twf=" + this.cover._parent);
		if (myDrop.fieldType.indexOf("i:",0) >= 0) {
			//myTrace("field type=" + myDrop.fieldType + " id=" + myDrop.fieldID);
			this.myTarget = myDrop.fieldID; //Number(myDrop.getDepth() - _global.ORCHID.coverDepth);
			this.myDropEvent = eval(this.cover._parent.dropCallback_param);
			this.myDropEvent();
		}
		//myTrace("realDrag: " + this + ".removeMovieClip")
		this.removeMovieClip();
	}
	// remove the event from the fieldCover
	delete this.onMouseDown;
	
	//undo the highlighting that you did (if any) with the rollOver function
	//this._parent.setFieldTextFormat(this.fieldID, _global.ORCHID.underlineOff);
	// remove the marker blob
	//trace("remove marker");
	this._parent.clearFieldBackground(this.fieldID);
	// v6.4.2.7 Also ticks
	this._parent.clearFieldTick(this.fieldID);

	// v6.2 - you might be dragging from a drop that contains a drag - so 
	// in that case get the drag field not the default drop one
	if (thisField.linkedField > 0) {
		var useFieldID = thisField.linkedField;
		var theDragField = me.getField(useFieldID);
		//myTrace("use linked field " + theDragField.id + "=" + theDragField.answer[0].value);
	} else {
		var useFieldID = this.fieldID;
		var theDragField = thisField;
		//myTrace("use drag field " + theDragField.id + "=" + theDragField.answer[0].value);
	}
	// save the 
	//trace("drag cover=" + theDragField.cover);
	//var theDropField = me.getField(this.fieldID);

	// v6.2 to allow for drags to be disabled then enabled back to their original format
	// (other fields get the original format saved during singleMarking)
	// Only need to do this once per drag field.
	if (theDragField.origTextFormat == undefined) {
		//var contentHolder = _root.exerciseHolder.Exercise_SP.getScrollContent();
		//var thisParaBox = contentHolder["ExerciseBox" + theDragField.paraNum];
		// v6.2 - I already know the twf
		// use the component to get the TextFormat of the field
		var thisTWF = this._parent;
		//trace("look up TF in " + thisTWF + ".fieldID=" + theDragField.id);
		theDragField.origTextFormat = thisTWF.getFieldTextFormat(theDragField.id);
		//trace("saved format for field " + theDragField.id + " size=" + theDragField.origTextFormat.size);
	}
	//trace("you want to drag field " + this.fieldID);
	//var fieldID = this.fieldID
	//trace("using " + fieldID);
	// v6.2 Now you will create the drag object on the mc I just created rather than the cover
	//createDragObject(theDragField, this);
	createDragObject(theDragField, realDrag);
	
	// if you want to provide a visual clue that you have dragged over a drop field
	// then perhaps you can run a setInterval loop using hitTest between the dragObject
	// and all the other fieldCovers held within the ExercisePane. But it might be difficult
	// to find them as _parent will only let you find the component you started from
	// which is of little interest. Maybe as you add each drop field you can create a simple
	// array at the ExercisePane level which holds their MC ids and then is quick to check.
	// v6.2
	// Try the following idea: use hitTest with the whole drop and drag fields, but don't do anything
	// to the drag field apart from record that which drop is currently "active" (if two drops could be
	// active, just accept the first one). When the drag is dropped, first check to see if any drops are active
	// and if they are, just use that rather than do any other checking.
	
	// why does a drop seem to disappear from the dzl once it has been dropped on once?
	//for (var i in _root.ExerciseHolder.dropZoneList) {
	//	trace("dropzone id=" + _root.ExerciseHolder.dropZoneList[i].fieldID + " cover=" + _root.ExerciseHolder.dropZoneList[i].cover);
	//}

	// v6.2 Now you will use the mc I just created rather than the cover
	//clearInterval(this.hitTestInterval);
	//this.dragOverDrop = function() {
	clearInterval(realDrag.hitTestInterval);
	realDrag.dragOverDrop = function() {
		//myTrace("interval: dragOverDrop?");
		//var thisX = _root._xmouse;
		//var thisY = _root._ymouse;
		// v6.4.2.7 CUP merge
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			var myMarker = "markerEGU";
		} else {
			var myMarker = "markerAPO";
		}
		// v6.3.4 Confusion reigns if it appears you are over more than one drop
		var oneDropActive = false;
		// v6.3.6 Merge exercise into main
		for (var i in _global.ORCHID.root.mainHolder.dropZoneList) {
			//myTrace("test dropZone=" + _root.mainHolder.dropZoneList[i].cover);
			var thisDrop = _global.ORCHID.root.mainHolder.dropZoneList[i];
			//trace("check drop " + thisDrop.fieldID + " at x,y " + thisDrop.cover._x + "," + thisDrop.cover._y + " against " + thisX + "," + thisY);
			//trace("test hit against field " + thisDrop.fieldID);
			//if (thisDrop.cover.hitTest(_root._xmouse, _root._ymouse, false)) {
			// v6.3.4 Confusion reigns if it appears you are over more than one drop
			if (thisDrop.cover.hitTest(this) && !oneDropActive) {
				//myTrace("over field " + thisDrop.fieldID);
				// You only want to set this once!
				if (!thisDrop.active) {
					//myTrace("not active");
					if (thisDrop.fieldType == "i:dropInsert" ) {
						//thisDrop.cover.showDropPosition("markerEGU");
						thisDrop.cover.showDropPosition(myMarker);
					} else {
						//thisDrop.twf.setFieldBackground(thisDrop.fieldID, "Marker");
						//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
						//thisDrop.twf.setFieldBackground(thisDrop.fieldID, "markerEGU");
						thisDrop.twf.setFieldBackground(thisDrop.fieldID, myMarker);
						//} else {
						//myTrace("so set background of drop");
						//	thisDrop.twf.setFieldBackground(thisDrop.fieldID, "markerAPO");
						//}
					}
					thisDrop.active = true;
				}
				// v6.3.4 You have now found one active drop, so don't let any others be acceptable
				// even if they are actually hits as well. 
				oneDropActive = true;
				//trace("setting dZA=" + thisDrop);
				// v6.2
				/*
				var dropPoint = {x:thisDrop.cover._x, y:thisDrop.cover._y};
				thisDrop.twf.localToGlobal(dropPoint); // dropPoint is now global
				var dragPoint = {x:dropPoint.x, y:dropPoint.y};
				//trace("change to local for " + this._parent);
				//trace("my x,y: " + this._x + "," + this._y);
				this._parent.globalToLocal(dragPoint); // dragPoint is now that point but relative to the drag starting point
				//trace("drag x,y: " + dragPoint.x + "," + dragPoint.y + " and drop x,y: " + dropPoint.x + "," + dropPoint.y);
				//clearInterval(this.hitTestInterval);
				//thisDrop.twf.setFieldBackground(thisDrop.fieldID, "Marker");
				// or trying snapping the drag object into place
				this._x = dragPoint.x;
				this._y = dragPoint.y;
				this.stopDrag(); // why does this not stop the cover dragging
				// or does it, but something else somewhere switches it on again?
				*/
			} else {
				// v6.2
				// if you were previously over this drop but are now out of it, clear the
				// highlighting and saved dropZone.
				//trace("missTest with " + thisDrop.fieldID);
				if (thisDrop.active) {
					thisDrop.twf.clearFieldBackground(thisDrop.fieldID);
					thisDrop.active = false;
					if (thisDrop.fieldType == "i:dropInsert" ) {
						thisDrop.cover.hideDropPosition();
					}
					//trace("it was hit so now clear it");
				}
				/*
				this.startDrag();
				//thisDrop.twf.clearFieldBackground(thisDrop.fieldID);
				*/
			}
		}
	}
	// for debugging
	//for (var i in _global.ORCHID.root.mainHolder.dropZoneList) {
	//	myTrace(i + " dropZone=" + _global.ORCHID.root.mainHolder.dropZoneList[i].cover);
	//}
	// this function does not work reliably - it hovers a little when you are over the
	// drop, but worse is that after a few, it seems to stop working altogether.
	// v6.2 - now seems fine
	//_root.ExerciseHolder.dropZoneActive = false;
	
	// v6.2 Now you will use the mc I just created rather than the cover
	//this.hitTestInterval = setInterval(this, "dragOverDrop", 100);
	realDrag.hitTestInterval = setInterval(realDrag, "dragOverDrop", 100); 
	//for (var i in _root.ExerciseHolder.dropZoneList) {
	//	trace("test dropZone=" + _root.ExerciseHolder.dropZoneList[i].cover);
	//}
	//for (var i in _level0.exerciseHolder.Exercise_SP.tmp_mc.ExerciseBox1) {
	//	if (_level0.exerciseHolder.Exercise_SP.tmp_mc.ExerciseBox1[i].fieldID > 0) {
	//		trace("fc=" + _level0.exerciseHolder.Exercise_SP.tmp_mc.ExerciseBox1[i]);
	//	}
	//}
	//trace("setting hitTestInt = " + this.hitTestInterval);

	// Again, are you dragging a drag out of drop?  If so
	// really take it away and leave the original __*__, or whatever
	if (thisField.linkedField > 0) {
		//trace("remove answer from field " + this.fieldID);
		//_global.ORCHID.LoadedExercises[0].getField(this.fieldID).dragField = undefined;
		//var emptyAnswer = "  •  ";
		//theDropField.dragField = undefined;
		
		// v6.2 whenever you start dragging a field, you should enable the original
		// in case you drop outside anywhere, which reinvigorates the original
		// Oh, you can't enable like this here as it clears the draggie
		//this._parent.enableField(useFieldID);

		// you can't just put the empy answer into the original field as the drag disappears
		// but I don't know why. Where is the link?
		// It is ok if you only do a partialRefresh in insertAnswerIntoField (true 3rd parameter)
		//trace("drag text is " + me.getField(this.dragField).answer[0].value);
		//insertAnswerIntoField(theDropField, emptyAnswer, true)
		// we want to call singleMarking as the person is changing their answer for this drop
		// and we must alter the score for this field. But if call the full marking function we will
		// lose the drag out of the drop. So until this is sorted/understood (and why isn't that now?)
		// lets just clear out the marking.
		//trace("clear out the drop you are dragging from " + thisField.id);
		singleClearMarking(thisField);
	}
}

// call back from component for a drop event
// 'this' is the fieldCover, this._parent is the paragraph
// this._droptarget is/should be a fieldCover
_global.ORCHID.fieldDrop = function() {
	// get rid of the hitTest function
	//trace("clearing hitTestInt = " + this.hitTestInterval);
	// v6.2 THIS now refers to the temporary realDrag field rather than a cover
	clearInterval(this.hitTestInterval);
	// v6.2
	//trace("myTarget=" + this.myTarget);
	var activeDrop = false;
	// v6.3.6 Merge exercise into main
	var dropZones = _global.ORCHID.root.mainHolder.dropZoneList;
	for (var i in dropZones) {
		if (dropZones[i].active) {
			var activeDrop = dropZones[i];
			break;
		}
	}
	//var activeDrop = _root.ExerciseHolder.dropZoneActive;
	if (activeDrop != false) {
		//trace("activeDrop field=" + activeDrop.fieldID + " from drag=" + this.dragField);
		//trace("use active dropZone " + _root.ExerciseHolder.dropZoneActive.fieldID);
		this.myTarget = activeDrop.fieldID;
		// clear the highlighting and the fact that there is an activeDrop
		activeDrop.twf.clearFieldBackground(activeDrop.fieldID);
		// v6.4.2.7 Also ticks
		activeDrop.twf.clearFieldTick(activeDrop.fieldID);
		
		activeDrop.active = false;
		//trace("at drop time the twf=" + activeDrop.twf);
	}
	//myTrace("drop from " + this + " on twf=" + activeDrop.twf);
	var me = _global.ORCHID.LoadedExercises[0];
	var targetField = me.getField(this.myTarget);
	// get rid of the drag text I created
	//var saveIt = this.dragText.text;
	//this.dragText.removeTextField();
	// The drag item is now a sub MC of the field cover, so dig to get the text
	var saveIt = this.drag.dragText.text;
	//trace("fD: you dropped '" + saveIt + "' on a " + targetField.type+"("+ this.myTarget + ")");
	
	// v6.2 does this drop field already hold a drag?
	if (targetField.linkedField != undefined) {
		// if so, enable the original drag if it was previously disabled
		// v6.3.3 change mode to settings
		//if (_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.OnlyDragOnce) {
		if (_global.ORCHID.LoadedExercises[0].settings.exercise.dragTimes == 1) {
			//trace("this drop already has a drag=" + targetField.linkedField);
			restoreFieldAppearance(me.getField(targetField.linkedField), true);
		}
	}
	
	// remove the textField and the MC.
	//trace("before dragMC=" + this.drag);
	this.drag.dragText.removeTextField();
	//this.drag.removeMovieClip();
	//trace("now dragMC=" + this.drag);
	if (targetField.type == "i:drop" || targetField.type == "i:gap") {
		// how do I know which component to insert the text in?
		//var targetPara = eval(this._droptarget)._parent;
		//trace("dropped " + this.fieldID + " on " + targetField.id + " in para " + targetPara);
		// singleMarking is responsible for inserting the dragged text into the drop zone
		//targetPara.setFieldText(targetField.id, saveIt);
		//trace("check if " + saveIt + " is correct.");
		// v6.2 - save the original drag field ID as a property in the drop field
		if (this.linkedField != undefined) {
			targetField.linkedField = this.linkedField;
			//trace("saving special drag=" + targetField.linkedField + " in drop=" + targetField.id);			
		} else {
			targetField.linkedField = this.cover.fieldID;
			//trace("saving normal drag=" + targetField.linkedField + " in drop=" + targetField.id);			
		}
		singleMarking(targetField, saveIt);
	// v6.3.4 Also allow new field type
	} else if (targetField.type == "i:dropInsert") {
		// hide any graphics used
		//myTrace("activeDrop.cover=" + activeDrop.cover)
		activeDrop.cover.hideDropPosition();
		// do the linked field bit from above
		if (this.linkedField != undefined) {
			targetField.linkedField = this.linkedField;
			//trace("saving special drag=" + targetField.linkedField + " in drop=" + targetField.id);			
		} else {
			targetField.linkedField = this.cover.fieldID;
			//trace("saving normal drag=" + targetField.linkedField + " in drop=" + targetField.id);			
		}
		// now work out where you have dropped the drag on the insert
		// what was the calculated closest word break?
		var insertIdx=activeDrop.cover.nearestDropPosition;
		var insertText = targetField.answer[0].value;
		//myTrace("drop [" + saveIt + "] onto " + insertText + " at idx=" + insertIdx);
		saveItArray = insertText.split(" ");
		saveItArray = saveItArray.slice(0,insertIdx).concat([saveIt]).concat(saveItArray.slice(insertIdx));
		saveIt = saveItArray.join(" ");
		//myTrace("so your answer=" + saveIt);
		singleMarking(targetField, saveIt);
	} else {
		//trace("you can't drop here");
		// put the field cover back over the drag field as you might want to drag it again
		//trace("go back to x,y=" + this._parent.fields[this.fieldID][0].x + "," + this._parent.fields[this.fieldID][0].y);
		//this._x = this._parent.fields[this.fieldID][0].x; 
		//this._y = this._parent.fields[this.fieldID][0].y  - this._parent.fields[fieldID][0].height; 
	}
	//trace("after singleMarking");
	// v6.2 the cover names will have changed as fields have been disabled (removed and added)
	// see unresolved note in twf). Therefore reassign the cover name in the dropZoneList.
	// ???? this is contentious. If I don't do it, then the cover ref is lost so the highlighting
	// function will not work anymore. If I do it, then when I pick up the drag from the drop
	// I also get the drop fieldCover, or something like it.
	//var fieldIDX = lookupArrayItem(activeDrop.twf.fields, activeDrop.fieldID, "id");
	//activeDrop.cover = activeDrop.twf.fields[fieldIDX].coords[0].coverMC;

	// v6.2 disable the drag field that you have just dropped on a drop
	// v6.3.3 change mode to settings
	//if (_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.OnlyDragOnce) {
	if (_global.ORCHID.LoadedExercises[0].settings.exercise.dragTimes <= 1) {
		var originalDrag = me.getField(targetField.linkedField);
		//var dragRegion = originalDrag.region;
		// v6.2 it would be much better to hold the regions as an array or something in exercise Holder, but for now...
		var contentHolder = getRegion(originalDrag).getScrollContent();
		//switch (originalDrag.region) {
		//	case _global.ORCHID.regionMode.noScroll:
		//		var contentHolder = _root.exerciseHolder.NoScroll_SP.getScrollContent();
		//		break;
		//	case _global.ORCHID.regionMode.title:
		//		var contentHolder = _root.exerciseHolder.Title_SP.getScrollContent();
		//		break;
		//	default:
		//		var contentHolder = _root.exerciseHolder.Exercise_SP.getScrollContent();
		//		break;
		//}
		//trace("the drag was from region " + contentHolder);
		var thisParaBox = contentHolder["ExerciseBox" + originalDrag.paraNum];
		//trace("disable drag field=" + originalDrag.id + " in " + thisParaBox);
		thisParaBox.setFieldTextFormat(originalDrag.id, _global.ORCHID.DisabledText);
		thisParaBox.disableField(originalDrag.id);
	}
	
	// this is not necessary if you dropped on a field in the same component, but it is if you
	// drop on a field in another
	this._parent.resetFieldCovers();
	// force a rollOut event after a drop event - only a problem for dropping on another component
	//trace("force " + this + this.onRollOut);
	this.onRollOut();
}

// a building function to react to clicking on a field
//_global.ORCHID.fieldClick = function (fieldTag) {
_global.ORCHID.fieldMouseUp = function (modKey) {
	var fieldID = this.fieldID
	//myTrace("FieldReaction:fieldMouseUp on " + fieldID + " mod=" + modKey);
	var me = _global.ORCHID.LoadedExercises[0];
	var thisField = me.getField(fieldID);
	//myTrace("fieldMouseUp on field " + fieldID + ":" + thisField.type);
	
	// v6.5.5.8 It is useful to save the field so that you can (perhaps amongst other things) display feedback next to it
	// But I don't think this is the best place to save it. Ah, I think I have to save it in a few places.
	saveThisField(thisField);

	// was the mouse click modified?
	// v6.4.1 If it is target spotting with hidden fields, then don't give the game away
	// by admitting there is no hint on this field.
	// v6.4.1 Also, no such thing as a hint for a drag (or a highlight)
	//if (modKey == Key.control) {
	// v6.4.2.7 Structure this cleanly. 
	// First, if it is a control click it means we want a hint if possible, if not we want a glossary.
	//if (modKey == Key.control && 
	//	!_global.ORCHID.LoadedExercises[0].settings.exercise.hiddenTargets) {
	if (modKey == Key.CONTROL) {
		// First, EGU has no hints, so ctrl-click always means glossary.
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			// the hint function will try to call glossary for the answer to this 
			// But if the field is more than one word, you don't know which word they clicked on, so you can't do
			// glossary from here - it has to be done from inside the twf. So here we do nothing.
			//_global.ORCHID.onControlClick(thisField.answer[0].value); 
		} else {
			// If this is a hiddenTargets, clicking on a field and on a regular word should both do glossary
			// Otherwise targets and gaps should do the hint,
			// drags and highlights should do the glossary
			if (_global.ORCHID.LoadedExercises[0].settings.exercise.hiddenTargets ||
				thisField.type == "i:drag" || thisField.type == "i:highlight") {
				// But if the field is more than one word, you don't know which word they clicked on, so you can't do
				// glossary from here - it has to be done from inside the twf. So here we do nothing.
				//_global.ORCHID.onControlClick(thisField.answer[0].value); 
			} else {
				myTrace("displayHint from fieldMouseUp");
				displayHint(thisField);
			}
		}
		// v6.4.2.7 except that EGU wants to do glossary for drags - can?
		//if (thisField.type <> "i:drag"){
			//trace("you did a control-click");
			//displayHint(thisField);
		//}
	} else {
		// remove the background (if any)
		this._parent.clearFieldBackground(this.fieldID);
		// v6.4.2.7 Also ticks and crosses
		this._parent.clearFieldTick(this.fieldID);
		// the whole of the arg is passed, so you might need to parse as it probably looks like 1|i:target
		//var fieldID = fieldTag.split("|",1);
		// if using the component, it has saved .fieldID and .fieldTarget
		//myTrace("you clicked on "+this.fieldID+" which is mode/type "+thisField.mode+"/"+thisField.type);
		// I don't know yet how to split the mode and type
		if (thisField.type == "i:target"){
			// then trigger singleMarking
			// v6.2 If you have already clicked on this target, a second click should unselect it (and clear marking)
			// v6.2 Also, if you (CUP) have already clicked (10) times, this click should not count (with a warning)
			singleMarking(thisField);
		//  _root.onSelectField(thisField);
		// v6.3.4 New hybrid type for correcting mistakes in a proof reading
		// v6.3.5 Change behvaiour of targetGap/presetGap
		// v6.4.3 If it is a full proofreading errorCorrection then you now need to convert the target to a gap
		// which would involve making it longer so would mean redrawing the whole paragraph (and pushing other ones down).
		//	// Steps ?:
		//	// 1) redo paraXMLToExercise (from XMLtoObject) having changed this field type to gap. I already know the 
		//	//     gap length (field.info.gapChars) if that would help? So I could do insertFieldText immediately.
		//} else if (thisField.type == "i:targetGap") {
		// More sensible to use hiddenTargets
		//} else if (thisField.type == "i:targetGap" && _global.ORCHID.LoadedExercises[0].settings.exercise.proofReading) {
		} else if (thisField.type == "i:targetGap" && _global.ORCHID.LoadedExercises[0].settings.exercise.hiddenTargets) {
			
			//myTrace("fieldMouseUp:wrong answer = " + thisField.answer[0].value);
			// you have found the mistake, so you need to replace the mistake with what would be there if
			// this had been a normal gap. 
			var thisTWF = this._parent;
			// v6.3.4 You have to set the text to be appropriate number of spaces to avoid seeing it through the cover.
			// So this line puts blanks into the full twf (which would have been the case with a real gap in the first place).
			// But the problem is that when this refreshes the twf it wipes out text in the other covers.
			// #errorCorrection problem#
			// Now i have the problem that if the target goes over two lines, the gap does too. How about &nbsp; ?
			// Well, almost, but I get an infinite loop when this goes over a line break, which is because an original set of many covers
			// has become just one (as the gap is now on one line) and you were calling createTypingBox with no cover.
			// I also get a simliar case when the target is on one line (at the end), and turning it into a gap pushes it to the next line. Why?
			//insertAnswerIntoField(thisField, makeString(" ", thisField.info.gapChars+1));
			// Before we put the new text into the field, check to see if the original was across mutlilines
			var originalMultiLines = this.multiLine;
			//myTrace("the original had multiLine=" + originalMultiLines);
			
			insertAnswerIntoField(thisField, makeString(String.fromCharCode(160), thisField.info.gapChars+1));
			thisTWF.setFieldTextFormat(fieldID, _global.ORCHID.UnderlineText);
			// v6.3.4 Try to populate the gap with the thing you clicked on to allow editing rather than retyping
			// once you have done this once, it will just keep what they last typed.
			//myTrace("current answer=" + thisField.attempt.finalAnswer);
			// This is duplicated in createTypingBox - except that by then this will be a standard gap
			if (thisField.attempt.finalAnswer == "" || thisField.attempt.finalAnswer == undefined) {
				thisField.attempt.finalAnswer = thisField.answer[0].value;
			}
			// v6.4.2.8 Try simply making this field a standard gap now that you have found it #errorCorrection problem#
			// Do note that doing this doesn't impact the TWF's understanding of the fieldType which is rebuilt from asfunction as needed
			thisField.type = "i:gap";
			
			// now you can go ahead and make a typing box as normal
			// (but this typing box cannot keep the answer just in the cover as due to movement of
			// text when you find another mistake the covers will keep disappearing)
			// If my target was split across lines, then clicking on the first line cover goes into an infinite loop here
			// because it has been deleted by the twf refreshing itself. So I need to get a new cover for this field.
			// This also happens if the cover was on line 1 and has now been pushed to line 2. Don't know why.
			//if (this.multiLine) var needNewCover = true;
			//if (originalMultiLines>=0) {
			//if (originalMultiLines>=0 || needNewCover) {
			var nowMultiLines = this.multiLine;
			//myTrace("original multiLines=" + originalMultiLines + " now it is " + nowMultiLines);
			// Wouldn't it be safer to always confirm the field cover you are going to use? It is not a big deal
			//if (originalMultiLines>=0 || nowMultiLines>=0) {
				var confirmedCover = thisTWF.getFieldCover(fieldID);
				myTrace("confirm the useful cover is " + confirmedCover);
			//} else {
			//	var confirmedCover = this;
			//}
			//myTrace("createTypingBox for " + confirmedCover);
			createTypingBox(thisField, confirmedCover);
		
		//} else if (thisField.type == "i:gap" || thisField.type == "i:presetGap") {
		//} else if (thisField.type == "i:gap" || thisField.type == "i:targetGap") {
		} else if (thisField.type == "i:gap") {
			// show the typing box and let them type in it, it will trigger singleMarking
			//trace("clicked on fieldCover " + this);
			//Note: I guess that this could go in the prototype, but then it would need to know the answers, so
			// maybe that is too much
			//trace("I want typing for " + this);
			createTypingBox(thisField, this);
		} else if (thisField.type == "i:dropdown") {
			//trace("this field is a dropdown");
			createSelectBox(thisField, this);
		} else if (thisField.type == "i:highlight") {
			// v6.2 Now, it is possible/likely/certain that the last typing box didn't insert it's answer into it's field
			// so we should do it for it.
			// v6.3.4 No longer - correctly handled by the selection listener
			//if (_global.ORCHID.session.currentItem.lastGap != undefined) {
			//	//trace("doing the last insert from cmdMarking");
			//	insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
			//	_global.ORCHID.session.currentItem.lastGap = undefined;
			//}
			// has it already been clicked? Use .linkedField to hold true=clicked
			//trace("click on a highlight field");
			// v6.3.5 hijack this function for testing countDown
			// v6.4.3 It doesn't appear to be used anymore for this.
			if (_global.ORCHID.LoadedExercises[0].settings.exercise.type == "Countdown") {
			//if (_global.ORCHID.LoadedExercises[0].settings.exercise.countDown) {
				var me = _global.ORCHID.LoadedExercises[0];
				var thisField = me.getField(this.fieldID);
				var thisWord = thisField.answer[0].value;
				myTrace("try your luck with " + thisWord);
				// ask each TWF to see if they can make use of this word
				sendWordToCountdown(thisWord);
			} else {
				var thisTWF = this._parent;
				if (thisField.origTextFormat == undefined) {
					//myTrace("save the original format");
					thisField.origTextFormat = thisTWF.getFieldTextFormat(fieldID);
				}
				if (thisField.linkedField) {
					//trace("restore original format");
					thisTWF.setFieldTextFormat(fieldID, thisField.origTextFormat);
				} else {
					//trace("disable it");
					thisTWF.setFieldTextFormat(fieldID, _global.ORCHID.DisabledText);
				}
				thisField.linkedField = !thisField.linkedField;
			}
		// v6.3.4 Add in hyperlinks
		} else if (thisField.type == "i:url") {
			//myTrace("click on a url=" + thisField.info.url);
			// v6.2 Now, it is possible/likely/certain that the last typing box didn't insert it's answer into it's field
			// so we should do it for it.
			// v6.3.4 No longer - correctly handled by the selection listener
			//if (_global.ORCHID.session.currentItem.lastGap != undefined) {
			//	//trace("doing the last insert from cmdMarking");
			//	insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
			//	_global.ORCHID.session.currentItem.lastGap = undefined;
			//}
			// v6.4.2.7 Network version needs fuller path
			//getURL(thisField.info.url, "_blank");
			var thisMedia = _global.ORCHID.viewObj.checkWeblink(thisField.info.url)
			myTrace("link to=" + thisMedia);
			getURL(thisMedia, "_blank");
			break;
		// v6.5.6.4 What about clicking an image that you want to start a video player in a popup
		// But how to make the image an active field?
		} else if (thisField.type == "i:videoPlayer") {
			myTrace("click on a video=" + thisField.info.url);
			var thisMedia = _global.ORCHID.viewObj.checkWeblink(thisField.info.url)
			myTrace("link to=" + thisMedia);
			getURL("javascript:popUpVideoPlayer('" + thisMedia + "', 800, 585 ,0 ,0 ,0 ,0 ,1 ,1 ,20 ,20 )");
			break;
		// v6.3.4 and pop-ups, linked to the readingText
		} else if (thisField.type == "i:text") {
			// v6.5 This called the function that comes from a button
			//_global.ORCHID.viewObj.cmdReadingText(thisField.id);
			_global.ORCHID.viewObj.displayReadingText(thisField.id);
			break;
		}
	}
}
// global callback if you want to catch clicks on an exercise that are not on fields
_global.ORCHID.clickOutOfField = function() {
	// v6.4.2.7 Don't do anything if this is a control click - handled by TWF
	if (Key.isDown(Key.CONTROL)) {
	} else {
		//myTrace("FieldReaction:clickOutOfField");
		var me = _global.ORCHID.LoadedExercises[0];
		// Don't do this after marking
		// v6.3.3 Change to currentItem for marking status
		//if(!(me.mode & _global.ORCHID.exMode.MarkingDone)) {
		if(!_global.ORCHID.session.currentItem.afterMarking) {
			// v6.3.3 change mode to setting (and proofReading now implies hiddenTargets)
			//if (me.mode & _global.ORCHID.exMode.HiddenTargets || me.mode & _global.ORCHID.exMode.ProofReading) {
			// v6.4.2.7 If the targets are hidden, but it is neutral marking (odd, but can happen), don't do oops
			//if (me.settings.exercise.hiddenTargets) {
			//myTrace("hiddenTargets=" + me.settings.exercise.hiddenTargets + " & neutral marking=" + me.settings.marking.neutral);
			if (me.settings.exercise.hiddenTargets && !me.settings.feedback.neutral) {
				//trace("that is incorrect");
				// is it sensible to count the clicks in the 0 group? 
				me.body.text.group[0].incorrectClicks++;
				var effectType = "oops";
				// v6.3.4 Move branding stuff to buttons
				//_root.brandingHolder.soundEffect(effectType);
				// v6.3.5 And allow it to be turned off by the author (default is on)
				if (_global.ORCHID.course.soundEffects && me.settings.misc.soundEffects) {
					_global.ORCHID.root.buttonsHolder.buttonsNS.soundEffect(effectType);
				} else {
					// v6.4.2.4 Show a non-audio oops? Display the cross here?
					//var coord = {x:0, y:0};
					//this.localToGlobal(coord);
					// v6.4.2 Since we might be off the zero, need to realign to match proxy root
					//myTrace("global x=" + coord.x + " proxy offset=" + _global.ORCHID.root._x);
					//var rootXOffset = _global.ORCHID.root._x;
					//var rootYOffset = _global.ORCHID.root._y;
					var thisBase = this._parent._parent._parent;
					var initObj = new Object();
					//initObj._x = coord.x - rootXOffset;
					//initObj._y = coord.y - rootYOffset;
					initObj._x = thisBase._xmouse;
					initObj._y = thisBase._ymouse;
					//myTrace("display the cross at x=" + initObj._x + " y=" + initObj._y);
					this.myCross = thisBase.attachMovie("InstantCross", "tempVisual", _global.ORCHID.mediaRelatedDepth, initObj);
					//myTrace(_global.ORCHID.mediaRelatedDepth + " cross=" + this.myCross);
					if (this.tempVisualInt >0) clearInterval(this.tempVisualInt);
					this.deleteIt = function() {
						//myTrace("then delete it " + this.myCross);
						clearInterval(this.tempVisualInt);
						this.myCross.removeMovieClip();
					}
					this.tempVisualInt = setInterval(this, "deleteIt", 1000);
				}
			}
		}
	}
}
// v6.5.5.8 So you know which field you have just clicked on
saveThisField = function(thisField) {
	var contentHolder = getRegion(thisField).getScrollContent();
	var thisParaBox = contentHolder["ExerciseBox" + thisField.paraNum];
	var thisCover = thisParaBox.getFieldObject(thisField.id).coords[0].coverMC;
	_global.ORCHID.session.currentItem.thisGap = {field:thisField, cover:thisCover};
}

// callback from component for control click on a TWF but outside a field
// v6.4.2.7 Name is too confusing
//_global.ORCHID.onControlClick = function(thisWord, cdRealWord) {
_global.ORCHID.onGlossary = function(thisWord, cdRealWord) {
	// v6.2 Now, it is possible/likely/certain that the last typing box didn't insert it's answer into it's field
	// so we should do it for it.
	// v6.3.4 No longer - correctly handled by the selection listener
	//if (_global.ORCHID.session.currentItem.lastGap != undefined) {
	//	//trace("doing the last insert");
	//	insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
	//	_global.ORCHID.session.currentItem.lastGap = undefined;
	//}
	//myTrace("FieldReaction.onGlossary with " + thisWord); // + " (real=" + cdRrealWord + ")");
	// v6.3.5 Countdown can also hijack this function to provide hints. But some words in countdown that 
	// are not guessed but already shown don't need hints but glossary instead.
	if (cdRealWord == true) {
		var needHint = false;
	} else {
		var needHint = true;
		if (_global.ORCHID.LoadedExercises[0].settings.exercise.type == "Countdown") {
		//if (_global.ORCHID.LoadedExercises[0].settings.exercise.countDown) {
			var guessListLen = _global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController.guessList_cb.getLength();
			for (var i=0; i<guessListLen;i++) {
				if (_global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController.guessList_cb.getItemAt(i).data == thisWord) {
					myTrace(thisWord + " already guessed, so glossary");
					var needHint = false;
					break;
				}
			}
			if (needHint) {
				//myTrace("get countdown hint for " + thisWord);
				_global.ORCHID.viewObj.cmdCountdownHint(thisWord);
				return;
			}
		}
	}
	// v6.4.2.7 Don't try to get glossary for rubbish
	if (thisWord == "") return;
	// v6.4.2.7 Do nicer escape characters for apostrophe as CUP doesn't like %27 to be passed in the string
	thisWord = findReplace(thisWord, "'", "&apos;");
	
	// v6.3.5 Non CUP doesn't need to load a glossary first (at least not now)
	// so goes direct to the glossaryLookup (which does a URL)
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		_global.ORCHID.viewObj.cmdGlossary(thisWord);
	} else {
		_global.ORCHID.viewObj.glossaryLookUp(thisWord);
	}
}
// v6.2 A function that is called after marking when you click on a field
// and you want to see individual feedback for that field
// v6.4.2.7 You know any modifier key that is being pressed
//_global.ORCHID.fieldFeedback = function() {
_global.ORCHID.fieldFeedback = function(modKey) {
	// The control key means you want glossary on the word - handled by onControlClick
	if (modKey == Key.CONTROL) {
		return;
	} 
	var fieldID = this.fieldID
	//myTrace("fieldFeedback " + fieldID);
	var me = _global.ORCHID.LoadedExercises[0];
	var thisField = me.getField(fieldID);	
	var thisGroupID = thisField.group;
	//trace("look for group " + thisGroupID);
	var groupArrayIDX = lookupArrayItem(me.body.text.group, thisGroupID, "ID");
	//myTrace("found group idx "+groupArrayIDX + " containing fields " + thisGroup.fieldsInGroup[i].toString());
	var thisGroup;
	if (groupArrayIDX >= 0){
		thisGroup = me.body.text.group[groupArrayIDX];
	}
	// v6.5.5.8 It is useful to save the field so that you can (perhaps amongst other things) display feedback next to it
	saveThisField(thisField);
	
	// v6.3.4 Group vs individual feedback
	// v6.3.4 Every field should know the fb it is supposed to show, no matter what the settings
	//if (me.settings.feedback.groupBased) {
	//	myTrace("group feedback id=" + thisGroup.correctFbID);
	//	feedbackArrayIDX = lookupArrayItem(me.feedback, thisGroup.correctFbID, "ID");
	//} else {
	//	myTrace("individual feedback id=" + thisField.answer[0].feedback);
		feedbackArrayIDX = lookupArrayItem(me.feedback, thisField.answer[0].feedback, "ID");
	//}
	//trace("found fb idx "+feedbackArrayIDX);
	if (feedbackArrayIDX >= 0){
		var thisFeedback = me.feedback[feedbackArrayIDX].text;
		//trace(thisFeedback.toString());
	} else {
		var thisFeedback = undefined; 
		//trace("uhhh, there is no feedback for this field " + thisFbID);
	}
	// put in their answer (if blank)
	// v6.3.4 Move attempt from group to field (but this only puts in part of the answer)
	//if (thisGroup.attempt.finalAnswer == null || thisGroup.attempt.finalAnswer == "") {
	//	stdAnswer = "____";
	//} else {
	//	stdAnswer = thisGroup.attempt.finalAnswer;
	//}
	// v6.3.4 For groups (multipart or not), the #ya# comes from all fields in the group, not just this one
	var makeYAAnswer = new Array();
	var thisAnswer;
	for (var i in thisGroup.fieldsInGroup) {
		thisAnswer = me.body.text.field[thisGroup.fieldsInGroup[i]].attempt.finalAnswer;
		//myTrace("fig " + i + "=" +thisAnswer);
		if (thisAnswer != null && thisAnswer != "") {
			makeYAAnswer.push(thisAnswer);
		}
	}
	if (makeYAAnswer.length==0) makeYAAnswer.push("_____");
	stdAnswer =makeYAAnswer.join("/");

	// v6.2 UGLY (but effective) work round for different buttons on the fb window at different times
	var setting = "Instant";
	//myTrace("after marking instant feedback");
	var correct = undefined; // They are clicking to see fb for each option, no such thing as right or wrong
	// where is this function?
	//v6.3.5 Also pass the correct answer 
	//var correctAnswer = thisField.answer[0].value; // No, not true. What is it really?
	var correctAnswer = thisGroup.correctAnswer;
	//myTrace("correct answer from group=" + correctAnswer);
	displayFeedback(thisFeedback, correct, stdAnswer, correctAnswer, thisGroup.questionNumber, setting);
	// v6.4.2.7 Finally acknowledge that you have seen (at least some) feedback
	_global.ORCHID.LoadedExercises[0].feedbackSeen = true;
}

displayHint = function(thisField) {
	// v6.2 Now, it is possible/likely/certain that the last typing box didn't insert it's answer into it's field
	// so we should do it for it.
	// v6.3.4 No longer - correctly handled by the selection listener
	//if (_global.ORCHID.session.currentItem.lastGap != undefined) {
	//	//trace("doing the last insert");
	//	insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
	//	_global.ORCHID.session.currentItem.lastGap = undefined;
	//}
	//myTrace("show a hint for field " + thisField.id);
	// CUP does not use hints at all
	// This is all done in onFieldMouseUp now
	// v6.4.2.7 Try to add the glossary to drags and to highlight words
	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
	//	myTrace("EGU ctrl-click on " + thisField.type + " so lookup " + thisField.answer[0].value);
	//	if (thisField.type == "i:highlight" || thisField.type == "i:drag") {
	//		_global.ORCHID.onControlClick(thisField.answer[0].value); 
	//	}
	//	return;
	//}
	var me = _global.ORCHID.LoadedExercises[0];
	var thisGroupID = thisField.group;
	hintArrayIDX = lookupArrayItem(me.hint, thisGroupID, "ID");
	//myTrace("found hint idx "+hintArrayIDX);
	if (hintArrayIDX >= 0){
		var thisHint = me.hint[hintArrayIDX].text;
		//myTrace("hint=" + thisHint);
	} else {
		// CUP does not use hints at all
		//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		//	return;
		//}
		var noHintNote = {style:"normal", coordinates:{x:"+0", y:"+0", width:"360"}};
		//noHintNote.plainText = "Sorry, there is no hint for this question.";
		// 6.0.4.0, take the no hint message from literal model
		noHintNote.plainText = '<font face="Verdana" size="12">' + _global.ORCHID.literalModelObj.getLiteral("noHint", "messages") + '</font>';
		var thisHint = {paragraph:[noHintNote]};
	}
	var substList = new Array();
	putParagraphsOnTheScreen(thisHint, "drag pane", "Hint_SP", substList);
}

// v6.2 a new function to clear the marking from a field that the student has cleared
singleClearMarking = function(thisField) {
	myTrace("singleClearMarking");
	var me = _global.ORCHID.LoadedExercises[0];
	// visually clearing the field selection/data entry first
	if (thisField.type == "i:drop") {
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			var emptyAnswer = "     ";
		} else {
			var emptyAnswer = "  •  ";
		}
		insertAnswerIntoField(thisField, emptyAnswer);
		//trace("enable drag field " + thisField.linkedField);
		restoreFieldAppearance(me.getField(thisField.linkedField), true);
		thisField.linkedField = undefined;
	} else if (thisField.type == "i:dropInsert") {
		var originalAnswer = thisField.answer[0].value;
		//myTrace("put drop back to original (" + originalAnswer + ")");
		insertAnswerIntoField(thisField, originalAnswer);
		//trace("enable drag field " + thisField.linkedField);
		restoreFieldAppearance(me.getField(thisField.linkedField), true);
		thisField.linkedField = undefined;

	} else if (thisField.type == "i:target") {
		//trace("restore field appearance on " + thisField.id);
		restoreFieldAppearance(thisField);
	}

	// Check that you haven't done mainMarking.seeTheAnswers as after that scores and colours are not changed
	// the only thing that can happen is that you get to see instant feedback
	// v6.3.3 Move marking status to currentItem
	if (!_global.ORCHID.session.currentItem.afterMarking) {
		var thisGroupID = thisField.group;
		var groupArrayIDX = lookupArrayItem(me.body.text.group, thisGroupID, "ID");
		var thisGroup;
		if (groupArrayIDX >= 0){
			thisGroup = me.body.text.group[groupArrayIDX];
		};
		// only clear the score if it is delayed marking, as with instant marking only the first attempt counts
		//v 6.3.3 change mode to settings
		//if (!(me.mode & _global.ORCHID.exMode.InstantMarking)) {
		// v6.4.3 Actually, this isn't really true. With instant your wrong goes do add up, but you should get credit for getting it right in the end
		// Also, for group exercises, if you don't clear the marking you will not display the answers correctly.
		// For now, just clear this if it is instant grouping as well.
		//if (me.settings.marking.delayed) {
		if (me.settings.marking.delayed || me.settings.exercise.grouping) {
			//myTrace("clear score for group " + thisGroupID);
			//thisGroup.attempt.score = undefined;
			thisField.attempt.score = undefined;
		}
		// but always clear the finalAnswer as that is used to determine the toggle for this binary field
		//thisGroup.attempt.finalAnswer = undefined;
		thisField.attempt.finalAnswer = undefined;
		// v6.5.4.2 Yiu, fixing 1227, added new variable
		thisField.attempt.firstAnswer = undefined;
	}
}	
// This function will take the answer a student chose, silently mark it and saves the result
// in the internal marking object. It returns "right", "wrong", "neutral"
singleMarking = function(thisField, stdAnswer) {
	// v6.3.2 To allow for knowing that something has been done whilst viewing an exercise,
	// note if this singleMarking is called at all.
	_global.ORCHID.session.currentItem.scoreDirty = true;
	
	// v6.2 This should be done somewhere during display really. For a gapfill, if the first thing you do
	// is to try and insert empty space, then you don't call singleMarking, but you need origTextFormat
	// to measure gap width.
	// if this is the first time that this field has been marked, save its textFormat for restoring colouring
	if (thisField.origTextFormat == undefined) {
		// v6.2 use getRegion
		//var contentHolder = _root.exerciseHolder.Exercise_SP.getScrollContent();
		var contentHolder = getRegion(thisField).getScrollContent();
		var thisParaBox = contentHolder["ExerciseBox" + thisField.paraNum];
		// use the component to get the TextFormat of the field
		thisField.origTextFormat = thisParaBox.getFieldTextFormat(thisField.id);
		//myTrace("for field " + thisField.id + " save TF.leading as " + thisField.origTextFormat.leading);
		//trace("setting oTF to = " + thisField.origTextFormat.font + " " + thisField.origTextFormat.size);
	}
	// v6.3.4 Drop fields should always be underlined, no matter what
	// And target gaps once you have clicked on them once
	//if (thisField.type == "i:drop" || thisField.type == "i:targetGap") {
	if (thisField.type == "i:drop") {
		thisField.origTextFormat.underline = true;
		//myTrace("make the drop underlined=" + thisField.origTextFormat.underline);
	}
	//myTrace("in single marking");
	
	var me = _global.ORCHID.LoadedExercises[0];
	//trace("in singleMarking, ex.mode=" + me.mode);
	// match the selected/typed answer against those in the field
	// for target spotting and multiple choice, there will only ever be 1 answer per field
	// and save this answer in the score object
	// how you save scores depends on instant marking
	// find the group that this field is in
	var thisGroupID = thisField.group;
	//myTrace("look for group " + thisGroupID);
	//for (var i in me.text.group) { trace("group[" + i + "].ID=" + me.text.group[i].ID)}; 
	var groupArrayIDX = lookupArrayItem(me.body.text.group, thisGroupID, "ID");
	//myTrace("found group idx "+groupArrayIDX);
	var thisGroup;
	if (groupArrayIDX >= 0){
		thisGroup = me.body.text.group[groupArrayIDX];
	};
	// debug only
	//for (var i in me.body.text.group) {
	//	myTrace("group " + me.body.text.group[i].ID + " has pop-up field " + me.body.text.group[i].popup.fieldID);
	//}

	// Check that you haven't done mainMarking.seeTheAnswers as after that scores and colours are not changed
	// the only thing that can happen is that you get to see instant feedback
	// v6.3.3 move marking status to currentItem
	//if (!(me.mode & _global.ORCHID.exMode.MarkingDone)) {
	if (!_global.ORCHID.session.currentItem.afterMarking){

		// You don't want to create a score if the marking is neutral
		// v6.3.3 change mode to settings
		//if (me.mode & _global.ORCHID.exMode.NeutralMarking) {
		// v6.3.4 targetGap might have answer[0] as false and answer[1] as the main correct one
		// But if it is a red-herring, answer[0] will be correct
		// Note: Maybe this should be replaced with a loop to simply get the first correct one
		// No, because you are finding the default answer, not the correct one here
		//if (thisField.type == "i:targetGap" || thisField.type == "i:presetGap") {
		if (thisField.type == "i:targetGap") {
			var i=0;
			while (thisField.answer[i].correct == "false" &&
					i< thisField.answer.length) {
				i++;
			}
			var answerIdx = i;
		} else {
			var answerIdx = 0;
		}
		//v6.4.1 neutral is a feedback attribute, not a marking one
		//if (me.settings.marking.neutral) {
		if (me.settings.feedback.neutral) {
			myTrace("neutral marking on this field");
			//thisGroup.attempt.score = null;
			thisField.attempt.score = null;
			var thisFbID = thisField.answer[answerIdx].feedback; // v6.5.1 Yiu commented
			//var thisFbID = thisField.group;	// v6.5.1 Yiu Use group id to find the feedback instead
			stdAnswer = thisField.answer[answerIdx].value;
			//myTrace("for neutral marking, stdAnswer=" + stdAnswer + " fbid=" + thisFbID);
		} else {
			// *****
			// SCORING section
			// *****
			//trace("marking " +stdAnswer + " against field " + thisField.id);
			var correct = "neutral";
			if (thisField.type == "i:target"){
				// v6.2 if this is a singleField that has already been selected, just deselect it
				// (plus clear the answer if delayed marking - which singleClearMarking does).
				// v6.3.4 Move attempt from group to field
				if (thisGroup.singleField && thisField.attempt.finalAnswer != undefined) {
					//trace("this is a binary field that is already clicked");
					singleClearMarking(thisField);
					// v6.2 this is all you want to do for a target that has been 'unclicked'
					// v6.2 Apart from unclick one item if limited
					_global.ORCHID.session.currentItem.clicks--;
					return;
				// v6.3.4 or with special multi options, you might need to click off an option
				} else if (me.settings.exercise.multiPart && thisField.attempt.finalAnswer != undefined) {
					//myTrace("this is a multiple field that is already clicked");
					singleClearMarking(thisField);
					// v6.3.4 AGU - at this point we should remove this selection from the pop-up
					// see comment below for inserting pop-ups
					var popupField = me.getField(thisGroup.popup.fieldID);
					// v6.3.4 AGU - once you have multipart fields, the pop-up should actually include each
					// option you select, not JUST the option you select. This is tricky as you need to append
					// the answer to what is there - and also remove it if you are unselecting an option (see above)
					var stdAnswerArray = new Array();
					var myFields = me.body.text.field;
					for (var field in thisGroup.fieldsInGroup) {
						//myTrace("for group " + myGroups[k].ID + " add field " + myGroups[k].fieldsInGroup[field] + " stdAnswer=" + myFields[myGroups[k].fieldsInGroup[field]].attempt.finalAnswer);
						if (myFields[thisGroup.fieldsInGroup[field]].attempt.finalAnswer != undefined) {
							stdAnswerArray.push(myFields[thisGroup.fieldsInGroup[field]].attempt.finalAnswer);
						}
					}
					var currentText = stdAnswerArray.join("/");
					if (currentText == "") {
						currentText = "  *  ";
					}
					//myTrace("each selected option=" + currentText);
					insertAnswerIntoField(popupField, currentText, false);
					
					return;
				// v6.2 Limit the number of clicks you can have in a target spotting (CUP)
				} else if ((_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) &&
					(_global.ORCHID.session.currentItem.clickLimit > 0) &&
					(_global.ORCHID.session.currentItem.clicks >= _global.ORCHID.session.currentItem.clickLimit)) {
					// display a warning that they have to do some unclicking
					// and get out
					//trace("you have already clicked " + _global.ORCHID.session.currentItem.clicks + " times, that is the limit.");
					_global.ORCHID.viewObj.displayMsgBox("clickLimit", _global.ORCHID.session.currentItem.clicks);
					return;
				} else {
					_global.ORCHID.session.currentItem.clicks++;
					//trace("you have now clicked " + _global.ORCHID.session.currentItem.clicks + " times. (" + _global.ORCHID.session.currentItem.clickLimit + ")");
					// v6.3.4 Making group based feedback work
					// I think this should be the same as each field has the correct fb in it
					//if (me.settings.feedback.groupBased) {
					//	var thisFbID = thisGroup.correctFbID;						
						//myTrace("use group feedback for group " + thisGroup.ID + " = " + thisGroup.correctFbID);
					//} else {
						var thisFbID = thisField.answer[answerIdx].feedback;	// v6.5 1 Yiu commented
						//var thisFbID = thisField.group;	// v6.5.1 Yiu Use group id to find the feedback instead
					//}
					correct = thisField.answer[answerIdx].correct;
					// v6.3.4 Move attempt from group to field
					//thisGroup.attempt.finalAnswer = thisField.answer[0].value;
					// v6.4.2.4 This has to go into the following conditional as you don't do it in a second attempt at instant marking
					//thisField.attempt.finalAnswer = thisField.answer[0].value;
					// also save the text of the selection in stdAnswer to make later marking consistent with other field types
					stdAnswer = thisField.answer[answerIdx].value;
					// v6.3.4 Move attempt from group to field - don't think I need this anymore
					//thisGroup.attempt.feedbackID = thisFbID;
					// v6.3.3 Change mode to settings
					//if (me.mode & _global.ORCHID.exMode.InstantMarking) {
					if (me.settings.marking.instant) {
						//myTrace("instant marking on this field");
						// if it is instant marking, then only the first attempt counts
						// v6.3.4 Move attempt from group to field
						//if (thisGroup.attempt.score === undefined) {
						// v6.4.2.4 But surely it is the first attempt at the group in an m/c - not just the field.
						//if (thisField.attempt.score === undefined) {
						var firstAttempt = true;
						if (thisField.group != undefined) {
							// if a field is in a group during instant marking, only score it if it is the first attempt
							for (i in me.body.text.field) { 
								var testField = me.body.text.field[i];
								if (testField.group == thisField.group && testField.id != thisField.id) {
									if (testField.attempt.score != undefined) {
										var firstAttempt = false;
										break;
									}
								}
							}	
						}
						if (firstAttempt) {
							// as this is the first attempt, set the score to 1 or 0 and remember their selection
							//trace("instant marking, correct=" + correct);
							if (correct == "true") {
								//thisGroup.attempt.score = 1;
								thisField.attempt.score = 1;
							} else if (correct == "false") {
								//thisGroup.attempt.score = 0;
								// v6.3.4 For multiple options, getting one wrong is so bad
								if (me.settings.exercise.multiPart) {
									thisField.attempt.score = -1;
								} else {
									thisField.attempt.score = 0;
								}
							} else {
								//thisGroup.attempt.score = null;
								thisField.attempt.score = null;
							}
							// Also save the first answer
							//thisGroup.attempt.firstAnswer = thisGroup.attempt.finalAnswer;
							//myTrace("first attempt, so score=" + thisField.attempt.score);
							// v6.4.2.4 This has to go into the following conditional as you don't do it in a second attempt at instant marking
							thisField.attempt.finalAnswer = thisField.answer[answerIdx].value;
						} else {
							//myTrace("extra attempt, so score=" + thisField.attempt.score);
						}
					} else {
						// v6.4.2.4 This has to go into this conditional as you don't do it in a second attempt at instant marking
						thisField.attempt.finalAnswer = thisField.answer[answerIdx].value;
						//myTrace("this field has score " + Number(correct));
						// this is delayed marking so all attempts count until mainMarking
						// v6.3.4 Move attempt from group to field
						if (correct == "true") {
							//thisGroup.attempt.score = 1;
							thisField.attempt.score = 1;
						} else if (correct == "false") {
							//thisGroup.attempt.score = 0;
							// v6.3.4 For multiple options, getting one wrong is so bad
							if (me.settings.exercise.multiPart) {
								thisField.attempt.score = -1;
							} else {
								thisField.attempt.score = 0;
							}
						// v6.4.2 For survey questions, the correct attribute holds a value
						} else if (Number(correct) > 0) {
							thisField.attempt.score = Number(correct);
						} else {
							//thisGroup.attempt.score = null;
							thisField.attempt.score = null;
						}
					}
					//trace("still thisGroup.attempt.score=" + thisGroup.attempt.score);
					//myTrace("score for this field=" + thisField.attempt.score);
				}
			} else if (thisField.type == "i:gap" || thisField.type == "i:drop" 
										|| thisField.type == "i:dropInsert" 
										|| thisField.type == "i:dropdown" 
										//|| thisField.type == "i:presetGap" 
										|| thisField.type == "i:targetGap") {
			// match what they typed or dropped in the typing box and sort out feedback
			// there will be many answers, some correct others not
				var thisFbID = thisField.answer[answerIdx].feedback; // use this if no specific feedback found
				// thisFbID = thisField.id; // even gaps can be part of groups (essential as you might mix gaps and m/c in 1 exercise)
				// v6.3.4 Move attempt from group to field

				// v6.5.4.2 Yiu, fixing 1227,  let's set the finalAnswer once so we will know what is the first answer of the user
				// first answer stored for later use	
				if (thisField.attempt.finalAnswer == undefined) thisField.attempt.firstAnswer = stdAnswer;
				thisField.attempt.finalAnswer = stdAnswer; // always record this answer to use in delayed feedback

				// can you match what they typed/dropped/chose against an 'expected' answer?
				// v6.2 cope with someone removing a drop or typing in blanks
				if (stdAnswer == "") {
					correct = undefined;
				} else {
					correct = "false";
				}
				//if (thisField.type == "i:dropdown") {
				//	for (i in thisField.answer){
				//		//trace("comparing "+stdAnswer+" against "+thisField.answer[i].value);
				//		if (stdAnswer == thisField.answer[i].value) { // && thisField.answer[i].correct) {
				//			thisFbID = thisField.answer[i].feedback; // this might overwrite the general fb for this field
				//			correct = thisField.answer[i].correct;
				//			//trace("matched against "+thisField.answer[i].value+" which is correct="+correct)
				//			break;
				//		}
				//	}
				//} else {
				//v6.4.1 If you are doing a gapfill or drag with groups, then this means that the text in this
				// field needs to be matched against all other fields' answers in this group. Or at least
				// it does at the moment. Later it might also need a new setting.
				//myTrace("fieldsInGroup.length=" + thisGroup.fieldsInGroup.length);
				// v6.4.2.4 This DOES NOT work for drags into a group. The groups get counted as 1 question only.
				// the matching is working but I end up showing everything as correct and with a totally wrong score.
				// I guess I will need to separate group (that which constitutes a question/mark) and grouping (for multiple matching)
				if (thisGroup.fieldsInGroup.length > 1 ){
					//myTrace("this field is one of a group");
					var fieldsArray = new Array();
					var myFields = me.body.text.field;
					var foundMatch = false;
					for (var field in thisGroup.fieldsInGroup) {
						var eachField = myFields[thisGroup.fieldsInGroup[field]];
						for (i in eachField.answer){
							//myTrace("comparing "+stdAnswer+" against "+eachField.answer[i].value);
							if (answerMatch(stdAnswer,eachField.answer[i].value)) {
								thisFbID = eachField.answer[i].feedback; // this might overwrite the general fb for this field
								correct = eachField.answer[i].correct;
								//myTrace("matched against "+thisField.answer[i].value+" which is correct="+correct)
								foundMatch = true;
								break;
							}
						}
						if (foundMatch) break;
					}
				// v6.4.3 If this is a grouping exercise, you want to match against all answers in this section
				// (but it is not a part of a whole thing like the above)
				} else if (me.settings.exercise.grouping && thisField.section<>undefined) {
					//myTrace("regular field in section " + thisField.section);
					var sections = me.body.text.section;
					var myFields = me.body.text.field;
					var foundMatch = false;
					for (var s in sections) {
						// Get the section and find all fields in that section.
						// Is this field also part of the same grouping? In which case use its answer(s) as well for matching
						// But how to make sure I only match against this answer once? And can I use the same field
						// to then help with inserting answers that weren't matched later on?
						if (sections[s].ID == thisField.section) {
							//myTrace("found matching section");
							for (var f in sections[s].fieldsInSection) {
								// In which case use its answer(s) as well for matching
								// But how to make sure I only match against this answer once? And can I use the same field
								// to then help with inserting answers that weren't matched later on?
								// v6.4.3 But this comes undone when I put a correct answer in, then decide to move it elsewhere
								// as I am not clearing it out from the usedInMarking. With drags it should be OK to remove when I 
								// take the drag out, but what about typing? How can I know? 
								// So you will have to compare the found match against other current group answers rather than
								// a static list.
								var myFieldInSection = sections[s].fieldsInSection[f];
								//myTrace("fieldsInSections.fieldID=" + myFieldInSection.id);
								var field = myFieldInSection.idx;
								for (i in myFields[field].answer) {
									//myTrace("comparing "+stdAnswer+" against "+thisField.answer[i].value);
									if (answerMatch(stdAnswer,myFields[field].answer[i].value)) {
										// only use each answer once (to avoid them typing the same answer many times)
										// So I need to see if I have used this matching field's answers with another field in the section
										var usedInMarking = false;
										//myTrace(thisField.attempt.finalAnswer + " matches to an answer from field " + myFields[field].id);
										var haveIusedThisField = myFields[field];
										for (var allAns in haveIusedThisField.answer) {
											//myTrace("whose other answers include " + haveIusedThisField.answer[allAns].value);
											for (var stdAns in sections[s].fieldsInSection) {
												// ignore the one you are trying to mark
												if (thisField.id <> sections[s].fieldsInSection[stdAns].id) {
													if (answerMatch(myFields[sections[s].fieldsInSection[stdAns].idx].attempt.finalAnswer, haveIusedThisField.answer[allAns].value)) {
														//myTrace("which already used in " + sections[s].fieldsInSection[stdAns].id + "..." + myFields[sections[s].fieldsInSection[stdAns].idx].attempt.finalAnswer);
														usedInMarking = true;
														break;
													}
												}
											}
										}
										// So, if I hadn't used that answer for another field, I can mark it right here
										//if (!myFieldInSection.usedInMarking) {
										if (usedInMarking) {
											//myTrace("your answer matched, but has already been used");
										} else {
											thisFbID = myFields[field].answer[i].feedback; // this might overwrite the general fb for this field
											correct = myFields[field].answer[i].correct;
											//myTrace("matched against "+thisField.answer[i].value+" which is correct="+correct)
											// I do still need to know this to help with inserting
											myFieldInSection.usedInMarking = true;
											foundMatch = true;
											break;
										}
									}
								}
								if (foundMatch) break;
							}
							// there is only one section that can match
							break;
						}
					}
					//myTrace("matched=" + foundMatch);
				} else {
					//myTrace("regular field on its own");
					for (i in thisField.answer){
						//myTrace("comparing "+stdAnswer+" against "+thisField.answer[i].value);
						if (answerMatch(stdAnswer,thisField.answer[i].value)) {
							thisFbID = thisField.answer[i].feedback; // this might overwrite the general fb for this field
							correct = thisField.answer[i].correct;
							//myTrace("matched against "+thisField.answer[i].value+" which is correct="+correct)
							break;
						}
					}
				}
				//}
				// if it is instant marking, then only the first attempt counts
				// v6.3.3 Change mode to settings
				//if (me.mode & _global.ORCHID.exMode.InstantMarking) {
				if (me.settings.marking.instant) {
					//myTrace("instant marking on this field");
					// v6.3.4 Move attempt from group to field
					//if (thisGroup.attempt.score === undefined) {
					if (thisField.attempt.score === undefined) {
						// so this is the first attempt, so set the score to 1 or 0 and record the answer
						if (correct == "true") {
							//thisGroup.attempt.score = 1;
							thisField.attempt.score = 1;
						} else if (correct == "false") {
							//thisGroup.attempt.score = 0;
							thisField.attempt.score = 0;
						} else {
							//thisGroup.attempt.score = null;
							thisField.attempt.score = null;
						}
					}
				} else {
					//myTrace("delayed marking on this field, correct=" + correct);
					// this is delayed marking to all attempts count until mainMarking
					// v6.3.4 If this is group based, then each score must be stored in the field rather than the group
					//var thisTarget = thisGroup;
					var thisTarget = thisField;
					if (correct == "true") {
						thisTarget.attempt.score = 1;
					} else if (correct == "false") {
						thisTarget.attempt.score = 0;
					} else {
						thisTarget.attempt.score = null;
					}
				}
				//myTrace("score for this field=" + thisField.attempt.score);
			}
		}
		//trace("marked it as "+correct+" - "+thisGroup.attempt.finalAnswer);
		// *****
		// COLOURING AND INSERTING section
		// *****
		// next change the appearance and contents of the field to show it has been "answered"
		// if the marking is instant, you can show the right or wrong with the colour, if it
		// is not, then you show a neutral colour/highlight
		// If you have answered a gapfill or a drop, this should insert the answer into the field
		// v6.2 You can no longer do this for gaps due to focus problems. It will be handled
		// separately.
		//if (thisField.type == "i:gap" || thisField.type == "i:drop" || thisField.type == "i:dropdown") {
		// v6.3.4 New field type of dropInsert - same behaviour as drop?
		if (thisField.type == "i:drop"|| thisField.type == "i:dropInsert" ) {
			insertAnswerIntoField(thisField, stdAnswer, false);
		//} else if (thisField.type == "i:gap" || thisField.type == "i:presetGap") { // try adding gaps back in again here
		//} else if (thisField.type == "i:gap") { 
		} else if (thisField.type == "i:gap" || thisField.type == "i:targetGap") { 
			//myTrace("singleMarking:1316:add back " + stdAnswer);
			insertAnswerIntoField(thisField, stdAnswer, true);
		// v6.4.3 For targetGaps do you need to put the typed answer back into the full twf, not just in the cover?
		// well, this does mean that the correct stuff is always displayed, but also 'hides' the gap again and continually
		// changes line lengths, so isn't really great. The only problem with the original way is when you have two gaps in 
		// one TWF. Only one cover seems to contain the answer, even though it reappears when you click and marking is correct.
		//} else if (thisField.type == "i:targetGap") { // try adding gaps back in again here
		//	myTrace("singleMarking:1320:add back " + stdAnswer);
		//	insertAnswerIntoField(thisField, stdAnswer, false);
		} else if (thisField.type == "i:dropdown") {
			insertAnswerIntoField(thisField, stdAnswer, true);
		// v6.3.5 Change behaviour of targetGap/presetGap
		/*
		} else if (thisField.type == "i:targetGap") {
			//myTrace("full insert of " + stdAnswer);
			// v6.3.4 this has to be a full insert otherwise you don't lose the cover functions from the field
			// under the typing box and a click on another field is grabbed by this cover.
			// v6.3.5 It seems to be troublesome - if you leave this as false, then you need to double
			// click on another gap to get it to take focus, but if you leave as true, then you lose the
			//text from the cover when  you move around.
			insertAnswerIntoField(thisField, stdAnswer, true);
		*/
		}
		// if it is instant marking you can show correct and wrong answers immediately
		// v6.3.3 Change mode to settings
		//if (me.mode & _global.ORCHID.exMode.InstantMarking) {
		if (me.settings.marking.instant) {
			if (correct  == "true") {
				//v6.4.2.4 Surely a proofreading should have different colour here?
				if (_global.ORCHID.LoadedExercises[0].settings.exercise.proofReading) {
					changeFieldAppearance(thisField, _global.ORCHID.PRYouWereCorrectText);
				} else {
					changeFieldAppearance(thisField, _global.ORCHID.YouWereCorrectText);
				}
				// v6.4.2.7 Also show a tick or cross for the instant answer
				// This works fine, except that since the fields are still active, fieldRollOut will clear the 
				// fieldBackground (since you also use it for the highlighting effect)
				// So I either need to dissolve the tick/cross slowly, which would be OK, or to add a new
				// layer that I can use for tick/cross separate from fieldBackground.
				//var offsetX=tickWidth; var oneLine=true;
				// v6.4.2.7 And you might need to remove an old tick or cross from this field
				// no - that is handled within setTicking
				setTicking(thisField, "Tick")
				
			} else if (correct == "false") {
				//v6.4.2.4 Surely a proofreading should have different colour here?
				if (_global.ORCHID.LoadedExercises[0].settings.exercise.proofReading) {
					changeFieldAppearance(thisField, _global.ORCHID.PRYouWereWrongText);
				} else {
					changeFieldAppearance(thisField, _global.ORCHID.YouWereWrongText);
				}
				// v6.4.2.7 Also show a tick or cross for the instant answer
				//var offsetX=crossWidth; var oneLine=true;
				setTicking(thisField, "Cross")
			} else {
				// Why would you want to change a neutral field's appearance??
				// v6.4.1 Agree, remove this line
				// v6.4.2.4 Not sure about this decision any more, it seems simple to at least underline it
				//changeFieldAppearance(thisField, _global.ORCHID.NeutralText);
				//changeFieldAppearance(thisField, _global.ORCHID.UnderlineText);				
			}
			// v6.4.2.4 Since Sweet Biscuits doesn't use underlining in the above styles you won't get it when you are getting
			// instant marking, only on delayed marking. But I really think you should. Always.
			changeFieldAppearance(thisField, _global.ORCHID.UnderlineText);		
			
			// v6.3.4 Since group is not used for finalAttempt, you need to clear
			// the finalAttempt from the other fields in the group.
			// This will have the side effect of removing colouring from other selected fields
			// and frankly that would seem like a more reasonable behaviour anyway.
			deselectOtherFields(thisField);
		// otherwise for delayed marking, show targets as selected
		} else {
			if (thisField.type == "i:target"){
				//trace("select this field " + thisField.id);
				selectThisField(thisField, stdAnswer);
			}
		}
		// next see if there is a popup for this group
		//myTrace("popup field=" + thisGroup.popupFieldID + " so add " + stdAnswer + " to it.");
		if (thisGroup.popup.fieldID != undefined) { // && thisGroup.popupFieldID >= 0) {
			var popupField = me.getField(thisGroup.popup.fieldID);
			// v6.3.4 AGU - once you have multipart fields, the pop-up should actually include each
			// option you select, not JUST the option you select. This is tricky as you need to append
			// the answer to what is there - and also remove it if you are unselecting an option (see above)
			if (_global.ORCHID.LoadedExercises[0].settings.exercise.multiPart) {
				var stdAnswerArray = new Array();
				var myFields = me.body.text.field;
				for (var field in thisGroup.fieldsInGroup) {
					//myTrace("for group " + myGroups[k].ID + " add field " + myGroups[k].fieldsInGroup[field] + " stdAnswer=" + myFields[myGroups[k].fieldsInGroup[field]].attempt.finalAnswer);
					if (myFields[thisGroup.fieldsInGroup[field]].attempt.finalAnswer != undefined) {
						stdAnswerArray.push(myFields[thisGroup.fieldsInGroup[field]].attempt.finalAnswer);
					}
				}
				var currentText = stdAnswerArray.join("/");
				//myTrace("each selected option=" + currentText);
			} else {
				var currentText = stdAnswer;
			}
			insertAnswerIntoField(popupField, currentText, false)
			
			// v6.3.5 Save the current state of pop-up field contents to help with printing
			//myTrace("overwrite pop field["+ poopupField.id+ "]=" + currentText);
			popupField.answer[0].value = currentText;
			
			// CUP doesn't use sound effects
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			} else {
				// v6.3.4 Move branding stuff to buttons
				//_root.brandingHolder.soundEffect("click");
				_global.ORCHID.root.buttonsHolder.buttonsNS.soundEffect("click");
			}
		}
	}
	
	// *****
	// DISPLAY FEEDBACK section
	// *****
	// now, do you show this feedback instantly or delay it? It is first set by exercise mode, although
	// it can be overruled by an individual field.
	// v6.3.3 Change mode to settings
	//if (me.mode & _global.ORCHID.exMode.InstantMarking) {
	if (me.settings.marking.instant) {
		myTrace("going to show instant feedback");
		// v6.2 Now, it is possible/likely/certain that the last typing box didn't insert it's answer into it's field
		// so we should do it for it.
		// v6.3.4 No longer - correctly handled by the selection listener
		//if (_global.ORCHID.session.currentItem.lastGap != undefined) {
		//	//trace("doing the last insert from singleMarking (with instantFB)");
		//	insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
		//	_global.ORCHID.session.currentItem.lastGap = undefined;
		//}
		//myTrace("clicked on "+ thisGroup.attempt.finalAnswer+" so get fbID="+thisFbID + " questionNum=" + thisGroup.questionNumber);
		// now that you have the fb, display it
		// build a text field for each paragraph in this feedback and get its content from ExObj
		// feedback array is NOT based on the array index = ID
		//for (var i in me.feedback) { trace("feedback[" + i + "].ID=" + me.feedback[i].ID)}; 
		feedbackArrayIDX = lookupArrayItem(me.feedback, thisFbID, "ID");
		//trace("found fb idx "+feedbackArrayIDX);
		if (feedbackArrayIDX >= 0){
			var thisFeedback = me.feedback[feedbackArrayIDX].text;
			//trace(thisFeedback.toString());
			// v6.2 UGLY work round for different buttons on the fb window at different times
			var setting = "Instant";
			//myTrace("instant fb for answer=" + thisGroup.attempt.finalAnswer);
			// v6.3.4 Switch attempt from group to field
			// v6.3.4 You really need to merge each field's attempt into one for this feedback (unless it is an mc)
			// Since the ONLY case we have at present of group based instant fb IS mc, just leave it as it is
			//displayFeedback(thisFeedback, correct, thisGroup.attempt.finalAnswer, thisGroup.questionNumber, setting);
			// v6.3.5 Can you pass the correct answer to feedback as well so that #ca# can be implemented?
			//myTrace("instantFeedback, send correct=" + thisField.answer[answerIdx].value);
			var correctAnswer = thisField.answer[answerIdx].value;
			displayFeedback(thisFeedback, correct, thisField.attempt.finalAnswer, correctAnswer, thisGroup.questionNumber, setting);
			// v6.4.2.8 Can you also record that you have seen this feedback? It will help to avoid asking about feedback if you have already seen it all.
			me.feedback[feedbackArrayIDX].seen = true;
		} else {
			var thisFeedback = undefined; 
			//trace("uhhh, there is no feedback for this field " + thisFbID);
			// v6.4.2.8 If you are using tick and cross, there is no point in displaying
			//"you are right" for empty instant feedback. So move the below code to just
			// the first part of this conditional.
			// But you do still want to go to nextGap if possible. So duplicate the code from displayFeedback
			if (_global.ORCHID.session.currentItem.nextGap != undefined) {
				_global.ORCHID.session.currentItem.nextGap.interval.push(setInterval(makeNextTypingBox, 100));
			}

		}
		// sounds
		//trace("trying to run " + _root.brandingHolder.soundEffect);
		// CUP doesn't use sound effects
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		} else {
			if (correct == "true") {
				var effectType = "clap";
			} else if (correct == "false") {
				var effectType = "oops";
			} else {
				var effectType = "click";
			}
			// v6.3.4 Move branding stuff to buttons
			//_root.brandingHolder.soundEffect(effectType);
			// v6.3.5 And allow it to be turned off by the author (default is on)
			//myTrace("use soundEffects, course=" + _global.ORCHID.course.soundEffects + " ex=" + me.settings.misc.soundEffects);
			if (_global.ORCHID.course.soundEffects && me.settings.misc.soundEffects) {
				_global.ORCHID.root.buttonsHolder.buttonsNS.soundEffect(effectType);
			}
		}
		
	} else {
		// delayed feedback
		
		//if (thisField.type == "i:gap" || thisField.type == "i:presetGap") {
		// v6.4.3 target gaps in proofReading should NOT go to the next one! Need this elsewhere too?
		//if (thisField.type == "i:gap" || thisField.type == "i:targetGap") {
		// More sense to use hiddenTargets
		//if (thisField.type == "i:gap" || (thisField.type == "i:targetGap" && !_global.ORCHID.LoadedExercises[0].settings.exercise.proofReading)) {
		if (thisField.type == "i:gap" || (thisField.type == "i:targetGap" && !_global.ORCHID.LoadedExercises[0].settings.exercise.hiddenTargets)) {
			//myTrace("go to next gap from single marking? nextGap="+_global.ORCHID.session.currentItem.nextGap.field.id);
			// at the end of single marking, if there is no feedback, a gap expects to go to the next gap
			// No - try doing this after you have inserted the last answer directly
			//myTrace("singleMarking for " + _global.ORCHID.session.currentItem.nextGap);
			if (_global.ORCHID.session.currentItem.nextGap != undefined) {
				//myTrace("go to nextGap = " + _global.ORCHID.session.currentItem.nextGap.field.fieldID)
				// Don't actually do this now as singleMarking was called from the last typingBox
				// so make a setInterval to do it once the last box has been disappeared.
				// v6.4.2.8 But I think that this can let you end up hitting enter a couple of times quickly to trigger
				// this twice, so the interval then keeps running forever.
				// Now try with an array to stop double triggering the interval
				//_global.ORCHID.session.currentItem.nextGap.interval = setInterval(makeNextTypingBox, 100);
				_global.ORCHID.session.currentItem.nextGap.interval.push(setInterval(makeNextTypingBox, 100));	// v6.5.1 Yiu commented  // AR reset
				//_global.ORCHID.session.currentItem.nextGap.interval.push(setInterval(makeNextTypingBox, 300));// v6.5.1 Yiu increase the wait time to solve the problem of failed to go to another gap when use pressed Enter key
				//gotoNextGap(_global.ORCHID.session.currentItem.nextGap.field);
			}
		}
		//trace("exercise mode is " + me.mode);
		// if you are in a gapfill, goto the next gap now
		/*
		if (thisField.type == "i:gap") {
			trace("in a gap at the end of single marking");
			if (thisField.noGapJump) {
				// this is a HORRIBLE way of avoiding the gap jumping if you lost focus
				// by clicking somewhere else
				thisField.noGapJump = false;
			} else {
				trace("goto next gap from single marking");
				// v6.2 working on tabbing - but since we might be here some time after they
				// clicked, the shift key may no longer be down - especially if instant marking!
				//gotoNextGap(thisField);
				if (Key.isDown(Key.SHIFT)) {
					gotoPreviousGap(thisField);
				} else {
					gotoNextGap(thisField);
				}
			}
		}
		*/
	}
	//trace("finished single marking");
}
// This (global) function will insert the std's answer into a gap field
// v6.3.4 No longer - correctly handled by the selection listener
/*
delayInsertAnswer = function() {
	//trace("here in delay insert, clear int=" + _global.ORCHID.session.currentItem.lastGap.interval);
	clearInterval(_global.ORCHID.session.currentItem.lastGap.interval);
	if (_global.ORCHID.session.currentItem.lastGap != undefined) {
		insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
	};
	_global.ORCHID.session.currentItem.lastGap = undefined;
}
*/
// This (global) function will create a typing box for the previously saved "next" gap
makeNextTypingBox = function() {
	myTrace("makeNextTypingBox");
	// v6.4.2.8 Just in case this is triggered by more than one setInterval - use an array to hold the intervals
	//clearInterval(_global.ORCHID.session.currentItem.nextGap.interval);
	for (var i in _global.ORCHID.session.currentItem.nextGap.interval){
		clearInterval(_global.ORCHID.session.currentItem.nextGap.interval[i]);
	}
	
	if (_global.ORCHID.session.currentItem.nextGap != undefined) {
		// v6.5.5.8 It is useful to save the field so that you can (perhaps amongst other things) display feedback next to it
		saveThisField(_global.ORCHID.session.currentItem.nextGap.field);
		//_global.ORCHID.session.currentItem.thisGap = {field:_global.ORCHID.session.currentItem.nextGap.field, cover:_global.ORCHID.session.currentItem.nextGap.cover};
		
		//trace("make next typing box now");
		createTypingBox(_global.ORCHID.session.currentItem.nextGap.field, _global.ORCHID.session.currentItem.nextGap.cover);
	}
	_global.ORCHID.session.currentItem.nextGap = undefined;
	
}
// a function that compares answers according to rules
answerMatch = function(stdAnswer, trueAnswer) {
	// first, ignore leading and trailling spaces
	sA = stdAnswer.trim("both");
	tA = trueAnswer.trim("both");

	// also ignore multiple spaces in the answer
	sA = sA.trim("middle");
	tA = tA.trim("middle");
	
	// treat curly and straight apostrophe as the same
	sA = convertCurlyQuote(sA);
	tA = convertCurlyQuote(tA);
	//myTrace("after curlies comparing " + sA + " to " + tA);
	
	// capitalisation should be an authorable trait (set per exercise)
	// but for now it is just ignored
	sA = sA.toLowerCase();
	tA = tA.toLowerCase();
	
	// v6.3.5 If the true answer is a pure number, then get rid of , in the std answer
	// Should I get rid of . as well for Europeans? but this is also a decimal, needs more thought.
	if (!isNaN(Number(ta))) {
		sA = findReplace(sA, ",", "");
		//myTrace("number matching, so sA=" + sA);
	}
	if (sA == tA) {
		//myTrace("answerMatch say yes");
		return true;
	} else {
		//myTrace("answerMatch say no");
		return false;
	}
}
// v6.4.2.7 A rare function that looks at all the answers for a question and compares them against all answers for another question.
// It tells you if there are the same (barring the order)
allAnswersMatch = function(firstArray, secondArray) {
	// firstArray = [{value:xxx, correct:true}]
	var firstAnswers = firstArray.slice(0);
	var secondAnswers = secondArray.slice(0);
	firstAnswers.sortOn("value");
	secondAnswers.sortOn("value");
	for (var i in firstAnswers) {
		//myTrace("first.value=" + firstAnswers[i].value + " second.value=" + secondAnswers[i].value);
		//myTrace("first.correct=" + firstAnswers[i].correct + " second.correct=" + secondAnswers[i].correct);
		if ((firstAnswers[i].value.trim("both") <> secondAnswers[i].value.trim("both")) ||
			(firstAnswers[i].correct <> secondAnswers[i].correct)) {
			// we found something that is not the same, so out we go
			return false;
		}
	}
	return true;
}
// this function adds text to a fieldcover that is about to be dragged
createDragObject= function(thisField, dragField) {
	//myTrace("put '" + thisField.answer[0].value + "' into " + dragField);
	var fieldID = thisField.id;
	// since the fieldcover will have been scaled it isn't easy to attach the drag to it as it will pick up
	// the xscale and yscale. How about attaching it directly to the overlay as you do with the dropdown box?
	// Ahh, but the drag and drop functions are provided by the fieldCover themselves
	//var contentHolder = fieldCover._parent.overlay_mc.createEmptyMovieClip("myDrag",0);
	// So add a MC to fieldCover instead of using it direct and rescale that MC.
	var origXScale = dragField._xscale;
	var origYScale = dragField._yscale;
	// v6.2 Now you will use the mc I just created rather than the cover
	// so there doesn't seem much point in adding another mc under this purely dragging thing
	// Ahhh, but the reason for doing it is to allow you to normalise the _xscale of the drag
	var contentHolder = dragField.createEmptyMovieClip("drag",0); 
	//var contentHolder = fieldCover; 
	contentHolder._xscale = 10000 / origXScale;
	contentHolder._yscale = 10000 / origYScale;
	//trace("creating a drag field=" + fieldID); // + " xscale"+ contentHolder._xscale + " yscale=" + contentHolder._yscale);
	// create a new MC for dragging
	//myDrag = contentHolder["drag"+fieldID]; 
	// and put a text field in it that duplicates the text you want to drag
	//contentHolder.createTextField("dragText",2,fieldCover._x,fieldCover._y,fieldCover._width,fieldCover._height); 
	var myX = -2; myY = -4;
	contentHolder.createTextField("dragText",0,myX,myY,contentHolder._width,contentHolder._height); 
	//var thisTF = contentHolder.cover._parent.getFieldTextFormat(fieldID); 
	var thisTF = thisField.origTextFormat;
	//trace("use TF.size=" + thisTF.size);
	contentHolder.dragText.setNewTextFormat(thisTF);
	contentHolder.dragText.text = thisField.answer[0].value;
	//trace("drag text=" + text);
	contentHolder.dragText.autosize = "left";
	contentHolder.dragText.multiline = false;
	contentHolder.dragText.selectable = false;
	contentHolder.dragText.embedFonts = false;
	// v6.3.6 to debug overlaying problem for text that is more than single spaced
	//myTrace("this dragText has height=" + contentHolder._height);
	//contentHolder.dragText.border = true;
//	myDrag.fieldID = fieldID; // used for Drop function
//	myDrag.component = fieldCover._parent;
//	contentHolder.startDrag(false);
};

createSelectBox = function(thisField, fieldCover) {
	var fieldID = thisField.id;
	//myTrace("creating a select field=" + fieldID + ', cover=' + fieldCover );

	// try to get the style and size of the list box right
	var thisTF = fieldCover._parent.getFieldTextFormat(fieldID); 
	var myCalc = fieldCover._parent.widthCalc;
	myCalc._visible = false;
	myCalc.setNewTextFormat(thisTF);
	var myMax = 0; //fieldCover._width;

	// v6.2 Clear out the cover text so you appear to be typing on blank
	//v6.3.5 If I remove this I get the desired effect of leaving text in place if I don't make new choice
	// but for some reason I am losing the formatting of the list box font the second time I click.
	var currentText = fieldCover.getText();
	//myTrace("font=" + thisTF.font + ", " + thisTF.size);
	fieldCover.clearText();
	//myTrace("still font=" + thisTF.font + ", " + thisTF.size + ", text=" + currentText);

	// v6.2 Create a higher level mc for the gap just as is now done for the drag
	// v6.3.3 Move exercise panels to buttons holder
	//var gapHolder = _root.exerciseHolder.attachMovie("fieldCover","gapHolder", _global.ORCHID.selectDepth);
	var gapHolder = _global.ORCHID.root.buttonsHolder.ExerciseScreen.attachMovie("fieldCover","gapHolder", _global.ORCHID.selectDepth);
	// first find the global coordinates of the fieldCover
	//var coord = {x:this._x, y:this._y};
	var coord = {x:0, y:0};
	fieldCover.localToGlobal(coord);
	// v6.4.2 Since we might be off the zero, need to realign to match proxy root
	//myTrace("global x=" + coord.x + " proxy offset=" + _global.ORCHID.root._x);
	var rootXOffset = _global.ORCHID.root._x;
	var rootYOffset = _global.ORCHID.root._y;
	gapHolder._x = coord.x - rootXOffset;
	gapHolder._y = coord.y - rootYOffset;
	gapHolder._width = fieldCover._width;
	gapHolder._height = fieldCover._height;
	// v6.2 Now - because you are using fieldCover as a holding mc for the listbox, it will initially
	// be wider than the list box (why I don't know) and will stick out yellow. Make it white
	// to avoid having to do anything complicated with scaling or whatever.
	//new Color(gapHolder).setRGB(0xFFFFFF);
	// Ahh, you can't do that as everything, including the border will become white.
	//gapHolder._alpha = 10;
	// link the single gap back to the cover that it is currently working with
	gapHolder.cover = fieldCover;	
	var origXScale = fieldCover._xscale;
	var origYScale = fieldCover._yscale;
	//myTrace("width=" + gapHolder._width + " xscale=" + origXScale);
	// v6.2 Now you will use the mc I just created rather than the cover
	// so there doesn't seem much point in adding another mc under this purely gap thing
	// Ahhh, but the reason for doing it is to allow you to normalise the _xscale of the drag
	var contentHolder = gapHolder.createEmptyMovieClip("gap",0); 
	contentHolder._xscale = 10000 / origXScale;
	contentHolder._yscale = 10000 / origYScale;

	// figures from gapfill - which are pretty perfect
	//var myX = -2; myY = -4; myW = 4; myH = 4// adjustment so that the letters in the box are over the letters in the text
	var myX=-3; myY=-4; myW=4; myH=0
	var initObj = {_x:myX, _y:myY};
	// v6.2 - now use a special combo box that doesn't have the down arrow
	// v6.2 - well, better to just use a list box then! But what about see through to the underneath mc?
	// Do you want to put the listbox on the real top like the drags?
	//var myListBox_lb = fieldCover._parent.overlay_mc.attachMovie("FListBoxSymbol","selectBox"+fieldID,this.fieldID,initObj);
	var myListBox_lb = contentHolder.attachMovie("FListBoxSymbol","selectBox"+fieldID,this.fieldID,initObj);
	myListBox_lb.setAutoHideScrollBar(true);
	// v6.3.5 If you don't remove the cover text (fieldCover.clearText) earlier, then the size
	// of the text in the list box gets bigger, irrespective of what you do here. There is some
	// conflict of xscale perhaps? Leave it removed and simply add back text when you mouse out, see later
	myListBox_lb.setStyleProperty("textFont", thisTF.font); 
	myListBox_lb.setStyleProperty("textSize", thisTF.size); 
	myListBox_lb.setStyleProperty("textColor", thisTF.color); 
	
	// v6.3.4 It would be good to pick this colour up from buttons.ExerciseScreen.fakeTitle
	// v6.4.2.4 Not always it wouldn't! Some titles might be a bit dark (Buffy) and anyway. Where do I set the outline?
	// Ahhh, it is picked from FBoundingBox, which in (SweetBiscuit) some I set to no outline. Is it not a style property?
	var colourObj = new Color(_global.ORCHID.root.buttonsHolder.ExerciseScreen.titlePlaceHolder.titleColour);
	var cT = colourObj.getTransform();
	var myBackgroundColour = (cT.rb<<16) | (cT.gb<<8) | cT.bb;
	// v6.3.5 But maybe the whole box should be coloured and the selection highlighted?
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		// CUP interface uses preset coloured background
		myListBox_lb.setStyleProperty("selection", 0xADD7E7); 
	} else {
		myListBox_lb.setStyleProperty("background", myBackgroundColour);
		// and set the selection to??? This is another thing that should be set in the buttons.swf, not here
		myListBox_lb.setStyleProperty("selection", 0xFFCC00);
	}
	
	// copy the answer array and shuffle it
	//trace("default answer=" + thisField.answer[0].value);
	var myArray = thisField.answer.slice();
	shuffle(myArray);
	for (var i in myArray) {
		myListBox_lb.addItem(myArray[i].value);
		myCalc.text = myArray[i].value;
		if (myCalc.textWidth > myMax) myMax = myCalc.textWidth;
		//trace("item is: " + myArray[i].value + ", width=" + myMax);
	}
	//trace("after shuffle default answer=" + thisField.answer[0].value);
	// this is using a private call to the comboBox to get the depth/width of the arrow - not allowed!
	// v6.2 - not needed anymore as no more arrow!
	//myListBox_lb.measureItmHgt();
	//var arrowWidth = Math.ceil(myListBox_lb.itmHgt);
	//trace("cb width=" + myMax + "+" + arrowWidth + "+" + myW);
	//myListBox_lb.setSize(myMax+arrowWidth + myW);
	//myListBox_lb.setSize(myMax + myW + 4);
	// v6.2 Use a list box rather than a combo box. Set width and row count (items or 5 whichever is less)
	//myListBox_lb.setWidth(myMax + myW);
	myListBox_lb.setWidth(fieldCover._width + myW);
	myListBox_lb.setRowCount(Math.min(5, myArray.length));
	myListBox_lb.field = thisField;
	fieldCover.onSelect = function(component) {
		//trace("hello " + component.getSelectedItem().label);
		singleMarking(component.field, component.getSelectedItem().label);
		//myListBox_lb.removeMovieClip();
		//trace("remove " + myListBox_lb._parent._parent);
		//myTrace("selectBox: " + myListBox_lb._parent._parent + ".removeMovieClip")
		myListBox_lb._parent._parent.removeMovieClip();
		delete this.onSelect;
	}
	myListBox_lb.setChangeHandler("onSelect", fieldCover);
	// how to drop the combo box straight away?
	// this seems to work, but it isn't a public method of the comboBox, so beware!
	//myListBox_lb.openOrClose(true);
	
	// v6.3.4 Move this from end of function to here - see note in createTypingBox about cover not scrolling with text
	// scroll the pane if the comboBox is out of pane
	// v6.2 - use special combo box
	// v6.2 - now use a regular list box
	//var rtnObj = getOutOfPaneLength(myListBox_lb, "APComboBoxSymbol", _root.exerciseHolder.Exercise_SP, "FScrollPaneSymbol");
	// v6.3.3 Move exercise panels to buttons holder
	//var rtnObj = getOutOfPaneLength(myListBox_lb, "FListBoxSymbol", _root.exerciseHolder.Exercise_SP, "FScrollPaneSymbol");
	var rtnObj = getOutOfPaneLength(myListBox_lb, "FListBoxSymbol", _global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP, "FScrollPaneSymbol");
	if (rtnObj.bottom > 0) {
		//myTrace("scroll pane by " + rtnObj.bottom);
		//tempPos = _root.exerciseHolder.Exercise_SP.getScrollPosition();
		//_root.exerciseHolder.Exercise_SP.refreshPane();
		//_root.exerciseHolder.Exercise_SP.setScrollPosition(0, tempPos.y + rtnObj.bottom);
		tempPos = _global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.getScrollPosition();
		_global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.refreshPane();
		_global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.setScrollPosition(0, tempPos.y + rtnObj.bottom);
		// v6.3.4 also need to shift up the selection box as it doesn't scroll with scrollPane
		myListBox_lb._y -= rtnObj.bottom;
	}
	
	//var doIt = Selection.setFocus(myListBox_lb);
	//trace('set selection=' + doIt);
	//myListBox_lb.setSelectedIndex(0);
	// v6.2 How about removing the box if you mouse away from it? This gets rid of any
	// worries about scrolling/buttons leaving the box hanging
	// Yes this works, but the function stops the list box working within the mc! Rats
	//gapHolder.onRollOut = function() {
	//	this..removeMovieClip();
	//}
	// SO instead use hitTest and an interval to know if you are still over it.
	// If an item is selected in the normal way, the listBox will be removed which will kill the interval event
	myListBox_lb.checkOver = function() {
		//v6.4.2 rootless
		//if (!gapHolder.hitTest(_global.ORCHID.root._xmouse, _global.ORCHID.root._ymouse)) {
		if (!gapHolder.hitTest(_root._xmouse, _root._ymouse)) {
			// v6.3.5
			// since you are leaving without selecting anything, can we put back the original text? Yes.
			//myTrace("old text=" + currentText + " into cover=" + gapHolder.cover);
			gapHolder.cover.setText(currentText);
			//myTrace("selectBox: " + gapHolder + ".removeMovieClip")
			gapHolder.removeMovieClip();
			clearInterval(checkOverInt);
		}
	}
	var checkOverInt = setInterval(myListBox_lb, "checkOver", 500);
}

gapListener = new Object();
gapListener.onMouseDown = function() {
	if (Key.isDown(Key.CONTROL)) {
		// what if I don't do this here? It then works when I ctrl-click somewhere else as other field
		// reactions will pick it up (onMouseUp with modKey).  But it means that if I am typing and 
		// ctrl-click nothing happens. So I need to know if I am over the current field.
		// OK, so this only works when you ctrl-click on the field you are typing in. Other ctrl-clicks
		// are picked up by an event sent from the TWF (and glossary attempts are stifled for
		// fields).
		var thisGap = eval(Selection.getFocus());
		var thisPoint = {x:thisGap._x, y:thisGap._y};
		thisGap._parent.localToGlobal(thisPoint);
		//myTrace("control click - check against gap=" + thisGap + " x=" + thisPoint.x + ", y=" + thisPoint.y);
		if ((thisPoint.x > _root._xmouse) || ((thisPoint.x + thisGap._width) < _root._xmouse) ||
		    (thisPoint.y > _root._ymouse) || ((thisPoint.y + thisGap._height) < _root._ymouse)){
			//myTrace("ignore gap listener");
		} else {
			//myTrace("control click in gapListener");
			//var myTypingBox = this.gapFocus;
			//var fieldID = myTypingBox.fieldID;
			var fieldID = thisGap.fieldID;
			var me = _global.ORCHID.LoadedExercises[0];
			var thisField = me.getField(fieldID);
			this.displayHint = true;
			//myTrace("displayHint from gapListener")
			displayHint(thisField);
			// v6.3 This does NOT put the cursor back to the gap after a hint is shown
			Selection.setFocus(thisGap);
			// v6.4.2.7 I need to set mouseUpKey for the twf to stop ctrl-clicking in the twf
			//myTrace("the gap cover=" + thisGap.cover + " thisGap=" + thisGap + " so twf=" + thisGap.cover._parent);
			thisGap.cover._parent.mouseUpKey = Key.CONTROL;

		}
	}
}
gapListener.onKeyDown = function () {
	// you have to catch ENTER here, but only need to catch TAB if there are no tab enabled
	// movies on stage at the moment (because if not there is nothing to tab to so onKillFocus
	// cannot be triggered.
	// The only time you want to go to the next field is if you Enter or Tab to leave a field
	// so that is why you calculate the next gap here - or not.
	if (Key.getAscii() == Key.ENTER || Key.getAscii() == Key.TAB) {
		//myTrace("you ENTERED or TABBED");
		// warning to anyone still in command: if you don't do EVAL you will appear to get
		// back the correct object from a trace, but it is actually just a string!!
		var thisGap = eval(Selection.getFocus());
		//trace("this gap id=" + thisGap.fieldID + "(" + thisGap + ")");
		//trace("this gap component=" + thisGap.component);
		// immediately see which the next gap is, this is stored globally so
		// that anything that needs to can later use it in focussing
		var fieldID = thisGap.fieldID;
		var me = _global.ORCHID.LoadedExercises[0];
		var nextField = me.getNextGap(fieldID);
		//myTrace("gapListener.onKeyDown, the next gap is field " + nextField.id + " (" + nextField.type + ")");
		//if (nextField.type == "i:gap" || nextField.type == "i:presetGap") {
		// v6.4.3 target gaps in proofReading should NOT go to the next one! Need this elsewhere too?
		//if (nextField.type == "i:gap" || nextField.type == "i:targetGap") {
		// More sense to use hiddenTargets
		//if (nextField.type == "i:gap" || (nextField.type == "i:targetGap" && !_global.ORCHID.LoadedExercises[0].settings.exercise.proofReading)) {
		if (nextField.type == "i:gap" || (nextField.type == "i:targetGap" && !_global.ORCHID.LoadedExercises[0].settings.exercise.hiddenTargets)) {
			// now need to find which twf this field is in so that we can get the fieldCover
			// v6.2 use getRegion
			//var contentHolder = _root.exerciseHolder.Exercise_SP.getScrollContent();
			var contentHolder = getRegion(nextField).getScrollContent();
			var thisParaBox = contentHolder["ExerciseBox" + nextField.paraNum];
			thisCover = thisParaBox.getFieldObject(nextField.id).coords[0].coverMC;
			if (thisCover != undefined) {
				//myTrace("so save the next gap as " + thisCover);
				//_global.ORCHID.session.currentItem.nextGap = {field:nextField, cover:thisCover};
				// v6.4.2.8 Need an array to hold setInterval ids
				_global.ORCHID.session.currentItem.nextGap = {field:nextField, cover:thisCover, interval:[]};
			}
			// ALL you have to do now is shift the focus to somewhere else
			// as this will trigger onKillFocus, which handles singleMarking
			// which in turn will handle gotoNextGap
			//trace("set focus to " + thisGap.cover.t); //  what is .t ??
			Selection.setFocus(thisGap.cover);
			// v6.3.5 But some browsers will now still interpret the tab and send focus to the URL bar (IE)
		} else {
		// if there is no next gap - do nothing, just stay in this gap
		// NO WAY, you can't do that - what about marking for this gap!
		// I think we will have to set the focus away to something else.
			//trace("no more gaps, so set focus to " + thisGap.cover);
			// fine, this works in that we leave the gap, but we don't do the insert answer stuff
			Selection.setFocus(thisGap.cover);
			// v6.2 Now, it is possible/likely/certain that the last typing box didn't insert it's answer into it's field
			// so we should do it for it.
			// v6.3.4 No longer - correctly handled by the selection listener
			//if (_global.ORCHID.session.currentItem.lastGap != undefined) {
			//	//trace("doing the last insert from cmdMarking");
			//	insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
			//	_global.ORCHID.session.currentItem.lastGap = undefined;
			//}
		}
	} else if (Key.isDown(Key.CONTROL) && Key.isDown(66)) { // ctrl-b
		myTrace("you clicked ctrl-B");
		Selection.setFocus(thisGap.cover);
	} else {
		_global.ORCHID.session.currentItem.nextGap = undefined;
	}
}
// v6.3.4 Catch focus changes away from gapfills
gapListener.onSetFocus = function(oldFocus, newFocus){
	//myTrace("focus lost from " + oldFocus._name); 
	if ((typeof oldFocus) == "object" && oldFocus._name.indexOf("gap") >= 0) {

		// v6.3.4 This now contains the code to react to something being typed in a gap
		// Moved from onKillFocus in the typing box + all scattered lastGap stuff
		
		var me = _global.ORCHID.LoadedExercises[0];
		var fieldID = oldFocus.fieldID;
		var thisField = me.getField(fieldID);
		//myTrace("text from field " + oldFocus.fieldID + "=" + oldFocus.text + " type is " + thisField.type);
		
		// v6.3.4 Let TWF do the truncation (it has to have the code anyway for multiline gaps)
		// Ah, except that only does the truncation for the cover, not for the actual answer.
		// So do it here as well. Note that .multiLine here is referring to the gap NOT the cover
		// so it is a boolean (textField property)
		if (oldFocus.multiLine) {
			// don't truncate
			//myTrace("don't truncate as multiLine=" + oldFocus.multiLine);
		} else {
			//myTrace("truncate as multiLine=" + oldFocus.multiLine);
			// v6.2 truncate the typed answer if it is too long
			// the gutter is 2 each side for a text field
			//myTrace("textWidth=" + oldFocus.textWidth + " _width="+oldFocus._width);
			// v6.3.4 But in createTypingBox I know add +8 so that the cursor doesn't send stuff off to the left
			//while (oldFocus.textWidth > (oldFocus._width - 4)) { 
			while (oldFocus.textWidth > (oldFocus._width - 8)) { 
				oldFocus.text = oldFocus.text.substr(0,oldFocus.text.length-1);
			}
		}
				
		// what is getting the focus?
		//myTrace("newFocus=" + newFocus._name);
		// if nothing has been typed, don't send the field for marking as it doesn't count.
		// v6.2 But hey! What happens if there was something there and they just cleared it out!
		// Whilst that doesn't need marking, it DOES need to be inserted into the field.
		// as the last thing - insert the answer through an interval
		if (oldFocus.text != "") {	// v6.5.1 Yiu commented     // AR reset
		//if(true){						// v6.5.1 Yiu force it to go here     // AR reset
			//myTrace("call single marking from onSetFocus");
			singleMarking(thisField, oldFocus.text);
		} else {
			// v6.4.2.4 You need to clear the field if you have already filled it in and then deleted it.
			singleClearMarking(thisField);
			
			//trace("empty answer of [" + this.text + "]");
			// and we also need to go to the next gap if there is one
			// Why do I wait before going there? Why not go straight away? After all you have only
			// got a next field if you entered or tabbed, so no worry about losing focus.
			// v6.4.2.8 OK, try this out then.
			//myTrace("gapListener.onSetFocus for " + _global.ORCHID.session.currentItem.nextGap);
			if (_global.ORCHID.session.currentItem.nextGap != undefined) {
				//_global.ORCHID.session.currentItem.nextGap.interval = setInterval(makeNextTypingBox, 100);
				// v6.5.5.8 Maybe a problem here, as a double enter can leave you vulnerable to making text disappear.
				// This does seem to fix it.
				_global.ORCHID.session.currentItem.nextGap.interval.push(setInterval(makeNextTypingBox, 100));
				//makeNextTypingBox();
			}
		}
		//myTrace("insert answer from onSetFocus");
		//v6.4.3 Is this a targetGap? If so, then add what they typed to the field 
		//myTrace("do a full field insert for this field ");
		//if (thisField.type == "i:targetGap"){
		//	myTrace("do a full field insert for this field of " + oldFocus.text);
		//	//insertAnswerIntoField(thisField, oldFocus.text, true);
		//	insertAnswerIntoField(thisField, oldFocus.text);
		//	// once this is done once, switch the field to be a regular gap
		//	thisField.type = "i:gap";
		//}
		
		// get rid of the typing box (remember it is in a double MC) and the listeners
		Key.removeListener(gapListener);
		Mouse.removeListener(gapListener);
		Selection.removeListener(gapListener);
		//_global.ORCHID.session.currentItem.lastGap.interval = setInterval(delayInsertAnswer, 100);
		//trace("setting up the delayInsert interval as " + _global.ORCHID.session.currentItem.lastGap.interval);
		oldFocus._parent._parent.unloadMovie();
		// stop the old technique from working in case you miss commenting some parts out
		_global.ORCHID.session.currentItem.lastGap = undefined;
	}
}

createTypingBox = function(thisField, fieldCover) {
	var fieldID = thisField.id;
	//myTrace("createTypingBox for cover=" + fieldCover);
	// v6.4.3 Just in case you care trying to create something over a cover that has been deleted (see errorCorrection)
	if (fieldCover == undefined) return;
	
	// v6.3.4 If you click on a multiLine gap, we actually want to locate 
	// the typing box over the first line of the gap (unless it is shorter than other lines I suppose - complex huh)
	// v6.3.4 Protect this code with the extra condition of the exercise setting to avoid splitting little ones
	if (fieldCover.multiLineField>=0 && _global.ORCHID.LoadedExercises[0].settings.exercise.splitGaps) {
		var thisTWF = fieldCover._parent;
		//myTrace("twf=" + thisTWF)
		//myTrace("cover for the first part=" + thisTWF.fields[fieldCover.fieldIDX].coords[0].coverMC);
		var maxWidth=0;
		for (var i in thisTWF.fields[fieldCover.fieldIDX].coords) {
			// first clear all the covers from current text
			thisCover = thisTWF.fields[fieldCover.fieldIDX].coords[i].coverMC;
			thisCover.clearText();
			// is this the widest cover?
			//myTrace("cover " + i + " width=" + thisCover._width);
			if (thisCover._width >= maxWidth) {
				maxWidth = thisCover._width;
				fieldCover = thisCover;
			}
		}
		//fieldCover = thisTWF.fields[fieldCover.fieldIDX].coords[0].coverMC;
	} else {
		// v6.2 Clear out the cover text so you appear to be typing on blank
		//myTrace("clear fieldCover=" + fieldCover);
		fieldCover.clearText();
	}
	// 
	// Now, it is possible/likely/certain that the last typing box didn't insert it's answer into it's field
	// so we should do it for it.
	// v6.3.4 No longer - correctly handled by the selection listener
	//if (_global.ORCHID.session.currentItem.lastGap != undefined) {
	//	//trace("doing the last insert from createTypingBox");
	//	insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
	//	_global.ORCHID.session.currentItem.lastGap = undefined;
	//}
	// v6.2 This has to be done before the gap is created as the gap is no longer
	// a child of the pane and so will not scroll with it
	// scroll the pane if the textField is out of pane
	//var rtnObj = getOutOfPaneLength(myGap, "textField", _root.exerciseHolder.Exercise_SP, "FScrollPaneSymbol");
	// v6.3.3 move exercise panels to buttons holder
	//var rtnObj = getOutOfPaneLength(fieldCover, "textField", _root.exerciseHolder.Exercise_SP, "FScrollPaneSymbol");
	var rtnObj = getOutOfPaneLength(fieldCover, "textField", _global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP, "FScrollPaneSymbol");
	if (rtnObj.bottom > 0) {
		//trace("rtnObj.bottom = " + rtnObj.bottom);
		// v6.3.3 move exercise panels to buttons holder
		//tempPos = _root.exerciseHolder.Exercise_SP.getScrollPosition();
		//_root.exerciseHolder.Exercise_SP.refreshPane();
		//_root.exerciseHolder.Exercise_SP.setScrollPosition(0, tempPos.y + rtnObj.bottom + 20);
		tempPos = _global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.getScrollPosition();
		_global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.refreshPane();
		_global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.setScrollPosition(0, tempPos.y + rtnObj.bottom + 20);
	} else if (rtnObj.top > 0) {
		//trace("rtnObj.top = " + rtnObj.top);
		// v6.3.3 move exercise panels to buttons holder
		tempPos = _global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.getScrollPosition();
		_global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.refreshPane();
		_global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.setScrollPosition(0, tempPos.y - rtnObj.top - 20);
	}
	//
	// First, find out the format of the field so you can mimic it in the typing box
	//
	//trace("going to create typing box "+fieldID + " over " + fieldCover);
	// what text formatting should be used? Read the first char of the gap to find out
	var thisTF = fieldCover._parent.getFieldTextFormat(fieldID); 
	// how tall should the gap be to fit in all letters?
	// add 6 to the text Extent to get the input box dimension. this is sometimes 1 or 2 pixels to tall, but is mostly
	// the minimum necessary (ie Verdana 9, 10, 11 are all 1 too big, the rest are fine including 8)
	//var textCoords = thisTF.getTextExtent("Gg");
	//trace("gap format = " + thisTF.font + " " + thisTF.size + "extent height=" + textCoords.height);
	// You might as well use the fieldCover size as that is based on the letters in question!
	// switch off underlining (whether or not it is on)
	thisTF.underline = false;

	// v6.2 Can you switch off the underline on the gap when the typing box goes up so that if the
	// underline is a bit longer then it doesn't show from underneath?
	// Ahh, maybe keep it for CUP but don't put a border/background round the typing box
	// But this would only work if you reset the field to empty when you back to it otherwise you
	// see the old answer through as you are typing over the top!
	//fieldCover._parent.setFieldTextFormat(fieldID, thisTF);
	// Where and when would I need to switch it back on again?
	
	// have they already typed anything?
	var me = _global.ORCHID.LoadedExercises[0];
	// v6.3.4 Switch attempt from group to field
	var currentAnswer = thisField.attempt.finalAnswer;
	// v6.3.5 Preset gaps will not have anything in answer on the first go, but we want to pretend they have.
	// You do need to work out how to distinguish between a deliberately removed answer and nothing though
	// (probably through .score)
	//if (currentAnswer == undefined && thisField.type == "i:presetGap") {
	// v6.4.2.8 duplicated in fieldMouseUp (and anyway, but now this is a real gap)
	if (currentAnswer == undefined && thisField.type == "i:targetGap") {
	//	//myTrace("first time, so pick up default");
		currentAnswer = thisField.answer[0].value;
	}
	//myTrace("currentAnswer=[" + currentAnswer + "] and type=" + thisField.type);
	/*
	var thisGroupID = thisField.group;
	var groupArrayIDX = lookupArrayItem(me.body.text.group, thisGroupID, "ID");
	if (groupArrayIDX >= 0){
		var currentAnswer = me.body.text.group[groupArrayIDX].attempt.finalAnswer;
	} else {
		var currentAnswer = "";
	};
	*/

	// Trying to get the typing box onto the field cover - so I can have lots of them
	//fieldCover.setTypingBox();
	//return;

	// v6.2 Create a higher level mc for the gap just as is now done for the drag
	// v6.3.3 move exercise panels to buttons holder
	//var gapHolder = _root.exerciseHolder.attachMovie("fieldCover","gapHolder", _global.ORCHID.selectDepth);
	var gapHolder = _global.ORCHID.root.buttonsHolder.ExerciseScreen.attachMovie("fieldCover","gapHolder", _global.ORCHID.selectDepth);
	// first find the global coordinates of the fieldCover
	//var coord = {x:this._x, y:this._y};
	var coord = {x:0, y:0};
	fieldCover.localToGlobal(coord);
	// v6.4.2 Since we might be off the zero, need to realign to match proxy root
	//myTrace("global x=" + coord.x + " proxy offset=" + _global.ORCHID.root._x);
	var rootXOffset = _global.ORCHID.root._x;
	var rootYOffset = _global.ORCHID.root._y;
	gapHolder._x = coord.x - rootXOffset;
	gapHolder._y = coord.y - rootYOffset;
	gapHolder._width = fieldCover._width;
	gapHolder._height = fieldCover._height;
	gapHolder._alpha = 100; //IE10+Win8 fix gh#390
	gapHolder._focusrect = false;
	// link the single gap back to the cover that it is currently working with
	// v6.2 I seem to do this again a little later direct to the myGap
	//gapHolder.cover = fieldCover;	
	var origXScale = fieldCover._xscale;
	var origYScale = fieldCover._yscale;
	// v6.2 Now you will use the mc I just created rather than the cover
	// so there doesn't seem much point in adding another mc under this purely gap thing
	// Ahhh, but the reason for doing it is to allow you to normalise the _xscale of the drag
	var contentHolder = gapHolder.createEmptyMovieClip("gap",0); 
	contentHolder._focusrect = false;
	contentHolder._xscale = 10000 / origXScale;
	contentHolder._yscale = 10000 / origYScale;
	//trace("cover xscale=" + fieldCover._xscale + " gap xscale=" + contentHolder._xscale);
	//trace("textExtent.height=" + textCoords.height + " fc.height=" + fieldCover._height);
	
	// make a textField in the gap holder to actually cope with the typing
	// it was y=-3, but this seems a trifle low
	var myX = -2; var myY = -4; var myH = 4// adjustment so that the letters in the box are over the letters in the text
	// v6.3.4 Allow slightly more room for the cursor at the end of the gap (see note in XMLtoObject)
	//var myW = 4; 
	// v6.3.4 Except that if the gap covers multiple lines, you will need a border round a big input box
	if (fieldCover.multiLineField>=0 && _global.ORCHID.LoadedExercises[0].settings.exercise.splitGaps) {
		var thisHeight = fieldCover._height * thisTWF.fields[fieldCover.fieldIDX].coords.length;
		// and you don't need to worry about the extra space for the box
		var myW = 4; 
	} else {
		var thisHeight = fieldCover._height;
		var myW = 8; 
	}
	contentHolder.createTextField("gap"+fieldID,2,myX,myY,Number(fieldCover._width + myW) ,Number(thisHeight + myH)); 
	myGap = contentHolder["gap"+fieldID]; // was attached to _root
	//myTrace("created gap " + myGap);
	//trace("called "+myGap._name + " put at depth " + (Number(_global.ORCHID.fieldDepth)+Number(fieldID)) + " but really at " + myGap.getDepth());
	myGap._visible = false;
	myGap.html = false;
	// v6.2 CUP try no visible typing box (for now only if there is nothing underneath)
	//trace("the current answer=" + currentAnswer);
	// v6.2 With the cover text, I should always be able to type without a border
	//if (currentAnswer == "" || currentAnswer == undefined) {
	// v6.3.4 Except that if the gap covers two lines, you might need a border round a big input box
	//myTrace("fieldCover.multiLineField=" + fieldCover.multiLineField);
	if (fieldCover.multiLineField>=0 && _global.ORCHID.LoadedExercises[0].settings.exercise.splitGaps) {
		myGap.border = true;
		myGap.background = true;
		myGap.wordWrap = true;
		myGap.multiline = true;
	} else {
		myGap.border = false;
		myGap.background = false;
		myGap.wordWrap = false;
		myGap.multiline = false;
	}
	myGap._focusrect = false;
	//myGap.autoSize = "none";
	myGap._xscale = 100;
	myGap._yscale = 100;
	//set the leading to null so that the height of the text box is fixed no matter what the line spacing is
	thisTF.leading = null;
	// v6.2 Also try removing underlining from the typing box since it is already on the screen
	thisTF.underline = false;
	myGap.setNewTextFormat(thisTF);
	//myGap.text = thisField.answer[0].value + " "; // how long is the expected answer?
	// I already know the answer with most number of characters, it is in thisField.info.gapWidth
	//trace("expecting "+myGap.text+" in "+normal.font);
	//myGap.maxChars = thisField.info.gapWidth; // Note: do you want to do this, AP doesn't at present
	// AM: to get the correct size of the textField, put the default answer into the textField first and then measure the width
	// finally, put the current answer into the textField and set the width to the correct width
	// v6.2 I shouldn't have to do this anymore with the cover text
	/*
	myGap.autoSize = true;
	//myGap.text = thisField.answer[0].value;
	myGap.text = thisField.info.longestAnswer + " ";
	myWidth = myGap._width;
	// v6.2 - add the gap width to the field information object so you can easily use it later
	thisField.info.gapWidth = myWidth;
	//trace("the gap width = " + myWidth);
	myGap.autoSize = "none";
	//myWidth = myGap._width;
	//myHeight = myGap._height;
	//myGap.autoSize = "none";
	//myGap._width = myWidth;
	//myGap._height= myHeight;
	*/
	if (_global.ORCHID.LoadedExercises[0].settings.exercise.splitGaps) {
		//myTrace("[" + currentAnswer + "]");
		currentAnswer = currentAnswer.trim("right");
		//myTrace("[" + currentAnswer + "]");
		//myTrace("code=" + currentAnswer.charCodeAt(myGap.text.length-1));
	}
	myGap.text = currentAnswer;
	myGap._width = myWidth;
	myGap.type = "input";
	myGap._visible = true;
	myGap.fieldID = fieldID; // used for keyUp function
	// link the single gap back to the cover that it is currently working with
	myGap.cover = fieldCover;
	//trace("adding fieldID=" +myGap.fieldID +" to " + myGap);
	//contentHolder.component = fieldCover._parent;

	// create a function that catches ANY move away from the typing box
	// whether from the user (clicking elsewhere) or the program (reacting to Enter).
	// Note - if they click with the mouse, newFocus will always be null, so useless.
	// v6.3.4 This is all now handled in the selection listener
	/*
	myGap.onKillFocus = function(newFocus) {
		
		//trace("leaving gap=" + this.fieldID + "(" + this +")");
		// having detected this event once, remove it immediately so that 
		// it cannot be triggered in a recursive loop by other fields playing
		// with the focus (singleMarking does it in insertAnswerIntoField)
		delete this.onKillFocus;

		// v6.2 truncate the typed answer if it is too long
		// the gutter is 2 each side for a text field
		while (this.textWidth > (this._width - 4)) { 
			this.text = this.text.substr(0,this.text.length-1);
		}

		var me = _global.ORCHID.LoadedExercises[0];
		var fieldID = this.fieldID;
		var thisField = me.getField(fieldID);
		// singleMarking will no longer insertAnswerIntoField for gaps to avoid
		// playing with Selection. So, save the key stuff somewhere so that
		// wherever you go can do it. 
		// BUT this means that LOADS of places have to take care of inserting answers into fields
		// for gaps that are hanging around. Would it work to trigger a setInterval here like you
		// do for going to the next gap? Think about it. Now some stuff (like cmdMenu) seem to 
		// leave the typing box hanging around.
		// Hmmm, just too bad. Places to do it are: 
		// createTypingBox, cmd[Buttons], click somewhere else on the text
		_global.ORCHID.session.currentItem.lastGap = {field:thisField, text:this.text, cover:this.cover};
		
		// if nothing has been typed, don't send the field for marking as it doesn't count.
		// v6.2 But hey! What happens if there was something there and they just cleared it out!
		// Whilst that doesn't need marking, it DOES need to be inserted into the field.
		// as the last thing - insert the answer through an interval

		if (this.text != "") {
			singleMarking(thisField, this.text);
		} else {
			//trace("empty answer of [" + this.text + "]");
			// and we also need to go to the next gap if there is one
			// Why do I wait before going there? Why not go straight away? After all you have only
			// got a next field if you entered or tabbed, so no worry about losing focus.
			if (_global.ORCHID.session.currentItem.nextGap != undefined) {
				_global.ORCHID.session.currentItem.nextGap.interval = setInterval(makeNextTypingBox, 100);
			}
		}
		// get rid of the typing box (remember it is in a double MC) and the listeners
		Key.removeListener(gapListener);
		Mouse.removeListener(gapListener);
		
		//_global.ORCHID.session.currentItem.lastGap.interval = setInterval(delayInsertAnswer, 100);
		//trace("setting up the delayInsert interval as " + _global.ORCHID.session.currentItem.lastGap.interval);
		this._parent._parent.unloadMovie();
	}
	*/
	
	// v6.2 - set the cursor to the beginning of the field 
	Selection.setFocus(myGap); // can't use myGap._name here // was attached to _root
	//Selection.setSelection(0,0);
	// NO, let's try selecting all the text if there is any as now it is possible to click on
	// any cursor position in the field and type there

	// we also need another set of listeners to catch ENTER in the field and
	// control-click (for hints) on the field
	Key.addListener(gapListener);
	Mouse.addListener(gapListener);
	// listener for focus change
	Selection.addListener(gapListener);
	// v6.4.3 Somewhere AFTER this the selection sometimes get shifted away from the gap you just set
	// so that we end setting to focus to null. Which means that you can't type in the next field. Don't know where though.

};
/*
gapObject.onKeyUp = function () {
	// v6.2 working on Tab key
	//if (Key.getAscii() == Key.ENTER || (Key.getAscii() == Key.TAB && !Key.isDown(Key.SHIFT))) {
	if (Key.getAscii() == Key.ENTER || Key.getAscii() == Key.TAB) {
		trace("onKeyUp with " + Key.getAscii());
		// maybe the TAB key already has shifted the focus away from the typing box by
		// the time you get here?
		Key.removeListener(this);
		//var myTypingBox = eval(Selection.getFocus());
		var myTypingBox = this.gapFocus;
		//trace("keyUp focus is on " + myTypingBox);
		//fieldID = Number(myTypingBox.getDepth() - _global.ORCHID.fieldDepth);
		var fieldID = myTypingBox.fieldID;
		//trace("typed in field " + fieldID + " " + myTypingBox.text);
		// v6.2 - here we should truncate the typed answer if it does not fit in the typing box
		//trace("typingbox.width=" + myTypingBox._width + " textWidth=" + myTypingBox.textWidth);
		while (myTypingBox.textWidth > (myTypingBox._width - 5)) {
			myTypingBox.text = myTypingBox.text.substr(0,myTypingBox.text.length-1);
		}
		//trace("now typingbox.width=" + myTypingBox._width + " textWidth=" + myTypingBox.textWidth + " text=" + myTypingBox.text);
		var me = _global.ORCHID.LoadedExercises[0];
		var thisField = me.getField(fieldID);
		// if nothing has been typed, don't send the field for marking as it doesn't count.
		if (myTypingBox.text != "") {
			singleMarking(thisField, myTypingBox.text);
			// singleMarking must call gotoNextGap as it might display instantFB in the meantime
			// Note: I think this whole focus after single marking issue is calling out for a broadcasting
			// solution.
		} else {
			//myTypingBox.text = makeString("_", thisField.info.gapWidth);
			trace("gotoAnotherGap before/after field " + thisField.id);
			if (Key.isDown(Key.SHIFT)) {
				gotoPreviousGap(thisField);
			} else {
				gotoNextGap(thisField);
			}
		}
		myTypingBox.removeTextField();
	// v6.2 working on tabbing
// 	// Note: SHIFT + TAB should gotoPreviousGap
// 	} else if (Key.getAscii() == Key.TAB && Key.isDown(Key.SHIFT)) {
// 		Key.removeListener(this);
// 		var myTypingBox = this.gapFocus;
// 		var fieldID = myTypingBox.fieldID;
// 		var me = _global.ORCHID.LoadedExercises[0];
// 		var thisField = me.getField(fieldID);
// 		if (myTypingBox.text != "") {
// 			singleMarking(thisField, myTypingBox.text);
// 		} else {
// 			gotoPreviousGap(thisField);
// 		}
// 		myTypingBox.removeTextField();
	} else if (Key.getAscii() == Key.ESCAPE) {
		Key.removeListener(this);
		// change as part of gapfill length solution
		//var myTypingBox = eval(Selection.getFocus());
		var myTypingBox = this.gapFocus;
		myTypingBox.removeTextField();
	} else {
		//trace ("You released "+Key.getAscii()+" in "+Selection.getFocus());
	};
}
*/
gotoNextGap = function(thisField) {
	// find if there is another gap after this one in the text
	// if so, create a typing box over it with due focus
	// if not, go back to the first or do nothing.
	//trace("try to find another gap now");
	var me = _global.ORCHID.LoadedExercises[0];
	var fieldID = thisField.id;
	var nextField = me.getNextGap(fieldID);
	//myTrace("the next gap is field " + nextField.id + " (" + nextField.type + ")");
	//if (nextField.type == "i:gap" || nextField.type == "i:presetGap") {
	// v6.4.3 target gaps in proofReading should NOT go to the next one! Need this elsewhere too?
	//if (nextField.type == "i:gap" || nextField.type == "i:targetGap") {
	// More sense to use hiddenTargets
	//if (nextField.type == "i:gap" || (nextField.type == "i:targetGap" && !_global.ORCHID.LoadedExercises[0].settings.exercise.proofReading)) {
	if (nextField.type == "i:gap" || (nextField.type == "i:targetGap" && !_global.ORCHID.LoadedExercises[0].settings.exercise.hiddenTargets)) {
		// now need to find which twf this field is in so that we can get the fieldCover
		// v6.2 use getRegion
		//var contentHolder = _root.exerciseHolder.Exercise_SP.getScrollContent();
		var contentHolder = getRegion(nextField).getScrollContent();
		var thisParaBox = contentHolder["ExerciseBox" + nextField.paraNum];
		thisCover = thisParaBox.getFieldObject(nextField.id).coords[0].coverMC;
		//trace("returned with " + thisCover);
		if (thisCover != undefined) {
			createTypingBox(nextField, thisCover);
			break;
		}
	}
}

gotoPreviousGap = function(thisField) {
	var me = _global.ORCHID.LoadedExercises[0];
	var fieldID = thisField.id;
	var previousField = me.getPreviousGap(fieldID);
	if (previousField.type == "i:gap") {
		// v6.2 use getRegion
		//var contentHolder = _root.exerciseHolder.Exercise_SP.getScrollContent();
		var contentHolder = getRegion(previousField).getScrollContent();
		var thisParaBox = contentHolder["ExerciseBox" + previousField.paraNum];
		thisCover = thisParaBox.getFieldObject(previousField.id).coords[0].coverMC;
		if(thisCover != undefined) {
			createTypingBox(previousField, thisCover);
			break;
		} else {
			Selection.setFocus(contentHolder["gap"+fieldID]);
		}
	}
}

// function to alter the text of a field
insertAnswerIntoField = function(thisField, stdAnswer, justCover) {
	
	// this should all be stored in the field so I don't need to search it
	var contentHolder = getRegion(thisField).getScrollContent();
	var thisParaBox = contentHolder["ExerciseBox" + thisField.paraNum];
	thisCover = thisParaBox.getFieldObject(thisField.id).coords[0].coverMC;
	//myTrace("contentHolder=" + contentHolder + " field.id=" + thisField.id);
	//trace("thisParaBox=" + thisParaBox);
	//myTrace("fR.insertAnswer cover=" + thisCover + " answer=" + stdAnswer);
	// v6.2 Now try using the cover text
	if (justCover) {
		//myTrace("justCover insert " + stdAnswer);
		thisCover.setText(stdAnswer);
	} else {
		//myTrace("insert answer of " + stdAnswer + " into para " + thisParaBox);

		// NOTE since gaps will use the cover text, and only pop-ups and drops use the
		// code that follows, we don't care about gap width, so comment all that code
		//		
		//	// Sometimes we want the new answer to not be any shorter than the original
		//	// In fact, apart from popup fields, gaps, drops and dropdowns are all like this
		//	// so can we add some spaces to the end of the stdAnswer if it is shorter?
		//	// Yes, this works, but since we do not have a fixed width font, this approach is only an approximation
		//	// you should be able to use textExtent to find how long the original was and do a nice comparison
		//	// That can come later though.
		//	// Note: adding 1 space per missing character is woefully short as spaces are tiny. Add 2?
		//	//trace("adding answer " + stdAnswer + " len=" + stdAnswer.length + " original length=" + thisField.info.gapWidth);
		//	// v6.2 no need to do this as dropdowns don't need extra space
		//	/*
		//	if (thisField.type == "i:dropdown") {
		//		var extraSpace = 2;
		//	} else if (thisField.type == "i:gap") {
		//		var extraSpace = 1;
		//	} else {
		//		var extraSpace = 0;
		//	}
		//	*/
		
		//	//trace("gapWidth=" + thisField.info.gapWidth + " stdAnswer=" + stdAnswer.length);
		//	// v6.2 - we do need to calculate this nicely now. We did the calculation earlier, and surely now
		//	// we know more about the text format of the field so should be able to get it just right.
		//	// Use a test textField to add spaces until it is just right.
		//	_root.exerciseHolder.createTextField ("fieldTest", _global.ORCHID.testDepth, 0 , 0 , 10 , 10);
		//	var myTestGap = _root.exerciseHolder.fieldTest;
		//	myTestGap._visible = false;
		//	myTestGap.html = false;
		//	myTestGap.border = true;
		//	myTestGap._focusrect = false;
		//	myTestGap.wordWrap = false;
		//	myTestGap.multiline = false;
		//	myTestGap._xscale = 100;
		//	myTestGap._yscale = 100;
		//	myTestGap.autoSize = true;
		// v6.2 - I now know the text format of this field
		//var TF = new TextFormat("Verdana", 10);
		// v6.2 You DON'T know the tf if singleMarking hasn't happened (ie this answer is empty and
		// it is the first one). In which case, you could just avoid doing anything I suppose.
		// NO, no! This routine is also used after delayed marking, in which case you will
		// get blanks on anything you haven't answered!
		var TF = thisField.origTextFormat;
		//myTrace("tf.underline=" + TF.underline);
		if (TF != undefined) {
		} else {
			// CUP defaults
			TF = new TextFormat("Verdana", 13);
		}
		//	myTestGap.setNewTextFormat(TF);
		//	myTestGap.text = stdAnswer;
		//	//trace("add spaces until answer width=" + thisField.info.gapWidth);
		//	while(myTestGap._width < thisField.info.gapWidth) {
		//		myTestGap.text += " ";
		//	}
		//	stdAnswer = myTestGap.text;
		//	//trace("ok, so longer answer=[" + stdAnswer + "]");
		
		// v6.2 reset the underlining that you took off when clicking on the gap
		// but this is slow and in fact might not even be refreshed until later!
		// Try doing it before the text insertion. Hmm, that seems better.
		// TF.underline = true;
		thisParaBox.setFieldTextFormat(thisField.id, TF);	
		// why doesn't this trigger the heightChange on seeTheAnswers yet it does for
		// actually dragging?
		//trace("inserting answer " + stdAnswer);
		//myTrace("calling setFieldText")
		// v6.4.3 partialRefresh is undefined
		//thisParaBox.setFieldText(thisField.id, stdAnswer, partialRefresh);
		// v6.4.3 #errorCorrection problem#
		// tell the twf that this is a special insertAnswer that requires you to pick up any existing cover text
		// from other fields in the twf - unless you are now in after marking and just filling in the correct answers.
		// Try to come to this function with 'justCover' in that case.
		if (thisField.type == "i:targetGap") {
		//if (thisField.type == "i:targetGap" && !(_global.ORCHID.session.currentItem.afterMarking)) {
			//myTrace("full insert for a " + thisField.type + " with saveCovers");
			thisParaBox.setFieldText(thisField.id, stdAnswer, "saveCovers");
		} else {
			//myTrace("full insert for a " + thisField.type);
			thisParaBox.setFieldText(thisField.id, stdAnswer);
		}
		//myTrace("back from setFieldText");
	}
}

// function to change the appearance of a field once it has been selected
// v6.3.4 You would not want to call this if you need to be able to select multiple option as necessarily correct
// You would simply switch each field on and off and ignore the others in the group.
selectThisField = function(thisField) {
	//trace("changing "+thisField.id);
	//myTrace("select by underline=" +thisField.id);
	changeFieldAppearance(thisField, _global.ORCHID.HighlightedText);
	// then check to see if this impacts anything else in the group
	//trace("others in group "+thisField.group+" against "+thisField.type);
	// v6.3.4 You want to do the deselecting separately from the changing appearance
	deselectOtherFields(thisField);
}
deselectOtherFields = function(thisField) {
	// v6.3.4 Don't do this if the special multiple option setting is on
	if (_global.ORCHID.LoadedExercises[0].settings.exercise.multiPart) {
		//myTrace("don't switch off other fields in the group");
	} else {
		if (thisField.group != undefined && thisField.type == "i:target") {
			// if a field is in a group it means that other fields in the same group should be "unselected"
			for (i in _global.ORCHID.LoadedExercises[0].body.text.field) { 
				var me = _global.ORCHID.LoadedExercises[0].body.text.field[i];
				if (me.group == thisField.group && me.id != thisField.id) {
					//myTrace("unselecting field " + me.id  + " for group "+thisField.group);
					restoreFieldAppearance(me);
					// v6.4.2.4 Except that if it was instant marking - only the first attempt counts
					if (_global.ORCHID.LoadedExercises[0].settings.marking.instant) {
						//myTrace("don't get rid of the first score when clearing other fields");
					} else {
						// v6.4.2.4 Clearing the score means setting it to undefined, not 0
						//me.attempt.score = 0;
						// v6.3.4 Now I need to also reset the field.attempt

						me.attempt.finalAnswer = undefined;
						me.attempt.score = undefined;
					}
				}
			}	
		}
	}
};

// v6.4.2.7 Extracted function for ticking - code comes from singleMarking
setTicking = function(thisField, tickOrCross, offsetX, oneLine) {
	if (tickOrCross <> "Tick") tickOrCross = "Cross";
	var contentHolder = getRegion(thisField).getScrollContent();
	var thisParaBox = contentHolder["ExerciseBox" + thisField.paraNum];
	if (offsetX == undefined) {
		//v6.4.2.4 Need to get dimensions of tick and cross so they can be positioned correctly
		// This will set it directly to the outside corner of the cover. If you want to merge a particular
		// tick or cross into the answer a bit, set the x and y at design time to -ve in buttons within the tick mc.
		var tickWidth = _global.ORCHID.root.buttonsHolder.ExerciseScreen.tickHolder._width;
		var tickHeight = _global.ORCHID.root.buttonsHolder.ExerciseScreen.tickHolder._height;
		var crossWidth = _global.ORCHID.root.buttonsHolder.ExerciseScreen.crossHolder._width;
		var crossHeight = _global.ORCHID.root.buttonsHolder.ExerciseScreen.crossHolder._height;		
		if (tickOrCross == "Cross") {
			offsetX = crossWidth;
		} else {
			offsetX = tickWidth;
		}
	}
	if (oneLine == undefined) oneLine = true;
	var markProps = {stretch:false, align:"right", offsetX:offsetX, oneLine:oneLine};
	//myTrace("try to add a " + tickOrCross + " to " + thisField.id + " fieldCover " + thisParaBox);						
	thisParaBox.setFieldTick(thisField.id, tickOrCross, markProps);
}

changeFieldAppearance = function(thisField, thisFormat) {
	// v6.2 use getRegion
	//var contentHolder = _root.exerciseHolder.Exercise_SP.getScrollContent();
	var contentHolder = getRegion(thisField).getScrollContent();
	var thisParaBox = contentHolder["ExerciseBox" + thisField.paraNum];
	// the new method that uses start and ends held in the textField
	//trace("try to call setFieldTextFormat for field " + thisField.id);
	thisParaBox.setFieldTextFormat(thisField.ID, thisFormat);
};

// this only undoes binary properties of the format (bold, italics, underline etc)
restoreFieldAppearance = function(thisField, enableField) {
	// v6.2 use getRegion
	//var contentHolder = _root.exerciseHolder.Exercise_SP.getScrollContent();
	var contentHolder = getRegion(thisField).getScrollContent();
	var thisParaBox = contentHolder["ExerciseBox" + thisField.paraNum];
	var applyFormat = thisField.origTextFormat;
	//myTrace("in component " + thisParaBox + " restore field " + thisField.id + " to TF.leading=" + applyFormat.leading);
	//for (name in applyFormat) {
	//	if (thisFormat[name] eq true || thisFormat[name] eq false) {
	//		//trace("I am going to reverse the " + name);
	//		applyFormat[name] = !thisFormat[name];
	//	}
	//	if (applyFormat[name]!= null) myTrace("origTF." + name + "=" + applyFormat[name]);
	//}
	thisParaBox.setFieldTextFormat(thisField.ID, applyFormat);
	// v6.2 as well as restoring formation, you might want to enable the field
	if (enableField) {
		thisParaBox.enableField(thisField.id);
	}
}

// this function checks if fieldBox gets out of holderBox.
// fieldBox should be holderBox's son, grandson or ...
// fieldBoxType and holderBoxType are the movieClip type of fieldBox and holderBox eg. "FComboBoxSymbol" for fieldBox and "FScrollPaneSymbol" for holderBox
// object like that {left: 0, right: 0, top: 0, bottom: 0} will be returned
// the return object represents the how long in each direction the fieldBox gets out of holderBox
// the value 0 means fieldBox does not get out of holderBox or fieldBox is not holderBox's son, grandson or ...
getOutOfPaneLength = function(fieldBox, fieldBoxType, holderBox, holderBoxType) {
	var fieldX = fieldBox._x;
	var fieldY = fieldBox._y;
	var holderX = holderBox._x;
	var holderY = holderBox._y;
	var fieldBoxBottom;
	var fieldBoxRight;
	var holderBoxBottom;
	var holderBoxRight;
	
	var tempParent1 = fieldBox._parent;
	while(tempParent1 <> _root) {
		fieldX += tempParent1._x;
		fieldY += tempParent1._y;
		tempParent1 = tempParent1._parent;
	}
	
	var tempParent2 = holderBox._parent;
	while(tempParent2 <> _root) {
		holderX += tempParent2._x;
		holderY += tempParent2._y;
		tempParent2 = tempParent2._parent;
	}
	
	// v6.2 - use special combo box
	if (fieldBoxType == "APComboBoxSymbol") {
		if (fieldBox.getLength() > fieldBox.getRowCount()) {
			var comboHeight = (fieldBox.getRowCount() + 1) * fieldBox._height;
		} else {
			var comboHeight = (fieldBox.getLength() + 1) * fieldBox._height;
		}
		fieldBoxBottom = fieldY + comboHeight;
		fieldBoxRight = fieldX + fieldBox._width;
	} else if (fieldBoxType == "FListBoxSymbol") {
		//trace("the height of the list box is " + fieldBox._height);
		fieldBoxBottom = fieldY + fieldBox._height - 8; // this is a spacer thingy
		fieldBoxRight = fieldX + fieldBox._width;
	} else if (fieldBoxType == "textField") {
		fieldBoxBottom = fieldY + fieldBox._height;
		fieldBoxRight = fieldX + fieldBox._width;
	} else {
		fieldBoxBottom = fieldY + fieldBox._height;
		fieldBoxRight = fieldX + fieldBox._width;
	}
	
	if (holderBoxType == "FScrollPaneSymbol") {
		//trace("holderBox.getScrollPosition().y = " + holderBox.getScrollPosition().y);
		holderBoxBottom = holderY + holderBox.getPaneHeight();
		//holderBoxBottom = holderY + holderBox.getPaneHeight() - holderBox.getScrollPosition().y;
		holderBoxRight = holderX + holderBox.getPaneWidth() - holderBox.getScrollPosition().x;
	} else {
		holderBoxBottom = holderY + holderBox._height;
		holderBoxRight = holderX + holderBox._width;
	}
	
	//trace("fieldX = " + fieldX);
	//trace("fieldY = " + fieldY);
	//trace("fieldBoxBottom = " + fieldBoxBottom);
	//trace("fieldBoxRight = " + fieldBoxRight);
	//trace("holderX = " + holderX);
	//trace("holderY = " + holderY);
	//trace("holderBoxBottom = " + holderBoxBottom);
	//trace("holderBoxRight = " + holderBoxRight);
	var rtnObj = {left: 0, right: 0, top: 0, bottom: 0};
	if(fieldY - holderY < 0) {
		rtnObj.top = holderY - fieldY;
	} else {
		rtnObj.top = 0;
	}
	if(fieldBoxBottom > holderBoxBottom) {
		rtnObj.bottom = fieldBoxBottom - holderBoxBottom;
	} else {
		rtnObj.bottom = 0;
	}
	if(fieldX - holderX < 0) {
		rtnObj.left = holderX - fieldX;
	} else {
		rtnObj.left = 0;
	}
	if(fieldBoxRight > holderBoxRight) {
		rtnObj.right = fieldBoxRight - holderBoxRight;
	} else {
		rtnObj.right = 0;
	}
	//trace("left = " + rtnObj.left);
	//trace("right = " + rtnObj.right);
	//trace("top = " + rtnObj.top);
	//trace("bottom = " + rtnObj.bottom);
	return rtnObj;

}
// v6.2 a new function to get the pane holding this region for a field
getRegion = function(thisField) {
	switch (thisField.region) {
		case _global.ORCHID.regionMode.noScroll:
			// v6.3.3 move exercise panels to buttons holder
			//var contentHolder = _root.exerciseHolder.NoScroll_SP;
			var contentHolder = _global.ORCHID.root.buttonsHolder.ExerciseScreen.NoScroll_SP;
			break;
		case _global.ORCHID.regionMode.title:
			var contentHolder = _global.ORCHID.root.buttonsHolder.ExerciseScreen.Title_SP;
			break;
		// v6.4.2.4 Can you drag from a reading text?
		case _global.ORCHID.regionMode.readingText:
			myTrace("getRegion=readingText");
			var contentHolder = _global.ORCHID.root.buttonsHolder.ExerciseScreen.ReadingText_SP;
			break;
		default:
			var contentHolder = _global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP;
			break;
	}
	return contentHolder;
}
