package com.clarityenglish.rotterdam.view.unit.widgets {
	
	public class TextWidget extends AbstractWidget {
		
		public function TextWidget() {
			super();
		}
		
		public function set text(value:String):void {
			_xml.setChildren(new XML("<![CDATA[" + value + "]]>"));
		}
		
		public function get text():String {
			return _xml[0].toString();
		}
		
	}
}
