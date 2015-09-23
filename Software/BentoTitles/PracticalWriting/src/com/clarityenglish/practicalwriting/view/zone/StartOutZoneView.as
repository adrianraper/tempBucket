package com.clarityenglish.practicalwriting.view.zone {
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.controls.video.VideoSelector;
import com.clarityenglish.textLayout.vo.XHTML;

import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.collections.XMLListCollection;

import spark.components.Label;

public class StartOutZoneView extends BentoView {

        [SkinPart]
        public var introductionVideoSelector:VideoSelector;

       //[SkinPart]
       // public var startOutLabel:Label;

        public var channelCollection:ArrayCollection;

        private var startOutXML:XML;

        public function StartOutZoneView() {
            super();

            actionBarVisible = false;
        }

        public override function set data(value:Object):void {
            super.data = value;

            dispatchEvent(new Event("dataChange"));
        }

        [Bindable(event="dataChange")]
        public function get videoXMLListCollection():XMLListCollection {
            return data? new XMLListCollection(data.unit.(attribute("class") == "startOut").exercise) : null;
        }

        [Bindable(event="dataChange")]
        public function get placeHolderString():String {
            return data? href.rootPath + "/" + data.unit.(attribute("class") == "startOut").exercise.@videoPoster : null;
        }

        override protected function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);

            switch (instance) {
                case introductionVideoSelector:
                    introductionVideoSelector.href = href;
                    introductionVideoSelector.channelCollection = channelCollection;
                    break;
                /* No need for a label now
                case startOutLabel:
                    startOutLabel.text = copyProvider.getCopyForId("startOutLabel" + data.childIndex());
                    break;
                 */
            }
        }
    }
}
