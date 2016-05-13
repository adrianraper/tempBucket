package com.clarityenglish.practicalwriting.view.zone {
import com.clarityenglish.bento.BentoApplication;
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.common.events.MemoryEvent;
import com.clarityenglish.textLayout.vo.XHTML;

import flash.errors.MemoryError;

import flash.events.Event;

import flash.events.MouseEvent;
import flash.net.ObjectEncoding;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import mx.charts.PieChart;
import mx.collections.ArrayCollection;
import mx.controls.SWFLoader;

import org.osflash.signals.Signal;

import spark.components.Button;

import spark.components.Label;

import spark.components.TabbedViewNavigator;
import spark.components.ViewNavigator;
import spark.components.VGroup;
import spark.events.IndexChangeEvent;
import spark.primitives.Rect;

    public class ZoneView extends BentoView {

        [SkinPart]
        public var zoneViewNavigator:TabbedViewNavigator;

        [SkinPart]
        public var startOutViewNavigator:ViewNavigator;

        [SkinPart]
        public var practiceZoneViewNavigator:ViewNavigator;

        [SkinPart]
        public var resourcesViewNavigator:ViewNavigator;

        [SkinPart]
        public var priceBannerSWFLoader:SWFLoader;

        /**
         * remove stats until we have a reasonable number of data points
         *

        [SkinPart]
        public var minsVGroup:VGroup;

        [SkinPart]
        public var minsNumberLabel:Label;

        [SkinPart]
        public var minsExplanationLabel:Label;

        [SkinPart]
        public var minsLabel:Label;

        [SkinPart]
        public var readLabel:Label;

        [SkinPart]
        public var midRect:Rect;
         */

        [SkinPart]
        public var backButton:Button;

        [SkinPart]
        public var skillCaptionLabel:Label;

        [SkinPart]
        public var skillContentLabel:Label;

        [SkinPart]
        public var forwardButton:Button;

        [SkinPart]
        public var backwardButton:Button;
        
        [Bindable]
        public var isPlatformTablet:Boolean;

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

        // gh#1307
        public function get isDemo():Boolean {
            return productVersion == BentoApplication.DEMO;
        }

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
                var averageDuration:Number = Math.round(Number(_everyoneCourseSummaries[i].AverageDuration) / 60);
                everyoneUnitScores[_everyoneCourseSummaries[i].CourseID] = {mins: averageDuration, read: _everyoneCourseSummaries[i].Count};
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
                //trace("data selected index: "+data.selectedIndex);
                zoneViewNavigator.selectedIndex = data.selectedIndex;
            }

        }

        override protected function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);

            switch (instance) {
                case zoneViewNavigator:
                    zoneViewNavigator.addEventListener(IndexChangeEvent.CHANGE, onIndexChange);
                    break;
                case backButton:
                    backButton.label = copyProvider.getCopyForId("Back");
                    backButton.addEventListener(MouseEvent.CLICK, onBackButtonClick);
                    break;
                case skillCaptionLabel:
                    skillCaptionLabel.text = copyProvider.getCopyForId("skillCaptionLabel");
                    break;
                /*
                case minsExplanationLabel:
                    minsExplanationLabel.text = copyProvider.getCopyForId("minsExplanationLabel");
                    break;
                case minsLabel:
                    minsLabel.text = copyProvider.getCopyForId("minsLabel");
                    break;
                */
                case startOutViewNavigator:
                    startOutViewNavigator.label = copyProvider.getCopyForId("startingOut");
                    break;
                case practiceZoneViewNavigator:
                    practiceZoneViewNavigator.label = copyProvider.getCopyForId("practiceZone");
                    break;
                case resourcesViewNavigator:
                    resourcesViewNavigator.label = copyProvider.getCopyForId("resourceBank");
                    break;
                case priceBannerSWFLoader:
                    priceBannerSWFLoader.addEventListener(MouseEvent.CLICK, onPriceBannerClick);
                    break;
                case forwardButton:
                    forwardButton.addEventListener(MouseEvent.CLICK, onForwardButtonClick);
                    break;
                case backwardButton:
                    backwardButton.addEventListener(MouseEvent.CLICK, onBackwardButtonClick);
                    break;
            }
        }

        override protected function commitProperties():void {
            super.commitProperties();

            if (_isCourseChanged) {
                _isCourseChanged = false;
                hasCourseChanged = true;

                skillContentLabel.text = copyProvider.getCopyForId("skillContent" + course.childIndex());
            }

            if (hasCourseChanged && _everyoneCourseSummariesChanged) {
                _everyoneCourseSummariesChanged = false;
                hasCourseChanged = false;
                /*
                // If no-one has done this unit, put in an estimate
                if (everyoneUnitScores[course.@id]) {
                    minsLabel.text = copyProvider.getCopyForId("minsLabel", {time: (everyoneUnitScores[course.@id].mins >= 10) ? everyoneUnitScores[course.@id].mins : 20});

                    if (everyoneUnitScores[course.@id].read >= 100) {
                        readLabel.text = copyProvider.getCopyForId("readLabel", {count: everyoneUnitScores[course.@id].read});
                        midRect.visible = midRect.includeInLayout = true;
                        readLabel.visible = readLabel.includeInLayout = true;
                    } else {
                        midRect.visible = midRect.includeInLayout = false;
                        readLabel.visible = readLabel.includeInLayout = false;
                    }
                } else {
                    minsLabel.text = copyProvider.getCopyForId("minsLabel", {time: 20});
                    midRect.visible = midRect.includeInLayout = false;
                    readLabel.visible = readLabel.includeInLayout = false;
                }
                */
            }

            if (_isOpenUnitMemoriesChanged) {
                _isOpenUnitMemoriesChanged = false;

                // #1294
                if (openUnitID[course.@id]) {
                    if(isUnitEnabled(course.unit[1])) {
                        zoneViewNavigator.selectedIndex = 1;
                    } else {
                        // If learning unit is disabled then find the first unit that is enable.
                        if(isUnitEnabled(course.unit[0])) {
                            zoneViewNavigator.selectedIndex = 0;
                        } else {
                            if (isUnitEnabled(course.unit[2])) {
                                zoneViewNavigator.selectedIndex = 2;
                            } else {
                                zoneViewNavigator.selectedIndex = 0;
                            }
                        }
                    }
                }
            }
        }

        protected override function getCurrentSkinState():String {
            // gh#1307
            if (this.isDemo)
                return "demo";

            return super.getCurrentViewState();
        }

        protected function onBackButtonClick(event:MouseEvent):void {
            this.navigator.popView();
        }

        protected function onPriceBannerClick(event:MouseEvent):void {
            var url:String = copyProvider.getCopyForId("demoPriceURL");
            navigateToURL(new URLRequest(url), "_blank");
        }

        protected function onIndexChange(event:Event):void {
            if (zoneViewNavigator.selectedIndex == zoneViewNavigator.length - 1) {
                forwardButton.visible = false;
            } else {
                forwardButton.visible = true;
            }

            if (zoneViewNavigator.selectedIndex == 0) {
                backwardButton.visible = false;
            } else {
                backwardButton.visible = true;
            }

            // gh#1358
            data = new Object();
            data.selectedIndex = zoneViewNavigator.tabBar.selectedIndex;

            // If the unit ID haven't been wriiten, then write memory if user open learning tab (index=1).
            if (zoneViewNavigator.tabBar.selectedIndex == 1 && !openUnitID[course.@id]) {
                var unitID:Number = course.unit[1].@id;
                var memoryValue:String = course.@id + "." + unitID;
                if (_openUnitMemories)
                    _openUnitMemories.push(memoryValue);
                writeMemory.dispatch(new MemoryEvent(MemoryEvent.WRITE, {openUnit: _openUnitMemories}));
            }
        }

        protected function onForwardButtonClick(event:MouseEvent):void {
            zoneViewNavigator.selectedIndex = zoneViewNavigator.selectedIndex < zoneViewNavigator.length - 1? zoneViewNavigator.selectedIndex + 1 : zoneViewNavigator.selectedIndex;
        }

        protected function onBackwardButtonClick(event:MouseEvent):void {
            zoneViewNavigator.selectedIndex = zoneViewNavigator.selectedIndex > 0? zoneViewNavigator.selectedIndex - 1 : zoneViewNavigator.selectedIndex;
        }

        // #1294
        private function isUnitEnabled(unit:XML):Boolean {
            if (unit.attribute("enabledFlag").length() > 0 && (unit.@enabledFlag.toString() & 8)) {
                return false;
            } else {
                return true;
            }
        }
    }
}
