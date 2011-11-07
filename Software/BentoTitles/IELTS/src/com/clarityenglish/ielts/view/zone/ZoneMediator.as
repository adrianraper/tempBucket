package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.CommonNotifications;
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
			
			// listen for these signals
			view.courseSelect.add(onCourseSelected);
			view.exerciseSelect.add(onExerciseSelect);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.exerciseSelect.removeAll();
		}
        
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				//IELTSNotifications.COURSE_SHOW,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				// You can't send a notification like this from another mediator under Title as this mediator will not exist
				/*
				case IELTSNotifications.COURSE_SHOW:
					var course:XMLList = note.getBody() as XMLList;
					view.course = course[0] as XML;
					break;
				*/
			}
		}
		
		/**
		 * An exercise was selected. Based on the extension of the Href we either want to open an exercise or open a pdf.
		 * 
		 * @param href
		 */
		private function onExerciseSelect(href:Href):void {
			sendNotification(IELTSNotifications.HREF_SELECTED, href);
		}
		
		/**
		 * Trigger the display of a course in the zone view
		 *
		 */
		private function onCourseSelected(course:XML):void {
			// dispatch a notification, which titleMediator is listening for
			sendNotification(IELTSNotifications.COURSE_SHOW, course);
		}
	}
}
