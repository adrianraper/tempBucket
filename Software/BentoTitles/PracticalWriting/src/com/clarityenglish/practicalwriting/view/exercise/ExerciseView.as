package com.clarityenglish.practicalwriting.view.exercise {
import com.clarityenglish.bento.events.ExerciseEvent;
import com.clarityenglish.bento.view.exercise.ExerciseView;
import com.clarityenglish.practicalwriting.view.exercise.ui.WindowShade;
import com.googlecode.bindagetools.Bind;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.setTimeout;

import mx.core.ClassFactory;

import org.davekeen.util.StateUtil;

import org.osflash.signals.Signal;

import skins.practicalwriting.exercise.ExerciseUnitListItemRenderer;

import skins.practicalwriting.exercise.WindowShadeSkin;

import spark.components.Button;

import spark.components.Label;

import spark.components.List;
import spark.components.ToggleButton;

    public class ExerciseView extends com.clarityenglish.bento.view.exercise.ExerciseView {

        [SkinPart]
        public var unitLabel:Label;

        [SkinPart]
        public var unitList:List;

        [SkinPart]
        public var windowShade:WindowShade;

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
        }

        protected override function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);

            switch (instance) {
                case unitList:
                    var exerciseSelected:Signal = new Signal(XML);

                    var unitListItemRenderer:ClassFactory = new ClassFactory(ExerciseUnitListItemRenderer);
                    unitListItemRenderer.properties = { selectedExerciseNode: selectedExerciseNode, exerciseSelected: exerciseSelected };
                    instance.itemRenderer = unitListItemRenderer;

                    unitList.addEventListener(ExerciseEvent.EXERCISE_SELECTED, onExerciseSelected);

                    // Select the current unit and exercise
                    Bind.fromProperty(this, "selectedExerciseNode").toFunction(function(node:XML):void {
                        if (node) {
                            unitList.selectedItem = node.parent();
                            callLater(function():void {
                                unitList.ensureIndexIsVisible(unitList.selectedIndex);
                                exerciseSelected.dispatch(node);
                            });

                            courseIndex = node.parent().parent().childIndex();
                        }
                    });
                    break;
            }
        }

        protected function onExerciseSelected(e:ExerciseEvent):void {
            if (e.node) {
                windowShade.close();
                setTimeout(nodeSelect.dispatch, 400, e.node);
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
    }
}
