package com.clarityenglish.rotterdam.view.settings {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	
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
			
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			view.currentCourse = courseProxy.currentCourse;
		}
		
		override public function onRemove():void {
			super.onRemove();
			
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				
			}
		}		
		
	}
}
