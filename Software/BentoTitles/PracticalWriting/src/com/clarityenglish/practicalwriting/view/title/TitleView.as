package com.clarityenglish.practicalwriting.view.title {
import com.clarityenglish.bento.BentoApplication;
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.practicalwriting.view.exercise.ExerciseView;
import com.clarityenglish.practicalwriting.view.home.HomeView;
import com.clarityenglish.practicalwriting.view.progress.ProgressView;
import com.clarityenglish.practicalwriting.view.settings.SettingsView;
import com.clarityenglish.practicalwriting.view.zone.ZoneView;
import com.googlecode.bindagetools.Bind;

import flash.events.Event;

import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import mx.core.FlexGlobals;

import org.davekeen.util.StateUtil;

import org.osflash.signals.Signal;
import org.puremvc.as3.core.View;

import spark.components.Button;
import spark.components.Label;

import spark.components.TabbedViewNavigator;
import spark.components.ToggleButton;
import spark.components.ViewNavigator;
import spark.events.IndexChangeEvent;
import spark.events.ViewNavigatorEvent;
import spark.managers.PersistenceManager;

    [SkinState("home")]
    [SkinState("progress")]
    [SkinState("exercise")]
    public class TitleView extends BentoView {

        [SkinPart]
        public var sectionNavigator:TabbedViewNavigator;

        [SkinPart]
        public var homeViewNavigator:ViewNavigator;

        [SkinPart]
        public var progressViewNavigator:ViewNavigator;

        [SkinPart]
        public var settingsViewNavigator:ViewNavigator;

        [SkinPart]
        public var backToMenuButton:Button;

        [SkinPart]
        public var goToProgressButton:Button;

        [SkinPart]
        public var goToHelpButton:Button;

        [SkinPart]
        public var goToSettingsButton:Button;

        [SkinPart]
        public var backToExerciseButton:Button;

        [SkinPart]
        public var logoutButton:Button;

        [SkinPart]
        public var helpButton:Button;

        [SkinPart]
        public var homeButton:Button;

        [SkinPart]
        public var versionLabel:Label;

        [SkinPart]
        public var copyrightLabel:Label;

        [SkinPart]
        public var topLeftDemoLabel:Label;

        [SkinPart]
        public var topRightDemoLabel:Label;

        public var backToMenu:Signal = new Signal();
        public var logout:Signal = new Signal();
        public var goToProgress:Signal = new Signal();
        public var goToSettings:Signal = new Signal();

        private var _selectedNode:XML;
        private var _isDirectStartCourse:Boolean;
        private var _directCourse:XML;
        private var _isDirectStartUnit:Boolean;
        private var _directUnit:XML;
        private var _isDirectStartEx:Boolean;
        private var _directExercise:XML;
        private var _isDirectLogout:Boolean;
        private var isProgressOpen:Boolean;

        public function set selectedNode(value:XML):void {
            _selectedNode = value;

            switch (_selectedNode.localName()) {
                case "menu":
                    currentState = "home";
                    homeViewNavigator.popToFirstView();
                    break;
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

        // gh#1307
        public function get isDemo():Boolean {
            return productVersion == BentoApplication.DEMO;
        }

        public function TitleView() {
            // The first one listed will be the default
            StateUtil.addStates(this, [ "home", "exercise", "progress", "zone", "settings"], true);
        }

        protected override function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);

            switch (instance) {
                case sectionNavigator:
                    setNavStateMap(sectionNavigator, {
                        home: { viewClass: HomeView },
                        zone: { viewClass: ZoneView, stack: true },
                        exercise: { viewClass: ExerciseView, stack: true },
                        progress: { viewClass: ProgressView },
                        settings: { viewClass: SettingsView }
                });
                    sectionNavigator.addEventListener(IndexChangeEvent.CHANGE, onSectionNavigatorIndexChange);
                break;
                case homeViewNavigator:
                    homeViewNavigator.label = copyProvider.getCopyForId("Home");
                    break;
                case progressViewNavigator:
                    progressViewNavigator.label = copyProvider.getCopyForId("myProgress");
                    break;
                case settingsViewNavigator:
                    settingsViewNavigator.label = copyProvider.getCopyForId("settings");
                    break;
                /*case backToMenuButton:
                    backToMenuButton.label = copyProvider.getCopyForId("Home");
                    backToMenuButton.addEventListener(MouseEvent.CLICK, onBackToMenuButtonClick);
                    break;*/
                case logoutButton:
                    logoutButton.addEventListener(MouseEvent.CLICK, onLogoutClick);
                    break;
                case helpButton:
                    instance.label = copyProvider.getCopyForId("help");
                    instance.addEventListener(MouseEvent.CLICK,onHelpClick);
                    break;
                // gh#1090 To hide progress tab for pure AA login
                case progressViewNavigator:
                    instance.enabled = !config.noLogin;
                    break;
                case homeButton:
                    homeButton.addEventListener(MouseEvent.CLICK, onHomeButtonClick);
                    break;
                /*case goToProgressButton:
                    goToProgressButton.label = copyProvider.getCopyForId("myProgress");
                    goToProgressButton.addEventListener(MouseEvent.CLICK, onGoToProgressButtonClick);
                    break;
                case goToHelpButton:
                    goToHelpButton.label = copyProvider.getCopyForId("help");
                    goToHelpButton.addEventListener(MouseEvent.CLICK,onHelpClick);
                    break;
                case goToSettingsButton:
                    goToSettingsButton.label = copyProvider.getCopyForId("settings");
                    goToSettingsButton.addEventListener(MouseEvent.CLICK, onGoToSettingsButtonClick)
                    break;*/
                case backToExerciseButton:
                    backToExerciseButton.label = copyProvider.getCopyForId("back");
                    backToExerciseButton.addEventListener(MouseEvent.CLICK, onBackToExerciseButtonClick);
                    break;
                case versionLabel:
                    versionLabel.text = copyProvider.getCopyForId("versionLabel", {versionNumber: FlexGlobals.topLevelApplication.versionNumber});
                    break;
                case copyrightLabel:
                    copyrightLabel.text = copyProvider.getCopyForId("copyright");
                    break;
                case topLeftDemoLabel:
                    topLeftDemoLabel.text = copyProvider.getCopyForId("topLeftDemoLabel");
                    break;
                case topRightDemoLabel:
                    topRightDemoLabel.text = copyProvider.getCopyForId("topRightDemoLabel");
                    break;
            }

        }

        /*override protected function onAddedToStage(event:Event):void {
            addEventListener(MouseEvent.CLICK, onStageClick);
        }*/

        protected override function getCurrentSkinState():String {
            return currentState;
        }

        /*protected function onBackToMenuButtonClick(event:MouseEvent):void {
            if (menuToggleButton.selected) {
                menuToggleButton.selected = false;
                sectionNavigator.left = menuToggleButton.left = 0;
                sectionNavigator.right = 0;
            }

            _isDirectLogout? logout.dispatch() : backToMenu.dispatch();
        }*/

        // gh#217
        protected function onLogoutClick(event:Event):void {
            logout.dispatch();
        }

        protected function onHelpClick(event:MouseEvent):void {
            var url:String = copyProvider.getCopyForId("helpURL");
            var urlRequest:URLRequest = new URLRequest(url);
            navigateToURL(urlRequest, "_blank");
        }

        protected function onHomeButtonClick(evnet:MouseEvent):void {
            backToMenu.dispatch();
        }

        /*protected function onGoToProgressButtonClick(event:MouseEvent):void {
            sectionNavigator.left = menuToggleButton.left = 0;
            sectionNavigator.right = 0;
            menuToggleButton.selected = false;
            isProgressOpen = true;

            goToProgress.dispatch();
        }

        protected function onGoToSettingsButtonClick(event:MouseEvent):void {
            sectionNavigator.left = menuToggleButton.left = 0;
            sectionNavigator.right = 0;
            menuToggleButton.selected = false;
            isProgressOpen = true;

            goToSettings.dispatch();
        }*/

        protected function onSectionNavigatorIndexChange(event:IndexChangeEvent):void {
            // After the active view changing to progress view, we hide the tab bar in progress page.
            if (isProgressOpen) {
                isProgressOpen = false;

                sectionNavigator.tabBar.visible = false;
                helpButton.visible = logoutButton.visible = false;
                backToExerciseButton.visible = backToExerciseButton.includeInLayout = true;
            } else {
                helpButton.visible = logoutButton.visible = true;
                backToExerciseButton.visible = backToExerciseButton.includeInLayout = false;
            }
        }

        protected function onBackToExerciseButtonClick(event:MouseEvent):void {
            sectionNavigator.selectedIndex = 0;
        }

        // When the side bar open, click the stage will close it.
        /*protected function onStageClick(event:Event):void {
            if (menuToggleButton) {
                if (event.target != menuToggleButton && menuToggleButton.selected) {
                    sectionNavigator.left = menuToggleButton.left = 0;
                    sectionNavigator.right = 0;
                    menuToggleButton.selected = false;
                }
            }
        }*/
    }
}
