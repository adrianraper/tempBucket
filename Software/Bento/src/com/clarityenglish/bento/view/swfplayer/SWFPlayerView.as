package com.clarityenglish.bento.view.swfplayer {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	
	import mx.controls.SWFLoader;
	import flash.events.Event;
	
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
			
			// #107
			//swfLoader.loadForCompatibility = true;
			var context:LoaderContext = new LoaderContext();
			//context.securityDomain = SecurityDomain.;
			context.applicationDomain = new ApplicationDomain();
			
			swfLoader.loaderContext = context;    
			swfLoader.load(url);
		}
		
		protected override function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);
			
			swfLoader.unloadAndStop();
		}
		
	}
	
}