package com.clarityenglish.practicalwriting.view.progress {
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.textLayout.vo.XHTML;

import mx.charts.PieChart;
import mx.charts.chartClasses.Series;
import mx.charts.series.PieSeries;

import mx.collections.ArrayCollection;
import mx.collections.XMLListCollection;

import spark.components.Group;

import spark.components.Label;

public class ProgressCoverageView extends BentoView {

        [SkinPart]
        public var coverageInstructionLabel:Label;

        [SkinPart]
        public var pieChartGroup:Group;

        [Bindable]
        public var nodeArrayCollection:ArrayCollection = new ArrayCollection();

        protected override function updateViewFromXHTML(xhtml:XHTML):void {
            super.updateViewFromXHTML(xhtml);

            for each (var course:XML in menu.course) {
                var notDone:Number = Number(course.@of - course.@count);
                var done:Number = Number(course.@count);
                var colorArray:Array = getStyle("pieChartFillColor");
                nodeArrayCollection.addItem([{coverage: done}, {coverage: notDone}, {caption: course.@caption, color: colorArray[course.childIndex()]}]);
            }
        }

        protected override function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);

            switch (instance) {
                case coverageInstructionLabel:
                    coverageInstructionLabel.text = copyProvider.getCopyForId("coverageInstructionLabel");
                    break;
            }
        }
    }
}
