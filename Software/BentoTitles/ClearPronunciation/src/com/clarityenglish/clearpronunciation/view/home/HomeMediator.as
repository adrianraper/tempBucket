package com.clarityenglish.clearpronunciation.view.home {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.googlecode.bindagetools.Bind;

import flash.utils.setTimeout;

import mx.collections.ArrayCollection;
	
	public class HomeMediator extends BentoMediator {
		
		public function HomeMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():HomeView {
			return viewComponent as HomeView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.nodeSelect.add(onNodeSelected);
			
			// Load courses.xml serverside gh#84
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			if (bentoProxy.menuXHTML) view.href = bentoProxy.menuXHTML.href; 
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.channelCollection = new ArrayCollection(configProxy.getConfig().channels);
			
			view.mediaFolder = new Href(Href.XHTML, "media/", configProxy.getConfig().paths.content).url;

			view.isPlatformTablet = configProxy.isPlatformTablet();
			
			// Bind the selected node to the view to keep them in sync
			Bind.fromProperty(bentoProxy, "selectedNode").toProperty(view, "selectedNode");
			
			// Try and hack a bit of direct start for testing...
			/*setTimeout(function():void {
				sendNotification(BBNotifications.SELECTED_NODE_CHANGE, bentoProxy.menuXHTML..exercise.(@id == "1250740678061")[0]);
			}, 500);*/
            //setTimeout(function():void {sendNotification(BBNotifications.RECORDER_SHOW);}, 500);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.nodeSelect.remove(onNodeSelected);
			// gh#1112
			view.courses = null;
		}
		
		protected function onNodeSelected(exercise:XML, attribute:String = null):void {
			sendNotification(BBNotifications.SELECTED_NODE_CHANGE, exercise, attribute);
		}
		
	}
}