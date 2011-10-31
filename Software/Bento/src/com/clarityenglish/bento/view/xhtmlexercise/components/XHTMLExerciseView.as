package com.clarityenglish.bento.view.xhtmlexercise.components {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.xhtmlexercise.events.SectionEvent;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.Answer;
	import com.clarityenglish.bento.vo.content.model.answer.AnswerMap;
	import com.clarityenglish.bento.vo.content.model.answer.NodeAnswer;
	import com.clarityenglish.bento.vo.content.model.answer.TextAnswer;
	import com.clarityenglish.textLayout.components.XHTMLRichText;
	import com.clarityenglish.textLayout.elements.InputElement;
	import com.clarityenglish.textLayout.elements.TextComponentElement;
	import com.clarityenglish.textLayout.util.TLFUtil;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flashx.textLayout.elements.FlowElement;
	
	import org.davekeen.util.ClassUtil;
	
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
		public function get exercise():Exercise {
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
		
		public function selectAnswerMap(question:Question, answerMap:AnswerMap):void {
			// This is only applicable for selectable questions
			if (!question.isSelectable())
				return;
			
			for each (var key:Object in answerMap.keys) {
				var answer:Answer = answerMap.get(key);
				var answerNode:XML = key as XML;
				var answerElement:FlowElement = getFlowElement(answerNode);
				
				// For some questions deselect all other nodes
				if (question.isMutuallyExclusive()) {
					for each (var allAnswers:NodeAnswer in question.answers) {
						for each (var otherSource:XML in allAnswers.getSourceNodes(exercise)) {
							XHTML.removeClass(otherSource, Answer.SELECTED);
							TLFUtil.markFlowElementFormatChanged(getFlowElement(otherSource));
						}
					}
				}
				
				// Add the selected class
				XHTML.addClass(answerNode, Answer.SELECTED);
				
				// Refresh the element and update the screen
				TLFUtil.markFlowElementFormatChanged(answerElement);
				answerElement.getTextFlow().flowComposer.updateAllControllers();
				break;
			}
		}
		
		public function markAnswerMap(question:Question, answerMap:AnswerMap):void {
			for each (var key:Object in answerMap.keys) {
				var answer:Answer = answerMap.get(key);
				var answerNode:XML = key as XML;
				var answerElement:FlowElement = getFlowElement(answerNode);
				
				// For some questions deselect all other nodes
				if (question.isMutuallyExclusive()) {
					for each (var allAnswers:NodeAnswer in question.answers) {
						for each (var otherSource:XML in allAnswers.getSourceNodes(exercise)) {
							XHTML.removeClasses(otherSource, [ Answer.CORRECT, Answer.INCORRECT, Answer.NEUTRAL ] );
							TLFUtil.markFlowElementFormatChanged(getFlowElement(otherSource));
						}
					}
				}
				
				if (answerElement is InputElement) {
					var inputElement:InputElement = answerElement as InputElement;
					
					if (answer is TextAnswer) {
						answerNode.text = inputElement.value = (answer as TextAnswer).value;
					} else {
						var sourceNodes:Vector.<XML> = (answer as NodeAnswer).getSourceNodes(exercise);
						inputElement.dragDrop(sourceNodes[0], sourceNodes[0].toString());
					}
				}
				
				// Remove any existing classes and add the result class
				XHTML.removeClasses(answerNode, [ Answer.CORRECT, Answer.INCORRECT, Answer.NEUTRAL ] );
				XHTML.addClass(answerNode, answer.markingClass);
				
				// Refresh the element and update the screen
				TLFUtil.markFlowElementFormatChanged(answerElement);
				answerElement.getTextFlow().flowComposer.updateAllControllers();
			}
		}
		
		public function showCorrectAnswers():void {
			for each (var question:Question in exercise.model.questions) {
				// Get the first correct answer
				var correctAnswer:Answer;
				for each (var answer:Answer in question.answers) {
					if (answer.score > 0) {
						correctAnswer = answer;
						break;
					}
				}
				
				if (correctAnswer) {
					switch (ClassUtil.getClass(correctAnswer)) {
						case NodeAnswer:
							var nodeAnswer:NodeAnswer = correctAnswer as NodeAnswer;
							for each (var answerNode:XML in nodeAnswer.getSourceNodes(exercise)) {
								var answerElement:FlowElement = getFlowElement(answerNode);
								
								XHTML.removeClasses(answerNode, [ Answer.CORRECT, Answer.INCORRECT, Answer.NEUTRAL ] );
								XHTML.addClass(answerNode, answer.markingClass);
								
								// Refresh the element and update the screen
								TLFUtil.markFlowElementFormatChanged(answerElement);
								answerElement.getTextFlow().flowComposer.updateAllControllers();
							}
							break;
						case TextAnswer:
							var textAnswer:TextAnswer = correctAnswer as TextAnswer;
							for each (var questionNode:XML in question.getSourceNodes(exercise)) {
								var inputElement:InputElement = getFlowElement(questionNode) as InputElement;
								inputElement.value = textAnswer.value;
							}
							break;
						default:
							throw new Error("Unsupported answer type " + correctAnswer);
					}
				}
			}
		}
		
	}

}