package com.clarityenglish.bento.view.timer {
import com.clarityenglish.common.model.interfaces.CopyProvider;

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.controls.HSlider;
import mx.events.FlexEvent;

import mx.events.SliderEvent;

import org.davekeen.util.StateUtil;

import spark.components.Button;

import spark.components.Group;
import spark.components.Label;
import spark.components.TextInput;
import spark.components.supportClasses.SkinnableComponent;
import spark.primitives.Rect;

    public class TimerComponent extends SkinnableComponent{

        [SkinPart]
        public var timerSlider:HSlider;

        [SkinPart]
        public var firstTipLabel:Label;

        [SkinPart]
        public var midTipLabel:Label;

        [SkinPart]
        public var lastTipLabel:Label;

        [SkinPart]
        public var progressBarGroup:Group;

        [SkinPart]
        public var firstProgressCoverRect:Rect;

        [SkinPart]
        public var midProgressCoverRect:Rect;

        [SkinPart]
        public var lastProgressCoverRect:Rect;

        [SkinPart]
        public var unitRect:Rect;

        [SkinPart]
        public var hoursTextInput:TextInput;

        [SkinPart]
        public var minsTextInput:TextInput;

        [SkinPart]
        public var secondsTextLabel:Label;

        [SkinPart]
        public var totalTimeLabel:Label;

        [SkinPart]
        public var startButton:Button;

        [SkinPart]
        public var pauseButton:Button;

        [SkinPart]
        public var resumeButton:Button;

        [SkinPart]
        public var resetButton:Button;

        [SkinPart]
        public var stopButton:Button;

        [Bindable]
        public var totalTimeLabelText:String;

        [Bindable]
        public var firstRectPercentWidth:Number;

        [Bindable]
        public var midRectPercentWidth:Number;

        [Bindable]
        public var lastRectPercentWidth:Number;

        [Bindable]
        public var leftRadius:Number;

        [Bindable]
        public var rightRadius:Number;

        public const sliderWidth:Number = 676;

        private var timer:Timer;
        private var defaultTotalTime:Number;
        private var valuesArray:Array = [];
        private var _currentState:String;
        private var _totalTime:Number;
        private var _isTotalTimeChange:Boolean;
        private var _timerTotalTime:Array = [];
        private var _isTimerTotalTimeChange:Boolean;
        private var _isFirstTimeChange:Boolean;
        private var _copyProvider:CopyProvider;

        public function TimerComponent() {
            StateUtil.addStates(this, ["startState", "pauseState", "resumeState"], true);

            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            _isFirstTimeChange = true;
        }

        public function set totalTime(value:Number):void {
            if (value) {
                _totalTime = value;
                _isTotalTimeChange = true;
                invalidateProperties();
            }
        }

        [Bindable]
        public function get totalTime():Number {
            return _totalTime;
        }

        public function set timerTotalTime(value:Array):void {
            if (value.length > 0) {
                _timerTotalTime = value;
                _isTimerTotalTimeChange = true;
                invalidateProperties();
            }
        }

        [Bindable]
        public function get timerTotalTime():Array {
            return _timerTotalTime;
        }

        public function set copyProvider(value:CopyProvider):void {
            _copyProvider = value;
        }

        [Bindable]
        public function get copyProvider():CopyProvider {
            return _copyProvider;
        }

        public function initializeValue(value:Number):void {
            timerSlider.maximum = value / 60;
            for (var i = 0; i < valuesArray.length; i++) {
                timerSlider.values[i] = timerSlider.maximum * valuesArray[i];
            }

            firstTipLabel.text = 'Planning ' + timeConvert(timerSlider.values[0]);
            midTipLabel.text = 'Writing ' + timeConvert(timerSlider.values[1] - timerSlider.values[0]);
            lastTipLabel.text = 'Proofreading ' + timeConvert(timerSlider.maximum - timerSlider.values[1]);

            midTipLabel.left = 100;
            lastTipLabel.left = sliderWidth - 100;
        }

        protected override function commitProperties():void {
            super.commitProperties();

            // Set the default total time.
            if (_isTimerTotalTimeChange) {
                _isTimerTotalTimeChange = false;

                // Get the timer total time.
                var time:Number = 0;
                for (var i = 0; i < timerTotalTime.length; i++) {
                    timerTotalTime[i] = Number(timerTotalTime[i]);
                    time += timerTotalTime[i];
                }
                totalTime = defaultTotalTime = time;

                // Get the default proportion of timer sessions.
                time = 0;
                for (var i = 0; i < timerTotalTime.length - 1; i++) {
                    time += timerTotalTime[i];
                    valuesArray[i] = time / totalTime;
                }

                hoursTextInput.text = formatTime(Math.floor(totalTime / 3600));
                minsTextInput.text = formatTime(Math.floor(totalTime / 60));
            }

            if (_isTotalTimeChange)  {
                _isTotalTimeChange = false;

                initializeValue(totalTime);
            }
        }

        protected override function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);

            switch (instance) {
                case hoursTextInput:
                case minsTextInput:
                    instance.addEventListener(FlexEvent.ENTER, onValueCommit);
                    instance.addEventListener(FocusEvent.FOCUS_OUT, onValueCommit);
                    break;
                case startButton:
                    startButton.addEventListener(MouseEvent.CLICK, onStartButtonClick);
                    break;
                case pauseButton:
                    pauseButton.addEventListener(MouseEvent.CLICK, onPauseButtonClick);
                    break;
                case resumeButton:
                    resumeButton.addEventListener(MouseEvent.CLICK, onResumeButtonClick);
                    break;
                case resetButton:
                    resetButton.addEventListener(MouseEvent.CLICK, onResetButtonClick);
                    break;
                case stopButton:
                    stopButton.addEventListener(MouseEvent.CLICK, onStopButtonClick);
                    break;
            }
        }

        protected override function getCurrentSkinState():String {
            return _currentState? _currentState : "startState";
        }

        protected function onAddedToStage(event:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

            stage.addEventListener(MouseEvent.CLICK, onStageClick);
        }

        protected function onStageClick(event:Event):void {
            // The input only will be commited when user click the outside of components
           if (event.target is Group || event.target is Button)
               onValueCommit();
        }

        // Commit the total time user input.
        protected function onValueCommit(event:Event = null) {
            var time:Number = 0;
            if (hoursTextInput.text) {
                time = Number(hoursTextInput.text) * 3600;
                hoursTextInput.text = formatTime(Number(hoursTextInput.text));
            }

            if (minsTextInput.text) {
                time += Number(minsTextInput.text) * 60;
                var minsCarry = Math.floor(Number(minsTextInput.text) / 60);
                if (minsCarry > 0) {
                    minsTextInput.text = formatTime(Number(minsTextInput.text) - 60 * minsCarry);
                    hoursTextInput.text = formatTime(Number(hoursTextInput.text) + minsCarry);
                } else {
                    minsTextInput.text = formatTime(Number(minsTextInput.text));
                }
            }

            totalTime = time;
        }

        protected function onTimerUpdate(event:TimerEvent):void {
            // Shrink the width of specific cover bar to make the progress bar appear.
            var unit:Number = sliderWidth / totalTime;
            if (timer.currentCount <= timerSlider.values[0] * 60) {
                firstProgressCoverRect.width = timer.currentCount < timerSlider.values[0] * 60 ? (firstProgressCoverRect.width - unit) : 0;
                firstProgressCoverRect.topLeftRadiusX = firstProgressCoverRect.topLeftRadiusY = firstProgressCoverRect.bottomLeftRadiusX = firstProgressCoverRect.bottomLeftRadiusY = 0;
            } else if (timer.currentCount <= timerSlider.values[1] * 60) {
                midProgressCoverRect.width = timer.currentCount < timerSlider.values[1] * 60 ? (midProgressCoverRect.width - unit) : 0;
            } else {
                lastProgressCoverRect.width = timer.currentCount < timerSlider.maximum * 60 ? (lastProgressCoverRect.width - unit) : 0;
            }

            var totalMSeconds:Number = totalTime - timer.currentCount;
            var sec:String = formatTime(totalMSeconds % 60);
            var min:String = formatTime(Math.floor((totalMSeconds % 3600 ) / 60));
            var hour:String = formatTime(Math.floor(totalMSeconds / (60 * 60)));
            totalTimeLabelText = String(hour + ":" + min + ":" + sec);
        }

        protected function onTimerComplete(event:Event):void {
            setState("pauseState");
        }

        protected function onStartButtonClick(event:MouseEvent):void {
            initializeTimer();
            initializeSlider();
            totalTimeLabelText = hoursTextInput.text + ":" +minsTextInput.text + ":" + secondsTextLabel.text;

            setState("pauseState");
            timer.reset();
            timer.start();
        }

        protected function onPauseButtonClick(event:MouseEvent):void {
            setState("resumeState");
            timer.stop();
        }

        protected function onResumeButtonClick(event:MouseEvent):void {
            setState("pauseState");
            timer.start();
        }

        protected function onResetButtonClick(event:MouseEvent):void {
            initializeValue(defaultTotalTime);
            hoursTextInput.text = formatTime(Math.floor(defaultTotalTime / 3600));
            minsTextInput.text = formatTime(Math.floor(defaultTotalTime / 60));
        }

        protected function onStopButtonClick(event:MouseEvent):void {
            resetSlider();
            setState("startState");
            timer.stop();
        }

        public function setState(state:String):void {
            // Can't use currentState as that belongs to the view and is not automatically linked to the skin
            _currentState = state;
            invalidateSkinState();
        }

        private function timeConvert(value:Number):String {
            var hours:Number = Math.floor(value / 60);
            var mins:Number = value % 60;

            return formatTime(hours) + ":" + formatTime(mins);
        }

        private function formatTime(value:Number):String {
            return String("0" + value).substr(-2);
        }

        private function initializeTimer():void {
            timer = new Timer(1000, totalTime);
            timer.addEventListener(TimerEvent.TIMER, onTimerUpdate);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
        }

        private function initializeSlider():void {
            firstRectPercentWidth = timerSlider.values[0] / timerSlider.maximum * 100;
            midRectPercentWidth = (timerSlider.values[1] - timerSlider.values[0]) / timerSlider.maximum * 100;
            lastRectPercentWidth = (timerSlider.maximum - timerSlider.values[1]) / timerSlider.maximum * 100;

            if (timerSlider.values[0] == 0) {
                leftRadius = 4;
            } else {
                leftRadius = 0;
            }

            if (timerSlider.values[1] == timerSlider.maximum) {
                rightRadius = 4;
            } else {
                rightRadius = 0;
            }
        }

        private function resetSlider():void {
            firstProgressCoverRect.width = sliderWidth * timerSlider.values[0] / timerSlider.maximum;
            midProgressCoverRect.width = sliderWidth * (timerSlider.values[1] - timerSlider.values[0]) / timerSlider.maximum;
            lastProgressCoverRect.width = sliderWidth * (timerSlider.maximum - timerSlider.values[1]) / timerSlider.maximum;
        }
    }
}
