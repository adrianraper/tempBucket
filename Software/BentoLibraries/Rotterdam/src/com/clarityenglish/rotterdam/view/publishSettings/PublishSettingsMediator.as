package com.clarityenglish.rotterdam.view.publishSettings {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	
	import mx.collections.ArrayCollection;
	
	import org.davekeen.util.ArrayUtils;
	import org.puremvc.as3.interfaces.IMediator;
	
	/**
	 * A Mediator
	 */
	public class PublishSettingsMediator extends BentoMediator implements IMediator {
		
		public function PublishSettingsMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():PublishSettingsView {
			return viewComponent as PublishSettingsView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.dirty.add(onDirty);
			view.saveCourse.add(onSaveCourse);
			view.back.add(onBack);
			view.sendEmail.add(onSendEmail);
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			view.groupTreesCollection = new ArrayCollection(ArrayUtils.duplicate(loginProxy.groupTrees) as Array);
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
			view.navigator.popView();
		}

		// gh#122
		protected function onSendEmail(course:XML, groupID:Number):void {
			facade.sendNotification(RotterdamNotifications.SEND_WELCOME_EMAIL, {course: course, groupID: groupID});
		}
		
	}
}
