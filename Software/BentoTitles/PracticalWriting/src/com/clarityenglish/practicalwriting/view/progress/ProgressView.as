/**
 * Created by alice on 17/4/15.
 */
package com.clarityenglish.practicalwriting.view.progress {
import com.clarityenglish.bento.BentoApplication;
import com.clarityenglish.bento.view.base.BentoView;

import flash.events.Event;

import mx.collections.ArrayCollection;

import spark.components.ButtonBar;
import spark.components.Label;

public class ProgressView extends BentoView {

        [SkinPart]
        public var progressNavBar:ButtonBar;

        [SkinPart]
        public var anonymousUserLabel:Label;

        [SkinPart]
        public var mockedUpMessage:Label;

        [Bindable]
        public var isAnonymousUser:Boolean;

        // gh#1307
        public function get isDemo():Boolean {
            return productVersion == BentoApplication.DEMO;
        }

        public function ProgressView() {
            super();

            actionBarVisible = false;
        }

        protected override function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);

            switch (instance) {
                case progressNavBar:
                    // gh#11 Language Code
                    progressNavBar.dataProvider = new ArrayCollection([
                        {label: copyProvider.getCopyForId("progressNavBarCoverage"), data: "coverage"},
                        {label: copyProvider.getCopyForId("progressNavBarCompare"), data: "compare"},
                        {label: copyProvider.getCopyForId("progressNavBarAnalyse"), data: "analysis"},
                        {label: copyProvider.getCopyForId("progressNavBarScores"), data: "score"},
                        {label: copyProvider.getCopyForId("progressNavBarCertificate"), data: "certificate"},
                    ]);
                    progressNavBar.requireSelection = true;
                    progressNavBar.addEventListener(Event.CHANGE, onNavBarIndexChange);
                    break;
                case anonymousUserLabel:
                    anonymousUserLabel.text = copyProvider.getCopyForId("anonymousProgressMessage");
                    break;
                case mockedUpMessage:
                    mockedUpMessage.text = copyProvider.getCopyForId("mockedUpProgressMessage");
                    break;
            }
        }

        /**
         * The state comes from the selection in the progress bar, plus _demo if we are in a demo version
         */
        protected override function getCurrentSkinState():String {
            // gh#1307
            if (this.isDemo)
                return "demo";

            // gh#1090
            if (isAnonymousUser)
                return "anonymous";

            var state:String = (!progressNavBar || !progressNavBar.selectedItem) ? "coverage" : progressNavBar.selectedItem.data;
            return state;
        }

        /**
         * When the tab is changed invalidate the skin state to force getCurrentSkinState() to get called again
         *
         * @param event
         */
        protected function onNavBarIndexChange(event:Event):void {
            invalidateSkinState(); // #301
        }
    }
}
