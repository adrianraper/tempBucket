package com.clarityenglish.bento.controller {
import flash.display.DisplayObject;
import flash.events.KeyboardEvent;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;

import mx.controls.SWFLoader;

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

    public class ImageEnlargeCommand extends SimpleCommand {

        /**
         * Standard flex logger
         */
        private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));

        private static var isPopUpWindowOpen:Boolean;
        private static var imageSourceArrayList:ArrayList = new ArrayList();

        private var titleWindow:TitleWindow; // There may be more one images, so the titleWindow cannot be static.
        private var image:Object = new Object();

        public override function execute(note:INotification):void {
            super.execute(note);

            image = note.getBody() as Object;

            // Search the imageSourceArrayList to see whether the current image source already existed, if it is then the image is still open.
            for (var i:int = 0; i < imageSourceArrayList.length; i++) {
                if (image.source == imageSourceArrayList.getItemAt(i) as String) {
                    isPopUpWindowOpen = true;
                    break;
                }
            }

            if (!isPopUpWindowOpen) {
                imageSourceArrayList.addItem(image.source);
                titleWindow = new TitleWindow();
                titleWindow.styleName = "feedbackTitleWindow";
                titleWindow.addEventListener(TitleWindowBoundsEvent.WINDOW_MOVING, onWindowMoving);
                titleWindow.addEventListener(CloseEvent.CLOSE, onClosePopUp);

                var swfLoader:SWFLoader = new SWFLoader();
                swfLoader.source = image.source;
                swfLoader.width = image.width;
                swfLoader.height = image.height;

                titleWindow.addElement(swfLoader);

                // Create and centre the popup
                PopUpManager.addPopUp(titleWindow, FlexGlobals.topLevelApplication as DisplayObject, false, PopUpManagerChildList.POPUP, FlexGlobals.topLevelApplication.moduleFactory);
                PopUpManager.centerPopUp(titleWindow);
            }
        }

        /**
         * Keep the window on the screen (#197)
         *
         * @param event
         */
        protected function onWindowMoving(event:TitleWindowBoundsEvent):void {
            if (event.afterBounds.left < 0) {
                event.afterBounds.left = 0;
            } else if (event.afterBounds.right > titleWindow.systemManager.stage.stageWidth) {
                event.afterBounds.left = titleWindow.systemManager.stage.stageWidth - event.afterBounds.width;
            }

            if (event.afterBounds.top < 0) {
                event.afterBounds.top = 0;
            } else if (event.afterBounds.bottom > titleWindow.systemManager.stage.stageHeight) {
                event.afterBounds.top = titleWindow.systemManager.stage.stageHeight - event.afterBounds.height;
            }
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

            isPopUpWindowOpen = false;
            imageSourceArrayList.removeItem(image.source);
        }
    }
}
