package com.clarityenglish.clearpronunciation.view.title {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.clearpronunciation.ClearPronunciationNotifications;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.facade.Facade;
	
	/**
	 * A Mediator
	 */	
	public class TitleMediator extends BentoMediator {
		
		public function TitleMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():TitleView {
			return viewComponent as TitleView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.settingsOpen.add(onSettingsOpen);
			view.logout.add(onLogout);
			
			// This view runs off the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.isPlatformiPad = configProxy.isPlatformiPad();
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.settingsOpen.remove(onSettingsOpen);
			view.logout.remove(onLogout);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.SELECTED_NODE_CHANGED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.SELECTED_NODE_CHANGED:
					view.selectedNode = note.getBody() as XML;
					break;
			}
		}
		
		protected function onSettingsOpen():void {
			sendNotification(ClearPronunciationNotifications.SETTINGS_SHOW);
		}
		
		protected function onLogout():void {
			sendNotification(BBNotifications.CLOSE_ALL_POPUPS, view);
			sendNotification(CommonNotifications.LOGOUT);
		}
		
		/*override public function onRegister():void {
			super.onRegister();
			
			view.dirtyWarningShow.add(onDirtyWarningShow);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.dirtyWarningShow.remove(onDirtyWarningShow);
			view.logout.remove(onLogout);
			view.settingsOpen.remove(onSettingsOpen);
		}
		
		protected function onDirtyWarningShow(next:Function):void {
			// gh#83 and gh#90
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			if (bentoProxy.isDirty) {
				sendNotification(BBNotifications.WARN_DATA_LOSS, { message: bentoProxy.getDirtyMessage(), func: next }, "changes_not_saved");
			} else {
				next();
			}
		}
		
		protected function onProgressTransform():void {
			//sendNotification();
		}*/
	}
}