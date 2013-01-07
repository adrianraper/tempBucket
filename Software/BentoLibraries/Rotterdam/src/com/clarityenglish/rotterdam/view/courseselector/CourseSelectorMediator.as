package com.clarityenglish.rotterdam.view.courseselector {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class CourseSelectorMediator extends BentoMediator implements IMediator {
		
		public function CourseSelectorMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():CourseSelectorView {
			return viewComponent as CourseSelectorView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.createCourse.add(onCreateCourse);
			view.selectCourse.add(onSelectCourse);
			view.deleteCourse.add(onDeleteCourse);
			
			// gh#13 
			facade.sendNotification(RotterdamNotifications.COURSE_RESET);
			
			// Load courses.xml serverside gh#84
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.href = new Href(Href.XHTML, "courses.xml", configProxy.getConfig().paths.content, true);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.createCourse.remove(onCreateCourse);
			view.selectCourse.remove(onSelectCourse);
			view.deleteCourse.remove(onDeleteCourse);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				RotterdamNotifications.COURSE_CREATED,
				RotterdamNotifications.COURSE_DELETED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case RotterdamNotifications.COURSE_CREATED:
					// When a course is created go straight into it GH #75
					facade.sendNotification(BBNotifications.MENU_XHTML_LOAD, { filename: note.getBody() } );
					break;
				case RotterdamNotifications.COURSE_DELETED:
					// Force a reload of course.xml
					view.href = view.href.clone();
					break;
			}
		}
		
		private function onCreateCourse():void {
			facade.sendNotification(RotterdamNotifications.COURSE_CREATE_WINDOW_SHOW);
		}
		
		/**
		 * This method is a big deal in Rotterdam; normal Bento titles are fixed to a single menu.xml file once they have started, but Rotterdam allows the menu.xml
		 * to be changed at runtime.  And this is the function that kicks it off :)
		 * 
		 * @param course
		 */
		private function onSelectCourse(course:XML):void {
			facade.sendNotification(BBNotifications.MENU_XHTML_LOAD, { filename: course.@href } );
		}
		
		private function onDeleteCourse(course:XML):void {
			facade.sendNotification(RotterdamNotifications.COURSE_DELETE, course);
		}
		
	}
}
