package com.clarityenglish.rotterdam.view.course {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	
	import flash.events.Event;
	
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
			
			// This view runs off the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			
			view.unitSelect.add(onUnitSelect);
			view.coursePublish.add(onCoursePublish);
			
			//alice s
			view.helpPublish.add(onHelpPublish);
			
			// gh#110 - use real events instead of signals because they hook into system copy/paste shortcuts automatically
			view.addEventListener(Event.COPY, onUnitCopy);
			view.addEventListener(Event.PASTE, onUnitPaste);
			
			// In case the course has already started before the CourseView is registered gh#88
			handleCourseStarted();
			
			// gh#208 need the teacher's group
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			view.group = loginProxy.group;

		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.unitSelect.remove(onUnitSelect);
			view.coursePublish.remove(onCoursePublish);
			
			view.removeEventListener(Event.COPY, onUnitCopy);
			view.removeEventListener(Event.PASTE, onUnitPaste);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.COURSE_STARTED,
				RotterdamNotifications.PREVIEW_SHOW,
				RotterdamNotifications.PREVIEW_HIDE,
				BBNotifications.ITEM_DIRTY,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.COURSE_STARTED:
					handleCourseStarted();
					break;
				case RotterdamNotifications.PREVIEW_SHOW:
					view.previewVisible = true;
					break;
				case RotterdamNotifications.PREVIEW_HIDE:
					view.previewVisible = false;
					break;
				case BBNotifications.ITEM_DIRTY:
					if (note.getBody().toString() == 'settings')
						view.publishChanged();
					break;
			}
		}
		
		protected function handleCourseStarted():void {
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			view.unitListCollection = courseProxy.unitCollection;
		}
		
		protected function onUnitSelect(unit:XML):void {
			facade.sendNotification(BBNotifications.UNIT_START, unit);
		}
		
		protected function onCoursePublish():void {
			view.publishChanged();
			// I am undecided if you should auto save when you click publish (or just set ITEM_DIRTY). 
			// I currently think - yes. You are, after all, doing a 1-click publish.
			facade.sendNotification(RotterdamNotifications.COURSE_SAVE);
		}
		
		protected function onUnitCopy(event:Event):void {
			facade.sendNotification(RotterdamNotifications.UNIT_COPY, view.unitList.selectedItem);
		}
		
		protected function onUnitPaste(event:Event):void {
			if (view.canPasteFromTarget(event.target))
				facade.sendNotification(RotterdamNotifications.UNIT_PASTE);
		}
		
		//alice s
		protected function onHelpPublish():void {
			facade.sendNotification(RotterdamNotifications.HELP_PUBLISH_WINDOW_SHOW);
		}
		
	}
}
