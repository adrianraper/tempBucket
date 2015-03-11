package com.clarityenglish.tensebuster.view.title {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.model.SCORMProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.tensebuster.TenseBusterNotifications;
	import com.clarityenglish.tensebuster.controller.TenseBusterStartupCommand;

import mx.utils.ObjectUtil;

import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.observer.Notification;
	
	/**
	 * A Mediator
	 */
	public class TitleMediator extends BentoMediator implements IMediator {
		
		public function TitleMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():TitleView {
			return viewComponent as TitleView;
		}
		
		public override function onRegister():void {
			super.onRegister();
			
			view.backToMenu.add(onBackToMenu);
			
			// This view runs off the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			
			view.logout.add(onLogout);
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
			var directStart:Object = configProxy.getDirectStart();
			if (ObjectUtil.getClassInfo(directStart).properties.length > 0) {
				// gh#853 If you have been passed invalid ids, you will not have valid objects now
				if (configProxy.getDirectStart().exerciseID) {
					view.directExercise = bentoProxy.menuXHTML.getElementById(directStart.exerciseID);
					if (!view.directExercise) {
						sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("DirectStartInvalidID", { id: directStart.exerciseID, idType: "exercise" }, true ));
					} else {
						view.isDirectStartExercise = true;
						view.isDirectLogout = configProxy.getDirectStart().scorm || configProxy.getDirectStart().exerciseID;
					}
				} else if (directStart.unitID) {
					view.directUnit = bentoProxy.menuXHTML..unit.(@id == directStart.unitID)[0];
					if (!view.directUnit) {
						sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("DirectStartInvalidID", { id: directStart.unitID, idType: "unit" }, true ));
					} else {
						view.isDirectStartUnit = true;
						view.isDirectLogout = configProxy.getDirectStart().scorm;
					}
				} else if (directStart.courseID) {
					view.directCourse = bentoProxy.menuXHTML..course.(@id == directStart.courseID)[0];
					if (!view.directCourse) {
						sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("DirectStartInvalidID", { id: directStart.courseID, idType: "course" }, true ));
					} else {
						view.isDirectStartCourse = true;
					}
				}
                // gh#1080 direct start to progress screen
                // gh#1156 otherwise reset to menu
                if (directStart.state && directStart.state == 'progress') {
                    view.callLater(setTabState, [1]);
                } else {
                    view.callLater(setTabState, [0]);
                }
            }
		}

        // gh#1080
        private function setTabState(index:uint):void {
            view.sectionNavigator.selectedIndex = index;
        }

		public override function onRemove():void {
			super.onRemove();
			
			view.backToMenu.remove(onBackToMenu);
			view.logout.remove(onLogout);
			view.backToMenu.remove(onBackToMenu);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.SELECTED_NODE_CHANGED,
				BBNotifications.SELECTED_NODE_UP,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.SELECTED_NODE_CHANGED:
					view.selectedNode = note.getBody() as XML;
					break;
			}
		}
		
		/**
		 * Click to go back to menu from an exercise. 
		 * Check if the exercise is dirty or with undisplayed feedback
		 */
		private function onBackToMenu():void {
			// #210 - can you simply stop the exercise now, or do you need any warning first?
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(bentoProxy.currentExercise)) as ExerciseProxy;
			
			if (exerciseProxy.attemptToLeaveExercise(new Notification(BBNotifications.SELECTED_NODE_UP))) {
				sendNotification(BBNotifications.CLOSE_ALL_POPUPS, view); // #265
				sendNotification(BBNotifications.SELECTED_NODE_UP);
			}
		}
		
		private function onLogout():void {
			sendNotification(CommonNotifications.LOGOUT);
		}
	}
}
