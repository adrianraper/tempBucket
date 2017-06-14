package com.clarityenglish.ielts.view.home {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.DataProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.ielts.IELTSNotifications;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import org.puremvc.as3.interfaces.IMediator;
	
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
			
			view.courseSelect.add(onCourseSelected);
			view.info.add(onInfoRequested);
			view.exerciseSelect.add(onExerciseSelect);
			
			// Inject required data into the view
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			view.user = loginProxy.user;
			
			// For standardised date formatting
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.accountName = configProxy.getConfig().accountName;
			view.dateFormatter = configProxy.getDateFormatter();
			
			
			// get the login platform
			if (configProxy.isPlatformTablet()) {
				view.isPlatformTablet = true;
				if (configProxy.isPlatformiPad()) {
					view.isPlatformipad = true;
				} else if (configProxy.isPlatformAndroid()) {
					view.isPlatformAndroid = true;
				}
			} else {
				view.isPlatformTablet = false;
			}
			
			// Inject data - but not default values
			// TODO: not sure if this is necessary as its already done in BentoMediator (albeit with a default) - check this with Adrian
			view.licenceType = configProxy.getLicenceType();
			
			// This view runs of the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			if(bentoProxy.menuXHTML) // gh#1517 Logout will pop up all the stacked views in homeNavigator and go to the home view however the bentoProxy reset before view pop up, so the bentoProxy.menuXHTML will be null and hence we need to skip the assignment for href.
				view.href = bentoProxy.menuXHTML.href;
			// gh#383
			view.findMore.add(onFindMoreClicked);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.courseSelect.remove(onCourseSelected);
            view.exerciseSelect..remove(onExerciseSelect);
			view.info.remove(onInfoRequested);
		}
		
		protected override function onXHTMLReady(xhtml:XHTML):void {
			super.onXHTMLReady(xhtml);
			
			// Provide the model to the view so that it can extract summary data for the course bar renderers
			view.dataProvider = xhtml..script.(@id == "model")[0];
			
			// Do a quick check to see if there is any data
			var foundCoverage:Boolean  = false;
			for each (var course:XML in view.dataProvider..course) {
				if (new Number(course.@coverage) > 0) {
					foundCoverage = true;
					break;
				}
			}
			view.noProgressData = !foundCoverage;
		}
		
		/**
		 * Trigger the display of a course in the zone view
		 *
		 */
		private function onCourseSelected(course:XML):void {
			// Open the selected course
			sendNotification(BBNotifications.SELECTED_NODE_CHANGE, course);
			
			// Set the selected course class
			var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;
			dataProxy.set("currentCourseClass", course.@["class"].toString());
		}
		
		private function onInfoRequested():void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var registerPage:String = (configProxy.getConfig().registerURL) ? configProxy.getConfig().registerURL : "www.takeielts.org";
			sendNotification(IELTSNotifications.IELTS_REGISTER, registerPage);
		}
		
		// gh#383
		protected function onFindMoreClicked():void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var morePage:String = (configProxy.getConfig().upgradeURL) ? configProxy.getConfig().upgradeURL : "www.ieltspractice.com";
			sendNotification(IELTSNotifications.IELTS_REGISTER, morePage);
		}

        protected function onExerciseSelect(node:XML, attribute:String = null):void {
            sendNotification(BBNotifications.SELECTED_NODE_CHANGE, node, attribute);
        }

	}
}
