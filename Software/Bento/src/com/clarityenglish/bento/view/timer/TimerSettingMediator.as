package com.clarityenglish.bento.view.timer {
import com.clarityenglish.bento.BBNotifications;
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;

import org.puremvc.as3.interfaces.IMediator;

    public class TimerSettingMediator extends BentoMediator implements IMediator {

        public function TimerSettingMediator(mediatorName:String, viewComponent:BentoView) {
            super(mediatorName, viewComponent);
        }

        private function get view():TimerSettingView {
            return viewComponent as TimerSettingView;
        }

        override public function onRegister():void {
            super.onRegister();

            view.startTimer.add(onTimerStart);
        }

        protected function onTimerStart(durationArray:Array, totalTime:Number, isTimerStart:Boolean):void {
            sendNotification(BBNotifications.TIMER_START, {durationArray: durationArray, totalTime: totalTime, isTimerStart: isTimerStart});
        }
    }
}
