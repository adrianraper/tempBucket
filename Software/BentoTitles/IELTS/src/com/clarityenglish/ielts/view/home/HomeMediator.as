﻿package com.clarityenglish.ielts.view.home {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.vo.progress.Progress;
	import com.clarityenglish.ielts.IELTSNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class HomeMediator extends BentoMediator implements IMediator {
		
		public function HomeMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():HomeView {
			return viewComponent as HomeView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			// listen for this signal
			view.courseSelect.add(onCourseSelected);
			
			// Inject required data into the view
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			view.user = loginProxy.user;
			
			// For standardised date formatting
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.dateFormatter = configProxy.getDateFormatter();
			
			// This view runs of the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			
			// Trigger loading of progress data for my summary chart
			//sendNotification(BBNotifications.PROGRESS_DATA_LOAD, {href:view.href}, Progress.PROGRESS_MY_SUMMARY);
			sendNotification(BBNotifications.PROGRESS_DATA_LOAD, view.href, Progress.PROGRESS_MY_SUMMARY);
			// AR No need to do this again as it is done for menu.xml
			//sendNotification(BBNotifications.PROGRESS_DATA_LOAD, view.href, Progress.PROGRESS_MY_DETAILS); 
		}
		
		override public function onRemove():void {
			super.onRemove();
			view.courseSelect.remove(onCourseSelected);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
					BBNotifications.PROGRESS_DATA_LOADED,
				]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.PROGRESS_DATA_LOADED:
					
					// Split the data that comes back for the various charts
					var rs:Object = note.getBody() as Object;
					switch (rs.type) {
						case Progress.PROGRESS_MY_DETAILS:
							// How should this merge with menu - or can it just replace it?
							var detailDataProvider:XML = new XML(rs.dataProvider);
							break;
						
						case Progress.PROGRESS_MY_SUMMARY:
							view.dataProvider = new XML(rs.dataProvider);
							break;
						default:
					}
				
			}
		}
		
		/**
		 * Trigger the display of a course in the zone view
		 *
		 */
		private function onCourseSelected(course:XML):void {
			// dispatch a notification, which titleMediator is listening for
			sendNotification(IELTSNotifications.COURSE_SHOW, course);
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			bentoProxy.currentCourseClass = course.@["class"];
		}
		
	}
}
