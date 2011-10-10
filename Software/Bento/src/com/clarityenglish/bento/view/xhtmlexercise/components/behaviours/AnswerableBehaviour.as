package com.clarityenglish.bento.view.xhtmlexercise.components.behaviours {
	import com.clarityenglish.bento.view.xhtmlexercise.events.SectionEvent;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Answer;
	import com.clarityenglish.bento.vo.content.model.Model;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.textLayout.components.behaviours.AbstractXHTMLBehaviour;
	import com.clarityenglish.textLayout.components.behaviours.IXHTMLBehaviour;
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	import com.clarityenglish.textLayout.elements.InputElement;
	import com.clarityenglish.textLayout.elements.TextComponentElement;
	import com.clarityenglish.textLayout.util.TLFUtil;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.IEventDispatcher;
	
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.FlowElementMouseEvent;
	import flashx.textLayout.events.UpdateCompleteEvent;
	import flashx.textLayout.tlf_internal;
	
	import org.davekeen.util.Closure;
	
	import spark.components.Group;
	
	public class AnswerableBehaviour extends AbstractXHTMLBehaviour implements IXHTMLBehaviour {
		
		private var clickableAnswerManager:ClickableAnswerManager;
		
		public function AnswerableBehaviour(container:Group) {
			super(container);
			
			clickableAnswerManager = new ClickableAnswerManager(container);
		}
		
		public function onTextFlowUpdate(textFlow:TextFlow):void { }
		
		/*public function onClick(event:MouseEvent, textFlow:TextFlow):void { }*/
		
		public function onCreateChildren():void { }
		
		public function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void {
			// TODO: This method is becoming a bit of a mess...
			
			var exercise:Exercise = xhtml as Exercise;
			
			if (!exercise.hasModel())
				return;
			
			var source:XML, answer:Answer, eventMirror:IEventDispatcher, inputElement:InputElement, flowElement:FlowElement;
			
			for each (var question:Question in exercise.model.questions) {
				switch (question.type) {
					case "MultipleChoiceQuestion":
					case "TargetSpottingQuestion":
						clickableAnswerManager.onQuestionImportComplete(exercise, question, flowElementXmlBiMap);
						break;
					case "DragQuestion":
					case "GapFillQuestion":
						// The answers for these questions is defined in the model so we need to set the underlying text here
						for each (source in Model.sourceToNodeArray(exercise, question.source)) {
							inputElement = flowElementXmlBiMap.getFlowElement(source) as InputElement;
							if (inputElement) {
								inputElement.text = getLongestAnswerValue(question.answers);
							}
						}
						break;
					case "ErrorCorrectionQuestion":
						for each (source in Model.sourceToNodeArray(exercise, question.source)) {
							inputElement = flowElementXmlBiMap.getFlowElement(source) as InputElement;
							if (inputElement) {
								// Error correction questions start with their text input hidden
								inputElement.hideChrome = true;
								
								// When the user clicks on the text show the component
								eventMirror = inputElement.tlf_internal::getEventMirror();
								
								if (eventMirror) {
									eventMirror.addEventListener(FlowElementMouseEvent.CLICK,
										Closure.create(this, function(e:FlowElementMouseEvent):void {
											log.info("Click detected on an error detection question");
											
											if ((e.flowElement as TextComponentElement).hideChrome) {
												// Set hide chrome to false, and dispatch a fake UPDATE_COMPLETE event to force OverlayBehaviour to redraw its components
												(e.flowElement as TextComponentElement).hideChrome = false;
												
												var tf:TextFlow = e.flowElement.getTextFlow();
												tf.dispatchEvent(new UpdateCompleteEvent(UpdateCompleteEvent.UPDATE_COMPLETE, true, false, tf, tf.flowComposer.getControllerAt(0)));
											}
										})
									);
								} else {
									log.error("Attempt to bind a click handler to non-leaf element {0} [question: {1}, answer {2}]", flowElement, question, answer);
								}
								
							}
						}
						break;
					case "DropDownQuestion":
						break;
					default:
						log.error("Unknown question type: " + question.type);
				}
			}
		}
		
		public function onTextFlowClear(textFlow:TextFlow):void { }
		
		private static function getLongestAnswerValue(answers:Vector.<Answer>):String {
			var longestAnswer:String = "";
			for each (var answer:Answer in answers)
			if (answer.value.length > longestAnswer.length)
				longestAnswer = answer.value;
			
			return longestAnswer;
		}
		
	}
}

import com.clarityenglish.bento.view.xhtmlexercise.events.SectionEvent;
import com.clarityenglish.bento.vo.content.Exercise;
import com.clarityenglish.bento.vo.content.model.Answer;
import com.clarityenglish.bento.vo.content.model.Model;
import com.clarityenglish.bento.vo.content.model.Question;
import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
import com.clarityenglish.textLayout.util.TLFUtil;
import com.clarityenglish.textLayout.vo.XHTML;

import flash.events.IEventDispatcher;

import flashx.textLayout.elements.FlowElement;
import flashx.textLayout.events.FlowElementMouseEvent;
import flashx.textLayout.tlf_internal;

import mx.logging.ILogger;
import mx.logging.Log;

import org.davekeen.util.ClassUtil;
import org.davekeen.util.Closure;

import spark.components.Group;

interface IAnswerManager {
	
}

class AnswerManager {
	
	protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this).replace("$", "-"));
	
	protected var container:Group;
	
	public function AnswerManager(container:Group) {
		this.container = container;
	}
	
}

/**
 * Manager for clickable questions like multiple choice and target spotting
 * 
 * @author Dave
 */
class ClickableAnswerManager extends AnswerManager implements IAnswerManager {
	
	public function ClickableAnswerManager(container:Group) {
		super(container);
	}
	
	public function onQuestionImportComplete(exercise:Exercise, question:Question, flowElementXmlBiMap:FlowElementXmlBiMap):void {
		for each (var answer:Answer in question.answers) {
			for each (var source:XML in Model.sourceToNodeArray(exercise, answer.source)) {
				var flowElement:FlowElement = flowElementXmlBiMap.getFlowElement(source);
				if (flowElement) {
					var eventMirror:IEventDispatcher = flowElement.tlf_internal::getEventMirror();
					if (eventMirror) {
						eventMirror.addEventListener(FlowElementMouseEvent.CLICK, Closure.create(this, onAnswerClick, flowElementXmlBiMap, exercise, question, answer, source));
					} else {
						log.error("Attempt to bind a click handler to non-leaf element {0} [question: {1}, answer {2}]", flowElement, question, answer);
					}
				}
			}
		}
	}
	
	private function onAnswerClick(e:FlowElementMouseEvent, flowElementXmlBiMap:FlowElementXmlBiMap, exercise:Exercise, question:Question, answer:Answer, source:XML):void {
		// First remove selected from all the other answers
		for each (var otherAnswer:Answer in question.answers) {
			for each (var otherSource:XML in Model.sourceToNodeArray(exercise, otherAnswer.source)) {
				XHTML.removeClass(otherSource, "selected");
				TLFUtil.refreshFlowElementFormat(flowElementXmlBiMap.getFlowElement(otherSource), false);
			}
		}
		
		// Then add selected to the chosen answer
		XHTML.addClass(source, "selected");
		
		// Refresh the element
		TLFUtil.refreshFlowElementFormat(e.flowElement);
		
		log.debug("Click detected on " + question.type);
		container.dispatchEvent(new SectionEvent(SectionEvent.QUESTION_ANSWERED, question, answer, true));
	}
	
}