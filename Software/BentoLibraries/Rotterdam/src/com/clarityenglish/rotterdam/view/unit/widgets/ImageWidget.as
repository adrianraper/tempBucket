package com.clarityenglish.rotterdam.view.unit.widgets {
	import flash.events.Event;
	
	import mx.controls.SWFLoader;
	
	import org.davekeen.util.StringUtils;
	
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
		
		[Bindable(event="srcAttrChanged")]
		public function get imageUrl():String {
			if (hasSrc) {
				// gh#111 - support absolute and relative image urls
				return (StringUtils.beginsWith(src.toLowerCase(), "http")) ? src : mediaFolder + "/" + src;
			}
			
			return null;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				
			}
		}
		
	 	protected override function commitProperties():void {
			super.commitProperties();
			
			if (image) {
				
			}
			
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// After lots of mucking about it turns out that this is what we need to get the image to size correctly!
			// TODO: See if the VideoWidget can be consolidated in a similar fashion
			if (image.loaderInfo) {
				// gh#312
				/*if (image.sourceWidth < unscaledWidth && span == 1) {
					image.width = image.sourceWidth;
					image.height = image.sourceHeight;
					isSmallImage = true;
				} else {*/
					// gh#311
					image.width = unscaledWidth - 2;
					// gh#63 the fraction is reversed, height should be molecule
					// gh#63
					//image.height = unscaledWidth * (image.loaderInfo.height / image.loaderInfo.width);
					image.height = unscaledWidth * (image.sourceHeight / image.sourceWidth);
				//}								
				
				invalidateSize();
			}
		}
		
	}
}
