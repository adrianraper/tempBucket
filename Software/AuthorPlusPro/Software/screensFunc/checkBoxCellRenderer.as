
import mx.core.UIComponent
import mx.controls.CheckBox

class screensFunc.checkBoxCellRenderer extends UIComponent {
	private var checkBoxWidth:Number = 18;
	private var startX:Number = 5;
	private var contentWidth:Number;
	private var cb:CheckBox;

 	var owner; // The row that contains this cell	
	var listOwner : MovieClip; // the reference we receive to the list
	var getCellIndex : Function; // the function we receive from the list
	var	getDataLabel : Function; // the function we receive from the list

	function checkBoxCellRenderer() {
	}
	
	function init(Void):Void {
		super.init();
		contentWidth = (startX*2)+checkBoxWidth;
	}
	
	function createChildren(Void):Void {
		cb = mx.controls.CheckBox(createObject("CheckBox", "cb"));
		cb.label = "";
		cb.labelPlacement = "bottom";
		
		cb.addEventListener("click", this);
	}

	function size(Void):Void {
		// layout the content
		doLayout();
	}
	
	function doLayout(Void):Void {
		var w:Number = __width;
		var h:Number = __height;
		var x:Number = (__width - contentWidth) / 2;
		x += startX;
	 	// 12 : minimal value for radio height
		cb.setSize(checkBoxWidth,12);
	 	cb._x = x;
	}
	
	function setValue(value:String, item:Object, sel:Boolean):Void {
		if (item==undefined){
			cb.visible = false;
			return;
		} else {
			cb.visible = true;
		}
		 
		if (value=="true") {
			cb.selected = true;
		} else {
			cb.selected = false;
		}
	 
	}

	function getPreferredHeight(Void):Number {
		if (owner == undefined) return 18;
		return owner.__height - 2;
	}

 	//function getPreferredWidth :: only really necessary for menu
	
	// v0.16.1, DL: on checkbox being clicked
	function click(eventObj:Object):Void {
		var target = eventObj.target;
		
		// set checkbox according to correctness (interface)
		listOwner.dataProvider.editField(getCellIndex().itemIndex, getDataLabel(), target.selected.toString());
		
		// update correctness in data
		_global.NNW.screens.updateWholeExercise();
	}

}
