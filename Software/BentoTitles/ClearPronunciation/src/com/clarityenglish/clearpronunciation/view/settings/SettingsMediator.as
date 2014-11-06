package com.clarityenglish.clearpronunciation.view.settings {
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.ConfigProxy;
	
	import flash.net.SharedObject;
	
	import mx.collections.ArrayCollection;
	
	public class SettingsMediator extends BentoMediator {
		public function SettingsMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():SettingsView {
			return viewComponent as SettingsView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.channelSaveClose.add(onChannelSaveClose);
			
			// Load courses.xml serverside gh#84
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.channelCollection = new ArrayCollection(configProxy.getConfig().channels);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.channelSaveClose.remove(onChannelSaveClose);
		}
		
		protected function onChannelSaveClose(value:Number):void {
			var settingsSharedObject:SharedObject = SharedObject.getLocal("settings");
			settingsSharedObject.data["channelIndex"] = value;
			settingsSharedObject.flush();
		}
	}
}