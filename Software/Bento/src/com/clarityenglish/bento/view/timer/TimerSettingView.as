package com.clarityenglish.bento.view.timer {
import com.clarityenglish.bento.view.base.BentoView;

import flash.events.Event;

import flash.events.MouseEvent;

import mx.controls.HSlider;

import mx.events.CloseEvent;

import org.osflash.signals.Signal;

import spark.components.Button;

import spark.components.Label;

    public class TimerSettingView extends BentoView {

        [SkinPart]
        public var timerSlider:mx.controls.HSlider;

        [SkinPart]
        public var instructionLabel:Label;

        [SkinPart]
        public var startButton:Button;

        [SkinPart]
        public var closeButton:Button;

        public var totalTime:Number;
        public var durationArray:Array = [15, 30, 15];
        public var newDurationArray:Array = [];

        public var startTimer:Signal = new Signal(Array, Number, Boolean);

        protected override function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);

            switch (instance) {
                case timerSlider:
                    timerSlider.values = [durationArray[0],  durationArray[0] + durationArray[1]];
                    timerSlider.maximum = totalTime;
                    trace("timerview totalTime: "+totalTime);
                    break;
                case instructionLabel:
                    instructionLabel.text = copyProvider.getCopyForId("instructionLabel");
                    break;
                case startButton:
                    startButton.label = copyProvider.getCopyForId("startButtonLabel");
                    startButton.addEventListener(MouseEvent.CLICK, onButtonClick);
                    break;
                case closeButton:
                    closeButton.label = copyProvider.getCopyForId("closeButton");
                    closeButton.addEventListener(MouseEvent.CLICK, onButtonClick);
                    break;
            }
        }

        protected function onButtonClick(event:Event):void {
            dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));

            newDurationArray[0] = timerSlider.values[0];
            newDurationArray[1] = timerSlider.values[1] - timerSlider.values[0];
            newDurationArray[2] = 60 - timerSlider.values[1];

            if (event.target == startButton) {
                startTimer.dispatch(newDurationArray, totalTime, true);
            } else  {
                startTimer.dispatch(newDurationArray, totalTime, false);
            }

        }

    }
}
