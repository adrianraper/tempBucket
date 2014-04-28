package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.content.ExerciseGenerator;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.events.AnswerDeleteEvent;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.events.CloseEvent;
	
	import spark.components.Button;
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	public class AuthoringView extends BentoView {
		
		[SkinPart]
		public var questionList:List;
		
		[SkinPart]
		public var answersList:List;
		
		[SkinPart]
		public var addAnswerButton:Button;
		
		[SkinPart(required="true")]
		public var okButton:Button;
		
		[SkinPart(required="true")]
		public var cancelButton:Button;
		
		[Bindable]
		public var questions:ListCollectionView;
		
		[Bindable]
		public var question:XML;
		
		[Bindable]
		public var answers:ListCollectionView;
		
		public var widgetNode:XML;
		
		public function get DELETE_ME_XML():XML { return _xhtml.xml; }
		
		protected function get exerciseGenerator():ExerciseGenerator {
			return _xhtml as ExerciseGenerator;
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			questions = new XMLListCollection(exerciseGenerator.questions.*);
			
			// Update the skin state from the loaded xhtml
			callLater(invalidateSkinState);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case questionList:
					questionList.dragEnabled = questionList.dropEnabled = questionList.dragMoveEnabled = true;
					questionList.addEventListener(IndexChangeEvent.CHANGE, onQuestionSelected);
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
					okButton.addEventListener(MouseEvent.CLICK, onSelectButton);
					okButton.label = copyProvider.getCopyForId("okButton");
					break;
				case cancelButton:
					cancelButton.addEventListener(MouseEvent.CLICK, onCancelButton);
					cancelButton.label = copyProvider.getCopyForId("cancelButton");
					break;
			}
		}
		
		protected function onQuestionSelected(event:IndexChangeEvent):void {
			question = questionList.selectedItem;
			answers = new XMLListCollection(question.answers.answer);
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
		
		protected function onSelectButton(event:MouseEvent):void {
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
		protected function onCancelButton(event:MouseEvent):void {
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
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