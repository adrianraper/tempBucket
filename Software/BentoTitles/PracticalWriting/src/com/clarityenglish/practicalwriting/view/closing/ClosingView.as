package com.clarityenglish.practicalwriting.view.closing {
import com.clarityenglish.bento.BentoApplication;
import com.clarityenglish.bento.view.base.BentoView;

import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import mx.controls.SWFLoader;

import mx.core.FlexGlobals;

import spark.components.Label;

public class ClosingView extends BentoView {

        [SkinPart]
        public var closingCaptionLabel:Label;

        [SkinPart]
        public var closingContentLabel:Label;

        [SkinPart]
        public var productNameLabel:Label;

        [SkinPart]
        public var priceBannerSWFLoader:SWFLoader;

        [SkinPart]
        public var versionLabel:Label;

        [SkinPart]
        public var copyrightLabel:Label;

        // gh#1307
        public function get isDemo():Boolean {
            return productVersion == BentoApplication.DEMO;
        }

        protected override function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);

            switch (instance) {
                case closingCaptionLabel:
                    closingCaptionLabel.text = copyProvider.getCopyForId("closingCaptionLabel");
                    break;
                case closingContentLabel:
                    closingContentLabel.text = copyProvider.getCopyForId("closingContentLabel");
                    break;
                case productNameLabel:
                    productNameLabel.text = copyProvider.getCopyForId("loginInputTitle") + "!";
                    break;
                case priceBannerSWFLoader:
                    priceBannerSWFLoader.addEventListener(MouseEvent.CLICK, onPriceBannerClick);
                    break;
                case versionLabel:
                    versionLabel.text = copyProvider.getCopyForId("versionLabel", {versionNumber: FlexGlobals.topLevelApplication.versionNumber});
                    break;
                case copyrightLabel:
                    copyrightLabel.text = copyProvider.getCopyForId("copyright");
                    break;
            }
        }

        protected override function getCurrentSkinState():String {
            // gh#1307
            if (this.isDemo)
                return "demo";

            return "normal";
        }

        protected function onPriceBannerClick(event:MouseEvent):void {
            var url:String = copyProvider.getCopyForId("demoPriceURL");
            navigateToURL(new URLRequest(url), "_blank");
        }
    }
}
