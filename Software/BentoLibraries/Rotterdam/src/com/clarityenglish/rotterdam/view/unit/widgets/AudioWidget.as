package com.clarityenglish.rotterdam.view.unit.widgets {
	
	public class AudioWidget extends AbstractWidget {
		
		public function AudioWidget() {
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
		
	}
}
