package com.clarityenglish.ielts.view.candidates
{
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	
	public class CandidatesMediator extends BentoMediator
	{
		public function CandidatesMediator(mediatorName:String, viewComponent:BentoView)
		{
			super(mediatorName, viewComponent);
		}
		
		private function get view():CandidatesView {
			return viewComponent as CandidatesView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;			
			var href:Href = new Href(Href.XHTML, "links.xml", configProxy.getContentPath(), true);
			view.href = href;
			view.channelCollection = new ArrayCollection(configProxy.getConfig().channels);
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.hrefToUidFunction = bentoProxy.getExerciseUID;
		}
	}
}