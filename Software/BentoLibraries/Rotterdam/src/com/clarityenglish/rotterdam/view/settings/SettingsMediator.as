package com.clarityenglish.rotterdam.view.settings {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	
	import mx.collections.ArrayCollection;
	
	import org.davekeen.util.ArrayUtils;
	import org.puremvc.as3.interfaces.IMediator;
	
	/**
	 * A Mediator
	 */
	public class SettingsMediator extends BentoMediator implements IMediator {
		
		public function SettingsMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():SettingsView {
			return viewComponent as SettingsView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.dirty.add(onDirty);
			view.saveCourse.add(onSaveCourse);
			view.back.add(onBack);
			view.sendEmail.add(onSendEmail);
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			view.isOwner = courseProxy.isOwner;
			view.isCollaborator = courseProxy.isCollaborator;
			view.isPublisher = courseProxy.isPublisher;
			view.isEditable = courseProxy.isEditable;
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.dirty.remove(onDirty);
			view.saveCourse.remove(onSaveCourse);
			view.back.remove(onBack);
			view.sendEmail.remove(onSendEmail);
			
			sendNotification(BBNotifications.ITEM_CLEAN, "settings"); // gh#83
		}
		
		protected function onDirty():void {
			sendNotification(BBNotifications.ITEM_DIRTY, "settings"); // gh#83
		}
		
		protected function onSaveCourse():void {
			facade.sendNotification(RotterdamNotifications.COURSE_SAVE);
		}
		
		protected function onBack():void {
			// gh#849
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;			
			facade.sendNotification(BBNotifications.COURSE_STARTED, bentoProxy.menuXHTML);
		}

		// gh#122
		protected function onSendEmail(course:XML, groupID:Number):void {
			facade.sendNotification(RotterdamNotifications.SEND_WELCOME_EMAIL, {course: course, groupID: groupID});
		}
		
	}
}