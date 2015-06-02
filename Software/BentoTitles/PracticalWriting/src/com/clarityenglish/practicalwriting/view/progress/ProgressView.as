/**
 * Created by alice on 17/4/15.
 */
package com.clarityenglish.practicalwriting.view.progress {
import com.clarityenglish.bento.view.base.BentoView;

import flash.events.Event;

import mx.collections.ArrayCollection;

import spark.components.ButtonBar;

    public class ProgressView extends BentoView {

        [SkinPart]
        public var progressNavBar:ButtonBar;

        [Bindable]
        public var isAnonymousUser:Boolean;

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
            }
        }

        /**
         * The state comes from the selection in the progress bar, plus _demo if we are in a demo version
         */
        protected override function getCurrentSkinState():String {
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
