package com.clarityenglish.activereading.view.progress {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.DataProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	public class ProgressAnalysisMediator extends BentoMediator implements IMediator {
		public function ProgressAnalysisMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ProgressAnalysisView {
			return viewComponent as ProgressAnalysisView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			// This view runs off the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			
			var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;
			view.courseClass = dataProxy.getString("currentCourseClass") || bentoProxy.menuXHTML..menu.course[0].@['class']; 
			
			view.courseSelect.add(onCourseSelect);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.DATA_CHANGED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);	
			
			switch (note.getName()) {
				case BBNotifications.DATA_CHANGED:
					if (note.getType() == "currentCourseClass") view.courseClass = note.getBody() as String;
					break;
			}
		}
		
		private function onCourseSelect(courseClass:String):void {
			// Set the selected course class
			var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;
			dataProxy.set("currentCourseClass", courseClass);
		}
		
	}
}