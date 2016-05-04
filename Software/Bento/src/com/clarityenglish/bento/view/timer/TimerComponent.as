package com.clarityenglish.bento.view.timer {
import com.clarityenglish.bento.BBNotifications;
import com.clarityenglish.bento.BentoFacade;
import com.clarityenglish.common.model.interfaces.CopyProvider;
import com.clarityenglish.common.vo.content.Bookmark;
import com.clarityenglish.textLayout.components.AudioPlayer;
import com.clarityenglish.textLayout.events.AudioCompleteEvent;

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.media.Sound;
import flash.net.URLRequest;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.controls.HSlider;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;

import mx.events.SliderEvent;
import mx.utils.StringUtil;

import org.davekeen.util.StateUtil;
import org.osmf.events.AudioEvent;

import spark.components.Button;

import spark.components.Group;
import spark.components.Label;
import spark.components.TextInput;
import spark.components.supportClasses.SkinnableComponent;
import spark.primitives.Rect;

    [SkinState("startState")]
    [SkinState("pauseState")]
    [SkinState("resumeState")]
    [SkinState("completeState")]
    public class TimerComponent extends SkinnableComponent{

        [SkinPart]
        public var timerSlider:HSlider;

        [SkinPart]
        public var planningBar:Rect;

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
        public var startButton:TimerButton;

        [SkinPart]
        public var pauseButton:TimerButton;

        [SkinPart]
        public var resumeButton:TimerButton;

        [SkinPart]
        public var resetButton:TimerButton;

        [SkinPart]
        public var stopButton:TimerButton;

        [SkinPart]
        public var resetCompleteButton:TimerButton;

        [SkinPart]
        public var initialTimeLabelText:String;

        /*[SkinPart]
        public var audioPlayer:AudioPlayer;*/

        [Bindable]
        public var totalTimeLabelText:String;

        [Bindable]
        public var firstRectPercentWidth:Number;

        [Bindable]
        public var midRectPercentWidth:Number;

        [Bindable]
        public var lastRectPercentWidth:Number;

        [Bindable]
        public var secondLeftRadius:Number;

        [Bindable]
        public var secondRightRadius:Number;

        [Bindable]
        public var firstRightRadius:Number;

        [Bindable]
        public var contentPath:String;

        [Bindable]
        public var isTimeFixed:Boolean;

        [Bindable]
        public var isTimerAutoControl:Boolean;

        [Bindable]
        public var isNoPause:Boolean;

        [Bindable]
        public var hoursText:String;

        [Bindable]
        public var minsText:String;

        [Bindable]
        public var secondsText:String = "00";

        [Bindable]
        public var firstTipString:String;

        [Bindable]
        public var midTipString:String;

        [Bindable]
        public var lastTipString:String;

        [Bindable]
        public var textSize:Number = 20;

        [Bindable]
        public var trackColor:uint = 0x15516D;

        [Bindable]
        public var trackHighLightColor:uint = 0x0681A8;

        [Bindable]
        public var progressLeftColor:uint = 0xFEEA8E;

        [Bindable]
        public var progressMidColor:uint = 0xF4A738;

        [Bindable]
        public var progressRightColor:uint = 0xED1F24;

        [Bindable]
        public var timeTextColor:uint = 0xED1F24;

        [Bindable]
        public var buttonColor:uint = 0xFFFFFF;

        [Bindable]
        public var buttonDownOverColor:uint = 0xFFFFFF;

        [Bindable]
        public var audios:Array = [];

        [Bindable]
        public var isPlatformTablet:Boolean;

        private var timer:Timer;
        private var defaultTotalTime:Number;
        private var ratios:Array = [];
        private var _currentState:String;
        private var _totalTime:Number;
        private var _isTotalTimeChange:Boolean;
        private var _timerTotalTime:Array = [];
        private var _isTimerTotalTimeChange:Boolean;
        private var _timerSectionLabels:Array = [];
        private var _isTimerSectionLabelsChange:Boolean;
        private var _isFirstTimeChange:Boolean;
        private var _copyProvider:CopyProvider;
        private var _sliderWidth:Number;
        private var _timerWidth:Number;
        private var _timerHeight:Number;
        private var audioPlayer:AudioPlayer;
        private const timterSectionInitialLabels:Array = ["Planning", "Writing", "Proofreading"];

        //protected var facade:BentoFacade;

        public function TimerComponent() {
            StateUtil.addStates(this, ["startState", "pauseState", "resumeState", "completeState"], true);

            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            _isFirstTimeChange = true;

            // For smaller android device.
            /*trace("sliderWidth: "+sliderWidth);
            if (FlexGlobals.topLevelApplication.width > 999) {
                sliderWidth = 676;
            } else {
                sliderWidth = FlexGlobals.topLevelApplication.width * 0.696 - 20;
            }*/

        }

        public function set totalTime(value:Number):void {
            if (value >= 0) {
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

        public function set timerSectionLabels(value:Array):void {
            if(value.length > 0) {
                _timerSectionLabels = value;
            } else {
                // gh#1372
                _timerSectionLabels = timterSectionInitialLabels;
            }
            _isTimerSectionLabelsChange = true;
        }

        [Bindable]
        public function get timerSectionLabels():Array {
            return _timerSectionLabels;
        }

        public function set copyProvider(value:CopyProvider):void {
            _copyProvider = value;
        }

        [Bindable]
        public function get copyProvider():CopyProvider {
            return _copyProvider;
        }

        public function set timerWidth(value:Number):void {
            _timerWidth = value;

            dispatchEvent(new Event("timerWidthChange"));
        }

        [Bindable]
        public function get timerWidth():Number {
            if (!_timerWidth) {
                if (FlexGlobals.topLevelApplication.width > 999) {
                    _timerWidth = 696;

                } else {
                    _timerWidth = FlexGlobals.topLevelApplication.width * 0.696;
                }
            }
            return _timerWidth;
        }

        [Bindable(event='timerWidthChange')]
        public function get sliderWidth():Number {
            return timerWidth - 20;
        }

        public function set timerHeight(value:Number):void {
            _timerHeight = value;

            dispatchEvent(new Event("timerHeightChange"));
        }

        [Bindable]
        public function get timerHeight():Number {
            if (!_timerHeight) {
                _timerHeight = 38;
            }

            return _timerHeight;
        }

        [Bindable(event="timerHeightChange")]
        public function get sliderHeight():Number {
            return timerHeight * 0.5;
        }

        public function stopTimer():void {
            if (timer) {
                onStopButtonClick();
            }
            AudioPlayer.stopAllAudio();
        }

        public function initializeValue(value:Number):void {
            timerSlider.maximum = value;
            for (var i:uint = 0; i < ratios.length; i++) {
                timerSlider.values[i] = timerSlider.maximum * ratios[i];
            }

            firstTipLabel.text = firstTipString ? firstTipString : timerSectionLabels[0] + ' ' + timeConvert(timerSlider.values[0]);
            midTipLabel.text = midTipString ? midTipString : timerSectionLabels[1] + ' ' + timeConvert(timerSlider.values[1] - timerSlider.values[0]);
            lastTipLabel.text = lastTipString ? lastTipString : timerSectionLabels[2] + ' ' + timeConvert(timerSlider.values[2] - timerSlider.values[1]);

            midTipLabel.left = sliderWidth * ratios[0];
            // If the last tip is too long it will exceed the timer slider, however I fail to get the specific length of the last tool tip (lastTipLabel.width = null).
            // So I use the following formula to get the estimated length of last tool tip.
            if (lastTipLabel.text.length * lastTipLabel.getStyle('fontSize') * 0.5 > sliderWidth - sliderWidth * ratios[1]) {
                lastTipLabel.right = 0
            } else {
                lastTipLabel.left = sliderWidth * ratios[1];
            }
        }

        protected override function commitProperties():void {
            super.commitProperties();

            // Set the default total time.
            if (_isTimerTotalTimeChange) {
                _isTimerTotalTimeChange = false;

                // Get the timer total time.
                var time:Number = 0;
                for (var i:uint = 0; i < timerTotalTime.length; i++) {
                    timerTotalTime[i] = Number(timerTotalTime[i]);
                    time += timerTotalTime[i];
                }
                if (time >= 0)
                    totalTime = defaultTotalTime = time;

                // Get the default proportion of timer sessions.
                time = 0;
                for (i = 0; i < timerTotalTime.length; i++) {
                    time += timerTotalTime[i];
                    ratios[i] = time / totalTime;
                }

                var hours:Number = Math.floor(totalTime / 3600);
                var mins:Number = Math.floor((totalTime % 3600 ) / 60);
                var seconds:Number = totalTime % 60;
                hoursText = formatTime(hours);
                minsText = formatTime(mins);
                secondsText = formatTime(seconds);

                totalTimeLabelText = initialTimeLabelText = hoursText + ':' + minsText + ':' + secondsText;
            }

            if (_isTimerSectionLabelsChange) {
                _isTimerSectionLabelsChange = false;

                // When the label array is less then maximum number of sections, we now hard code it as 3, fill the array with the empty string to be the same length of the maximum number of sections.
                if (timerSectionLabels.length < 3) {
                    for (i = 0; i < (3 - timerSectionLabels.length); i++) {
                        timerSectionLabels.push("");
                    }
                }
            }

            if (_isTotalTimeChange && timerSlider)  {
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
                    instance.addEventListener(MouseEvent.CLICK, onStopButtonClick);
                    break;
                case resetCompleteButton:
                    if (isTimerAutoControl) {
                        instance.addEventListener(MouseEvent.CLICK, onRestartTimer);
                    } else {
                        instance.addEventListener(MouseEvent.CLICK, onStopButtonClick);
                    }
                    break;
                case timerSlider:
                    timerSlider.setStyle("disabledAlpha", 1);
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
           if ((event.target is Group || event.target is Button) && !isTimeFixed)
               onValueCommit();
        }

        // Commit the total time user input.
        protected function onValueCommit(event:Event = null):void {
            var time:Number = 0;
            if (hoursTextInput.text) {
                time = Number(hoursTextInput.text) * 3600;
                hoursTextInput.text = formatTime(Number(hoursTextInput.text));
            }

            if (minsTextInput.text) {
                time += Number(minsTextInput.text) * 60;
                // The maximum seconds the timer can accept is 362340 which is 99:00:00.
                var minsNumber:Number = Number(minsTextInput.text);
                var hoursNumber:Number = Number(hoursTextInput.text);
                if (time > 356400) {
                    minsNumber = 356400 / 60;
                    hoursNumber = 0;
                }
                var minsCarry:Number = Math.floor(minsNumber / 60);
                if (minsCarry > 0) {
                    minsTextInput.text = formatTime(minsNumber - 60 * minsCarry);
                    hoursTextInput.text = formatTime(hoursNumber + minsCarry);
                } else {
                    minsTextInput.text = formatTime(minsNumber);
                }
            }

            initialTimeLabelText = hoursTextInput.text+":"+minsTextInput.text+":00";
            totalTimeLabelText = hoursTextInput.text+":"+minsTextInput.text+":00";
            totalTime = time;
        }

        protected function onTimerUpdate(event:TimerEvent):void {
            // Shrink the width of specific cover bar to make the progress bar appear.
            var unit:Number = sliderWidth / totalTime;
            if (timerTotalTime.length == 1) {
                firstProgressCoverRect.width = timer.currentCount < timerTotalTime[0] ? (firstProgressCoverRect.width - unit) : 0;
            } else {
                if (timer.currentCount <= timerSlider.values[0]) {
                    firstProgressCoverRect.width = timer.currentCount < timerSlider.values[0] ? (firstProgressCoverRect.width - unit) : 0;
                    firstProgressCoverRect.topLeftRadiusX = firstProgressCoverRect.topLeftRadiusY = firstProgressCoverRect.bottomLeftRadiusX = firstProgressCoverRect.bottomLeftRadiusY = 0;
                } else if (timer.currentCount > timerSlider.values[0] && timer.currentCount <= timerSlider.values[1]) {
                    midProgressCoverRect.width = timer.currentCount < timerSlider.values[1] ? (midProgressCoverRect.width - unit) : 0;
                } else {
                    lastProgressCoverRect.width = timer.currentCount < timerSlider.maximum ? (lastProgressCoverRect.width - unit) : 0;
                }
            }

            var totalMSeconds:Number = totalTime - timer.currentCount;
            var sec:String = formatTime(totalMSeconds % 60);
            var min:String = formatTime(Math.floor((totalMSeconds % 3600 ) / 60));
            var hour:String = formatTime(Math.floor(totalMSeconds / 3600));
            totalTimeLabelText = String(hour + ":" + min + ":" + sec);

            // detect the time when any of the section of timer is complete
            if (timerTotalTime.length > 1) {
                if (timer.currentCount == timerSlider.values[0]) {
                    if (audios.length > 1 && audios[1] != "") {
                        onPauseButtonClick();
                        audioPlayer = new AudioPlayer();
                        audioPlayer.addEventListener(AudioCompleteEvent.Audio_Complete, onFirstSectionAudioComplete);
                        audioPlayer.autoplay = audioPlayer.playComponentEnable = true;
                        audioPlayer.src = contentPath + "/" + StringUtil.trim(audios[1]);
                        this.stage.addChild(audioPlayer);
                    }
                }
            } else if (timerTotalTime.length > 2) {
                if (timer.currentCount == timerSlider.values[1]) {
                    dispatchEvent(new Event("TimerSecondSectionCompleteEvent"));
                }
            }


            // gh#1342 The timer running acts like someone clicking to keep the session/licence updated
            // Maybe need to do this by dispatching an event?
            //facade.sendNotification(BBNotifications.USER_ACTIVE);
        }

        protected function onTimerComplete(event:Event):void {
            setState("completeState");

            audioPlayer = new AudioPlayer();
            audioPlayer.addEventListener(AudioCompleteEvent.Audio_Complete, onLastAudioComplete);
            audioPlayer.autoplay = audioPlayer.playComponentEnable = true;
            if (audios[timerTotalTime.length - 1]) {
                audioPlayer.src = contentPath + "/" + StringUtil.trim(audios[audios.length - 1]);
            } else {
                audioPlayer.src = contentPath + "/media/beep.mp3";
            }
            this.stage.addChild(audioPlayer);

            if(isTimerAutoControl)
                dispatchEvent(new Event('TimerCompleteEvent'));
        }

        protected function onStartButtonClick(event:MouseEvent = null):void {
            if (isTimerAutoControl) {
                if (audios.length!= 0 && audios[0] != "") {
                    audioPlayer = new AudioPlayer();
                    audioPlayer.addEventListener(AudioCompleteEvent.Audio_Complete, onFirstAudioComplete);
                    audioPlayer.autoplay = audioPlayer.playComponentEnable = true;
                    audioPlayer.src = contentPath + "/" + StringUtil.trim(audios[0]);
                    this.stage.addChild(audioPlayer);
                } else {
                    var initialTimer:Timer = new Timer(1000, 1);
                    initialTimer.start();
                    initialTimer.addEventListener(TimerEvent.TIMER_COMPLETE, startTimer);
                }
            } else {
                startTimer();
            }
        }

        protected function onFirstAudioComplete(event:AudioCompleteEvent):void {
            audioPlayer.removeEventListener(AudioCompleteEvent.Audio_Complete, onFirstAudioComplete);

            if (!event.isStopAllAudio) {
                if (_currentState != "completeState") {
                    startTimer();
                }
            }
        }

        protected function onFirstSectionAudioComplete(event:AudioCompleteEvent):void {
            audioPlayer.removeEventListener(AudioCompleteEvent.Audio_Complete, onFirstSectionAudioComplete);
            if (!event.isStopAllAudio) {
                onResumeButtonClick();
                dispatchEvent(new Event("TimerFirstSectionCompleteEvent"));
            }
        }

        protected function onLastAudioComplete(event:AudioCompleteEvent):void {
            audioPlayer.removeEventListener(AudioCompleteEvent.Audio_Complete, onLastAudioComplete);

            if (!event.isStopAllAudio) {
                dispatchEvent(new Event("LastAudioCompleteEvent"));
            }
        }


        protected function startTimer(event:Event = null):void {
            initializeTimer();
            initializeSlider();

            setState("pauseState");
            timer.reset();
            timer.start();

            callLater(function() {
                if (timerTotalTime.length == 1) {
                    planningBar.radiusX = planningBar.radiusY = 4;
                } else {
                    planningBar.topLeftRadiusX = planningBar.topLeftRadiusY = planningBar.bottomLeftRadiusX = planningBar.bottomLeftRadiusY = 4;
                }
            });
        }

        protected function onPauseButtonClick(event:MouseEvent = null):void {
            setState("resumeState");
            timer.stop();
        }

        protected function onResumeButtonClick(event:MouseEvent = null):void {
            setState("pauseState");
            timer.start();
        }

        protected function onResetButtonClick(event:MouseEvent):void {
            initializeValue(defaultTotalTime);
            hoursTextInput.text = formatTime(Math.floor(defaultTotalTime / 3600));
            minsTextInput.text = formatTime(Math.floor((defaultTotalTime % 3600 ) / 60));
            secondsTextLabel.text =  formatTime(defaultTotalTime % 60);
        }

        protected function onStopButtonClick(event:MouseEvent = null):void {
            resetSlider();
            timer.stop();
            totalTimeLabelText = initialTimeLabelText;
            setState("startState");
        }

        protected function onRestartTimer(event:MouseEvent = null):void {
            onStopButtonClick();

            if (isTimerAutoControl)
                onStartButtonClick();

            dispatchEvent(new Event("TimerRestartEvent"));
        }

        public function setState(state:String):void {
            // Can't use currentState as that belongs to the view and is not automatically linked to the skin
            _currentState = state;
            invalidateSkinState();
        }

        private function timeConvert(value:Number):String {
            var hours:Number = Math.floor(value / 3600);
            var mins:Number = Math.floor((defaultTotalTime % 3600 ) / 60);
            var seconds:Number = value % 60;

            return formatTime(hours) + ":" + formatTime(mins) + ":" + formatTime(seconds);
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
            if (timerTotalTime.length == 1) {
                firstRectPercentWidth = 100;
                midRectPercentWidth = lastRectPercentWidth = 0;
                firstRightRadius = 4;
            } else {
                firstRectPercentWidth = timerSlider.values[0] / timerSlider.maximum * 100;
                midRectPercentWidth = (timerSlider.values[1] - timerSlider.values[0]) / timerSlider.maximum * 100;
                if (timerTotalTime.length > 2)
                    lastRectPercentWidth = (timerSlider.maximum - timerSlider.values[1]) / timerSlider.maximum * 100;
                firstRightRadius = 0;
            }

            if (timerSlider.values[0] == 0) {
                secondLeftRadius = 4;
            } else {
                secondLeftRadius = 0;
            }

            if (timerSlider.values[1] == timerSlider.maximum) {
                secondRightRadius = 4;
            } else {
                secondRightRadius = 0;
            }
        }

        private function resetSlider():void {
            if (timerTotalTime.length == 1) {
                firstProgressCoverRect.width = (sliderWidth + 4);
                midProgressCoverRect.width = lastProgressCoverRect.width = 0;
            } else {
                firstProgressCoverRect.width = (sliderWidth + 4) * timerSlider.values[0] / timerSlider.maximum;
                midProgressCoverRect.width = (sliderWidth + 4) * (timerSlider.values[1] - timerSlider.values[0]) / timerSlider.maximum;
                if (timerTotalTime.length > 2)
                    lastProgressCoverRect.width = (sliderWidth + 4) * (timerSlider.maximum - timerSlider.values[1]) / timerSlider.maximum;
            }
        }
    }
}
