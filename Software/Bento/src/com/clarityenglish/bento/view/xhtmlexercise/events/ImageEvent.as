package com.clarityenglish.bento.view.xhtmlexercise.events {
import flash.events.Event;

    public class ImageEvent extends Event {

        public static const IMAGE_ENLARGE:String = "imageEnlarge";

        private var _image:Object;

        public function ImageEvent(type:String, image:Object, bubbles:Boolean = false) {
            super(type, bubbles);

            _image = image;
        }

        public function get image():Object {
            return _image;
        }

        public override function clone():Event {
            return new ImageEvent(type, image, bubbles);
        }

        public override function toString():String {
            return formatToString("ImageEvent", "image", "bubbles");
        }
    }
}
