package com.clarityenglish.controls.video.providers {
	import com.clarityenglish.controls.video.IVideoProvider;
	
	public class VimeoProvider implements IVideoProvider {
		
		protected var source:String;
		
		public function VimeoProvider(source:String = null) {
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
			return matches[1] == "vimeo";
		}
		
		public function getHtml(source:Object):String {
			var matches:Array = (source.toString()) ? source.toString().match(/^(\w+):?(.*)$/i) : null;
			if (!matches || matches.length < 3) return null;
			var id:String = matches[2];
			
			var html:String = "";
			html += "<!DOCTYPE html>";
			html += "<html>";
			html += "<body style='margin:0;padding:0;border:0;overflow:hidden;'>";
			html += "	<iframe style='position:absolute;top:0px;width:100%;height:100%'";
			html += "			src='http://player.vimeo.com/video/" + id + "'";
			html += "			frameborder='0'";
			html += "			webkitallowfullscreen mozallowfullscreen allowfullscreen";
			html += "	</iframe>";
			html += "</body>";
			html += "</html>";
			return html;
		}
		
	}
}