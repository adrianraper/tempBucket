package com.clarityenglish.clearpronunciation.view.home {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	
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
			
			view.exerciseSelect.add(onExerciseSelected);
			
			// Load courses.xml serverside gh#84
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			if (bentoProxy.menuXHTML) view.href = bentoProxy.menuXHTML.href; 
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.channelCollection = new ArrayCollection(configProxy.getConfig().channels);
			
			view.mediaFolder = new Href(Href.XHTML, "media/", configProxy.getConfig().paths.content).url;
			
			// Try and hack a bit of direct start for testing...
			/*setTimeout(function():void {
				sendNotification(BBNotifications.SELECTED_NODE_CHANGE, bentoProxy.menuXHTML..exercise.(@id == "1250740678061")[0]);
			}, 500);*/
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.exerciseSelect.remove(onExerciseSelected);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				RotterdamNotifications.COURSE_CREATED,
				BBNotifications.MENU_XHTML_LOAD,
				BBNotifications.MENU_XHTML_LOADED,
				BBNotifications.MENU_XHTML_NOT_LOADED,
				BBNotifications.SELECTED_NODE_CHANGED,
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
				case BBNotifications.SELECTED_NODE_CHANGED:
					view.selectedNode = note.getBody() as XML;
					break;
			}
		}
		
		protected function onExerciseSelected(exercise:XML, attribute:String = null):void {
			sendNotification(BBNotifications.SELECTED_NODE_CHANGE, exercise, attribute);
		}
		
	}
}