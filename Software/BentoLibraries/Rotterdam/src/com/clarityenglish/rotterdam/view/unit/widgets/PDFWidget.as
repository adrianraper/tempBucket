package com.clarityenglish.rotterdam.view.unit.widgets {
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import spark.components.Image;
	
	public class PDFWidget extends AbstractWidget {
		
		[SkinPart(required="true")]
		public var pdfImage:Image;
		
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
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case pdfImage:
					pdfImage.buttonMode = true;
					pdfImage.addEventListener(MouseEvent.CLICK, onPdfImageClick);
					break;
			}
		}
		
		protected function onPdfImageClick(event:MouseEvent):void {
			trace("CLICK!");
		}
		
	}
}
