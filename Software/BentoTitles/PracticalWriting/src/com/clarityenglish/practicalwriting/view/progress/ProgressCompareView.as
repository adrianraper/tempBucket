package com.clarityenglish.practicalwriting.view.progress {
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.textLayout.vo.XHTML;

import flash.events.Event;

import mx.charts.BarChart;
import mx.charts.CategoryAxis;
import mx.charts.LinearAxis;
import mx.charts.series.BarSeries;
import mx.collections.XMLListCollection;
import mx.containers.Grid;
import mx.events.FlexEvent;

import org.osflash.signals.Signal;

import spark.components.BusyIndicator;
import spark.components.Button;
import spark.components.Label;
import spark.components.List;

public class ProgressCompareView extends BentoView {

    [SkinPart]
    public var chartList:List;

    [SkinPart]
    public var compareInstructionLabel:Label;

    [SkinPart]
    public var mylegendLabel:Label;

    [SkinPart]
    public var everyonelegendLabel:Label;

    [SkinPart]
    public var compareEmptyScoreLabel:Button;

    [SkinPart]
    public var busyIndicator:BusyIndicator;

    private var _everyoneCourseSummaries:Object;
    private var _everyoneCourseSummariesChanged:Boolean;
    private var _isPlatformOnline:Boolean;
    private var isNoData:Boolean;
    private var everyoneUnitScores:Object = new Object();

    /**
     * This can be called from outside the view to make the view display a different course
     *
     * @param XML A course node from the menu
     *
     */

    public function set isPlatformOnline(value:Boolean):void {
        _isPlatformOnline = value;
    }

    [Bindable]
    public function get isPlatformOnline():Boolean {
        return _isPlatformOnline;
    }

    public function set everyoneCourseSummaries(value:Object):void {
        _everyoneCourseSummaries = value;
        _everyoneCourseSummariesChanged = true;
        // Make the array easier to search by unitID later
        for (var i:Number = 0; i < _everyoneCourseSummaries.length; i++) {
            everyoneUnitScores[_everyoneCourseSummaries[i].CourseID] = _everyoneCourseSummaries[i].AverageScore;
        }
        invalidateProperties();
    }

    protected override function updateViewFromXHTML(xhtml:XHTML):void {
        super.updateViewFromXHTML(xhtml);
    }

    protected override function onViewCreationComplete():void {
        super.onViewCreationComplete();

        compareInstructionLabel.text = copyProvider.getCopyForId("compareInstructionLabel");
        mylegendLabel.text = copyProvider.getCopyForId("mylegendLabel");
        everyonelegendLabel.text = copyProvider.getCopyForId("everyonelegendLabel");
        compareEmptyScoreLabel.label = copyProvider.getCopyForId("compareEmptyScoreLabel");
    }

    protected override function commitProperties():void {
        super.commitProperties();

        if (menu && _everyoneCourseSummariesChanged) {
            // alice: Flag for empty score
            isNoData = true;

            // Merge the my and everyone summary into some XML and return a list collection of the course nodes
            var xml:XML = <progress />;

            for each (var courseNode:XML in menu.course) {
                var everyoneAverageScore:Number = (everyoneUnitScores[courseNode.@id]) ? everyoneUnitScores[courseNode.@id] : 0;
                xml.appendChild(<course caption={courseNode.@caption} myAverageScore={courseNode.@averageScore} everyoneAverageScore={everyoneAverageScore} index={courseNode.childIndex()}/>);
                if (courseNode.@averageScore > 0 || everyoneAverageScore > 0) {
                    isNoData = false;
                }
            }
            chartList.dataProvider = new XMLListCollection(xml.course);

            if (isNoData) {
                compareEmptyScoreLabel.visible = true;
            } else {
                compareEmptyScoreLabel.visible = false;
            }
        }
    }
}
}