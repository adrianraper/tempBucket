package com.clarityenglish.rotterdam.view.unit.widgets {
	import com.clarityenglish.textLayout.components.AudioPlayer;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.davekeen.util.StringUtils;
	
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
		
		[Bindable(event="srcAttrChanged")]
		public function get audioUrl():String {
			if (hasSrc) {
				// gh#111 - support absolute and relative image urls
				return (StringUtils.beginsWith(src.toLowerCase(), "http")) ? src : mediaFolder + "/" + src;
			}
			
			return null;
		}
		
		//gh #106
		public function onPlayClicked(event:MouseEvent):void {
			playAudio.dispatch(xml);
		}
		
	}
}
