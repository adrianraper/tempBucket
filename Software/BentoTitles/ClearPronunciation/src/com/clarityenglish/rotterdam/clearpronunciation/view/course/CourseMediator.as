package com.clarityenglish.rotterdam.clearpronunciation.view.course
{
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	import com.googlecode.bindagetools.Bind;
	
	import flash.events.Event;
	
	import mx.collections.XMLListCollection;
	
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
			if (bentoProxy.menuXHTML) view.href = bentoProxy.menuXHTML.href;
			
			view.unitSelect.add(onUnitSelect);
			view.coursePublish.add(onCoursePublish);
			view.helpPublish.add(onHelpPublish);
			// gh#849
			view.settingsShow.add(onSettingsShow);
			view.scheduleShow.add(onScheduleShow);
			view.record.add(onRecorderOpen);
			
			// gh#110 - use real events instead of signals because they hook into system copy/paste shortcuts automatically
			view.unitDuplicate.add(onUnitDuplicate);
			// gh#240
			//view.addEventListener(Event.PASTE, onUnitPaste);
			
			// gh#208 need the teacher's group
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			view.group = loginProxy.group;
			
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			// gh#871 Course_Start notification doesn't be sent when open a unit, so unitCollection in CourseProxy cannot be used to bind data
			Bind.fromProperty(courseProxy, "currentUnit").convert(function(unit:XML):XMLListCollection {
				return new XMLListCollection(unit.parent().unit);
			}).toProperty(view, "unitListCollection");
			// gh#91
			view.isOwner = courseProxy.isOwner;
			view.isCollaborator = courseProxy.isCollaborator;
			view.isPublisher = courseProxy.isPublisher;
			view.isEditable = courseProxy.isEditable;
			// gh#871
			view.unit = courseProxy.currentUnit;
			// gh#91a 
			if (courseProxy.isPublisher || !courseProxy.isEditable)
				facade.sendNotification(RotterdamNotifications.PREVIEW_SHOW, true);
			
			// gh#870 should be same as the one in WidgetMediator
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.mediaFolder = new Href(Href.XHTML, "media/", configProxy.getConfig().paths.content).url;
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.unitSelect.remove(onUnitSelect);
			view.coursePublish.remove(onCoursePublish);
			view.unitDuplicate.remove(onUnitDuplicate);
			
			// gh#240
			//view.removeEventListener(Event.PASTE, onUnitPaste);
			
			// gh#279 - this helps with strange video rendering on the iPad for no obvious reason...
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			courseProxy.currentUnit = null;
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				RotterdamNotifications.PREVIEW_SHOWN,
				RotterdamNotifications.PREVIEW_HIDDEN,
				BBNotifications.ITEM_DIRTY,
				BBNotifications.UNIT_STARTED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			switch (note.getName()) {
				case RotterdamNotifications.PREVIEW_SHOWN:
				case RotterdamNotifications.PREVIEW_HIDDEN:
					view.previewVisible = courseProxy.isPreviewMode;
					break;
				case BBNotifications.UNIT_STARTED:
					view.unit = note.getBody() as XML;
					break;
				/*case BBNotifications.ITEM_DIRTY:
				if (note.getBody().toString() == 'settings')
				view.publishChanged();
				break;*/
			}
		}
		
		protected function onUnitSelect(unit:XML):void {
			facade.sendNotification(BBNotifications.UNIT_START, unit);
		}
		
		protected function onCoursePublish():void {
			//view.publishChanged();
			// I am undecided if you should auto save when you click publish (or just set ITEM_DIRTY). 
			// I currently think - yes. You are, after all, doing a 1-click publish.
			facade.sendNotification(RotterdamNotifications.COURSE_SAVE);
		}
		
		protected function onUnitDuplicate():void {
			facade.sendNotification(RotterdamNotifications.UNIT_COPY, view.unitList.selectedItem);
		}
		
		/* gh#240
		protected function onUnitPaste(event:Event):void {
		if (view.canPasteFromTarget(event.target))
		facade.sendNotification(RotterdamNotifications.UNIT_PASTE);
		}*/
		
		protected function onHelpPublish():void {
			facade.sendNotification(RotterdamNotifications.HELP_PUBLISH_WINDOW_SHOW);
		}
		
		protected function onSettingsShow():void {
			facade.sendNotification(RotterdamNotifications.SETTINGS_SHOW);
		}
		
		protected function onScheduleShow():void {
			facade.sendNotification(RotterdamNotifications.SCHEDULE_SHOW);	
		}
		
		protected function onRecorderOpen():void {
			facade.sendNotification(BBNotifications.RECORDER_SHOW);
		}
		
	}
}