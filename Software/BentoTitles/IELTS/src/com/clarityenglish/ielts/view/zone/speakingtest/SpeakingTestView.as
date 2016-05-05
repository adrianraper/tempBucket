package com.clarityenglish.ielts.view.zone.speakingtest {
import com.clarityenglish.bento.events.ExerciseEvent;
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.bento.view.recorder.RecorderView;
import com.clarityenglish.bento.view.timer.TimerComponent;
import com.clarityenglish.common.model.interfaces.CopyProvider;
import com.clarityenglish.components.PageNumberDisplay;
import com.clarityenglish.ielts.IELTSApplication;
import com.clarityenglish.textLayout.components.AudioPlayer;
import com.clarityenglish.textLayout.vo.XHTML;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.XMLListCollection;
import mx.events.FlexEvent;
import mx.events.StateChangeEvent;

import org.davekeen.util.StateUtil;
import org.osflash.signals.Signal;

import skins.ielts.assets.candidates.videoframe;

import spark.components.Button;
import spark.components.Group;
import spark.components.Label;
import spark.components.List;

public class SpeakingTestView extends BentoView{

    [SkinPart]
    public var actionTextGroup:Group;

    [SkinPart]
    public var recorderGroup:Group;

    [SkinPart]
    public var list:List;

    [SkinPart]
    public var timer:TimerComponent;

    [SkinPart]
    public var recorderView:RecorderView;

    [SkinPart]
    public var planningLabel:Label;

    [SkinPart]
    public var recordingLabel:Label;

    [SkinPart]
    public var completeLabel:Label;
	
	[SkinPart]
	public var pageNumberDisplay:PageNumberDisplay;

    [Bindable]
    public var testXMLListCollection:XMLListCollection;

    [Bindable]
    public var testXML:XML;

    [Bindable]
    public var selectedPageNumber:Number;

    [Bindable]
    public var isPlanningComplete:Boolean;

    [Bindable]
    public var isPlatformTablet:Boolean;

    [Bindable]
    public var isRecordEnabled:Boolean;

    [Bindable]
    public var isReflectionShow:Boolean;

    [Bindable]
    public var horizontalScrollPolicy:String;

    [Bindable]
    public var isExitSpeaking:Boolean;
	
	[Bindable]
	public var isDirectLinkStart:Boolean;
	
	[Bindable]
	public var exerciseID:Number;
	
	[Bindable]
	public var pageToScroll:Number;

    public var exerciseSelect:Signal = new Signal(XML, String);

    private var _currentState:String;

    public function SpeakingTestView() {
        StateUtil.addStates(this, ["normalState", "testState"], true);

        addEventListener("backButtonClickEvent", onBackButtonClick);
        addEventListener("startButtonClickEvent", onStartButtonClick);
    }

    public function getCopyProvider():CopyProvider {
        return copyProvider;
    }

    public function get assetFolder():String {
        return config.remoteDomain + config.assetFolder + copyProvider.getDefaultLanguageCode().toLowerCase() + '/';
    }

    public function get isTestDrive():Boolean {
        return (productVersion == IELTSApplication.TEST_DRIVE);
    }

    public function setState(state:String):void {
        // Can't use currentState as that belongs to the view and is not automatically linked to the skin
        _currentState = state;
        invalidateSkinState();
    }
	
	override protected function commitProperties():void {
		super.commitProperties();
		
		if (testXMLListCollection && isDirectLinkStart) {
			if (exerciseID) {
				pageToScroll = testXMLListCollection.source.(attribute("id") == exerciseID).childIndex();
			}
		}
	}

    override protected function partAdded(partName:String, instance:Object):void {
        super.partAdded(partName, instance);

        switch (instance) {
            case list:
                list.addEventListener(ExerciseEvent.EXERCISE_SELECTED, onStartButtonClick);
                break;
            case timer:
                timer.addEventListener("TimerFirstSectionCompleteEvent", onPlanningComplete);
                timer.addEventListener("TimerCompleteEvent", onTimerComplete);
                timer.addEventListener("LastAudioCompleteEvent", onLastAudioComplete);
                break;
            case planningLabel:
                planningLabel.text = copyProvider.getCopyForId("planningLabel");
                break;
            case recordingLabel:
                recordingLabel.text = copyProvider.getCopyForId("recordingLabel");
                break;
            case completeLabel:
                completeLabel.text = copyProvider.getCopyForId("completeLabel");
                break;
        }

    }

    protected override function getCurrentSkinState():String {
        if (!_currentState) {
            currentState = "normalState";
        } else {
            currentState = _currentState
        }
        return currentState;
    }

    protected function onStartButtonClick(event:ExerciseEvent):void {
        setState('testState');

        if (isPlatformTablet)
            list.setStyle("horizontalScrollPolicy", "off");

        callLater(function () {
            testXML = list.dataProvider.getItemAt(selectedPageNumber) as XML;
            timer.startButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
            timer.visible = true;

            actionTextGroup.visible = true;
            recorderGroup.visible = false;

            planningLabel.visible = true;
            recordingLabel.visible = false;
            completeLabel.visible = false;
        });

        exerciseSelect.dispatch(event.node, event.attribute);
    }

    protected function onPlanningComplete(event:Event):void {
        isPlanningComplete = true;
        if (isRecordEnabled){
            recorderGroup.visible = true;
            // gh#1459
            recorderView.recordWaveformView.isRecordHide = false;
            recorderView.recordWaveformView.isSaveEnabled = false;
            recorderView.recordWaveformView.recordButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
        } else {
            recordingLabel.visible = true;
        }
        planningLabel.visible = false;
    }

    protected function onTimerComplete(event:Event):void {
        if (isRecordEnabled) {
            // Manually change the recorder skin state
            // gh#1459
            recorderGroup.visible = false;
            recorderView.recordWaveformView.isRecordHide = true;
            // Stop the recorder
            callLater(function () {
                recorderView.recordWaveformView.stopButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
            });
        } else {
            recordingLabel.visible = false;
        }
        completeLabel.visible = true;
    }

    protected function onLastAudioComplete(event:Event):void {
        dispatchEvent(new Event("flipToReflectionEvent"));
        if (isRecordEnabled) {
            recorderGroup.visible = true;
        }
        actionTextGroup.visible = false;
        completeLabel.visible = false;
        timer.visible = false;

        isReflectionShow = true;
    }

    protected function onBackButtonClick(event:Event):void {
        setState('normalState');

        if (isPlatformTablet)
            list.setStyle("horizontalScrollPolicy", "on");

        restTestState();
    }

    protected override function onRemovedFromStage(event:Event):void {
        super.onRemovedFromStage(event);

        restTestState();
    }

    private function restTestState():void {
        AudioPlayer.stopAllAudio();
        isReflectionShow = false;

        if (timer)
            timer.stopTimer();

        if (isPlanningComplete) {
            isPlanningComplete = false;

            if (isRecordEnabled) {
                recorderView.recordWaveformView.stopButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
                recorderView.recordWaveformView.newButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
            }
        }
    }

}
}
