package com.clarityenglish.ielts.view.credits {
import com.clarityenglish.bento.view.base.BentoView;

import flashx.textLayout.elements.TextFlow;

import mx.collections.XMLListCollection;

import spark.components.Label;

import spark.components.List;
import spark.components.RichText;
import spark.utils.TextFlowUtil;

public class CreditsView extends BentoView {

    [SkinPart]
    public var teamList:List;

    [SkinPart]
    public var authenticityLabel:Label;

    [SkinPart]
    public var authenticityList:List;

    [SkinPart]
    public var creditsDeclarationLabel:Label;

    //For tablet credits
    [SkinPart]
    public var creditsRichText:RichText;

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
            case creditsRichText:
                var creditsContentString:String = this.copyProvider.getCopyForId("creditsRichText");
                var creditFlow:TextFlow = TextFlowUtil.importFromString(creditsContentString);
                creditFlow.color = "#4E4E4E";
                creditFlow.fontSize = 14;
                creditFlow.lineHeight = 22;
                creditFlow.paragraphSpaceAfter = 12;
                creditsRichText.textFlow = creditFlow;
        }
    }
}
}
