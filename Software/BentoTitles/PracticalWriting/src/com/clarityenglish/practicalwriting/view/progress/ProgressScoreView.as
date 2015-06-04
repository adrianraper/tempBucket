package com.clarityenglish.practicalwriting.view.progress {
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.bento.view.progress.ui.ProgressBarRenderer;
import com.clarityenglish.bento.view.progress.ui.ProgressCourseButtonBar;
import com.clarityenglish.textLayout.vo.XHTML;

import flash.events.Event;

import mx.collections.XMLListCollection;

import org.davekeen.util.StringUtils;
import org.osflash.signals.Signal;

import spark.components.Button;
import spark.components.DataGrid;
import spark.components.gridClasses.GridColumn;
import spark.events.IndexChangeEvent;

public class ProgressScoreView extends BentoView {

    [SkinPart(required="true")]
    public var scoreDetailsDataGrid:DataGrid;

    [Bindable]
    public var tableDataProvider:XMLListCollection;

    [SkinPart]
    public var scoreGridC1:GridColumn;

    [SkinPart]
    public var scoreGridC2:GridColumn;

    [SkinPart]
    public var scoreGridC3:GridColumn;

    [SkinPart]
    public var scoreGridC4:GridColumn;

    [SkinPart]
    public var scoreGridC5:GridColumn;

    [SkinPart]
    public var ScoreEmptyScoreLabelButton:Button;

    [Bindable]
    public var courseIndex:Number;

    private var _buildXML:XMLList;
    private var _buildXMLChanged:Boolean;

    /**
     * This can be called from outside the view to make the view display a different course
     *
     * @param XML A course node from the menu
     *
     */
    public function set buildXML(value:XMLList):void {
        _buildXML = value;
        _buildXMLChanged = true;
        invalidateProperties();
    }

    [Bindable]
    public function get buildXML():XMLList {
        return _buildXML;
    }

    protected override function onViewCreationComplete():void {
        super.onViewCreationComplete();

        if (scoreGridC1) scoreGridC1.headerText = copyProvider.getCopyForId("scoreGridC1");
        if (scoreGridC2) scoreGridC2.headerText = copyProvider.getCopyForId("scoreGridC2");
        if (scoreGridC3) scoreGridC3.headerText = copyProvider.getCopyForId("scoreGridC3");
        if (scoreGridC4) scoreGridC4.headerText = copyProvider.getCopyForId("scoreGridC4");
        if (scoreGridC5) scoreGridC5.headerText = copyProvider.getCopyForId("scoreGridC5");
        ScoreEmptyScoreLabelButton.label = copyProvider.getCopyForId("ScoreEmptyScoreLabelButton");
    }

    protected override function updateViewFromXHTML(xhtml:XHTML):void {
        super.updateViewFromXHTML(xhtml);

        buildXML = menu.course.unit.(@["class"] == "learning").exercise.score;

        // Then add the caption from the exercise to the score to make it easy to display in the grid
        // If the grid can do some sort of subheading, then I could do something similar with the unit name too
        for each (var score:XML in buildXML) {
            score.@caption = score.parent().@caption;

            // Caption is different from PracticeZone and others
            if (score.parent().attribute("group").length() > 0) {
                score.@unitCaption = menu.course.(@["class"] == courseClass).groups.group.(@id == score.parent().@group).@caption;
            } else {
                score.@unitCaption = score.parent().parent().@caption;
            }

            // #232. Scores of -1 (nothing to mark) should show in the table as ---
            score.@displayScore = (Number(score.@score) >= 0) ? score.@score : '---';
        }
        tableDataProvider = new XMLListCollection(buildXML);
    }

    protected override function commitProperties():void {
        super.commitProperties();

        if (_buildXMLChanged) {
            _buildXMLChanged = false;
            if (buildXML.length() == 0) {
                ScoreEmptyScoreLabelButton.visible = true;
            } else {
                ScoreEmptyScoreLabelButton.visible = false;
            }
        }
    }
}
}
