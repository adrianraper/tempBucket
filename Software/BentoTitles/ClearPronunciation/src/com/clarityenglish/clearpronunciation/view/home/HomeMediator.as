package com.clarityenglish.clearpronunciation.view.home
{
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.clearpronunciation.ClearPronunciationNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	import com.googlecode.bindagetools.Bind;
	
	import flash.media.Video;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.INotification;
	
	public class HomeMediator extends BentoMediator {
		public function HomeMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():HomeView {
			return viewComponent as HomeView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.exerciseShow.add(onExerciseShow);
			
			// Load courses.xml serverside gh#84
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			if (bentoProxy.menuXHTML) view.href = bentoProxy.menuXHTML.href; 
			
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			if (courseProxy.currentUnit) view.unit = courseProxy.currentUnit;
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.channelCollection = new ArrayCollection(configProxy.getConfig().channels);
			
			view.mediaFolder = new Href(Href.XHTML, "media/", configProxy.getConfig().paths.content).url;
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.exerciseShow.remove(onExerciseShow);
			// gh#1073
			view.unit = null;
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
		
		protected function onExerciseShow(item:XML):void {
			if (item.hasOwnProperty("@class") && item.(@["class"] == "practiseSounds")) {
				facade.sendNotification(ClearPronunciationNotifications.COMPOSITEUNIT_START, { unit: item.parent(), exercise: item });
			} else {
				facade.sendNotification(ClearPronunciationNotifications.COMPOSITEUNIT_START, { unit: item.parent().parent(), exercise: item });
			}
			
		}
	}
}