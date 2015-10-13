package com.clarityenglish.practicalwriting.view.progress {
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.bento.view.progress.ui.ProgressCourseButtonBar;
import com.clarityenglish.common.model.interfaces.CopyProvider;
import com.clarityenglish.practicalwriting.view.progress.event.StackedBarMouseOutEvent;
import com.clarityenglish.practicalwriting.view.progress.event.StackedBarMouseOverEvent;
import com.clarityenglish.practicalwriting.view.progress.ui.StackedCircleWedgeChart;
import com.clarityenglish.textLayout.vo.XHTML;

import flash.events.MouseEvent;
import mx.collections.ListCollectionView;
import mx.collections.XMLListCollection;

import org.davekeen.util.StringUtils;
import org.osflash.signals.Signal;

import spark.components.DataGroup;
import spark.components.Label;
import spark.components.VGroup;
import spark.events.IndexChangeEvent;

public class ProgressAnalysisView extends BentoView {
    [SkinPart(required="true")]
    public var stackedChart:StackedCircleWedgeChart;

    [SkinPart(required="true")]
    public var analysisTimeLabel:Label;

    [SkinPart(required="true")]
    public var durationDataGroup:DataGroup;

    [SkinPart]
    public var circleWedgeCourseLabel:Label;

    [SkinPart]
    public var analyseInstructionLabel:Label;

    [SkinPart]
    public var circleWedgeLabel:Label;

    [SkinPart]
    public var minLabel:Label;

    [SkinPart]
    public var totalLabel:Label;

    [SkinPart]
    public var totalDurationLabel:Label;

    [SkinPart]
    public var totalMinLabel:Label;

    [SkinPart]
    public var totalTimeLabel:Label;

    [SkinPart]
    public var totalTimeNumberLabel:Label;

    [SkinPart]
    public var totalTimeMinLabel:Label;

    [SkinPart]
    public var timeWedgeVGroup:VGroup;

    [SkinPart]
    public var totalTimeWedgeVGroup:VGroup;

    [Bindable]
    public var courseListCollection:ListCollectionView;

    public function getCopyProvider():CopyProvider {
        return copyProvider;
    }

    // Alice: for TB
    protected override function updateViewFromXHTML(xhtml:XHTML):void {
        super.updateViewFromXHTML(xhtml);

        var courseXMLList:XMLList = new XMLList(menu.course);

        stackedChart.dataProvider = new  XMLListCollection(menu.course).toArray().reverse();
        stackedChart.colours = getStyle("pieChartFillColor");

        courseListCollection = new XMLListCollection(menu.course);

        var duration:Number = 0;
        for each (var item:XML in menu.course) {
            var itemDuration:Number = new Number(item.@duration)
            duration += Math.floor(itemDuration / 60);
        }
        totalDurationLabel.text = String(duration);

        totalTimeNumberLabel.text = String(duration);
    }

    protected override function onViewCreationComplete():void {
        super.onViewCreationComplete();

        totalLabel.text = copyProvider.getCopyForId("totalLabel");
        totalMinLabel.text = copyProvider.getCopyForId("minLabel");
        totalTimeLabel.text = copyProvider.getCopyForId("totalTimeLabel");
        totalTimeMinLabel.text = copyProvider.getCopyForId("minLabel");
        minLabel.text = copyProvider.getCopyForId("minLabel");
        circleWedgeLabel.text = copyProvider.getCopyForId("circleWedgeInstructionLabel");
    }

    protected override function commitProperties():void {
        super.commitProperties();

    }

    protected override function partAdded(partName:String, instance:Object):void {
        super.partAdded(partName, instance);

        switch (instance) {
            case stackedChart:
                // set the field we will be drawing
                stackedChart.field = "duration";
                stackedChart.addEventListener(StackedBarMouseOverEvent.WEDGE_OVER, onStackedBarMouseOver);
                stackedChart.addEventListener(StackedBarMouseOutEvent.WEDGE_OUT, onStackedBarMouseOut);
                stackedChart.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
                break;
        }
    }

    protected override function getCurrentSkinState():String {
        return super.getCurrentSkinState();
    }

    protected function onStackedBarMouseOver(event:StackedBarMouseOverEvent):void {
        totalTimeWedgeVGroup.visible = false;
        // gh#1092
        var duration:Number = menu.course.(@caption == event.caption).@duration;
        var index:Number = menu.course.(@caption == event.caption).childIndex();

        analysisTimeLabel.text = String(Math.floor(duration / 60) );
        analysisTimeLabel.setStyle('color', getStyle('pieChartFillColor')[index]);

        circleWedgeCourseLabel.text = event.caption;
        circleWedgeCourseLabel.setStyle('color', getStyle('pieChartFillColor')[index]);

        minLabel.setStyle('color', getStyle('pieChartFillColor')[index]);

        timeWedgeVGroup.visible = true;
    }

    protected function onStackedBarMouseOut(event:StackedBarMouseOutEvent):void {
        timeWedgeVGroup.visible = false;
        totalTimeWedgeVGroup.visible = true;
    }

    protected function onMouseOut(event:MouseEvent):void {
        totalTimeWedgeVGroup.visible = true;
    }
}
}