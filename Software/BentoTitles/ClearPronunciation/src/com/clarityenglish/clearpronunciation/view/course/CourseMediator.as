package com.clarityenglish.clearpronunciation.view.course
{
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.clearpronunciation.ClearPronunciationNotifications;
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
			if (bentoProxy.selectedExerciseNode.hasOwnProperty("@href")) view.isExerciseVisible = true;
			
			view.unitSelect.add(onUnitSelect);;
			// gh#849
			view.settingsShow.add(onSettingsShow);
			view.record.add(onRecorderOpen);
			view.exerciseShow.add(onExerciseShow);
			view.nextExercise.add(onNextExercise);
			view.backExercise.add(onBackExercise);
			view.dirtyWarningShow.add(onDirtyWarningShow);
			
			// gh#208 need the teacher's group
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			view.group = loginProxy.group;
			
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			// gh#871 Course_Start notification doesn't be sent when open a unit, so unitCollection in CourseProxy cannot be used to bind data
			Bind.fromProperty(courseProxy, "currentUnit").convert(function(unit:XML):XMLListCollection {
				if (unit) {
					return new XMLListCollection(unit.parent().unit);
				} else {
					return null;
				}
			}).toProperty(view, "unitListCollection");
			Bind.fromProperty(courseProxy, "currentUnit").toProperty(view, "unit");
			
			// gh#870 should be same as the one in WidgetMediator
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.mediaFolder = new Href(Href.XHTML, "media/", configProxy.getConfig().paths.content).url;
			UnitCaptionComponent.mediaFolder = new Href(Href.XHTML, "media/", configProxy.getConfig().paths.content).url;
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.unitSelect.remove(onUnitSelect);
			
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			courseProxy.currentUnit = null;
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
			]);
		}
		
		protected function onUnitSelect(unit:XML):void {
			facade.sendNotification(BBNotifications.UNIT_START, unit);
		}
		
		protected function onSettingsShow():void {
			facade.sendNotification(RotterdamNotifications.SETTINGS_SHOW);
		}
		
		protected function onRecorderOpen():void {
			facade.sendNotification(BBNotifications.RECORDER_SHOW);
		}
		
		protected function onExerciseShow(exercise:XML):void {
			facade.sendNotification(BBNotifications.SELECTED_NODE_CHANGE, exercise);
		}
		
		protected function onNextExercise():void {
			log.debug("The user clicked on next exercise");
			sendNotification(BBNotifications.EXERCISE_SHOW_NEXT);
		}
		
		protected function onBackExercise():void {
			log.debug("The user clicked on previous exercise");
			sendNotification(BBNotifications.EXERCISE_SHOW_PREVIOUS);
		}
		
		// gh#1064
		protected function onDirtyWarningShow(next:Function):void {
			facade.sendNotification(ClearPronunciationNotifications.HOME_BACK, next);
		}
	}
}