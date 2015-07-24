package com.clarityenglish.practicalwriting.view.exercise {
import com.clarityenglish.bento.events.ExerciseEvent;
import com.clarityenglish.bento.view.exercise.ExerciseView;
import com.clarityenglish.bento.view.timer.TimerComponent;
import com.clarityenglish.practicalwriting.view.exercise.event.WindowShadeEvent;
import com.clarityenglish.practicalwriting.view.exercise.ui.WindowShade;
import com.googlecode.bindagetools.Bind;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.SoftKeyboardEvent;
import flash.utils.setTimeout;

import mx.core.ClassFactory;

import org.davekeen.util.StateUtil;

import org.osflash.signals.Signal;

import skins.practicalwriting.exercise.WindowShadeSkin;

import spark.components.Button;
import spark.components.Group;

import spark.components.Label;

import spark.components.List;
import spark.components.ToggleButton;
import spark.events.IndexChangeEvent;
import spark.primitives.Rect;

    public class ExerciseView extends com.clarityenglish.bento.view.exercise.ExerciseView {

        [SkinPart]
        public var courseLabelButton:Button;

        [SkinPart]
        public var exerciseList:List;

        [SkinPart]
        public var windowShade:WindowShade;

        [SkinPart]
        public var exerciseCaptionGroup:Group;

        [SkinPart]
        public var dynamicViewCover:Rect;

        [SkinPart]
        public var timerComponent:TimerComponent;

        [Bindable]
        public var selectedExerciseNode:XML;

        [Bindable]
        public var courseIndex:Number;

        public function ExerciseView() {
            super();

            actionBarVisible = false;
        }

        protected override function onAddedToStage(event:Event):void {
            super.onAddedToStage(event);

            // gh#1099
            stage.addEventListener(MouseEvent.CLICK, onStageClick);
            addEventListener(WindowShadeEvent.WINDOWSHADE_OPEN, onWindowShadeOpen);
            addEventListener(WindowShadeEvent.WINDOWSHADE_CLOSE, onWindowShadeClose);
        }

        protected override function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);

            switch (instance) {
                case courseLabelButton:
                    courseLabelButton.addEventListener(MouseEvent.CLICK, onCourseLabelButtonClick);
                    break;
                case exerciseCaptionGroup:
                    exerciseCaptionGroup.addEventListener(MouseEvent.CLICK, onExerciseCaptionGroupClick);
                    break;
                case exerciseList:
                    var exerciseSelected:Signal = new Signal(XML);

                    exerciseList.addEventListener(IndexChangeEvent.CHANGE, onExerciseSelected);

                    // Select the current unit and exercise
                    Bind.fromProperty(this, "selectedExerciseNode").toFunction(function(node:XML):void {
                        if (node) {
                            courseIndex = node.parent().parent().childIndex();
                            exerciseList.selectedItem = node;
                            callLater(function():void {
                                exerciseList.ensureIndexIsVisible(exerciseList.selectedIndex);
                                exerciseSelected.dispatch(node);
                            });
                        }
                    });
                    break;
                case timerComponent:
                    timerComponent.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, onSoftKeyBoardActivate);
                    timerComponent.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, onSoftKeyBoardDeactivate);
                    break;
            }
        }

        protected function onExerciseSelected(e:Event):void {
            if (exerciseList.selectedItem) {
                windowShade.close();
                setTimeout(nodeSelect.dispatch, 400, exerciseList.selectedItem);
            }
        }

        protected function onStageClick(event:MouseEvent):void {
            var component:Object = event.target;

            while(component) {
                if (component is WindowShadeSkin) { // detect if user click on window shade
                    break;
                }
                component = component.parent;
            }

            if (!(component is WindowShadeSkin)) {
                windowShade.close();
            }
        }

        protected function onWindowShadeOpen(event:Event):void {
            dynamicView.enabled = false;
            dynamicViewCover.visible = true;
        }

        protected function onWindowShadeClose(event:Event):void {
            dynamicView.enabled = true;
            dynamicViewCover.visible = false;
        }

        protected function onSoftKeyBoardActivate(event:Event):void {
            trace("softkeyboard height: "+stage.softKeyboardRect.height);
            if (!isPlatformiPad) {
                timerComponent.bottom = stage.softKeyboardRect.height + 10;
            }
        }

        protected function onSoftKeyBoardDeactivate(event:Event):void {
            if (!isPlatformiPad) {
                timerComponent.bottom = 0;
            }
        }

        protected function onExerciseCaptionGroupClick(event:Event):void {
            windowShade.open();
        }

        protected function onCourseLabelButtonClick(event:Event):void {
            backToMenu.dispatch();
        }
    }
}
