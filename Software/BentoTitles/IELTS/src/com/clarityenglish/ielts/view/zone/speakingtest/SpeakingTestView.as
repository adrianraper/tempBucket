package com.clarityenglish.ielts.view.zone.speakingtest {
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.bento.view.recorder.RecorderView;
import com.clarityenglish.bento.view.timer.TimerComponent;
import com.clarityenglish.common.model.interfaces.CopyProvider;
import com.clarityenglish.textLayout.components.AudioPlayer;
import com.clarityenglish.textLayout.vo.XHTML;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.XMLListCollection;

import mx.events.FlexEvent;
import mx.events.StateChangeEvent;

import org.davekeen.util.StateUtil;

import skins.ielts.assets.candidates.videoframe;

import spark.components.Button;
import spark.components.Group;
import spark.components.Label;
import spark.components.List;

public class SpeakingTestView extends BentoView{

    [SkinPart]
    public var planningGroup:Group;

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

    [Bindable]
    public var testXMLListCollection:XMLListCollection;

    [Bindable]
    public var testXML:XML;

    [Bindable]
    public var selectedPageNumber:Number;

    [Bindable]
    public var isPlanningComplete:Boolean;

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

    public function setState(state:String):void {
        // Can't use currentState as that belongs to the view and is not automatically linked to the skin
        _currentState = state;
        invalidateSkinState();
    }

    override protected function partAdded(partName:String, instance:Object):void {
        super.partAdded(partName, instance);

        switch (instance) {
            case timer:
                timer.addEventListener("TimerFirstSectionCompleteEvent", onPlanningComplete);
                timer.addEventListener("TimerCompleteEvent", onTimerComplete);
                timer.addEventListener("TimerRestartEvent", onTimerRestart);
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

    protected function onStartButtonClick(event:Event):void {
        setState('testState');
        callLater(function () {
            testXML = list.dataProvider.getItemAt(selectedPageNumber) as XML;
            timer.startButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
            /*planningGroup.visible = true;
             recorderGroup.visible = false;*/
            planningLabel.visible = true;
            recordingLabel.visible = false;
            completeLabel.visible = false;
        })
    }

    protected function onPlanningComplete(event:Event):void {
        isPlanningComplete = true;
        /*planningGroup.visible = false;
        recorderGroup.visible = true;*/
        planningLabel.visible = false;
        recordingLabel.visible = true;
        completeLabel.visible = false;

        // gh#1459
        /*recorderView.recordWaveformView.isRecorHide = false;
        recorderView.recordWaveformView.isSaveEnabled = false;
        recorderView.recordWaveformView.recordButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));*/
    }

    protected function onTimerComplete(event:Event):void {
        timer.totalTimeLabel.visible = false;

        planningLabel.visible = false;
        recordingLabel.visible = false;
        completeLabel.visible = true;

        // Manually change the recorder skin state
        // gh#1459
        //recorderView.recordWaveformView.isRecorHide = true;
        // Stop the recorder
        /*callLater(function () {
            recorderView.recordWaveformView.stopButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
        });*/
    }

    protected function onTimerRestart(event:Event):void {
        isPlanningComplete = false;
        /*planningGroup.visible = true;
        recorderGroup.visible = false;*/
        planningLabel.visible = true;
        recordingLabel.visible = false;
        completeLabel.visible = false;
        timer.totalTimeLabel.visible = true;

        // Stop the recorder and reset recorded audio
        /*recorderView.recordWaveformView.stopButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
        recorderView.recordWaveformView.newButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));*/
    }

    protected function onBackButtonClick(event:Event):void {
        setState('normalState');
        restTestState();
    }

    protected override function onRemovedFromStage(event:Event):void {
        super.onRemovedFromStage(event);

        restTestState();
    }

    private function restTestState():void {
        AudioPlayer.stopAllAudio();

        if (timer && timer.stopButton)
            timer.stopButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));

        if (isPlanningComplete) {
            isPlanningComplete = false;

            /*recorderView.recordWaveformView.stopButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
            recorderView.recordWaveformView.newButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));*/
        }
    }

}
}
