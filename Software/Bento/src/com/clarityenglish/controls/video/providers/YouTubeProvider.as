package com.clarityenglish.controls.video.providers {
	import com.clarityenglish.controls.video.IVideoProvider;
	
	public class YouTubeProvider implements IVideoProvider {
		
		protected var source:String;
		
		public function YouTubeProvider(source:String = null) {
			this.source = source;
		}
		
		/**
		 * This provider applies if the source is in the format 'youtube:<id>'
		 *  
		 * @param source
		 * @return 
		 * 
		 */
		public function canHandleSource(source:Object):Boolean {
			var matches:Array = (source.toString()) ? source.toString().match(/^(\w+):?(.*)$/i) : null;
			if (!matches || matches.length < 3) return false;
			return matches[1] == "youtube";
		}
		
		public function getHtml(source:Object):String {
			var matches:Array = (source.toString()) ? source.toString().match(/^(\w+):?(.*)$/i) : null;
			if (!matches || matches.length < 3) return null;
			var id:String = matches[2];
			
			var html:String = "";
			html += "<!DOCTYPE html>";
			html += "<html>";
			html += "<body style='margin:0;padding:0;border:0;overflow:hidden;'>";
			html += "	<iframe id='ytplayer' style='position:absolute;top:0px;width:100%;height:100%'";
			html += "			type='text/html'";
			html += "			src='http://www.youtube.com/embed/" + id + "?rel=0&fs=1'";
			html += "			frameborder='0'>";
			html += "	</iframe>";
			html += "</body>";
			html += "</html>";
			return html;
			
			/*html += "<head>";
			html += "	<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no' />";
			html += "</head>";
			html += "<body style='margin:0;padding:0;border:0;overflow:hidden'>";
			html += "	<iframe id='player'";
			html += "			type='text/html'";
			html += "			width='" + width + "'";
			html += "			height='" + height + "'";
			html += "			src='http://www.youtube.com/embed/" + source + "?rel=0&hd=1&fs=1'";
			html += "			frameborder='0'>";
			html += "	</iframe>";
			html += "</body>";
			html += "</html>";*/
		}
		
	}
}