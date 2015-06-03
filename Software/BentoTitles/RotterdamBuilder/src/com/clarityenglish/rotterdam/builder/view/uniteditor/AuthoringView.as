package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.ExerciseGenerator;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.events.AnswerDeleteEvent;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.events.AuthoringEvent;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.events.GapEvent;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.events.QuestionDeleteEvent;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.tlf.GapEditManager;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.events.CloseEvent;
	import mx.events.CollectionEvent;
	
	import org.davekeen.util.StringUtils;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.List;
	import spark.components.TextArea;
	import spark.events.IndexChangeEvent;
	
	public class AuthoringView extends BentoView {

		[SkinPart]
		public var questionsLabel:Label;
		
		[SkinPart]
		public var answersLabel:Label;
		
		[SkinPart]
		public var feedbackLabel:Label;

		[SkinPart]
		public var questionTextArea:TextArea;
		
		[SkinPart]
		public var feedbackTextArea:TextArea;
		
		[SkinPart]
		public var addGapButton:Button;
		
		[SkinPart]
		public var clearGapButton:Button;
		
		[SkinPart]
		public var questionList:List;
		
		[SkinPart]
		public var answersList:List;
		
		[SkinPart(required="true")]
		public var okButton:Button;
		
		[SkinPart(required="false")]
		public var cancelButton:Button;
		
		[SkinPart(required="false")]
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
		
		protected override function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			addEventListener(AuthoringEvent.OPEN_SETTINGS, openSettings);
		}

		protected override function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);
			removeEventListener(AuthoringEvent.OPEN_SETTINGS, openSettings);
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
				case questionsLabel:
					instance.text = copyProvider.getCopyForId("authoringQuestionsLabel");
					break;
				case answersLabel:
					instance.text = copyProvider.getCopyForId("authoringAnswersLabel");
					break;
				case feedbackLabel:
					instance.text = copyProvider.getCopyForId("authoringFeedbackLabel");
					break;
				case questionTextArea:
					questionTextArea.addEventListener(Event.CHANGE, function(e:Event):void {
						updateQuestionText();
						checkAutoAddQuestion();
					});
					questionTextArea.prompt = copyProvider.getCopyForId("authoringQuestionPrompt");
					break;
				case addGapButton:
					addGapButton.addEventListener(MouseEvent.CLICK, onAddGap);
					addGapButton.label = copyProvider.getCopyForId("authoringAddGapButton");
					break;
				case clearGapButton:
					clearGapButton.addEventListener(MouseEvent.CLICK, onClearGap);
					clearGapButton.label = copyProvider.getCopyForId("authoringClearGapButton");
					break;
				case questionList:
					questionList.dragEnabled = questionList.dropEnabled = questionList.dragMoveEnabled = true;
					questionList.addEventListener(IndexChangeEvent.CHANGE, onQuestionSelected);
					questionList.addEventListener(QuestionDeleteEvent.QUESTION_DELETE, onQuestionDeleted);
					questionList.requireSelection = true;
					
					// gh#1240 Add a blank question at the end
					addQuestion();
					showQuestion(questions.getItemAt(0) as XML);
					
					break;
				case answersList:
					// TODO: allowing drag moving on this does weird things, duplicating and deleting answers.  Need to investigate this.
					// answersList.dragEnabled = answersList.dropEnabled = answersList.dragMoveEnabled = true;
					answersList.addEventListener(AnswerDeleteEvent.ANSWER_DELETE, onAnswerDeleted);
					break;
				case okButton:
					okButton.addEventListener(MouseEvent.CLICK, onOkButton);
					okButton.label = copyProvider.getCopyForId("authoringOkButton");
					break;
				case cancelButton:
					cancelButton.addEventListener(MouseEvent.CLICK, onCancelButton);
					cancelButton.label = copyProvider.getCopyForId("cancelButton");
					break;
				case settingsButton:
					settingsButton.addEventListener(MouseEvent.CLICK, openSettings);
					settingsButton.label = copyProvider.getCopyForId("settingsButton");
					break;
			}
		}
		
		protected function onQuestionSelected(event:IndexChangeEvent = null):void {
			showQuestion(questionList.selectedItem);
		}
		
		protected function showQuestion(value:XML):void {
			question = value;
			
			if (questionList) questionList.selectedItem = question;
			
			if (question) {
				questionTextArea.textFlow = exerciseGenerator.htmlToTextFlow(question.question);
				questionTextArea.textFlow.interactionManager = new GapEditManager();
				questionTextArea.textFlow.addEventListener(GapEvent.GAP_CREATED, onGapCreated, false, 0, true);
				questionTextArea.textFlow.addEventListener(GapEvent.GAP_REMOVED, onGapRemoved, false, 0, true);
				questionTextArea.textFlow.addEventListener(GapEvent.GAP_SELECTED, onGapSelected, false, 0, true);
				questionTextArea.textFlow.addEventListener(GapEvent.GAP_DESELECTED, onGapDeselected, false, 0, true);
				
				if (exerciseGenerator.exerciseType == Question.MULTIPLE_CHOICE_QUESTION) {
					showAnswers(question.answers.answer);
				} else {
					showAnswers(null); // gh#1018
				}
			} else {
				questionTextArea.textFlow = null;
				showAnswers(null);
			}
		}
		
		protected function showAnswers(value:XMLList):void {
			// Remove any old listeners
			if (answers)
				answers.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onAnswersCollectionChange);
			
			if (value) {
				answers = new XMLListCollection(value);
				answers.addEventListener(CollectionEvent.COLLECTION_CHANGE, onAnswersCollectionChange);
				
				checkAutoAddAnswer();
			} else {
				answers = null;
			}
		}
		
		protected function onAnswersCollectionChange(event:CollectionEvent):void {
			checkAutoAddAnswer();
		}
		
		protected function checkAutoAddQuestion():void {
			// gh#1005 - if this is the last question and we have entered some text then create a new question (but don't select it)
			if (exerciseGenerator.layoutType == ExerciseGenerator.QUESTIONS && StringUtils.trim(questionTextArea.text).length > 0 && questionList.selectedIndex == questions.length - 1)
				addQuestion();
		}
		
		protected function checkAutoAddAnswer():void {
			// gh#1005 - if the last answer isn't empty then add an empty one
			if (answers && (answers.length == 0 || StringUtils.trim(answers.getItemAt(answers.length - 1).toString()).length != 0))
				onAnswerAdded();
			
			if (answers.length > 1)
				for (var n:int = answers.length - 2; n >= 0; n--)
					if (StringUtils.trim(answers.getItemAt(n).toString()).length == 0)
						answers.removeItemAt(n);
			
		}
		
		protected function addQuestion():void {
			if (questions && exerciseGenerator && exerciseGenerator.hasSettingParam("exerciseType")) {
				var question:XML =
					<{exerciseGenerator.getSettingParam("exerciseType")}>
						<question />
						<answers />
						<feedback />
					</{exerciseGenerator.getSettingParam("exerciseType")}>;
				
				// gh#1005 - add a default answer for multiple choice questions
				if (exerciseGenerator.getSettingParam("exerciseType") == Question.MULTIPLE_CHOICE_QUESTION)
					question.answers.setChildren(<answer correct='true' />);
				
				questions.addItem(question);
			}
		}
		
		/** The add gap button was pressed */
		protected function onAddGap(event:Event):void {
			var manager:GapEditManager = questionTextArea.textFlow.interactionManager as GapEditManager;
			manager.createGap();
			updateQuestionText();
		}
		
		/** The clear gap button was pressed */
		protected function onClearGap(e:Event):void {
			var manager:GapEditManager = questionTextArea.textFlow.interactionManager as GapEditManager;
			if (manager.getSelectedGapId()) manager.removeGap(manager.getSelectedGapId());
			updateQuestionText();
		}
		
		protected function onGapCreated(event:GapEvent):void {
			// Create an answers section for the gap
			question.appendChild(
				<answers source={event.gapId}>
					<answer correct="true">{event.gapText}</answer>
				</answers>
			);
			
			onGapSelected(event);
			updateQuestionText();
		}
		
		protected function onGapRemoved(event:GapEvent):void {
			var answer:XMLList = question.answers.(attribute("source") == event.gapId);
			if (answer.length() == 1) delete answer[0];
			
			showAnswers(null);
		}
		
		protected function updateQuestionText():void {
			if (questionList.selectedItem)
				questionList.selectedItem.question.setChildren(new XML("<![CDATA[" + exerciseGenerator.textFlowToHtml(questionTextArea.textFlow) + "]]>"));
		}
		
		protected function onGapSelected(event:GapEvent):void {
			showAnswers(question.answers.(attribute("source") == event.gapId).answer);
		}
		
		protected function onGapDeselected(event:GapEvent):void {
			showAnswers(null);
		}
		
		protected function onQuestionDeleted(event:QuestionDeleteEvent):void {
			// Don't allow the user to delete the last question gh#1005
			if (questions && questions.length > 1) {
				var idx:int = questions.getItemIndex(event.question);
				if (idx >= 0) {
					questions.removeItemAt(idx);
					showQuestion(null);
				}
			}
		}
		
		protected function onAnswerAdded(event:Event = null):void {
			if (answers) answers.addItem(<answer correct='true' />);
		}
		
		protected function onAnswerDeleted(event:AnswerDeleteEvent):void {
			if (answers) {
				var idx:int = answers.getItemIndex(event.answer);
				if (idx >= 0) answers.removeItemAt(idx);
			}
		}
		
		protected function onOkButton(event:MouseEvent):void {
			// Before saving the widget clear out any empty questions
			questions.disableAutoUpdate();
			for (var n:int = questions.length - 1; n >= 0; n--) {
				if (StringUtils.trim(questions.getItemAt(n).question.toString()).length == 0) {
					questions.removeItemAt(n);
				} else {
					var question:XML = questions.getItemAt(n) as XML;
					
					for each (var answer:XML in question.answers.answer) {
						// Delete any empty answers (note that this gets at *all* answer nodes, including when there are multiple ones in gapfill style questions)
						if (StringUtils.trim(answer.toString()).length == 0) delete answer.parent().children()[answer.childIndex()];
						
						// Remove any inverted commas from the answer gh#1039
						answer.setChildren(answer.toString().replace(/"/g, ""));
					}
					
					// #1027 - Now for gap-fill style questions delete any <answers source="..."> which don't have a matching input with that id
					if (exerciseGenerator.exerciseType != Question.MULTIPLE_CHOICE_QUESTION) {
						var questionHTML:XML = new XML(question.question.toString());
						for each (var answers:XML in question.answers) {
							if (questionHTML..input.(@id == answers.@source.toString()).length() == 0) delete answers.parent().children()[answers.childIndex()];
						}
					}
				}
			}
			
			exerciseSave.dispatch(widgetNode, _xhtml.xml, _xhtml.href);
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
		protected function onCancelButton(event:MouseEvent):void {
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
		public function openSettings(event:MouseEvent = null):void {
			showSettings.dispatch(href);
		}
		
		/**
		 * The skin state is made up of <exerciseType>_<layoutType>.  So for example, MultipleChoiceQuestion_questions, or GapFillQuestion_text.
		 */
		protected override function getCurrentSkinState():String {
			if (exerciseGenerator && exerciseGenerator.exerciseType && exerciseGenerator.layoutType) {
				return exerciseGenerator.exerciseType + "_" + exerciseGenerator.layoutType;
			} else {
				return super.getCurrentSkinState();
			}
		}
		
	}
}