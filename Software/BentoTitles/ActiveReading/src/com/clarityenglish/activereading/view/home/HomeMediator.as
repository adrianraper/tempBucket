package com.clarityenglish.activereading.view.home {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.googlecode.bindagetools.Bind;
	
	import mx.utils.ObjectUtil;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	public class HomeMediator extends BentoMediator implements IMediator {
		
		public function HomeMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():HomeView {
			return viewComponent as HomeView;
		}
		
		public override function onRegister():void {
			super.onRegister();
			
			view.courseSelect.add(onCourseSelected);
			
			// This view runs off the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			if (bentoProxy.menuXHTML) view.href = bentoProxy.menuXHTML.href;
			
			// gh#757
			Bind.fromProperty(bentoProxy, "selectedCourseNode").toProperty(view, "course");
			Bind.fromProperty(bentoProxy, "selectedUnitNode").toProperty(view, "unit");	
			
			view.unitSelect.add(onUnitSelected);
			view.exerciseSelect.add(onExerciseSelected);
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			if (ObjectUtil.getClassInfo(configProxy.getDirectStart()).properties.length > 0) {
				var directStart:Object = configProxy.getDirectStart();
				if (directStart.courseID) { 
					view.directCourseID = directStart.courseID
					// gh#853
					view.isDirectStart = true;
				}
				if (directStart.unitID) { 
					view.directUnitID = directStart.unitID;
					view.isDirectStart = true;
				}
			}
		}
		
		public override function onRemove():void {
			view.courseSelect.remove(onCourseSelected);
			view.unitSelect.remove(onUnitSelected);
			view.exerciseSelect.remove(onExerciseSelected);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
		}
		
		protected function onCourseSelected(course:XML):void {
			sendNotification(BBNotifications.SELECTED_NODE_CHANGE, course);
		}
		
		protected function onUnitSelected(unit:XML):void {
			sendNotification(BBNotifications.SELECTED_NODE_CHANGE, unit);
		}
		
		protected function onExerciseSelected(exercise:XML, attribute:String = null):void {
			sendNotification(BBNotifications.SELECTED_NODE_CHANGE, exercise, attribute);
		}
	}
}