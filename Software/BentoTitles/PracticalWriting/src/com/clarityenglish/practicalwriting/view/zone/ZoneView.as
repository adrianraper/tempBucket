package com.clarityenglish.practicalwriting.view.zone {
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.textLayout.vo.XHTML;

import flash.events.Event;

import flash.events.MouseEvent;
import flash.net.ObjectEncoding;

import mx.charts.PieChart;
import mx.collections.ArrayCollection;

import org.osflash.signals.Signal;

import spark.components.Button;

import spark.components.Label;

import spark.components.TabbedViewNavigator;
import spark.primitives.Rect;

    public class ZoneView extends BentoView {

        [SkinPart]
        public var zoneViewNavigator:TabbedViewNavigator;

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

        private var _course:XML;
        private var _isCourseChanged:Boolean;
        private var hasCourseChanged:Boolean;
        private var _everyoneCourseSummaries:Object;
        private var _everyoneCourseSummariesChanged:Boolean;
        private var everyoneUnitScores:Object = new Object();

        public function ZoneView() {
            actionBarVisible = false;
        }

        [Bindable]
        public function get course():XML {
            return _course;
        }

        public function set course(value:XML):void {
            _course = value;
            _isCourseChanged = true;
            invalidateProperties();
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
                        minsLabel.text = everyoneUnitScores[course.@id].mins + copyProvider.getCopyForId("minsLabel");
                    } else {
                        minsLabel.visible = minsLabel.includeInLayout = false;
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
        }

        protected function onZoneViewNavigatorClick(event:MouseEvent):void {
            if (!data) {
                // Store the index of selected viewNavigator.
                data = new Object();
                data.selectedIndex = zoneViewNavigator.tabBar.selectedIndex;
            }
        }

        protected function onBackButtonClick(event:MouseEvent):void {
            this.navigator.popView();
        }
    }
}
