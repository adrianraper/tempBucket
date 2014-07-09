package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.ExerciseGenerator;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.events.AnswerDeleteEvent;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.events.QuestionDeleteEvent;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.events.CloseEvent;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	public class AuthoringView extends BentoView {
		
		[SkinPart]
		public var questionList:List;
		
		[SkinPart]
		public var answersList:List;
		
		[SkinPart]
		public var addQuestionButton:Button;
		
		[SkinPart]
		public var addAnswerButton:Button;
		
		[SkinPart(required="true")]
		public var okButton:Button;
		
		[SkinPart(required="true")]
		public var cancelButton:Button;
		
		[SkinPart(required="true")]
		public var settingsButton:Button;
		
		[Bindable]
		public var questions:ListCollectionView;
		
		[Bindable]
		public var question:XML;
		
		[Bindable]
		public var answers:ListCollectionView;
		
		public var widgetNode:XML;
		
		public var exerciseSave:Signal = new Signal(XML, XML, Href);
		public var showSettings:Signal = new Signal(Href);
		
		public function get DELETE_ME_XML():XML { return _xhtml.xml; }
		
		protected function get exerciseGenerator():ExerciseGenerator {
			return _xhtml as ExerciseGenerator;
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			questions = new XMLListCollection(exerciseGenerator.questions.*);
			log.debug("Loaded {0} questions from xml", questions.length);
			
			// Update the skin state from the loaded xhtml
			callLater(invalidateSkinState);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case questionList:
					questionList.dragEnabled = questionList.dropEnabled = questionList.dragMoveEnabled = true;
					questionList.addEventListener(IndexChangeEvent.CHANGE, onQuestionSelected);
					questionList.addEventListener(QuestionDeleteEvent.QUESTION_DELETE, onQuestionDeleted);
					break;
				case addQuestionButton:
					addQuestionButton.addEventListener(MouseEvent.CLICK, onQuestionAdded);
					addQuestionButton.label = copyProvider.getCopyForId("addQuestionButton");
					break;
				case answersList:
					// TODO: allowing drag moving on this does weird things, duplicating and deleting answers.  Need to investigate this.
					// answersList.dragEnabled = answersList.dropEnabled = answersList.dragMoveEnabled = true;
					answersList.addEventListener(AnswerDeleteEvent.ANSWER_DELETE, onAnswerDeleted);
					break;
				case addAnswerButton:
					addAnswerButton.addEventListener(MouseEvent.CLICK, onAnswerAdded);
					addAnswerButton.label = copyProvider.getCopyForId("addAnswerButton");
					break;
				case okButton:
					okButton.addEventListener(MouseEvent.CLICK, onOkButton);
					okButton.label = copyProvider.getCopyForId("okButton");
					break;
				case cancelButton:
					cancelButton.addEventListener(MouseEvent.CLICK, onCancelButton);
					cancelButton.label = copyProvider.getCopyForId("cancelButton");
					break;
				case settingsButton:
					settingsButton.addEventListener(MouseEvent.CLICK, onSettingsButton);
					settingsButton.label = copyProvider.getCopyForId("settingsButton");
					break;
			}
		}
		
		protected function onQuestionSelected(event:IndexChangeEvent):void {
			question = questionList.selectedItem;
			answers = new XMLListCollection(question.answers.answer);
		}
		
		protected function onQuestionAdded(event:Event):void {
			if (questions && exerciseGenerator && exerciseGenerator.hasSettingParam("exerciseType")) {
				questions.addItem(
					<{exerciseGenerator.getSettingParam("exerciseType")}>
						<question />
						<answers />
						<feedback />
					</{exerciseGenerator.getSettingParam("exerciseType")}>
				);
			}
		}
		
		protected function onQuestionDeleted(event:QuestionDeleteEvent):void {
			if (questions) {
				var idx:int = questions.getItemIndex(event.question);
				if (idx >= 0) questions.removeItemAt(idx);
			}
		}
		
		protected function onAnswerAdded(event:Event):void {
			if (answers) {
				answers.addItem(<answer correct='true' />);
			}
		}
		
		protected function onAnswerDeleted(event:AnswerDeleteEvent):void {
			if (answers) {
				var idx:int = answers.getItemIndex(event.answer);
				if (idx >= 0) answers.removeItemAt(idx);
			}
		}
		
		protected function onOkButton(event:MouseEvent):void {
			exerciseSave.dispatch(widgetNode, _xhtml.xml, _xhtml.href);
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
		protected function onCancelButton(event:MouseEvent):void {
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
		protected function onSettingsButton(event:MouseEvent):void {
			showSettings.dispatch(href);
		}
		
		/**
		 * The skin state is made up of <exerciseType>_<layoutType>.  So for example, MultipleChoiceQuestion_questions, or GapFillQuestion_text.
		 */
		protected override function getCurrentSkinState():String {
			if (exerciseGenerator && exerciseGenerator.hasSettingParam("exerciseType") && exerciseGenerator.hasSettingParam("questionNumberingEnabled")) {
				return exerciseGenerator.getSettingParam("exerciseType") + "_" + (exerciseGenerator.hasSettingParam("questionNumberingEnabled") ? "questions" : "text");
			} else {
				return super.getCurrentSkinState();
			}
		}
		
	}
}