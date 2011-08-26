//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.controls.listclasses.SelectableRow;
import mx.effects.Tween;

class treeRowWithCheckBox extends SelectableRow
{
	//::: Defaults
	var indentAdjust : Number = 3;

	//::: Declarations
	var node : Object;
	var checkbox:MovieClip;
	var disclosure : MovieClip;
	var nodeIcon : MovieClip;
	var open : Boolean;
	var rotationTween : Tween;

	function treeRowWithCheckBox() {
		// listen to mouse and mouseClick (for left/right clicks)
		_global.mouseClick.addListener(this);
	}
	
	function setValue(item, state)
	{
		node = item;
		var branch = owner.getIsBranch(node);
		super.setValue(node, state);
	//	cell._width = cell.textWidth+10;
		if (node==undefined) {
			disclosure._visible = checkbox._visible = nodeIcon._visible = false;
			return;
		}
		checkbox._visible = true;
		nodeIcon._visible = false;

		open = owner.getIsOpen(node);
		var indent = (owner.getNodeDepth(node)-1) * getStyle("indentation");

		// commented & added by Doris
		var dI = owner.getStyle( (open) ? "disclosureOpenIcon" : "disclosureClosedIcon");
		//var dI = (open) ? "ArrowOpen" : "ArrowClose";
		// end of commenting and adding by Doris
		disclosure = createObject(dI, "disclosure", 3);
		disclosure.onPress = disclosurePress;
		disclosure.useHandCursor = false;

		disclosure._visible = branch;
		disclosure._x = indent + 4;

		// added by Doris for adding checkbox
		if (checkbox!=undefined) {
			checkbox.removeMovieClip();
		}
		//checkbox = attachMovie("CheckBox", "checkbox", 1000, {label:"", state:Number(node.attributes.check)});
		checkbox = createEmptyMovieClip("checkbox", 1000);
		checkbox.createEmptyMovieClip("c0", 1001);
		checkbox.createEmptyMovieClip("c1", 1002);
		checkbox.createEmptyMovieClip("c2", 1003);
		checkbox.c0.attachMovie("CheckBox - Unchecked", "checkbox0", 1001);
		checkbox.c1.attachMovie("CheckBox - Half", "checkbox1", 1002);
		checkbox.c2.attachMovie("CheckBox - Checked", "checkbox2", 1003);
		switch (node.attributes.check)  {
			case "1" :
				checkbox.c0._visible = false;
				checkbox.c1._visible = true;
				checkbox.c2._visible = false;
				break;
			case "2" :
				checkbox.c0._visible = false;
				checkbox.c1._visible = false;
				checkbox.c2._visible = true;
				break;
			default :
				checkbox.c0._visible = true;
				checkbox.c1._visible = false;
				checkbox.c2._visible = false;
				break;
		}
		checkbox._x = disclosure._x + disclosure._width + 2;

		var nI = owner.nodeIcons[node.getID()][(open) ? "iconID2" : "iconID"];
		//if (nI==undefined) {
		//	nI = owner.__iconFunction(node);
		//}
		
		if (branch) {
			if (nI==undefined) {
				nI = owner.getStyle( (open) ? "folderOpenIcon" : "folderClosedIcon");
			}
		} else {
			if (nI==undefined) {
				nI = node.attributes[owner.iconField];
			}
			if (nI==undefined) {
				nI = owner.getStyle("defaultLeafIcon");
			}
		}
		nodeIcon.removeMovieClip();
		nodeIcon = createObject(nI, "nodeIcon", 20);

		//nodeIcon._x = disclosure._x + disclosure._width + 2;
		nodeIcon._x = checkbox._x + checkbox._width + 5;

		// added by Doris
		nodeIcon.useHandCursor = false;

		//cell._x = nodeIcon._x + nodeIcon._width + 2;
		nodeIcon._visible = false;
		cell._x = nodeIcon._x;
		
		//indent + (indentAdjust*3) + owner.disclosureWidth + 16;

		// Make sure we size our height and our cell-width.
		size();
	}

	function getNormalColor()
	{
		node = item;
		var c = super.getNormalColor();
		var itemIndex = rowIndex + owner.__vPosition;
		var col = owner.getColorAt(itemIndex);
		if (col==undefined) {
			var colArray = owner.getStyle("depthColors");
			if (colArray == undefined) {
				return c;
			} else {
				var d = owner.getNodeDepth(node);
				if (d==undefined) d = 1;
				col = colArray[(d-1)%colArray.length];
			}
		}
		return col;
	}


	// ::: PRIVATE METHODS

	function createChildren()
	{
		super.createChildren();
		if (disclosure==undefined) {
			createObject("Disclosure", "disclosure", 3, {_visible:false} );
			disclosure.onPress = disclosurePress;
			disclosure.useHandCursor = false;
		}
	}

	function size()
	{
		super.size();
		disclosure._y = (__height - disclosure._height) / 2;
		nodeIcon._y = (height - nodeIcon._height) / 2;
		cell.setSize(__width - cell._x, __height);
	}


	// this is scoped to the disclosure icon. _parent is the row.
	function disclosurePress()
	{
		var p = _parent;
		var c = p.owner;
		if (c.isOpening || !c.enabled) return;
		var o = (p.open) ? 90 : 0;
		p.open = !_parent.open;
		c.pressFocus();
		c.releaseFocus();

		c.setIsOpen(p.node, p.open, true, true);
	}
	
//*** my functions to capture checkBox selection & right-clicking ***
	function refreshCheckBoxState() {
		var rowsHolder = owner.content_mc;
		for (var i in rowsHolder) {
			if ((typeof rowsHolder[i] == "movieclip") && ((rowsHolder[i]._name.indexOf("listRow")!=-1) || (rowsHolder[i]._name.indexOf("treeRow")!=-1))) {
				switch (rowsHolder[i].item.attributes.check) {
					case "0":
						rowsHolder[i].checkbox.c0._visible = true;
						rowsHolder[i].checkbox.c1._visible = false;
						rowsHolder[i].checkbox.c2._visible = false;
						break;
					case "1":
						rowsHolder[i].checkbox.c0._visible = false;
						rowsHolder[i].checkbox.c1._visible = true;
						rowsHolder[i].checkbox.c2._visible = false;
						break;
					case "2":
						rowsHolder[i].checkbox.c0._visible = false;
						rowsHolder[i].checkbox.c1._visible = false;
						rowsHolder[i].checkbox.c2._visible = true;
						break;
					default:
						break;
				}
				//trace("In Nodes: " + rowsHolder[i].item.attributes.label + " " + rowsHolder[i].item.attributes.check);
				//trace("In MC: " + i + " " + rowsHolder[i].cell.text + " " + rowsHolder[i].checkbox.state);
			}
		}
	}

	function onMouseDown() {
		// react only if the checkbox has been clicked
		if (this.hitTest(_root._xmouse, _root._ymouse, true)) {
			if (!disclosure.hitTest(_root._xmouse, _root._ymouse, true)) {
				item.attributes.check = (item.attributes.check=="0") ? "2" : "0";
				item.toggleChildrenCheck();
				for (var i in owner.dataProvider.childNodes) {
					owner.dataProvider.childNodes[i].toggleCheckByChildren();
				}
				refreshCheckBoxState();
			}
		}
		updateAfterEvent();
	}
//*** end of my functions ***
}

