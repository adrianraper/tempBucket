package com.clarityenglish.practicalwriting.view.progress.ui {
import com.clarityenglish.common.vo.content.Bookmark;

import mx.charts.PieChart;
import mx.charts.series.PieSeries;
import mx.collections.ArrayCollection;
import mx.core.UIComponent;

import skins.practicalwriting.progress.ui.DottedLine;

import spark.components.Group;
import spark.components.Label;

    public class PieChartCoverageComponent extends UIComponent {

        [Bindable]
        public var maxRadius:Number = 509;

        [Bindable]
        public var maxLineWidth:Number = 355;

        protected var pieChartGroup:Group;

        private var pieChartColors:Array = [0x0B789C, 0xE6E7E8];
        private var _nodeArrayCollection:ArrayCollection = new ArrayCollection();
        private var _isNodeArrayCollectionChange:Boolean;

        public function set nodeArrayCollection(value:ArrayCollection):void {
            _nodeArrayCollection = value;
            _isNodeArrayCollectionChange = true;
        }

        [Bindable]
        public function get nodeArrayCollection():ArrayCollection {
            return _nodeArrayCollection;
        }

        protected override function commitProperties():void {
            super.commitProperties();

            if (_isNodeArrayCollectionChange) {
                _isNodeArrayCollectionChange = false;

                pieChartGroup = new Group();
                pieChartGroup.width = maxRadius;
                pieChartGroup.height = maxRadius;
                addChild(pieChartGroup);

                for (var i:uint = 0; i < nodeArrayCollection.length; i++) {
                    var pieChart:PieChart = new PieChart();
                    var pieSeries:PieSeries = new PieSeries();
                    pieChart.dataProvider = nodeArrayCollection.getItemAt(i);
                    pieChart.setStyle("innerRadius", getInnerRadius(maxRadius - i * 35));
                    pieChart.horizontalCenter = 0;
                    pieChart.verticalCenter = 0;
                    pieChart.width = maxRadius - i * 35;
                    pieChart.height = maxRadius - i * 35;
                    pieSeries.startAngle = 90;
                    pieSeries.filters = [];
                    pieSeries.setStyle("fills", pieChartColors);
                    pieSeries.field = "coverage";
                    pieChart.series.push(pieSeries);
                    pieChartGroup.addElement(pieChart);

                    var dottedHLine:DottedLine = new DottedLine();
                    dottedHLine.left = maxRadius * 0.5;
                    dottedHLine.top = 18 + i * 17.5;
                    dottedHLine.width = maxLineWidth - i * 10;
                    dottedHLine.height = 1;
                    dottedHLine.dotWidth = 1;
                    dottedHLine.dotColor = 0x333333;
                    pieChartGroup.addElement(dottedHLine);

                    var dottedCLine:DottedLine = new DottedLine();
                    dottedCLine.rotation = 70;
                    dottedCLine.left = dottedHLine.width + maxRadius * 0.5;
                    dottedCLine.top = 18 + i * 17.5;
                    dottedCLine.width = i * 31;
                    dottedCLine.height = 1;
                    dottedCLine.dotWidth = 1;
                    dottedCLine.dotColor = 0x333333;
                    pieChartGroup.addElement(dottedCLine);

                    var label:Label = new Label();
                    label.text = nodeArrayCollection.getItemAt(i)[2].caption;
                    label.setStyle("color", nodeArrayCollection.getItemAt(i)[2].color);
                    label.setStyle("fontSize", 16);
                    label.left = maxRadius * 0.5 + maxLineWidth + 15;
                    label.top = 15 + 46 * i;
                    pieChartGroup.addElement(label);
                }
            }
        }

        private function getInnerRadius(value:Number):Number {
            return (value - 35) / value;
        }
    }
}
