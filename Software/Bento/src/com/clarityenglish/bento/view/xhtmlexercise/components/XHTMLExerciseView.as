package com.clarityenglish.bento.view.xhtmlexercise.components {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.marking.events.MarkingEvent;
	import com.clarityenglish.bento.view.xhtmlexercise.IExerciseView;
	import com.clarityenglish.bento.view.xhtmlexercise.events.MarkingOverlayEvent;
	import com.clarityenglish.bento.view.xhtmlexercise.events.SectionEvent;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.Answer;
	import com.clarityenglish.bento.vo.content.model.answer.AnswerMap;
	import com.clarityenglish.bento.vo.content.model.answer.NodeAnswer;
	import com.clarityenglish.bento.vo.content.model.answer.TextAnswer;
	import com.clarityenglish.textLayout.components.AudioPlayer;
	import com.clarityenglish.textLayout.components.XHTMLRichText;
	import com.clarityenglish.textLayout.elements.InputElement;
	import com.clarityenglish.textLayout.elements.SelectElement;
	import com.clarityenglish.textLayout.elements.TextComponentElement;
	import com.clarityenglish.textLayout.util.TLFUtil;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.geom.Rectangle;
	
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.TextFlow;
	
	import mx.controls.SWFLoader;
	import mx.core.mx_internal;
	
	import spark.components.Group;
	
	[Event(name="questionAnswered", type="com.clarityenglish.bento.view.xhtmlexercise.events.SectionEvent")]
	public class XHTMLExerciseView extends BentoView implements IExerciseView {
		
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
		
		public function stopAllAudio():void {
			AudioPlayer.stopAllAudio();
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
				// TODO: This is crazy inefficient!  Instead build up the text flows that have changed and do them once each at the end.
				TLFUtil.markFlowElementFormatChanged(answerElement);
				answerElement.getTextFlow().flowComposer.updateAllControllers();
				break;
			}
		}
		
		public function markAnswerMap(question:Question, answerMap:AnswerMap, isShowAnswers:Boolean = false):void {
			for each (var key:Object in answerMap.keys) {
				var answer:Answer = answerMap.get(key);
				var answerNode:XML = key as XML;
				var answerElement:FlowElement = getFlowElement(answerNode);
				
				var sourceNodes:Vector.<XML>;
				
				// If we are in show answers then clear any existing icons for this question (MarkableIconsBehaviour)
				if (isShowAnswers) answerElement.getTextFlow().dispatchEvent(new MarkingOverlayEvent(MarkingOverlayEvent.FLOW_ELEMENT_UNMARKED, answerElement));
				
				// For some questions deselect all other nodes
				if (question.isMutuallyExclusive()) {
					for each (var allAnswers:NodeAnswer in question.answers) {
						for each (var otherSource:XML in allAnswers.getSourceNodes(exercise)) {
							var otherSourceElement:FlowElement = getFlowElement(otherSource);
							
							// Remove any icon for this answer (MarkableIconsBehaviour)
							answerElement.getTextFlow().dispatchEvent(new MarkingOverlayEvent(MarkingOverlayEvent.FLOW_ELEMENT_UNMARKED, otherSourceElement));
							
							XHTML.removeClasses(otherSource, [ Answer.CORRECT, Answer.INCORRECT, Answer.NEUTRAL ] );
							TLFUtil.markFlowElementFormatChanged(otherSourceElement);
						}
					}
				}
				
				// Fill in the input element with the given answer (if we are using 'show answer' this will fill it in,
				// otherwise this will just fill it in with what is already there and will have no effect)
				if (answerElement is InputElement) {
					var inputElement:InputElement = answerElement as InputElement;
					
					if (answer is TextAnswer) {
						answerNode.text = inputElement.value = (answer as TextAnswer).value;
					} else {
						sourceNodes = (answer as NodeAnswer).getSourceNodes(exercise);
						
						// TODO: This is not putting the flow element into the input; right now this has no impact as the flow element here is used
						// during a live drag and drop and its not possible to drag after marking.  However, keep an eye on this in case things change
						// in the future.
						inputElement.dragDrop(sourceNodes[0], null, sourceNodes[0].toString());
					}
				}
				
				if (answerElement is SelectElement) {
					var selectElement:SelectElement = answerElement as SelectElement;
					
					sourceNodes = (answer as NodeAnswer).getSourceNodes(exercise);
					if (sourceNodes) {
						selectElement.selectedItem = sourceNodes[0];
					} else {
						log.error("Unable to find a correct answer for dropdown {0}", selectElement);
					}
				}
				
				// This is used by MarkableIconsBehaviour
				if (isShowAnswers) {
					// The tick/cross rules when showing answers is slightly different; we tick something you got right, otherwise we do nothing
					if (XHTML.hasClass(answerNode, "selected") && answer.markingClass == Answer.CORRECT) {
						answerElement.getTextFlow().dispatchEvent(new MarkingOverlayEvent(MarkingOverlayEvent.FLOW_ELEMENT_MARKED, answerElement, answer.markingClass));
					}
				} else {
					// Otherwise the tick/cross reflects the marking class
					answerElement.getTextFlow().dispatchEvent(new MarkingOverlayEvent(MarkingOverlayEvent.FLOW_ELEMENT_MARKED, answerElement, answer.markingClass));
				}
				
				// Remove any existing classes and add the result class
				XHTML.removeClasses(answerNode, [ Answer.CORRECT, Answer.INCORRECT, Answer.NEUTRAL ] );
				XHTML.addClass(answerNode, answer.markingClass);
				
				// Refresh the element and update the screen
				// TODO: This is crazy inefficient!  Instead build up the text flows that have changed and do them once each at the end.
				TLFUtil.markFlowElementFormatChanged(answerElement);
				answerElement.getTextFlow().flowComposer.updateAllControllers();
			}
		}
		
		/**
		 * When an exercise has been marked, various things (i.e. drags, inputs, etc) become non-interactive.
		 * 
		 * @param value 
		 */
		public function setExerciseMarked():void {
			// Get all the source node
			var sourceNodes:Vector.<XML> = exercise.model.getAllSourceNodes();
			
			// Combine those with all draggable nodes
			var draggableNodes:Array = exercise.select("*[draggable=true]");
			if (draggableNodes) {
				sourceNodes = sourceNodes.concat(Vector.<XML>(draggableNodes));
			}
			
			// Now go through either adding or removing the disabled class as required.  There may be duplication in the sourceNodes vector,
			// but that doesn't matter as addClass and removeClass will do nothing unless it needs to.
			for each (var node:XML in sourceNodes) {
				var flowElement:FlowElement = getFlowElement(node);
				
				if (flowElement) {
					XHTML.addClass(node, "disabled");
					
					if (flowElement is TextComponentElement)
						(flowElement as TextComponentElement).enabled = false;
					
					// TODO: This is crazy inefficient!  Instead build up the text flows that have changed and do them once each at the end.
					TLFUtil.markFlowElementFormatChanged(flowElement);
					flowElement.getTextFlow().flowComposer.updateAllControllers();
				} else {
					log.error("Cannot find flow element for {0}", node);
				}
			}
		}
		
	}

}