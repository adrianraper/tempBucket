package com.clarityenglish.ielts.view.account.ui {
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import spark.components.Button;

public class StudyGuideButton extends Button {

    [Bindable]
    public var linkSource:String;

    [Bindable]
    public var itemIndex:Number;

    public function StudyGuideButton() {
        super();

        addEventListener(MouseEvent.CLICK, onMouseClick);
    }

    protected function onMouseClick(event:Event){
        var url:String = linkSource;
        navigateToURL(new URLRequest(url), "_blank");
    }
}
}
