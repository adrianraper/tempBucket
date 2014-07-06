package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.form.CheckBoxFormItemHandler;
	import com.clarityenglish.bento.form.RadioButtonGroupItemHandler;
	import com.clarityenglish.bento.form.TextFormItemHandler;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.content.ExerciseGenerator;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.CheckBox;
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
		public var feedbackTextArea:TextArea;
		
		[SkinPart]
		public var testModeCheckBox:CheckBox;
		
		[SkinPart]
		public var timerMinutesTextInput:TextInput;
		
		[SkinPart]
		public var showFirstNQuestionsTextInput:TextInput;
		
		[SkinPart]
		public var shuffleAnswersCheckBox:CheckBox;
		
		[SkinPart]
		public var questionByQuestionCheckBox:CheckBox;
		
		public function get DELETE_ME_XML():XML { return _xhtml.xml; }
		
		protected function get exerciseGenerator():ExerciseGenerator {
			return _xhtml as ExerciseGenerator;
		}
		
		override protected function updateViewFromXHTML(xhtml:XHTML):void {
			addFormItemHandler(new RadioButtonGroupItemHandler(numberingGroup, exerciseGenerator.settings.questionNumbering[0],
				[ numbering1RadioButton, numbering2RadioButton, numbering3RadioButton, numbering4RadioButton, numbering5RadioButton ],
				[ "1", "2", "3", "4", "5" ]));
			addFormItemHandler(new TextFormItemHandler(questionStartNumberTextInput, exerciseGenerator.settings.questionStartNumber[0]));
			addFormItemHandler(new RadioButtonGroupItemHandler(markingTypeGroup, exerciseGenerator.settings.markingType[0],
				[ delayedMarkingRadioButton, instantMarkingRadioButton ],
				[ "delayed", "instant" ]));
			addFormItemHandler(new RadioButtonGroupItemHandler(answerMarkersGroup, exerciseGenerator.settings.answerNumbering[0],
				[ answerMarker1RadioButton, answerMarker2RadioButton, answerMarker3RadioButton, answerMarker4RadioButton, answerMarker5RadioButton],
				[ "1", "2", "3", "4", "5" ]));
			addFormItemHandler(new CheckBoxFormItemHandler(shuffleAnswersCheckBox, exerciseGenerator.settings.shuffleAnswers[0]));
			addFormItemHandler(new TextFormItemHandler(feedbackTextArea, exerciseGenerator.settings.exerciseFeedbackText[0]));
			addFormItemHandler(new CheckBoxFormItemHandler(exerciseFeedbackCheckBox, exerciseGenerator.settings.exerciseFeedbackEnabled[0]));
			addFormItemHandler(new CheckBoxFormItemHandler(testModeCheckBox, exerciseGenerator.settings.testMode[0]));
			addFormItemHandler(new TextFormItemHandler(timerMinutesTextInput, exerciseGenerator.settings.timerMinutes[0]));
			addFormItemHandler(new TextFormItemHandler(showFirstNQuestionsTextInput, exerciseGenerator.settings.showFirstNQuestions[0]));
			addFormItemHandler(new CheckBoxFormItemHandler(questionByQuestionCheckBox, exerciseGenerator.settings.questionByQuestionEnabled[0]));
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case okButton:
					okButton.addEventListener(MouseEvent.CLICK, onOkButton);
					okButton.label = copyProvider.getCopyForId("okButton");
					break;
				case questionStartNumberTextInput:
					questionStartNumberTextInput.restrict = "0-9";
					break
			}
		}
		
		protected function onOkButton(event:MouseEvent):void {
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
	}
}