package com.clarityenglish.rotterdam.clearpronunciation.view.home
{
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	import com.googlecode.bindagetools.Bind;
	
	import org.puremvc.as3.interfaces.INotification;
	import com.clarityenglish.bento.model.BentoProxy;
	
	public class HomeMediator extends BentoMediator {
		public function HomeMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():HomeView {
			return viewComponent as HomeView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.selectUnit.add(onSelectUnit);
			
			// Load courses.xml serverside gh#84
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href; 
			
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			
			if (courseProxy.currentUnit)
				view.unit = courseProxy.currentUnit;
				
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.selectUnit.remove(onSelectUnit);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				RotterdamNotifications.COURSE_CREATED,
				BBNotifications.MENU_XHTML_LOAD,
				BBNotifications.MENU_XHTML_LOADED,
				BBNotifications.MENU_XHTML_NOT_LOADED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case RotterdamNotifications.COURSE_CREATED:
					// When a course is created go straight into it GH #75
					facade.sendNotification(BBNotifications.MENU_XHTML_LOAD, { filename: note.getBody().filename, options: { courseId: note.getBody().id } } );
					break;
				case BBNotifications.MENU_XHTML_LOAD:
					view.enabled = false; // gh#280
					break;
				case BBNotifications.MENU_XHTML_LOADED:
				case BBNotifications.MENU_XHTML_NOT_LOADED:
					view.enabled = true; // gh#280
					break;
			}
		}
		
		private function onSelectUnit(unit:XML):void {
			facade.sendNotification(BBNotifications.UNIT_START, unit);
		}
	}
}