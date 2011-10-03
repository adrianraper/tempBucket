package com.clarityenglish.bento.view.swfplayer {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import mx.controls.SWFLoader;
	
	public class SWFPlayerView extends BentoView {
		
		[SkinPart(required="true")]
		public var swfLoader:SWFLoader;
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			var exercise:Exercise = xhtml as Exercise;
			
			// Get the src parameter (this should be an swf)
			var src:String = exercise.model.getViewParam("src");
			if (!src) {
				log.error("Required view parameter 'src' was not found");
				return;
			}
			
			// Get the full url by making an href relative to the current href, using the provided src
			var url:String = href.createRelativeHref(null, src).url;
			
			swfLoader.load(url);
		}
		
	}
	
}