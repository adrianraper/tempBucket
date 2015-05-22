package com.clarityenglish.practicalwriting.view.zone {
import org.davekeen.util.StateUtil;

import spark.components.supportClasses.SkinnableComponent;

    public class CompletenessButton extends SkinnableComponent {

        [Bindable]
        public var completeColor:uint;

        [Bindable]
        public var incompleteColor:uint;

        [Bindable]
        public var labelText:String;

        private var _isComplete:Boolean;
        private var _isCompletenessChange:Boolean;
        private var _currentState:String;

        public function CompletenessButton() {
            StateUtil.addStates(this, ['incomplete', 'complete'], true);
        }

        public function set isComplete(value:Boolean):void {
            _isComplete = value;
            _isCompletenessChange = true;
            invalidateProperties();
        }

        [Bindable]
        public function get isComplete():Boolean {
            return _isComplete;
        }

        override protected function commitProperties():void {
            if (_isCompletenessChange) {
                _isCompletenessChange = false;

                if (isComplete) {
                    _currentState = "complete";
                } else {
                    _currentState = "incomplete";
                }
                invalidateSkinState();
            }

            super.commitProperties();
        }

        protected override function getCurrentSkinState():String {
            return _currentState? _currentState : "incomplete";
        }
    }
}