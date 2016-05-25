package com.clarityenglish.ielts.view.zone.ui {
import spark.components.Button;

public class ExamPracticeButton extends Button{

    [Bindable]
    public var thumbnailSource:String;

    [Bindable]
    public var textBackgroundColor:uint;

    [Bindable]
    public var isBottomLeftRound:Boolean;

    [Bindable]
    public var isBottomRightRound:Boolean;

    public function ExamPracticeButton() {
    }
}
}
