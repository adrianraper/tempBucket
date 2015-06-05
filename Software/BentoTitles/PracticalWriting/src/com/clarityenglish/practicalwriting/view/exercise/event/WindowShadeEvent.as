package com.clarityenglish.practicalwriting.view.exercise.event {
import flash.events.Event;

    public class WindowShadeEvent extends Event {

        public static const WINDOWSHADE_OPEN:String = "windowshadeOpen";

        public static const WINDOWSHADE_CLOSE:String = "windowshadeClose";

        public function WindowShadeEvent(type:String, bubbles:Boolean) {
            super(type, bubbles, cancelable);
        }
    }
}
