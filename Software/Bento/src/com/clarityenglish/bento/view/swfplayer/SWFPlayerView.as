package com.clarityenglish.bento.view.swfplayer {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	
	import mx.controls.SWFLoader;
	import mx.core.UIComponent;
	
	public class SWFPlayerView extends BentoView {
		
		[SkinPart(required="true")]
		public var swfLoader:SWFLoader;
		
		[SkinPart]
		public var loadingGraphic:SWFLoader;

		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case loadingGraphic:
					loadingGraphic.source = getStyle("loadingGraphic");
					break;
			}
		}
		
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
			// The following has no impact. Also noticed that if you leave video running and leave the Question Zone
			// video keeps playing. This is very bad, and perhaps solving that will solve this too.
			//swfLoader.loadForCompatibility = true;
			// var context:LoaderContext = new LoaderContext();
			//context.securityDomain = SecurityDomain.;
			// context.applicationDomain = new ApplicationDomain();
			// swfLoader.loaderContext = context;
			
			swfLoader.addEventListener(Event.COMPLETE, onComplete);
			showLoadingGraphic();
			swfLoader.load(url);
		}
		
		protected function onComplete(event:Event):void {
			swfLoader.removeEventListener(Event.COMPLETE, onComplete);
			hideLoadingGraphic();
		}
		
		protected override function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);
			
			swfLoader.unloadAndStop();
		}
		
		private function showLoadingGraphic():void {
			if (loadingGraphic) loadingGraphic.visible = true;
		}
		
		private function hideLoadingGraphic():void {
			if (loadingGraphic) loadingGraphic.visible = false;
		}
		
	}
	
}