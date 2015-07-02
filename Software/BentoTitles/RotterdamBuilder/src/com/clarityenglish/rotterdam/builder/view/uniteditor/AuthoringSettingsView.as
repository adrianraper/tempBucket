package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.form.CheckBoxFormItemHandler;
	import com.clarityenglish.bento.form.RadioButtonGroupItemHandler;
	import com.clarityenglish.bento.form.TextFormItemHandler;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.content.ExerciseGenerator;
import com.clarityenglish.bento.vo.content.model.Question;
import com.clarityenglish.textLayout.vo.XHTML;

import flash.display.DisplayObject;

import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

import mx.core.UIComponent;

import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.CheckBox;
import spark.components.Group;
import spark.components.Label;
	import spark.components.RadioButton;
	import spark.components.RadioButtonGroup;
	import spark.components.TextArea;
	import spark.components.TextInput;
	
	public class AuthoringSettingsView extends BentoView {
		
		[SkinPart]
		public var okButton:Button;
		
		[SkinPart]
		public var numberingGroup:RadioButtonGroup;
		
		[SkinPart]
		public var numbering1RadioButton:RadioButton;
		
		[SkinPart]
		public var numbering2RadioButton:RadioButton;
		
		[SkinPart]
		public var numbering3RadioButton:RadioButton;
		
		[SkinPart]
		public var numbering4RadioButton:RadioButton;
		
		[SkinPart]
		public var numbering5RadioButton:RadioButton;
		
		[SkinPart]
		public var questionStartNumberTextInput:TextInput;
		
		[SkinPart]
		public var markingTypeGroup:RadioButtonGroup;
		
		[SkinPart]
		public var instantMarkingRadioButton:RadioButton;
		
		[SkinPart]
		public var delayedMarkingRadioButton:RadioButton;
		
		[SkinPart]
		public var answerMarkersGroup:RadioButtonGroup;
		
		[SkinPart]
		public var answerMarker1RadioButton:RadioButton;
		
		[SkinPart]
		public var answerMarker2RadioButton:RadioButton;
		
		[SkinPart]
		public var answerMarker3RadioButton:RadioButton;
		
		[SkinPart]
		public var answerMarker4RadioButton:RadioButton;
		
		[SkinPart]
		public var answerMarker5RadioButton:RadioButton;
		
		[SkinPart]
		public var exerciseFeedbackCheckBox:CheckBox;
		
		[SkinPart]
		public var exerciseFeedbackTextArea:TextArea;
		
		[SkinPart]
		public var testModeCheckBox:CheckBox;
		
        [SkinPart]
		public var timerCheckBox:CheckBox;
		
		[SkinPart]
		public var timerUnitsLabel:Label;
		
		[SkinPart]
		public var questionMarkersLabel:Label;
		
		[SkinPart]
		public var answerMarkersLabel:Label;
		
		[SkinPart]
		public var depthOfWidgetLabel1:Label;
		
		[SkinPart]
		public var depthOfWidgetLabel2:Label;
		
		[SkinPart]
		public var depthOfWidgetLabel3:Label;
		
		[SkinPart]
		public var timerMinutesTextInput:TextInput;
		
		[SkinPart]
		public var showFirstNQuestionsTextInput:TextInput;
		
		[SkinPart]
		public var shuffleAnswersCheckBox:CheckBox;
		
		[SkinPart]
		public var questionStartNumberLabel:Label;
		
		[SkinPart]
		public var markingOptionsLabel:Label;
		
		[SkinPart]
		public var displayOptionsLabel:Label;
		
		[SkinPart]
		public var questionByQuestionCheckBox:CheckBox;

        [SkinPart]
        public var answerMarkers:UIComponent;
		
		public function get DELETE_ME_XML():XML { return _xhtml.xml; }
		
		protected function get exerciseGenerator():ExerciseGenerator {
			return _xhtml as ExerciseGenerator;
		}
		
		override protected function updateViewFromXHTML(xhtml:XHTML):void {
			addFormItemHandler(new RadioButtonGroupItemHandler(numberingGroup, exerciseGenerator.settings.questionNumbering[0],
				[ numbering1RadioButton, numbering2RadioButton, numbering3RadioButton, numbering4RadioButton, numbering5RadioButton ],
				[ "1", "2", "3", "4", "5" ]));
            if (exerciseGenerator.exerciseType == Question.MULTIPLE_CHOICE_QUESTION) {
                answerMarkers.visible = answerMarkers.includeInLayout = true;
                addFormItemHandler(new RadioButtonGroupItemHandler(answerMarkersGroup, exerciseGenerator.settings.answerNumbering[0],
                        [answerMarker1RadioButton, answerMarker2RadioButton, answerMarker3RadioButton, answerMarker4RadioButton, answerMarker5RadioButton],
                        ["3", "4", "1", "7", "6"]));
                addFormItemHandler(new CheckBoxFormItemHandler(shuffleAnswersCheckBox, exerciseGenerator.settings.shuffleAnswers[0]));
            } else {
                answerMarkers.visible = answerMarkers.includeInLayout = false;
            }
			addFormItemHandler(new TextFormItemHandler(questionStartNumberTextInput, exerciseGenerator.settings.questionStartNumber[0]));
			addFormItemHandler(new RadioButtonGroupItemHandler(markingTypeGroup, exerciseGenerator.settings.markingType[0],
				[ delayedMarkingRadioButton, instantMarkingRadioButton ],
				[ "delayed", "instant" ]));
			addFormItemHandler(new CheckBoxFormItemHandler(exerciseFeedbackCheckBox, exerciseGenerator.settings.exerciseFeedbackEnabled[0]));
			addFormItemHandler(new TextFormItemHandler(exerciseFeedbackTextArea, exerciseGenerator.settings.exerciseFeedbackText[0]));
			addFormItemHandler(new TextFormItemHandler(showFirstNQuestionsTextInput, exerciseGenerator.settings.showFirstNQuestions[0]));
            // The following are not used yet
		    addFormItemHandler(new CheckBoxFormItemHandler(testModeCheckBox, exerciseGenerator.settings.testMode[0]));
   			addFormItemHandler(new TextFormItemHandler(timerMinutesTextInput, exerciseGenerator.settings.timerMinutes[0]));
            addFormItemHandler(new CheckBoxFormItemHandler(timerCheckBox, exerciseGenerator.settings.timerEnabled[0]));
			addFormItemHandler(new CheckBoxFormItemHandler(questionByQuestionCheckBox, exerciseGenerator.settings.questionByQuestionEnabled[0]));
            /*
			*/
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case okButton:
					okButton.addEventListener(MouseEvent.CLICK, onOkButton);
					okButton.label = copyProvider.getCopyForId("doneButton");
					break;
				case questionStartNumberTextInput:
					questionStartNumberTextInput.restrict = "0-9";
					break;
				case instantMarkingRadioButton:
					instance.label = copyProvider.getCopyForId("authoringInstantMarking");
					break;
				case delayedMarkingRadioButton:
					instance.label = copyProvider.getCopyForId("authoringDelayedMarking");
					break;
				case numbering1RadioButton:
					instance.label = copyProvider.getCopyForId("questionNumberingFormat1");
					break;
				case numbering2RadioButton:
					instance.label = copyProvider.getCopyForId("questionNumberingFormat2");
					break;
				case numbering3RadioButton:
					instance.label = copyProvider.getCopyForId("questionNumberingFormat3");
					break;
				case numbering4RadioButton:
					instance.label = copyProvider.getCopyForId("questionNumberingFormat4");
					break;
				case numbering5RadioButton:
					instance.label = copyProvider.getCopyForId("questionNumberingFormat5");
					break;
				case answerMarker1RadioButton:
					instance.label = copyProvider.getCopyForId("answerNumberingFormat3");
					break;
				case answerMarker2RadioButton:
					instance.label = copyProvider.getCopyForId("answerNumberingFormat4");
					break;
				case answerMarker3RadioButton:
					instance.label = copyProvider.getCopyForId("answerNumberingFormat1");
					break;
				case answerMarker4RadioButton:
					instance.label = copyProvider.getCopyForId("answerNumberingFormat7");
					break;
				case answerMarker5RadioButton:
					instance.label = copyProvider.getCopyForId("answerNumberingFormat6");
					break;
				case answerMarkersLabel:
					answerMarkersLabel.text = copyProvider.getCopyForId("authoringAnswerMarkersLabel");
					break;
				case questionMarkersLabel:
					questionMarkersLabel.text = copyProvider.getCopyForId("authoringQuestionMarkersLabel");
					break;
				case shuffleAnswersCheckBox:
					shuffleAnswersCheckBox.label = copyProvider.getCopyForId("authoringShuffleAnswers");
					break;
				case questionStartNumberLabel:
					questionStartNumberLabel.text = copyProvider.getCopyForId("authoringQuestionStartNumber");
					break;
				case markingOptionsLabel:
					markingOptionsLabel.text = copyProvider.getCopyForId("authoringMarkingOptions");
					break;
				case displayOptionsLabel:
					displayOptionsLabel.text = copyProvider.getCopyForId("authoringDisplayOptions");
					break;
				case questionByQuestionCheckBox:
					questionByQuestionCheckBox.label = copyProvider.getCopyForId("authoringQuestionByQuestion");
					break;
				case testModeCheckBox:
					testModeCheckBox.label = copyProvider.getCopyForId("authoringTestMode");
					break;
				case timerCheckBox:
					timerCheckBox.label = copyProvider.getCopyForId("authoringTimerCheckBox");
					break;
				case timerUnitsLabel:
					timerUnitsLabel.text = copyProvider.getCopyForId("authoringTimerUnits");
					break;
				case depthOfWidgetLabel1:
                    depthOfWidgetLabel1.text = copyProvider.getCopyForId("authoringDepthOfWidgetLabel1");
					break;
				case depthOfWidgetLabel2:
                    depthOfWidgetLabel2.text = copyProvider.getCopyForId("authoringDepthOfWidgetLabel2");
					break;
				case depthOfWidgetLabel3:
                    depthOfWidgetLabel3.text = copyProvider.getCopyForId("authoringDepthOfWidgetLabel3");
					break;
				case exerciseFeedbackCheckBox:
					exerciseFeedbackCheckBox.label = copyProvider.getCopyForId("authoringExerciseFeedback");
					break;
				case exerciseFeedbackTextArea:
					exerciseFeedbackTextArea.prompt = copyProvider.getCopyForId("authoringExerciseFeedbackPrompt");
					break;
			}
		}
		
		protected function onOkButton(event:MouseEvent):void {
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
	}
}