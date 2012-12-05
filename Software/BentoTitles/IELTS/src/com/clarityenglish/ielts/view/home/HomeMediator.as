package com.clarityenglish.ielts.view.home {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.common.vo.progress.Progress;
	import com.clarityenglish.ielts.IELTSNotifications;
	import com.clarityenglish.ielts.model.IELTSProxy;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	import skins.ielts.home.CourseButtonSkin;
	
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
			view.info.add(onInfoRequested);
			
			// Inject required data into the view
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			view.user = loginProxy.user;
			
			// For standardised date formatting
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.accountName = configProxy.getConfig().accountName;
			view.dateFormatter = configProxy.getDateFormatter();
			
			// Inject data - but not default values
			view.productVersion = configProxy.getProductVersion();
			view.productCode = configProxy.getProductCode();
			view.licenceType = configProxy.getLicenceType();
			
			// This view runs of the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			
			// Trigger loading of progress data for my summary chart
			//sendNotification(BBNotifications.PROGRESS_DATA_LOAD, {href:view.href}, Progress.PROGRESS_MY_SUMMARY);
			// BUG: If you do a direct start you skip this, so it crashes on coming back from an exercise
			// Perhaps this should be in bentostartupcommand then.
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
							// #250. Save xml rather than a string
							//var detailDataProvider:XML = new XML(rs.dataProvider);
							var detailDataProvider:XML = rs.dataProvider;
							break;
						
						// No longer call mySummary, calculate it from myDetails instead
						// So all this stuff goes in the above case
						case Progress.PROGRESS_MY_SUMMARY:
							// #250. Save xml rather than a string
							//view.dataProvider = new XML(rs.dataProvider);
							view.dataProvider = rs.dataProvider;
							
							// Do a quick check to see if there is any data
							var foundAValue:Boolean  = false;
							for each (var course:XML in view.dataProvider.course) {
							//for each (var course:XML in view.dataProvider.course.summaryData) {
								if (new Number(course.@coverage)>0) {
									foundAValue = true;
									break;
								}
							}
							view.noProgressData = !foundAValue;
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
			
			var ieltsProxy:IELTSProxy = facade.retrieveProxy(IELTSProxy.NAME) as IELTSProxy;
			ieltsProxy.currentCourseClass = course.@["class"];
		}

		private function onInfoRequested():void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var registerPage:String = (configProxy.getConfig().registerURL) ? configProxy.getConfig().registerURL : "www.takeielts.org";
			sendNotification(IELTSNotifications.IELTS_REGISTER, registerPage);
		}

	}
}
