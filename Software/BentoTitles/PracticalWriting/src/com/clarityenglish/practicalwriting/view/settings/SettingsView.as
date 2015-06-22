package com.clarityenglish.practicalwriting.view.settings {
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.controls.video.VideoSelector;
import com.clarityenglish.textLayout.vo.XHTML;

import flash.events.Event;

import flash.events.FocusEvent;

import mx.collections.ArrayCollection;
import mx.collections.XMLListCollection;

import org.osflash.signals.Signal;

import spark.components.Label;

public class SettingsView extends BentoView {

        [SkinPart]
        public var videoSelector:VideoSelector;

        [SkinPart]
        public var videoLabel:Label;

        public var channelCollection:ArrayCollection;

        public var channelSave:Signal = new Signal(Number);

        private var course:XMLList;

        public function SettingsView() {
            actionBarVisible = false;
        }

        protected override function updateViewFromXHTML(xhtml:XHTML):void {
            super.updateViewFromXHTML(xhtml);

            course = xhtml..menu.(@id == productCode).course;
        }

        protected override function commitProperties():void {
            super.commitProperties();

            if (videoSelector) {
                var settingVideoXML:XML = _xhtml..course[0].unit[0].exercise[0];
                videoSelector.href = href;
                videoSelector.channelCollection = channelCollection;
                // gh#1100
                videoSelector.videoCollection = new XMLListCollection(new XMLList(<item href={settingVideoXML.@href} />));
                videoSelector.placeholderSource = href.rootPath + "/" + settingVideoXML.@videoPoster;
            }
        }

        protected override function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);

            switch(instance) {
                case videoSelector:
                    videoSelector.channelList.addEventListener(FocusEvent.FOCUS_OUT, onChannelListFocusOut);
                    break;
                case videoLabel:
                    videoLabel.text = copyProvider.getCopyForId("videoLabel");
                    break;
            }
        }

        protected function onChannelListFocusOut(event:Event):void {
            trace("channel list selected index: "+videoSelector.channelList.selectedIndex);
            channelSave.dispatch(videoSelector.channelList.selectedIndex);
        }

    }
}
