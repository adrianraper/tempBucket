package com.clarityenglish.textLayout.events {
import flash.events.Event;

public class AudioCompleteEvent extends Event{

    public static const Audio_Complete:String = "audioplayer/audioComplete";

    private var _isStopAllAudio:Boolean;

    public function AudioCompleteEvent(type:String, isStopAllAudio:Boolean, bubbles:Boolean = false) {
        super(type, bubbles, cancelable);

        this._isStopAllAudio = isStopAllAudio;
    }

    public function get isStopAllAudio():Boolean {
        return _isStopAllAudio;
    }

    public override function clone():Event {
        return new AudioCompleteEvent(type, _isStopAllAudio, bubbles);
    }

    public override function toString():String {
        return formatToString("AudioCompleteEvent", "AudioCompleteEvent", "bubbles");
    }
}
}
