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
				case image:
					image.addEventListener(Event.COMPLETE, onImageUploadComplete);
					break;
			}
		}
		
	 	protected override function commitProperties():void {
			super.commitProperties();

		}
		
		protected function onImageUploadComplete(event:Event):void {
			invalidateDisplayList();
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			// gh#312
			if (span == 1) {
				var oneColumnWidth:Number = Math.round(unscaledWidth/span);				
			} else if (span == 2) {
				oneColumnWidth = Math.round((unscaledWidth - 2) / span );
			} else if (span == 3) {
				oneColumnWidth = Math.round((unscaledWidth - 4) / span );
			}
			
			var twoColumnWidth:Number = 2*oneColumnWidth + 2;
			var threeColumnWidth:Number = 3*oneColumnWidth + 4;
			
			// After lots of mucking about it turns out that this is what we need to get the image to size correctly!
			// TODO: See if the VideoWidget can be consolidated in a similar fashion
			if (image.loaderInfo) {
				if (image.sourceWidth <= oneColumnWidth) {
					image.width = image.sourceWidth;
					image.height = image.sourceHeight;
				} else if (image.sourceWidth > oneColumnWidth && image.sourceWidth <= twoColumnWidth) {
					if (span == 1) {
						image.width = unscaledWidth - 2;
						image.height = unscaledWidth * (image.sourceHeight / image.sourceWidth);
					} else {
						image.width = image.sourceWidth;
						image.height = image.sourceHeight;
					}
				} else if (image.sourceWidth > twoColumnWidth && image.sourceWidth <= threeColumnWidth) {
					if (span == 3) {
						image.width = image.sourceWidth;
						image.height = image.sourceHeight;
					} else {
						image.width = unscaledWidth - 2;
						image.height = unscaledWidth * (image.sourceHeight / image.sourceWidth);
					}
				} else {
					image.width = unscaledWidth - 2;
					image.height = unscaledWidth * (image.sourceHeight / image.sourceWidth);
				}
				
				invalidateSize();
			}
		}
		
	}
}
