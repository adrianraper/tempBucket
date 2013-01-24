﻿package com.clarityenglish.rotterdam.view.settings {
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class SettingsMediator extends BentoMediator implements IMediator {
		
		public function SettingsMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():SettingsView {
			return viewComponent as SettingsView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.dirty.add(onDirty);
			view.saveCourse.add(onSaveCourse);
			view.back.add(onBack);
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			view.groupTreesCollection = new ArrayCollection(loginProxy.groupTrees);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.dirty.remove(onDirty);
			view.saveCourse.remove(onSaveCourse);
			view.back.remove(onBack);
			
			sendNotification(RotterdamNotifications.SETTINGS_CLEAN); // GH #83
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				RotterdamNotifications.COURSE_SAVED
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case RotterdamNotifications.COURSE_SAVED:
					sendNotification(RotterdamNotifications.SETTINGS_CLEAN); // GH #83
					break;
			}
		}
		
		protected function onDirty():void {
			sendNotification(RotterdamNotifications.SETTINGS_DIRTY); // GH #83
		}
		
		protected function onSaveCourse():void {
			facade.sendNotification(RotterdamNotifications.COURSE_SAVE);
		}
		
		protected function onBack():void {
			view.navigator.popView();
		}
		
	}
}
