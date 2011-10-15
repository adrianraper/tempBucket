package com.clarityenglish.bento.view.xhtmlexercise.components {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.xhtmlexercise.events.SectionEvent;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.answer.Answer;
	import com.clarityenglish.bento.vo.content.model.answer.NodeAnswer;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.textLayout.components.XHTMLRichText;
	import com.clarityenglish.textLayout.elements.InputElement;
	import com.clarityenglish.textLayout.util.TLFUtil;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flashx.textLayout.elements.FlowElement;
	
	import spark.components.Group;
	
	[Event(name="questionAnswered", type="com.clarityenglish.bento.view.xhtmlexercise.events.SectionEvent")]
	public class XHTMLExerciseView extends BentoView {
		
		/**
		 * All the supported sections should be listed here.  They must also be defined below as required or optional skin parts.  The naming
		 * convention must be as follows:
		 * 
		 * For each section the containing group (i.e. the thing that should be hidden if there is no content) should be named {section}Group
		 * and the ExerciseRichText that displays the content should be named {section}RichText.
		 */
		private static const SUPPORTED_SECTIONS:Array = [ "header", "noscroll", "body", "readingText" ];
		
		/**
		 * These sections are required in all skins
		 */		
		[SkinPart(type="spark.components.Group", required="true")]
		public var headerGroup:Group;
		
		[SkinPart(type="com.clarityenglish.textLayout.components.XHTMLRichText", required="true")]
		public var headerRichText:XHTMLRichText;
		
		[SkinPart(type="spark.components.Group", required="true")]
		public var bodyGroup:Group;
		
		[SkinPart(type="com.clarityenglish.textLayout.components.XHTMLRichText", required="true")]
		public var bodyRichText:XHTMLRichText;
		
		/**
		 * These sections are optional and don't have to be in every skin 
		 */
		[SkinPart(type="spark.components.Group", required="false")]
		public var noscrollGroup:Group;
		
		[SkinPart(type="com.clarityenglish.textLayout.components.XHTMLRichText", required="false")]
		public var noscrollRichText:XHTMLRichText;
		
		[SkinPart(type="spark.components.Group", required="false")]
		public var readingTextGroup:Group;
		
		[SkinPart(type="com.clarityenglish.textLayout.components.XHTMLRichText", required="false")]
		public var readingTextRichText:XHTMLRichText;
		
		/**
		 * Since this view can only be driven by an Exercise provide a helper to typecast it
		 * 
		 * @return 
		 */
		private function get exercise():Exercise {
			return _xhtml as Exercise;
		}
		
		/**
		 * Search through all the sections for the given node
		 * 
		 * @param node
		 * @return 
		 */
		private function getFlowElement(node:XML):FlowElement {
			for each (var sectionName:String in SUPPORTED_SECTIONS) {
				var xhtmlRichText:XHTMLRichText = this[sectionName + "RichText"];
				
				if (xhtmlRichText && xhtmlRichText.flowElementXmlBiMap) {
					var flowElement:FlowElement = xhtmlRichText.flowElementXmlBiMap.getFlowElement(node);
					if (flowElement)
						return flowElement;
				}
			}
			
			return null;
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// If some XHTML makes it this far, its actually an Exercise (at least, it should be)
			var exercise:Exercise = xhtml as Exercise;
			
			// Go through the sections supported by this exercise setting the visibility and contents of each section in the skin
			for each (var sectionName:String in SUPPORTED_SECTIONS) {
				var group:Group = this[sectionName + "Group"];
				var xhtmlRichText:XHTMLRichText = this[sectionName + "RichText"];
				
				if (group && xhtmlRichText) {
					group.visible = group.includeInLayout = (sectionName == "header") ? exercise.hasHeader() : exercise.hasSection(sectionName);
					
					xhtmlRichText.xhtml = exercise;
					xhtmlRichText.nodeId = (sectionName == "header") ? "header" : "#" + sectionName;
				}
			}
		}
		
		public function questionAnswered(question:Question, answer:Answer):void {
			switch (question.type) {
				case Question.MULTIPLE_CHOICE_QUESTION:
				case Question.TARGET_SPOTTING_QUESTION:
					var nodeAnswer:NodeAnswer = answer as NodeAnswer;
					
					// First deselect any other selected answers
					for each (var otherAnswer:NodeAnswer in question.answers) {
						for each (var otherSource:XML in otherAnswer.getSourceNodes(exercise)) {
							XHTML.removeClass(otherSource, "selected");
							TLFUtil.markFlowElementFormatChanged(getFlowElement(otherSource));
						}
					}
					
					// Get the node and FlowElement for the selected answer
					var answerNode:XML = exercise.getElementById(nodeAnswer.source);
					var answerElement:FlowElement = getFlowElement(answerNode);
					
					// Add the selected class
					XHTML.addClass(answerNode, "selected");
					
					// Refresh the element and update the screen
					TLFUtil.markFlowElementFormatChanged(answerElement);
					answerElement.getTextFlow().flowComposer.updateAllControllers();
					break;
			}
		}
		
		public function questionMark(question:Question, answer:Answer):void {
			// At this point there is *no way* to work out which input an answer may have been dropped into if this is a group question.
			// But it doesn't feel like good MVC to pass that very view-specific thing to the model and back.  I suppose an id could be
			// passed back and forth, or perhaps the XML for that node.  Even then its not ideal though.
			
			// P.S. for a non group question it can be figured out using question.source
			
			// - One potential solution is to both submit and mark all the questions at once.
			// - Another is to retrieve the answer here, from the view (or proxy??)
			// - Another is to set the node in the <answer> (this is a bit rubbish too)
			// - Another is to check for the last action in the view (totally rubbish, don't even consider this)
			
			switch (question.type) {
				case Question.MULTIPLE_CHOICE_QUESTION:
				case Question.TARGET_SPOTTING_QUESTION:
					var nodeAnswer:NodeAnswer = answer as NodeAnswer;
					
					// First unmark any other marked answers
					for each (var otherAnswer:NodeAnswer in question.answers) {
						for each (var otherSource:XML in otherAnswer.getSourceNodes(exercise)) {
							XHTML.removeClass(otherSource, Answer.CORRECT);
							XHTML.removeClass(otherSource, Answer.INCORRECT);
							XHTML.removeClass(otherSource, Answer.NEUTRAL);
							TLFUtil.markFlowElementFormatChanged(getFlowElement(otherSource));
						}
					}
					
					// Get the node and FlowElement for the selected answer
					var answerNode:XML = exercise.getElementById(nodeAnswer.source);
					var answerElement:FlowElement = getFlowElement(answerNode);
					
					// Add the selected class
					XHTML.addClass(answerNode, answer.result);
					
					// Refresh the element and update the screen
					TLFUtil.markFlowElementFormatChanged(answerElement);
					answerElement.getTextFlow().flowComposer.updateAllControllers();
					break;
				case Question.GAP_FILL_QUESTION:
				case Question.DRAG_QUESTION:
					var sourceNode:XML = exercise.getElementById(question.source);
					var inputElement:InputElement = getFlowElement(sourceNode) as InputElement;
					
					// Remove any existing classes and add the result class
					XHTML.removeClass(sourceNode, Answer.CORRECT);
					XHTML.removeClass(sourceNode, Answer.INCORRECT);
					XHTML.removeClass(sourceNode, Answer.NEUTRAL);
					
					XHTML.addClass(sourceNode, answer.result);
					
					// Refresh the element and update the screen
					TLFUtil.markFlowElementFormatChanged(inputElement);
					inputElement.getTextFlow().flowComposer.updateAllControllers();
					break;
			}
		}
		
	}

}