package com.clarityenglish.ielts.view.module.ui {
	import almerblank.flex.spark.components.SkinnableItemRenderer;
	
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Image;
	
	public class ImageItemRenderer extends SkinnableItemRenderer {
		
		[SkinPart(required="true")]
		public var image:Image;
		
		public var exerciseClick:Signal;
		
		/**
		 * This is an example of using injection from the component to get data into the skin (see DifficultyRenderer for another method)
		 */ 
		public override function set data(value:Object):void {
			super.data = value;
			trace("add imageItemRenderer for " + data.@thumbnail);
			image.source = data.@thumbnail;
			image.addEventListener(Event.COMPLETE, onComplete);
			image.addEventListener(IOErrorEvent.IO_ERROR, onError);
		}
		protected function onComplete(e:Event):void {
			trace("onComplete for " + e.toString());
		}
		protected function onError(e:IOErrorEvent):void {
			trace("onError for " + e.toString());
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			//trace("partAdded imageItemRenderer for " + partName);
			
			switch (instance) {
				case image:
					image.addEventListener(MouseEvent.CLICK, onClick);
					break;
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			
			switch (instance) {
				case image:
					image.removeEventListener(MouseEvent.CLICK, onClick);
					break;
			}
		}
		
		protected function onClick(event:MouseEvent):void {
			exerciseClick.dispatch(data);
		}
		
	}
	
}
