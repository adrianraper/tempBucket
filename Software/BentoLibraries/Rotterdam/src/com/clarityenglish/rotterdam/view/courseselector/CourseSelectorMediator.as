package com.clarityenglish.rotterdam.view.courseselector {
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
			view.editCourse.add(onEditCourse);
			
			// TODO: This should go elsewhere since lots of things will use it
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			
			//var contentPath:String = configProxy.getConfig().paths.content; - until we have a product and product code this points at RoadToIELTS so do it manually
			var contentPath:String = "http://dock.contentbench/Content/Rotterdam";
			contentPath += "/" + loginProxy.user.id;
			
			view.href = new Href(Href.XHTML, "courses.xml", contentPath);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.createCourse.remove(onCreateCourse);
			view.editCourse.remove(onEditCourse);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				RotterdamNotifications.COURSE_CREATED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				// Force a reload of course.xml
				case RotterdamNotifications.COURSE_CREATED:
					view.href = view.href.clone();
					break;
			}
		}
		
		private function onCreateCourse(course:Course):void {
			facade.sendNotification(RotterdamNotifications.COURSE_CREATE, course);
		}
		
		private function onEditCourse(course:XML):void {
			facade.sendNotification(RotterdamNotifications.COURSE_EDITOR_SHOW, course);
		}
		
	}
}
