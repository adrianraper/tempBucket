package com.clarityenglish.ielts.view.credits {
import com.clarityenglish.bento.view.base.BentoView;

import mx.collections.XMLListCollection;

import spark.components.Label;

import spark.components.List;

public class CreditsView extends BentoView {

    [SkinPart]
    public var teamList:List;

    [SkinPart]
    public var authenticityLabel:Label;

    [SkinPart]
    public var authenticityList:List;

    [SkinPart]
    public var creditsDeclarationLabel:Label;

    public function CreditsView() {
        trace("the credits view is added");
    }

    protected override function partAdded(partName:String, instance:Object):void {
        super.partAdded(partName, instance);

        switch (instance) {
            case teamList:
                teamList.dataProvider = new XMLListCollection(new XML(copyProvider.getCopyForId("creditsString")).credit.team.member);
                break;
            case authenticityLabel:
                authenticityLabel.text =  copyProvider.getCopyForId("authenticityLabel");
                break;
            case authenticityList:
                authenticityList.dataProvider = new XMLListCollection(new XML(copyProvider.getCopyForId("creditsString")).credit.authenticity.column);
                break;
            case creditsDeclarationLabel:
                creditsDeclarationLabel.text = copyProvider.getCopyForId("creditsDeclarationLabel");
                break;
        }
    }
}
}
