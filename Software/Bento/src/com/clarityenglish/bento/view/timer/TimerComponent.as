package com.clarityenglish.bento.view.timer {
import com.clarityenglish.bento.view.timer.events.TimerComponentEvent;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.collections.ArrayCollection;

import mx.events.FlexEvent;

import org.davekeen.util.StateUtil;

import org.osflash.signals.Signal;

import spark.components.Button;

import spark.components.Group;
import spark.components.supportClasses.SkinnableComponent;
import spark.primitives.Rect;

    public class TimerComponent extends SkinnableComponent{

        [SkinPart]
        public var timerSessionGroup:Group;

        [SkinPart]
        public var progressBar:Rect;

        [SkinPart]
        public var startButton:Button;

        [SkinPart]
        public var pauseButton:Button;

        [SkinPart]
        public var resumeButton:Button;

        [SkinPart]
        public var restartButton:Button;

        [SkinPart]
        public var timerSetButton:Button;

        [Bindable]
        public var sessionWidthArray:ArrayCollection = new ArrayCollection();

        public var isTimerStart:Boolean;

        private var timer:Timer;
        private var _totalTime:Number;
        private var _timerDurationArray:Array = [];
        private var _isTimerDurationChange:Boolean;
        private var _currentState:String;

        public function TimerComponent() {
            StateUtil.addStates(this, ["startState", "pauseState", "reState"], true);
        }

        public function set timerDurationArray(value:Array):void {
            if (value) {
                _timerDurationArray = value;
                _isTimerDurationChange = true;
                invalidateProperties();
            }
        }

        [Bindable]
        public function get timerDurationArray():Array {
            return _timerDurationArray;
        }

        public function set totalTime(value:Number):void {
            if (_totalTime != value) {
                _totalTime = value;
                initializeTimer(_totalTime);
            }
        }

        [Bindable]
        public function get totalTime():Number {
            return _totalTime;
        }

        protected override function commitProperties():void {
            if (_isTimerDurationChange) {
                _isTimerDurationChange = false;

                for (var i:Number = 0; i < timerDurationArray.length; i ++) {
                    sessionWidthArray.addItemAt(timerSessionGroup.width * (timerDurationArray[i] / totalTime), i);
                    trace("sessionWidthArray[" + i + "]: "+ sessionWidthArray.getItemAt(i));
                }

                if (isTimerStart) {
                    isTimerStart = false;
                    timer.reset();
                    timer.start();
                    setState("pauseState");
                }

            }

            super.commitProperties();
        }

        protected override function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);

            switch (instance) {
                case startButton:
                    startButton.addEventListener(MouseEvent.CLICK, onStartButtonClick);
                    break;
                case pauseButton:
                    pauseButton.addEventListener(MouseEvent.CLICK, onPauseButtonClick);
                    break;
                case resumeButton:
                    resumeButton.addEventListener(MouseEvent.CLICK, onResumeButtonClick);
                    break;
                case restartButton:
                    restartButton.addEventListener(MouseEvent.CLICK, onRestartButtonClick);
                    break;
                case timerSetButton:
                    timerSetButton.addEventListener(MouseEvent.CLICK, onTimerSetButtonClick);
                    break;
            }
        }

        protected override function getCurrentSkinState():String {
            return _currentState? _currentState : "startState";
        }

        protected function initializeTimer(value:Number):void {
            timer = new Timer(1000, value);
            timer.addEventListener(TimerEvent.TIMER, onTimerUpdate);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
        }

        protected function onTimerUpdate(event:TimerEvent):void {
            progressBar.width = timerSessionGroup.width * (timer.currentCount / totalTime);
            trace("current count: "+timer.currentCount);
        }

        protected function onTimerComplete(event:Event):void {
            setState("startState");
        }

        protected function onStartButtonClick(event:MouseEvent):void {
            setState("pauseState");
            timer.reset();
            timer.start();
        }

        protected function onPauseButtonClick(event:MouseEvent):void {
            setState("reState");
            timer.stop();
        }

        protected function onResumeButtonClick(event:MouseEvent):void {
            setState("pauseState");
            timer.start();
        }

        protected function onRestartButtonClick(event:MouseEvent):void {
            setState("startState");
            progressBar.width = 0;
        }

        protected function onTimerSetButtonClick(event:MouseEvent):void {
            if (_currentState == "pauseState")
                setState("reState");
            timer.stop();
            dispatchEvent(new TimerComponentEvent(TimerComponentEvent.TIMER_SET, true, timerDurationArray, totalTime));
        }

        public function setState(state:String):void {
            // Can't use currentState as that belongs to the view and is not automatically linked to the skin
            _currentState = state;
            invalidateSkinState();
        }
    }
}
