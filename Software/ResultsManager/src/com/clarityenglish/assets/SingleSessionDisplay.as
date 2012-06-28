package com.clarityenglish.assets 
{
	/**
	 * ...
	 * @author Adrian Raper
	 */
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	import mx.containers.Canvas;
	//import mx.controls.Label;
	import mx.core.Container;
	//import com.clarityenglish.utils.TraceUtils;
	
	public class SingleSessionDisplay extends Canvas {
		
		private var _sessions:uint;
		
		//[Embed(source="/../assets/stamperFont.swf")]
		//private var stamperFont:Class;
		
		// Constructor
		public function SingleSessionDisplay() {
			super();			
			removeAllChildren();
			var myFormat:TextFormat = new TextFormat();
			myFormat.align = "left";
			myFormat.font = "Verdana";
			myFormat.size = "36";
			var myTF:TextField = new TextField();
			myTF.defaultTextFormat = myFormat;
			myTF.text = '123';
			addChild(myTF);
		}
		// Getter and setter
		public function set value(value:uint):void {
			//TraceUtils.myTrace("setting value of ssd to " + value);
			_sessions = Math.floor(value);
			redraw();
		}
		public function get value():uint {
			return _sessions;
		}
		
		// Display functions
		private function redraw():void {
			//removeAllChildren();
		}

	}

}