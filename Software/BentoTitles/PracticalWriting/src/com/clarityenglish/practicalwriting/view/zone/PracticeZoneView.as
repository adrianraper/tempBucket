package com.clarityenglish.practicalwriting.view.zone {
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.bento.vo.content.Exercise;

import flash.events.Event;

import mx.collections.XMLListCollection;

import mx.collections.XMLListCollection;

import org.osflash.signals.Signal;

import spark.components.List;
import spark.events.IndexChangeEvent;

    public class PracticeZoneView extends BentoView {

        [SkinPart]
        public var exerciseList:List;

        public var exerciseSelect:Signal = new Signal(XML);

        public function PracticeZoneView():void {
            super();

            actionBarVisible = false;
        }

        public override function set data(value:Object):void {
            super.data = value;

            dispatchEvent(new Event("dataChange"));
        }

        [Bindable(event="dataChange")]
        public function get exerciseXMLListCollection():XMLListCollection {
            return data? new XMLListCollection(data.unit.(attribute("class") == "learning").exercise) : null;
        }

        [Bindable(event="dataChange")]
        public function get courseIndex():Number {
            return data? data.childIndex() : 0;
        }
        protected override function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);

            switch (instance) {
                case exerciseList:
                    exerciseList.addEventListener(IndexChangeEvent.CHANGE, onExerciseSelect);
                    break;
            }
        }

        protected function onExerciseSelect(event:IndexChangeEvent):void {
            var exercise:XML = event.target.selectedItem as XML;
            if (exercise && Exercise.exerciseEnabledInMenu(exercise))
                exerciseSelect.dispatch(exercise);
        }
    }
}
