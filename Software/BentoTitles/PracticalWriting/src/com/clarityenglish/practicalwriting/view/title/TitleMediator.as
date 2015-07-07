package com.clarityenglish.practicalwriting.view.title {
import com.clarityenglish.bento.BBNotifications;
import com.clarityenglish.bento.model.BentoProxy;
import com.clarityenglish.bento.model.ExerciseProxy;
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.common.CommonNotifications;
import com.clarityenglish.common.model.ConfigProxy;
import com.clarityenglish.common.model.CopyProxy;
import com.clarityenglish.practicalwriting.view.home.HomeView;

import org.alivepdf.transitions.Transition;

import org.puremvc.as3.interfaces.IMediator;
import org.puremvc.as3.interfaces.INotification;
import org.puremvc.as3.patterns.observer.Notification;

import spark.transitions.ViewTransitionBase;

public class TitleMediator extends BentoMediator implements IMediator {

        public function TitleMediator(mediatorName:String, viewComponent:BentoView) {
            super(mediatorName, viewComponent);
        }

        private function get view():TitleView {
            return viewComponent as TitleView;
        }

        public override function onRegister():void {
            super.onRegister();

            // This view runs off the menu xml so inject it here
            var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
            view.href = bentoProxy.menuXHTML.href;

            view.logout.add(onLogout);
            view.backToMenu.add(onBackToMenu);
            view.goToProgress.add(onGoToProgress);
            view.goToSettings.add(onGoToSettings);

            var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
            var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
            var directStart:Object = configProxy.getDirectStart();
            if (directStart) {
                // gh#853 If you have been passed invalid ids, you will not have valid objects now
                if (configProxy.getDirectStart().exerciseID) {
                    view.directExercise = bentoProxy.menuXHTML.getElementById(directStart.exerciseID);
                    if (!view.directExercise) {
                        sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("DirectStartInvalidID", {
                            id: directStart.exerciseID,
                            idType: "exercise"
                        }, true));
                    } else {
                        view.isDirectStartExercise = true;
                        view.isDirectLogout = configProxy.getDirectStart().scorm || configProxy.getDirectStart().exerciseID;
                    }
                } else if (directStart.unitID) {
                    view.directUnit = bentoProxy.menuXHTML..unit.(@id == directStart.unitID)[0];
                    if (!view.directUnit) {
                        sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("DirectStartInvalidID", {
                            id: directStart.unitID,
                            idType: "unit"
                        }, true));
                    } else {
                        view.isDirectStartUnit = true;
                        view.isDirectLogout = configProxy.getDirectStart().scorm;
                    }
                } else if (directStart.courseID) {
                    view.directCourse = bentoProxy.menuXHTML..course.(@id == directStart.courseID)[0];
                    if (!view.directCourse) {
                        sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("DirectStartInvalidID", {
                            id: directStart.courseID,
                            idType: "course"
                        }, true));
                    } else {
                        view.isDirectStartCourse = true;
                    }
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

        override public function listNotificationInterests():Array {
            return super.listNotificationInterests().concat([
                BBNotifications.SELECTED_NODE_CHANGED,
                BBNotifications.SELECTED_NODE_UP,
                BBNotifications.PROGRESS_SHOW,
                BBNotifications.SETTINGS_SHOW,
            ]);
        }

        override public function handleNotification(note:INotification):void {
            super.handleNotification(note);

            switch (note.getName()) {
                case BBNotifications.SELECTED_NODE_CHANGED:
                    view.selectedNode = note.getBody() as XML;
                    break;
                case BBNotifications.PROGRESS_SHOW:
                    view.sectionNavigator.selectedIndex = 1;
                    break;
                case BBNotifications.SETTINGS_SHOW:
                    view.sectionNavigator.selectedIndex = 2;
                    break;
            }
        }

        public override function onRemove():void {
            super.onRemove();

            view.logout.remove(onLogout);
            view.backToMenu.remove(onBackToMenu);
        }

        private function setTabState(index:uint):void {
            view.sectionNavigator.selectedIndex = index;
        }

        private function onLogout():void {
            sendNotification(CommonNotifications.LOGOUT);


            // Make sure the first page you always see is the home page after login.
            view.homeViewNavigator.popToFirstView();
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

        private function onGoToProgress():void {
            var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
            var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(bentoProxy.currentExercise)) as ExerciseProxy;

            if (exerciseProxy.attemptToLeaveExercise(new Notification(BBNotifications.PROGRESS_SHOW))) {
                sendNotification(BBNotifications.CLOSE_ALL_POPUPS, view); // #265
                sendNotification(BBNotifications.PROGRESS_SHOW);
            }
        }

        private function onGoToSettings():void {
            var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
            var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(bentoProxy.currentExercise)) as ExerciseProxy;

            if (exerciseProxy.attemptToLeaveExercise(new Notification(BBNotifications.SETTINGS_SHOW))) {
                sendNotification(BBNotifications.CLOSE_ALL_POPUPS, view); // #265
                sendNotification(BBNotifications.SETTINGS_SHOW);
            }
        }
    }
}
