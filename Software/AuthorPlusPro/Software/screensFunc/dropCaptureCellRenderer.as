import mx.core.UIComponent
import mx.controls.TextInput

class screensFunc.dropCaptureCellRenderer extends UIComponent {

	// DL: label
	var label : TextInput;
	
	var listOwner : MovieClip; // the reference we receive to the list
	var getCellIndex : Function; // the function we receive from the list
	var	getDataLabel : Function; // the function we receive from the list
	
	function dropCaptureGridCellRenderer() {
	}
	
	function createChildren(Void) : Void {
		//label = createLabel("label", 10);
		//label.autoSize = "left";
		createClassObject(TextInput, "label", 2);
		var l = label;
		l.setStyle("borderStyle", "none");
		l.border_mc._visible = false;
		l.label.selectable = false;
		l.editable = false;
		size();
	}

	// note that setSize is implemented by UIComponent and calls size(), after setting
	// __width and __height
	function size(Void) : Void {
		label.setSize(233, 20);	// v0.12.0, DL: debug - some words doesn't show!
		label._x = 0;
		label._y = 0;
	}

	function setValue(str:String, item:Object, sel:Boolean) : Void {
		label._visible = (item!=undefined);
		label.text = str; //item[getDataLabel()];
	}

	function getPreferredWidth(Void) : Number {
		return listOwner.getColumnAt(0).width;//16;
	}

	function getPreferredHeight(Void) : Number {
		return __height;//20;
	}
	
	function onMouseUp() : Void {
		if (this.hitTest(_root._xmouse, _root._ymouse, false)) {
			//_global.myTrace("item index on mouse up: "+getCellIndex().itemIndex);
			_global.NNW.screens.dgs.dragRow.targetIndex = getCellIndex().itemIndex;
		}
	}
}