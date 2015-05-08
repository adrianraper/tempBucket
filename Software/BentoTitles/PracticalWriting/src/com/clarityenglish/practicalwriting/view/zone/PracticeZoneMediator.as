package com.clarityenglish.practicalwriting.view.zone {
import com.clarityenglish.bento.BBNotifications;
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;

import org.puremvc.as3.interfaces.IMediator;

    public class PracticeZoneMediator extends BentoMediator implements IMediator {

        public function PracticeZoneMediator(mediatorName:String, viewComponent:BentoView) {
            super(mediatorName, viewComponent);
        }

        private function get view():PracticeZoneView {
            return viewComponent as PracticeZoneView;
        }

        override public function onRegister():void {
            super.onRegister();

            view.exerciseSelect.add(onExerciseSelect);
        }

        protected function onExerciseSelect(exercise:XML):void {
            sendNotification(BBNotifications.SELECTED_NODE_CHANGE, exercise);
        }
    }
}
