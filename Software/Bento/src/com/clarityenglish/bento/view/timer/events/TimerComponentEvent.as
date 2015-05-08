package com.clarityenglish.bento.view.timer.events {
import flash.events.Event;

    public class TimerComponentEvent extends Event {

        public static const TIMER_SET:String = "timerSet";

        private var _sessionArray:Array;
        private var _totalTime:Number;

        public function TimerComponentEvent(type:String, bubbles:Boolean, sessionArray:Array, totalTime:Number) {
            super(type, bubbles);

            this._sessionArray = sessionArray;
            this._totalTime = totalTime;
        }

        public function get sessionArray():Array {
            return _sessionArray;
        }

        public function get totalTime():Number {
            return _totalTime;
        }

        public override function clone():Event {
            return new TimerComponentEvent(type, bubbles, sessionArray, totalTime);
        }

        public override function toString():String {
            return formatToString("TimerComponentEvent", "bubbles", "sessionArray", "totalTime");
        }
    }
}
