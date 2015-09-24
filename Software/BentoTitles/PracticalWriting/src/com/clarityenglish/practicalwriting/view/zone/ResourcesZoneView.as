package com.clarityenglish.practicalwriting.view.zone {
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.bento.vo.Href;
import com.clarityenglish.textLayout.vo.XHTML;

import flash.events.Event;

import mx.collections.XMLListCollection;

import spark.components.List;

public class ResourcesZoneView extends BentoView {

    [SkinPart]
    public var studySheetList:List;

    [SkinPart]
    public var sampleEssayList:List;

    public function ResourcesZoneView() {
        super();

        actionBarVisible = false;
    }

    public override function set data(value:Object):void {
        super.data = value;

        dispatchEvent(new Event("dataChange"));
    }

    [Bindable(event="dataChange")]
    public function get studySheetListXMLListCollction():XMLListCollection {
        return data ? new XMLListCollection(data.unit.(attribute("class") == "resources").exercise.(attribute("group") == "1")): null;
    }

    [Bindable(event="dataChange")]
    public function get sampleEssayXMLListCollection():XMLListCollection {
        return data ? new XMLListCollection(data.unit.(attribute("class") == "resources").exercise.(attribute("group") == "2")): null;
    }

    [Bindable(event="dataChange")]
    public function get modelAnswerXMLListCollection():XMLListCollection {
        return data ? new XMLListCollection(data.unit.(attribute("class") == "resources").exercise.(attribute("group") == "3")): null;
    }

    [Bindable(event="dataChange")]
    public function get transcriptXMLListCollection():XMLListCollection {
        return data ? new XMLListCollection(data.unit.(attribute("class") == "resources").exercise.(attribute("group") == "4")): null;
    }
}
}
