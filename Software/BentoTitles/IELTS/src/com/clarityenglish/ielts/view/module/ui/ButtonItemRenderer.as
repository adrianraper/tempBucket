	package com.clarityenglish.ielts.view.module.ui {
	import almerblank.flex.spark.components.SkinnableItemRenderer;
	
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	
	public class ButtonItemRenderer extends SkinnableItemRenderer {
		
		[SkinPart(required="true")]
		public var button:Button;
		
		public var exerciseClick:Signal;
		
		/**
		 * This is an example of using injection from the component to get data into the skin (see DifficultyRenderer for another method)
		 */ 
		public override function set data(value:Object):void {
			super.data = value;
			
			button.label = data.@caption;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case button:
					button.addEventListener(MouseEvent.CLICK, onButtonClick);
					break;
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			
			switch (instance) {
				case button:
					button.removeEventListener(MouseEvent.CLICK, onButtonClick);
					break;
			}
		}
		
		protected function onButtonClick(event:MouseEvent):void {
			exerciseClick.dispatch(data);
		}
		
	}
	
}
