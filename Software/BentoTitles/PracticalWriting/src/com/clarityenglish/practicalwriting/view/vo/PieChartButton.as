package com.clarityenglish.practicalwriting.view.vo {
import mx.collections.ArrayCollection;

import spark.components.supportClasses.SkinnableComponent;

    public class PieChartButton extends SkinnableComponent {

        [Bindable]
        public var title:String;

        [Bindable]
        public var fillColor:uint;

        [Bindable]
        public var bottomColor:uint;

        [Bindable]
        public var disabledFillColor:uint;

        [Bindable]
        public var disabledBottomColor:uint;

        [Bindable]
        public var backgroundColor:uint;

        [Bindable]
        public var nodeArrayCollection:ArrayCollection;

        private var _node:XML;
        private var _isNodeChange:Boolean;

        public function set node(value:XML):void {
            _node = value;
            _isNodeChange = true;
            invalidateProperties();
        }

        [Bindable]
        public function get node():XML {
            return _node;
        }

        override protected function commitProperties():void {
            super.commitProperties();

            if (_isNodeChange) {
                _isNodeChange = false;

                if (node) {
                    var notDone:Number = Number(node.@of - node.@count);
                    var done:Number = Number(node.@count);
                    var extra:Number = Math.round(Number(node.@of) * 10 / 360);
                    nodeArrayCollection = new ArrayCollection([{coverage: done + extra}, {coverage: notDone }]);

                    title = node.@caption;
                }
            }
        }
    }
}
