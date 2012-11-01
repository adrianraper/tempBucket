package com.clarityenglish.rotterdam.view.courseselector {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.vo.Course;
	
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
			
			// Load courses.xml
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.href = new Href(Href.XHTML, "courses.xml", configProxy.getConfig().paths.content);
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
				// Force a reload of course.xml
				case RotterdamNotifications.COURSE_CREATED:
				case RotterdamNotifications.COURSE_DELETED:
					view.href = view.href.clone();
					break;
			}
		}
		
		private function onCreateCourse(course:Course):void {
			facade.sendNotification(RotterdamNotifications.COURSE_CREATE, course);
		}
		
		private function onSelectCourse(course:XML):void {
			facade.sendNotification(BBNotifications.MENU_XHTML_LOAD, { filename: course.@href, noProgress: true } );
		}
		
		private function onDeleteCourse(course:XML):void {
			facade.sendNotification(RotterdamNotifications.COURSE_DELETE, course);
		}
		
	}
}
