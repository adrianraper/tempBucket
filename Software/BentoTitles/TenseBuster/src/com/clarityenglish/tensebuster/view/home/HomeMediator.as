package com.clarityenglish.tensebuster.view.home {
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.tensebuster.TenseBusterNotifications;
	
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
		
		public override function onRegister():void {
			super.onRegister();
			
			view.courseSelect.add(onCourseSelected);
			
			// This view runs off the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
		}
		
		public override function onRemove():void {
			view.courseSelect.remove(onCourseSelected);
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
		
		protected function onCourseSelected(course:XML):void {
			/**
			 * TODO: The current method of selecting a course (taken from IELTS using a COURSE_SHOW notification) is quite messy and doesn't scale all that well across titles and
			 * devices.  For Tensebuster its still ok, since we don't want to prematurely optimize this without seeing at least one more title, but if the pattern for course/unit
			 * selection keeps going for future titles there are definitely much cleaner ways to do this.
			 */
			sendNotification(TenseBusterNotifications.COURSE_SHOW, course);
		}
		
	}
}
