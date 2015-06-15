package com.clarityenglish.practicalwriting.view.zone {
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.common.events.MemoryEvent;
import com.clarityenglish.textLayout.vo.XHTML;

import flash.errors.MemoryError;

import flash.events.Event;

import flash.events.MouseEvent;
import flash.net.ObjectEncoding;

import mx.charts.PieChart;
import mx.collections.ArrayCollection;

import org.osflash.signals.Signal;

import spark.components.Button;

import spark.components.Label;

import spark.components.TabbedViewNavigator;
import spark.components.VGroup;
import spark.primitives.Rect;

    public class ZoneView extends BentoView {

        [SkinPart]
        public var zoneViewNavigator:TabbedViewNavigator;

        [SkinPart]
        public var minsVGroup:VGroup;

        [SkinPart]
        public var minsNumberLabel:Label;

        [SkinPart]
        public var minsLabel:Label;

        [SkinPart]
        public var readLabel:Label;

        [SkinPart]
        public var midRect:Rect;

        [SkinPart]
        public var backButton:Button;

        [SkinPart]
        public var skillCaptionLabel:Label;

        [SkinPart]
        public var skillContentLabel:Label;

        public var backHome:Signal = new Signal();
        public var writeMemory:Signal = new Signal(MemoryEvent);

        private var _course:XML;
        private var _isCourseChanged:Boolean;
        private var hasCourseChanged:Boolean;
        private var _everyoneCourseSummaries:Object;
        private var _everyoneCourseSummariesChanged:Boolean;
        private var everyoneUnitScores:Object = new Object();
        private var _openUnitMemories:Array = [];
        private var _isOpenUnitMemoriesChanged:Boolean;
        private var openUnitID:Object = new Object();

        public function ZoneView() {
            actionBarVisible = false;
        }

        [Bindable]
        public function get course():XML {
            return _course;
        }

        public function set course(value:XML):void {
            if (value) {
                _course = value;
                _isCourseChanged = true;
                invalidateProperties();
            }
        }

        public function set everyoneCourseSummaries(value:Object):void {
            _everyoneCourseSummaries = value;
            _everyoneCourseSummariesChanged = true;
            // Make the array easier to search by unitID
            for (var i:Number = 0; i < _everyoneCourseSummaries.length; i++) {
                everyoneUnitScores[_everyoneCourseSummaries[i].CourseID] = {mins: Number(_everyoneCourseSummaries[i].AverageDuration) / 60, read: _everyoneCourseSummaries[i].Count};
            }
            invalidateProperties();
        }

        public function set openUnitMemories(value:Object):void {
            if (value) {
                _openUnitMemories = String(value).split(",");
                _isOpenUnitMemoriesChanged = true;
                var values:Array = [];
                for (var i:Number = 0; i < _openUnitMemories.length; i++) {
                    values = String(_openUnitMemories[i]).split(".");
                    openUnitID[values[0]] = {unitID: values[1]};
                }
            }
        }

        override protected function updateViewFromXHTML(xhtml:XHTML):void {
            super.updateViewFromXHTML(xhtml);
        }

        override protected function onViewCreationComplete():void {
            if (data) {
                zoneViewNavigator.selectedIndex = data.selectedIndex;
            }

        }

        override protected function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);

            switch (instance) {
                case zoneViewNavigator:
                    zoneViewNavigator.tabBar.addEventListener(MouseEvent.CLICK, onZoneViewNavigatorClick);
                    break;
                case backButton:
                    backButton.label = copyProvider.getCopyForId("Back");
                    backButton.addEventListener(MouseEvent.CLICK, onBackButtonClick);
                    break;
                case skillCaptionLabel:
                    skillCaptionLabel.text = copyProvider.getCopyForId("skillCaptionLabel");
                    break;
                case minsLabel:
                    minsLabel.text = copyProvider.getCopyForId("minsLabel");
                    break;
            }
        }

        override protected function commitProperties():void {
            super.commitProperties();

            if (_isCourseChanged) {
                _isCourseChanged = false;
                hasCourseChanged = true;

                skillContentLabel.text = copyProvider.getCopyForId(course.attribute("class") + "Skill");
            }

            if (hasCourseChanged && _everyoneCourseSummariesChanged) {
                _everyoneCourseSummariesChanged = false;
                hasCourseChanged = false;
                if (everyoneUnitScores[course.@id]) {
                    if (everyoneUnitScores[course.@id].mins > 0) {
                        minsVGroup.visible = minsVGroup.includeInLayout = true;
                        minsNumberLabel.text = everyoneUnitScores[course.@id].mins;
                    } else {
                        minsVGroup.visible = minsVGroup.includeInLayout = false;
                    }

                    if (everyoneUnitScores[course.@id].read > 0) {
                        readLabel.text = everyoneUnitScores[course.@id].read + copyProvider.getCopyForId("readLabel");
                        midRect.visible = midRect.includeInLayout = true;
                    } else {
                        midRect.visible = midRect.includeInLayout = false;
                        readLabel.visible = readLabel.includeInLayout = false;
                    }
                }
            }

            if (_isOpenUnitMemoriesChanged) {
                _isOpenUnitMemoriesChanged = false;

                if (openUnitID[course.@id]) {
                    zoneViewNavigator.selectedIndex = course.unit.(@id == openUnitID[course.@id].unitID).childIndex();
                }
            }
        }

        protected function onZoneViewNavigatorClick(event:MouseEvent):void {
            if (!data) {
                // Store the index of selected viewNavigator.
                data = new Object();
                data.selectedIndex = zoneViewNavigator.tabBar.selectedIndex;
            }

            // If the unit ID haven't been wriiten, then write memory if user open learning tab (index=1).
            if (zoneViewNavigator.tabBar.selectedIndex == 1 && !openUnitID[course.@id]) {
                var unitID:Number = course.unit[1].@id;
                var memoryValue:String = course.@id + "." + unitID;
               if (_openUnitMemories)
                    _openUnitMemories.push(memoryValue);
                writeMemory.dispatch(new MemoryEvent(MemoryEvent.WRITE, {openUnit: _openUnitMemories}));
            }
        }

        protected function onBackButtonClick(event:MouseEvent):void {
            this.navigator.popView();
        }
    }
}
