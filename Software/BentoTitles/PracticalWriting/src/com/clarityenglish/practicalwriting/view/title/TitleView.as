package com.clarityenglish.practicalwriting.view.title {
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.bento.view.exercise.ExerciseView;
import com.clarityenglish.practicalwriting.view.home.HomeView;
import com.clarityenglish.practicalwriting.view.progress.ProgressView;
import com.clarityenglish.practicalwriting.view.zone.ZoneView;

import flash.events.Event;

import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import org.davekeen.util.StateUtil;

import org.osflash.signals.Signal;

import spark.components.Button;

import spark.components.TabbedViewNavigator;
import spark.components.ViewNavigator;

    [SkinState("home")]
    [SkinState("progress")]
    [SkinState("exercise")]
    public class TitleView extends BentoView {

        [SkinPart]
        public var sectionNavigator:TabbedViewNavigator;

        [SkinPart]
        public var progressViewNavigator:ViewNavigator;

        [SkinPart]
        public var backToMenuButton:Button;

        [SkinPart]
        public var logoutButton:Button;

        [SkinPart]
        public var helpButton:Button;

        public var backToMenu:Signal = new Signal();
        public var logout:Signal = new Signal();

        private var _selectedNode:XML;
        private var _isDirectStartCourse:Boolean;
        private var _directCourse:XML;
        private var _isDirectStartUnit:Boolean;
        private var _directUnit:XML;
        private var _isDirectStartEx:Boolean;
        private var _directExercise:XML;
        private var _isDirectLogout:Boolean;

        public function set selectedNode(value:XML):void {
            _selectedNode = value;

            switch (_selectedNode.localName()) {
                case "course":
                case "unit":
                    currentState = "zone";
                    break;
                case "exercise":
                    currentState = "exercise";
                    break;
            }
        }

        public function set isDirectStartCourse(value:Boolean):void {
            _isDirectStartCourse = value;
        }

        public function set directCourse(value:XML):void {
            _directCourse = value;
        }
        // gh#853
        public function get directCourse():XML {
            return _directCourse;
        }

        public function set isDirectStartUnit(value:Boolean):void {
            _isDirectStartUnit = value;
        }

        public function set directUnit(value:XML):void {
            _directUnit = value;
        }
        public function get directUnit():XML {
            return _directUnit;
        }

        public function set isDirectStartExercise(value:Boolean):void {
            _isDirectStartEx = value;
        }

        public function set directExercise(value:XML):void {
            _directExercise = value;
        }
        public function get directExercise():XML {
            return _directExercise;
        }

        public function set isDirectLogout(value:Boolean):void {
            _isDirectLogout = value;
        }

        [Bindable]
        public function get isDirectLogout():Boolean {
            return _isDirectLogout;
        }

        public function TitleView() {
            // The first one listed will be the default
            StateUtil.addStates(this, [ "home", "exercise", "progress", "zone" ], true);
        }

        protected override function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);

            switch (instance) {
                case sectionNavigator:
                    setNavStateMap(sectionNavigator, {
                        home: { viewClass: HomeView },
                        zone: { viewClass: ZoneView, stack: true },
                        exercise: { viewClass: ExerciseView, stack: true },
                        progress: { viewClass: ProgressView }
                });
                break;
                case backToMenuButton:
                    backToMenuButton.label = copyProvider.getCopyForId("backToMenuButton");
                    backToMenuButton.addEventListener(MouseEvent.CLICK, onBackToMenuButtonClick);
                    break;
                case logoutButton:
                    instance.addEventListener(MouseEvent.CLICK, onLogoutClick);
                    break;
                case helpButton:
                    instance.label = copyProvider.getCopyForId("help");
                    instance.addEventListener(MouseEvent.CLICK,onHelpClick);
                    break;
                // gh#1090 To hide progress tab for pure AA login
                case progressViewNavigator:
                    instance.enabled = !config.noLogin;
                    break;
            }

        }

        protected override function getCurrentSkinState():String {
            return currentState;
        }

        protected function onBackToMenuButtonClick(event:MouseEvent):void {
            _isDirectLogout? logout.dispatch() : backToMenu.dispatch();
        }

        // gh#217
        protected function onLogoutClick(event:Event):void {
            logout.dispatch();
        }

        protected function onHelpClick(event:MouseEvent):void {
            var url:String = copyProvider.getCopyForId("helpURL");
            var urlRequest:URLRequest = new URLRequest(url);
            navigateToURL(urlRequest, "_blank");
        }
    }
}
