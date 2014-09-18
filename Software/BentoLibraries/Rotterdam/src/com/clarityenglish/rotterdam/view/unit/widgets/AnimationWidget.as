package com.clarityenglish.rotterdam.view.unit.widgets {
	import mx.controls.SWFLoader;
	
	import org.davekeen.util.StringUtils;
	
	public class AnimationWidget extends AbstractWidget {
		
		public function AnimationWidget() {
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
		public function get animationUrl():String {
			if (hasSrc) {
				// gh#111 - support absolute and relative image urls
				return (StringUtils.beginsWith(src.toLowerCase(), "http")) ? src : mediaFolder + src;
			}
			
			return null;
		}
	}
}