package com.clarityenglish.rotterdam.builder.view.course {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class CourseMediator extends BentoMediator implements IMediator {
		
		public function CourseMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():CourseView {
			return viewComponent as CourseView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.courseLoad.add(onCourseLoad);
			view.unitSelect.add(onUnitSelect);
			
			// If the view already has data set then load a course straight away
			if (view.data)
				onCourseLoad(view.data as XML);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.courseLoad.remove(onCourseLoad);
			view.unitSelect.remove(onUnitSelect);
		}
		
		protected override function onXHTMLReady(xhtml:XHTML):void {
			super.onXHTMLReady(xhtml);
			
			// When the XHTML has loaded into the course editor then the course has started
			facade.sendNotification(RotterdamNotifications.COURSE_START, xhtml);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				RotterdamNotifications.COURSE_STARTED,
				RotterdamNotifications.PREVIEW_SHOW,
				RotterdamNotifications.PREVIEW_HIDE,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case RotterdamNotifications.COURSE_STARTED:
					var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
					view.unitListCollection = courseProxy.unitCollection;
					break;
				case RotterdamNotifications.PREVIEW_SHOW:
					view.previewVisible = true;
					break;
				case RotterdamNotifications.PREVIEW_HIDE:
					view.previewVisible = false;
					break;
			}
		}
		
		protected function onCourseLoad(course:XML):void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.href = new Href(Href.XHTML, course.@href, configProxy.getConfig().paths.content);
		}
		
		protected function onUnitSelect(unit:XML):void {
			facade.sendNotification(RotterdamNotifications.UNIT_START, unit);
		}
		
	}
}
