package com.clarityenglish.rotterdam.view.unit.widgets {
	import flash.events.Event;
	
	import mx.controls.SWFLoader;
	
	import spark.components.Group;
	import spark.components.Image;
	
	public class ImageWidget extends AbstractWidget {
		
		[SkinPart]
		public var image:Image;
		
		public function ImageWidget() {
			super();
		}
		
		[Bindable(event="srcAttrChanged")]
		public function get src():String {
			return _xml.@src;
		}
		
		[Bindable(event="srcAttrChanged")]
		public function get hasSrc():Boolean {
			return _xml.hasOwnProperty("@src");
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				
			}
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// After lots of mucking about it turns out that this is what we need to get the image to size correctly!
			// TODO: See if the VideoWidget can be consolidated in a similar fashion
			if (image.loaderInfo) {
				image.width = unscaledWidth;
				image.height = unscaledWidth * (image.loaderInfo.width / image.loaderInfo.height);
				invalidateSize();
			}
		}
		
	}
}
