package com.clarityenglish.bento.controller {
import com.clarityenglish.bento.view.timer.TimerSettingView;

import flash.display.DisplayObject;

import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.managers.PopUpManagerChildList;

import org.davekeen.util.ClassUtil;
import org.puremvc.as3.interfaces.INotification;

import org.puremvc.as3.patterns.command.SimpleCommand;

import spark.components.TitleWindow;
import spark.events.TitleWindowBoundsEvent;

    public class TimerSettingShowCommand extends SimpleCommand {

        /**
         * Standard flex logger
         */
        private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));

        private var titleWindow:TitleWindow;

        public override function execute(note:INotification):void {
            super.execute(note);

            titleWindow = new TitleWindow();
            titleWindow.styleName = "feedbackTitleWindow";
            titleWindow.title = "Timer";
            titleWindow.addEventListener(TitleWindowBoundsEvent.WINDOW_MOVING, onWindowMoving, false, 0, true);
            titleWindow.addEventListener(CloseEvent.CLOSE, onClosePopUp);

            var timerView:TimerSettingView = new TimerSettingView();
            timerView.totalTime = note.getBody().totalTime as Number;
            if (note.getBody().timerDurationArray)
                timerView.durationArray = note.getBody().timerDurationArray as Array;
            titleWindow.addElement(timerView);

            // Create and centre the popup
            PopUpManager.addPopUp(titleWindow, FlexGlobals.topLevelApplication as DisplayObject, false, PopUpManagerChildList.POPUP, FlexGlobals.topLevelApplication.moduleFactory);
            PopUpManager.centerPopUp(titleWindow);
        }

        /**
         * Close the popup and make all variables eligible for garbage collection
         *
         * @param event
         */
        protected function onClosePopUp(event:CloseEvent = null):void {
            titleWindow.removeEventListener(CloseEvent.CLOSE, onClosePopUp);
            titleWindow.removeEventListener(TitleWindowBoundsEvent.WINDOW_MOVING, onWindowMoving);

            PopUpManager.removePopUp(titleWindow);
            titleWindow = null;
        }

        protected function onWindowMoving(evt:TitleWindowBoundsEvent):void {
            if (evt.afterBounds.left < 0) {
                evt.afterBounds.left = 0;
            } else if (evt.afterBounds.right > FlexGlobals.topLevelApplication.width) {
                evt.afterBounds.left = FlexGlobals.topLevelApplication.width - evt.afterBounds.width;
            }

            if (evt.afterBounds.top < 0) {
                evt.afterBounds.top = 0;
            } else if (evt.afterBounds.bottom > FlexGlobals.topLevelApplication.height) {
                evt.afterBounds.top = FlexGlobals.topLevelApplication.height - evt.afterBounds.height;
            }
        }
    }
}
