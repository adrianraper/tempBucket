package com.clarityenglish.bento {
	import com.clarityenglish.bento.controller.*;
	import com.clarityenglish.bento.view.*;
	import com.clarityenglish.bento.view.exercise.ExerciseMediator;
	import com.clarityenglish.bento.view.exercise.components.ExerciseView;
	import com.clarityenglish.common.controller.*;
	
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.facade.Facade;
	
	/**
	* ...
	* @author Dave Keen
	*/
	public class BentoFacade extends Facade implements IFacade {
		
		private var mediatorClassByViewClass:Dictionary = new Dictionary();
		
		private var mediatorInstanceByView:Dictionary = new Dictionary();
		
		private var mediatorNameByInstance:Dictionary = new Dictionary();
		
		public function BentoFacade():void {
			super();
			
			//mediatorClassByViewClass = new Dictionary();;
			//mediatorInstanceByView = new Dictionary();
			//mediatorNameByInstance = new Dictionary();
		}
		
		override protected function initializeController():void {
			super.initializeController();
			
			mapView(ExerciseView, ExerciseMediator);
			
			registerCommand(BBNotifications.STARTUP, StartupCommand);
			
			/*registerCommand(CommonNotifications.LOGIN, LoginCommand);
			registerCommand(CommonNotifications.LOGOUT, LogoutCommand);
			registerCommand(CommonNotifications.LOGGED_IN, LoggedInCommand);
			registerCommand(CommonNotifications.LOGGED_OUT, LoggedOutCommand);*/
		}
		
		private function mapView(viewClass:Class, mediatorClass:Class):void {
			mediatorClassByViewClass[viewClass] = mediatorClass;
		}
		
		public function onViewAdded(viewComponent:Object):void {
			trace("added " + viewComponent);
			if (!viewComponent)
				return;
			
			var mediatorClass:Class = mediatorClassByViewClass[ClassUtil.getClass(viewComponent)];
			
			if (mediatorClass) {
				var uniqueMediatorName:String = ClassUtil.getClassAsString(mediatorClass) + new Date().getTime().toString();
				trace(uniqueMediatorName);
				var mediator:IMediator = new mediatorClass(uniqueMediatorName, viewComponent);
				registerMediator(mediator);
				mediatorInstanceByView[viewComponent] = mediator;
				mediatorNameByInstance[mediator] = uniqueMediatorName;
			}
		}
		
		public function onViewRemoved(viewComponent:Object):void {
			if (!viewComponent)
				return;
			
			var mediator:IMediator = mediatorInstanceByView[viewComponent];
			if (mediator) {
				removeMediator(mediatorNameByInstance[mediator]);
				
				// This should free the view component and mediator for garbage collection
				delete mediatorNameByInstance[mediator];
				delete mediatorInstanceByView[viewComponent];
			}
		}
		
	}
	
}