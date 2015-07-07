package com.clarityenglish.rotterdam.view.unit.widgets {
	import com.clarityenglish.bento.view.DynamicView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.MouseEvent;
	
	import mx.events.ResizeEvent;
	
	import spark.components.Button;
	
	/**
	 * Note that the widget embeds the DynamicView directly and so doesn't use ExerciseMediator/ExerciseView at all.
	 */
	public class AuthoringWidget extends AbstractWidget {
		
		[SkinPart]
		public var startAgainButton:Button;
		
		[SkinPart]
		public var markingButton:Button;
		
		[SkinPart]
        public var feedbackButton:Button;

        [SkinPart]
        public var dynamicView:DynamicView;

        // gh#413
        private var _hasExerciseFeedback:Boolean;
        private var _hasQuestionFeedback:Boolean;

        [Bindable]
        public function get hasExerciseFeedback():Boolean {
            return _hasExerciseFeedback;
        }

        public function set hasExerciseFeedback(value:Boolean):void {
            _hasExerciseFeedback = value;
        }
        [Bindable]
        public function get hasQuestionFeedback():Boolean {
            return _hasQuestionFeedback;
        }

        public function set hasQuestionFeedback(value:Boolean):void {
            _hasQuestionFeedback = value;
        }

        public function AuthoringWidget() {
			super();
			
			// Add a top priority, capture phase, click listener which switches exercise before anything else has a chance to happen #885
			addEventListener(MouseEvent.CLICK, onMouseClick, true, int.MAX_VALUE);
		}
		
		protected override function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);
			
			removeEventListener(MouseEvent.CLICK, onMouseClick);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case dynamicView:
					if (!_xml.hasOwnProperty("@tempid")) // THIS IS TEMPORARY
						reloadContents();
					break;
				case markingButton:
					markingButton.addEventListener(MouseEvent.CLICK, onShowMarking);
					markingButton.label = copyProvider.getCopyForId("exerciseMarkingButton");
					break;
                case feedbackButton:
                    feedbackButton.addEventListener(MouseEvent.CLICK, function():void {
                        // gh#413
                        if (hasExerciseFeedback) {
                            showFeedback.dispatch();
                        } else {
                            showFeedbackReminder.dispatch(copyProvider.getCopyForId("feedbackClickAnswersMsg"));
                        }} );
                    feedbackButton.label = copyProvider.getCopyForId("exerciseFeedbackButton");
                    break;
            }
		}
		
		protected override function validateUnitListLayout(e:Event=null):void {
			super.validateUnitListLayout(e);
			
			// Reload the widget if the span has changed (this means that dragging to a new column will *not* reload the contents)
			if (e.type == "spanAttrChanged")
				reloadContents()
		}
		
		protected function onMouseClick(e:Event):void {
			// Switch exercise
			if (dynamicView.xhtml is Exercise)
				exerciseSwitch.dispatch(dynamicView.xhtml as Exercise);
		}
		
		protected function onShowMarking(e:MouseEvent):void {
			// Mark exercise
			if (dynamicView.xhtml is Exercise)
                // gh#1256 Send the view so marking can be aligned
				showMarking.dispatch(dynamicView.xhtml as Exercise, dynamicView);
		}
		
		/**
		 * gh#919 - creating a new Href causes the view to reload its contents
		 */
		public override function reloadContents():void {
			dynamicView.href = menuXHTMLHref.createRelativeHref(Href.EXERCISE, _xml.@href, true);
		}
		
	}
	
}
