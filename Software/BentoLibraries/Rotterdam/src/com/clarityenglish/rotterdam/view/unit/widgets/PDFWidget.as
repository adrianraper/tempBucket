package com.clarityenglish.rotterdam.view.unit.widgets {
	import flash.events.MouseEvent;
	
	import org.davekeen.util.StringUtils;
	
	import spark.components.Image;
	
	public class PDFWidget extends AbstractWidget {
		
		[SkinPart(required="true")]
		public var thumbnailImage:Image;
		
		public function PDFWidget() {
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
		
		[Bindable(event="thumbnailAttrChanged")]
		public function get thumbnail():String {
			return _xml.@thumbnail;
		}
		
		[Bindable(event="thumbnailAttrChanged")]
		public function get hasThumbnail():Boolean {
			return _xml.hasOwnProperty("@thumbnail");
		}

		[Bindable(event="thumbnailAttrChanged")]
		public function get thumbnailUrl():String {
			if (hasThumbnail) {
				// gh#111 - support absolute and relative image urls
				return (StringUtils.beginsWith(thumbnail.toLowerCase(), "http")) ? thumbnail : mediaFolder + "/" + thumbnail;
			} else {
				// gh#259
				return thumbnailScript + "?type=pdf";
			}
			
			return null;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case thumbnailImage:
					thumbnailImage.buttonMode = true;
					thumbnailImage.addEventListener(MouseEvent.CLICK, onPdfImageClick);
					break;
			}
		}
		
		protected function onPdfImageClick(event:MouseEvent):void {
			if (hasSrc) {
				openMedia.dispatch(xml, src);
			} else {
				log.error("The user managed to click on a PDF image when no src attribute was set");
			}
		}
		
	}
}
