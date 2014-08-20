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
	import com.clarityenglish.textLayout.util.TLFUtil;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.core.mx_internal;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.List;
	import spark.components.TextArea;
	import spark.events.IndexChangeEvent;
	
	public class AuthoringView extends BentoView {
		
		[SkinPart]
		public var questionTextArea:TextArea;
		
		[SkinPart]
		public var addGapButton:Button;
		
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
		
		[SkinPart(required="false")]
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
			
			this.addEventListener(AuthoringEvent.OPEN_SETTINGS, openSettings);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case questionTextArea:
					questionTextArea.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						/*if (questionList.selectedItem) {
							trace(TLFUtil.dumpTextFlow(questionTextArea.textFlow));
							trace(exerciseGenerator.textFlowToHtml(questionTextArea.textFlow));
							trace("---");
							questionList.selectedItem.question.setChildren(new XML("<![CDATA[" + exerciseGenerator.textFlowToHtml(questionTextArea.textFlow) + "]]>"));
						}*/
						updateQuestionText();
					});
					break;
				case addGapButton:
					addGapButton.addEventListener(MouseEvent.CLICK, onAddGap);
					break;
				case questionList:
					questionList.dragEnabled = questionList.dropEnabled = questionList.dragMoveEnabled = true;
					questionList.addEventListener(IndexChangeEvent.CHANGE, onQuestionSelected);
					questionList.addEventListener(QuestionDeleteEvent.QUESTION_DELETE, onQuestionDeleted);
					questionList.requireSelection = true;
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
					settingsButton.addEventListener(MouseEvent.CLICK, openSettings);
					settingsButton.label = copyProvider.getCopyForId("settingsButton");
					break;
			}
		}
		
		protected function onQuestionSelected(event:IndexChangeEvent = null):void {
			question = questionList.selectedItem;
			
			questionTextArea.textFlow = exerciseGenerator.htmlToTextFlow(question.question);
			questionTextArea.textFlow.interactionManager = new GapEditManager();
			questionTextArea.textFlow.addEventListener(GapEvent.GAP_CREATED, onGapCreated, false, 0, true);
			questionTextArea.textFlow.addEventListener(GapEvent.GAP_SELECTED, onGapSelected, false, 0, true);
			questionTextArea.textFlow.addEventListener(GapEvent.GAP_DESELECTED, onGapDeselected, false, 0, true);
			
			if (exerciseGenerator.exerciseType == Question.MULTIPLE_CHOICE_QUESTION)
				answers = new XMLListCollection(question.answers.answer);
		}
		
		protected function onQuestionAdded(event:Event = null):void {
			if (questions && exerciseGenerator && exerciseGenerator.hasSettingParam("exerciseType")) {
				questions.addItem(
					<{exerciseGenerator.getSettingParam("exerciseType")}>
						<question />
						<answers />
						<feedback />
					</{exerciseGenerator.getSettingParam("exerciseType")}>
				);
			}
			// Immediately select this new question
			// The need for this code will disappear when gh#1005 implemented
			questionList.selectedIndex = questions.length - 1;
			onQuestionSelected();
		}
		
		protected function onAddGap(e:Event):void {
			var manager:GapEditManager = questionTextArea.textFlow.interactionManager as GapEditManager;
			manager.createGap();
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
		
		protected function updateQuestionText():void {
			if (questionList.selectedItem)
				questionList.selectedItem.question.setChildren(new XML("<![CDATA[" + exerciseGenerator.textFlowToHtml(questionTextArea.textFlow) + "]]>"));
		}
		
		protected function onGapSelected(event:GapEvent):void {
			answers = new XMLListCollection(question.answers.(attribute("source") == event.gapId).answer);
		}
		
		protected function onGapDeselected(event:GapEvent):void {
			answers = null;
		}
		
		protected function onQuestionDeleted(event:QuestionDeleteEvent):void {
			if (questions) {
				var idx:int = questions.getItemIndex(event.question);
				if (idx >= 0) questions.removeItemAt(idx);
			}
		}
		
		protected function onAnswerAdded(event:Event = null):void {
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