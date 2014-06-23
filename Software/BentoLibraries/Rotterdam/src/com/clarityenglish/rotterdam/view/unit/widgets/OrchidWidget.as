package com.clarityenglish.rotterdam.view.unit.widgets {
	import org.davekeen.util.StringUtils;
	import flash.net.URLRequest;
	import flash.display.Loader;
	
	public class OrchidWidget extends AbstractWidget {
		
		public function OrchidWidget() {
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
		
		public function get orchidUrl():String {
			if (hasSrc) {
				trace("src: "+src);
				return src;
			} 
			
			return null;
		}
		
	}
}