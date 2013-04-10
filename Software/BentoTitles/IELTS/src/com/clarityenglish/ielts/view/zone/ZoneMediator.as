package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.DataProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.ielts.IELTSNotifications;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class ZoneMediator extends BentoMediator implements IMediator {
		
		public function ZoneMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ZoneView {
			return viewComponent as ZoneView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			// Inject required data into the view
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			view.user = loginProxy.user;
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.dateFormatter = configProxy.getDateFormatter();
			
			// #234
			view.productVersion = configProxy.getProductVersion();
			view.licenceType = configProxy.getLicenceType();
			
			// listen for these signals
			view.courseSelect.add(onCourseSelected);
			view.exerciseSelect.add(onExerciseSelected);
			
			// This view runs off the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			
			view.isMediated = true; // #222
			
			// #514 If you are SCORM you don't want the course selector
			// #378 Actually, you will still use it, just disable the courses that are hidden.
			//view.useCourseSelector = !configProxy.getConfig().scorm;
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.courseSelect.remove(onCourseSelected);
			view.exerciseSelect.remove(onExerciseSelected);
			
			view.isMediated = false; // #222
		}
        
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.SCORE_WRITTEN,
				IELTSNotifications.PRACTICE_ZONE_POPUP_SHOW,
				IELTSNotifications.PRACTICE_ZONE_POPUP_HIDE,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				// #164 For updating of coverage blobs when you do another exercise
				case BBNotifications.SCORE_WRITTEN:
					//view.popoutExerciseSelector.exercises = view.refreshedExercises();
					break;
				case IELTSNotifications.PRACTICE_ZONE_POPUP_SHOW:
					view.setCourseSelectorVisible(false);
					break;
				case IELTSNotifications.PRACTICE_ZONE_POPUP_HIDE:
					view.setCourseSelectorVisible(true);
					break;
			}
		}
		
		/**
		 * An exercise was selected. Based on the extension of the Href we either want to open an exercise or open a pdf.
		 * 
		 * @param href
		 */
		private function onExerciseSelected(href:Href):void {
			sendNotification(IELTSNotifications.HREF_SELECTED, href);
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
		
	}
}
