package com.clarityenglish.practicalwriting.view.home {
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.textLayout.vo.XHTML;

import mx.collections.XMLListCollection;

import mx.collections.XMLListCollection;

import org.osflash.signals.Signal;

import spark.components.List;
import spark.events.IndexChangeEvent;

public class HomeView extends BentoView {

        [SkinPart]
        public var courseList:List;

        [Bindable]
        public var courseXMLListCollection:XMLListCollection;

        public var courseSelect:Signal = new Signal(XML);

        public function HomeView() {
            actionBarVisible = false;
        }

        override protected function updateViewFromXHTML(xhtml:XHTML):void {
            super.updateViewFromXHTML(xhtml);

            courseXMLListCollection = new XMLListCollection(xhtml..menu.course);
        }

        override protected function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);

            switch (instance) {
                case courseList:
                    courseList.addEventListener(IndexChangeEvent.CHANGE, onIndexChange);
                    break;
            }
        }

        protected function onIndexChange(event:IndexChangeEvent):void {
            if (event.target.selectedItem)
                courseSelect.dispatch(event.target.selectedItem);
        }
    }
}
