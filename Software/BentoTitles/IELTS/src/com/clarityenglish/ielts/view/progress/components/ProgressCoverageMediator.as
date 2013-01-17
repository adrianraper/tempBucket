package com.clarityenglish.ielts.view.progress.components {
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.ielts.IELTSNotifications;
	import com.clarityenglish.ielts.model.IELTSProxy;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class ProgressCoverageMediator extends BentoMediator implements IMediator {
		
		public function ProgressCoverageMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ProgressCoverageView {
			return viewComponent as ProgressCoverageView;
		}
		
		override public function onRegister():void {
			super.onRegister();

			// This view runs off the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var ieltsProxy:IELTSProxy = facade.retrieveProxy(IELTSProxy.NAME) as IELTSProxy;
			view.href = bentoProxy.menuXHTML.href;
			view.courseClass = ieltsProxy.currentCourseClass;
			
			// Listen for course changing signal
			view.courseSelect.add(onCourseSelect);

		}

		override public function onRemove():void {
			super.onRemove();
			
			view.courseSelect.remove(onCourseSelect);
		}
				
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				IELTSNotifications.COURSE_CLASS_SELECTED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);	
			
			switch (note.getName()) {
				case IELTSNotifications.COURSE_CLASS_SELECTED:
					view.courseClass = note.getBody() as String;
					break;
			}
		}
		
		private function onCourseSelect(courseClass:String):void {
			sendNotification(IELTSNotifications.COURSE_CLASS_SELECT, courseClass);
		}
	}
}
