package com.clarityenglish.bento.view.xhtmlexercise.components.behaviours {
	import com.clarityenglish.bento.view.xhtmlexercise.events.SectionEvent;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.Answer;
	import com.clarityenglish.textLayout.components.behaviours.AbstractXHTMLBehaviour;
	import com.clarityenglish.textLayout.components.behaviours.IXHTMLBehaviour;
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	import com.clarityenglish.textLayout.elements.InputElement;
	import com.clarityenglish.textLayout.elements.TextComponentElement;
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
		
		private var clickableAnswerManager:IAnswerManager;
		private var inputAnswerManager:IAnswerManager;
		private var errorCorrectionAnswerManager:IAnswerManager;
		private var dropDownAnswerManager:IAnswerManager;
		
		public function AnswerableBehaviour(container:Group) {
			super(container);
			
			clickableAnswerManager = new ClickableAnswerManager(container);
			inputAnswerManager = new InputAnswerManager(container);
			errorCorrectionAnswerManager = new ErrorCorrectionAnswerManager(container);
			dropDownAnswerManager = new DropDownAnswerManager(container);
		}
		
		public function onTextFlowUpdate(textFlow:TextFlow):void { }
		
		/*public function onClick(event:MouseEvent, textFlow:TextFlow):void { }*/
		
		public function onCreateChildren():void { }
		
		public function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void {
			var exercise:Exercise = xhtml as Exercise;
			
			if (!exercise.hasModel())
				return;
			
			for each (var question:Question in exercise.model.questions) {
				switch (question.type) {
					case Question.MULTIPLE_CHOICE_QUESTION:
					case Question.TARGET_SPOTTING_QUESTION:
						clickableAnswerManager.onQuestionImportComplete(exercise, question, flowElementXmlBiMap);
						break;
					case Question.DRAG_QUESTION:
					case Question.GAP_FILL_QUESTION:
						inputAnswerManager.onQuestionImportComplete(exercise, question, flowElementXmlBiMap);
						break;
					case Question.ERROR_CORRECTION_QUESTION:
						errorCorrectionAnswerManager.onQuestionImportComplete(exercise, question, flowElementXmlBiMap);
						break;
					case Question.DROP_DOWN_QUESTION:
						dropDownAnswerManager.onQuestionImportComplete(exercise, question, flowElementXmlBiMap);
						break;
					default:
						log.error("Unknown question type: " + question.type);
				}
			}
		}
		
		public function onTextFlowClear(textFlow:TextFlow):void { }
		
	}
}

import com.clarityenglish.bento.view.xhtmlexercise.events.SectionEvent;
import com.clarityenglish.bento.vo.content.Exercise;
import com.clarityenglish.bento.vo.content.model.Question;
import com.clarityenglish.bento.vo.content.model.answer.Answer;
import com.clarityenglish.bento.vo.content.model.answer.NodeAnswer;
import com.clarityenglish.bento.vo.content.model.answer.TextAnswer;
import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
import com.clarityenglish.textLayout.elements.InputElement;
import com.clarityenglish.textLayout.elements.SelectElement;
import com.clarityenglish.textLayout.elements.TextComponentElement;
import com.clarityenglish.textLayout.util.TLFUtil;
import com.clarityenglish.textLayout.vo.XHTML;

import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;
import flash.utils.setTimeout;

import flashx.textLayout.elements.FlowElement;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.FlowElementMouseEvent;
import flashx.textLayout.events.UpdateCompleteEvent;
import flashx.textLayout.tlf_internal;

import mx.events.FlexEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.utils.UIDUtil;

import org.davekeen.util.ClassUtil;
import org.davekeen.util.Closure;

import spark.components.Group;

interface IAnswerManager {

	function onQuestionImportComplete(exercise:Exercise, question:Question, flowElementXmlBiMap:FlowElementXmlBiMap):void;
	
}

class AnswerManager {
	
	protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this).replace("$", "-"));
	
	protected var container:Group;
	
	public function AnswerManager(container:Group) {
		this.container = container;
	}
	
	protected function getLongestAnswerValue(answers:Vector.<Answer>):String {
		var longestAnswer:String = "";
		for each (var answer:Answer in answers) {
			if (answer is TextAnswer) {
				var textAnswer:TextAnswer = answer as TextAnswer;
				if (textAnswer.value.length > longestAnswer.length) {
					longestAnswer = textAnswer.value;
				}
			}
		}
		
		return longestAnswer;
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
		for each (var answer:NodeAnswer in question.answers) {
			for each (var source:XML in answer.getSourceNodes(exercise)) {
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
		container.dispatchEvent(new SectionEvent(SectionEvent.QUESTION_ANSWER, question, answer, source, true));
	}
	
}

class DropDownAnswerManager extends AnswerManager implements IAnswerManager {
	
	public function DropDownAnswerManager(container:Group) {
		super(container);
	}
	
	public function onQuestionImportComplete(exercise:Exercise, question:Question, flowElementXmlBiMap:FlowElementXmlBiMap):void {
		// The answers for these questions is defined in the model so we need to set the underlying text here
		for each (var source:XML in question.getSourceNodes(exercise)) {
			var selectElement:SelectElement = flowElementXmlBiMap.getFlowElement(source) as SelectElement;
			if (selectElement) {
				selectElement.text = getLongestAnswerValue(question.answers);
				
				var eventMirror:IEventDispatcher = selectElement.tlf_internal::getEventMirror();
				if (eventMirror) {
					eventMirror.addEventListener(Event.CHANGE, Closure.create(this, onAnswerSubmitted, exercise, question, source));
				}
			}
		}
	}
	
	private function onAnswerSubmitted(e:Event, exercise:Exercise, question:Question, selectNode:XML):void {
		// Since the event actually comes from the overlaid DropDownList we need to use this tomfoolery to get the associated SelectElement
		var selectElement:SelectElement = e.target.tlf_internal::_element as SelectElement;
		
		// Get the Answer that matches the selected <option> node
		var optionNode:XML = selectElement.selectedItem;
		for each (var answer:NodeAnswer in question.answers) {
			for each (var source:XML in answer.getSourceNodes(exercise)) {
				if (source === optionNode) {
					// Once we find a matching answer dispatch it
					container.dispatchEvent(new SectionEvent(SectionEvent.QUESTION_ANSWER, question, answer, selectNode, true));
					return;
				}
			}
		}
		
		log.error("Unable to find a matching answer for option {0}", optionNode.toXMLString());
	}
	
}

/**
 * Manager for input questions like gapfills or drag and drop
 * 
 * @author Dave
 */
class InputAnswerManager extends AnswerManager implements IAnswerManager {
	
	private var flowElementXmlBiMap:FlowElementXmlBiMap;
	
	public function InputAnswerManager(container:Group) {
		super(container);
	}
	
	public function onQuestionImportComplete(exercise:Exercise, question:Question, flowElementXmlBiMap:FlowElementXmlBiMap):void {
		this.flowElementXmlBiMap = flowElementXmlBiMap;
		
		// The answers for these questions is defined in the model so we need to set the underlying text here
		for each (var source:XML in question.getSourceNodes(exercise)) {
			var inputElement:InputElement = flowElementXmlBiMap.getFlowElement(source) as InputElement;
			if (inputElement) {
				inputElement.text = getLongestAnswerValue(question.answers);
				
				var eventMirror:IEventDispatcher = inputElement.tlf_internal::getEventMirror();
				if (eventMirror) {
					eventMirror.addEventListener(FlexEvent.VALUE_COMMIT, Closure.create(this, onAnswerSubmitted, exercise, question, source));
					eventMirror.addEventListener(MouseEvent.CLICK, Closure.create(this, onAnswerClicked, exercise, question, source));
				}
			}
		}
	}
	
	private function onAnswerSubmitted(e:Event, exercise:Exercise, question:Question, inputNode:XML):void {
		// Since the event actually comes from the overlaid TextInput we need to use this tomfoolery to get the associated InputElement
		var inputElement:InputElement = e.target.tlf_internal::_element as InputElement;
		
		var answerOrString:* = null;
		
		// Ignore empty answers (where there is neither a typed value, nor a dropped node)
		if (inputElement.enteredValue == "" && !inputElement.droppedNode)
			return;
		
		// If there is a dropped node then match it up to an answer if possible
		if (inputElement.droppedNode) {
			for each (var nodeAnswer:NodeAnswer in question.answers) {
				var answerSourceNodes:Vector.<XML> = nodeAnswer.getSourceNodes(exercise);
				if (answerSourceNodes && answerSourceNodes.indexOf(inputElement.droppedNode) > -1) {
					// If the dropped node matches any of the source nodes then this is the matching answer
					answerOrString = nodeAnswer;
					break;
				}
			}
			
			if (!answerOrString) {
				// If the dropped node doesn't match any of the source nodes then we need to make a new answer with the droppedNode as the source.
				// In case the dropped node doesn't have an id then we auto-generate one and add it to the XHTML.
				if (!inputElement.droppedNode.hasOwnProperty("@id"))
					inputElement.droppedNode.@id = "auto-" + UIDUtil.createUID();
				
				// Create a NodeAnswer pointing to the dropped node with a score of 0
				var source:String = inputElement.droppedNode.@id;
				answerOrString = new NodeAnswer(<Answer score="0" source={source} />);
			}
			
			// TODO: THIS ISN'T UPDATING THE DISPLAY, I HAVE NO IDEA WHY.  IT WORKS IF THE SPAN ISN'T IN A FLOAT :(
			/*XHTML.addClass(inputElement.droppedNode, "disabled");
			TLFUtil.markFlowElementFormatChanged(inputElement.droppedFlowElement);
			inputElement.droppedFlowElement.getTextFlow().flowComposer.updateAllControllers();*/
		}
		
		// If this is a true gapfill, with a user entered answer then answerOrString will still be null, in which case we
		// use a String with the value the user has entered.  QuestionStringAnswerCommand will derive the score for this
		// string and create a TextAnswer to pass on to ExerciseProxy. 
		if (!answerOrString)
			answerOrString = inputElement.enteredValue;
		
		container.dispatchEvent(new SectionEvent(SectionEvent.QUESTION_ANSWER, question, answerOrString, inputNode, true));
	}
	
	/**
	 * This is a special case; if an input is disabled then we want to answer the question on a click instead of a value commit.  This is because
	 * once marking has taken place all the inputs will be disabled, but clicking on them should still show feedback.
	 * 
	 * @param e
	 * @param exercise
	 * @param question
	 * @param inputNode
	 */
	private function onAnswerClicked(e:Event, exercise:Exercise, question:Question, inputNode:XML):void {
		// This is only relevant for a disabled node
		if (!XHTML.hasClass(inputNode, "disabled"))
			return;
		
		onAnswerSubmitted(e, exercise, question, inputNode);
	}
	
}

/**
 * Manager for error correction questions.  This is basically exactly the same as a gapfill with some extra functionality to show the input
 * on click, so this manager extends the InputAnswerManager in order to inherit its functionality.
 * 
 * @author Dave
 */
class ErrorCorrectionAnswerManager extends InputAnswerManager implements IAnswerManager {
	
	public function ErrorCorrectionAnswerManager(container:Group) {
		super(container);
	}
	
	override public function onQuestionImportComplete(exercise:Exercise, question:Question, flowElementXmlBiMap:FlowElementXmlBiMap):void {
		super.onQuestionImportComplete(exercise, question, flowElementXmlBiMap)
		
		for each (var source:XML in question.getSourceNodes(exercise)) {
			var inputElement:InputElement = flowElementXmlBiMap.getFlowElement(source) as InputElement;
			if (inputElement) {
				// Error correction questions start with their text input hidden
				inputElement.hideChrome = true;
				
				// When the user clicks on the text show the component
				var eventMirror:IEventDispatcher = inputElement.tlf_internal::getEventMirror();
				if (eventMirror) {
					eventMirror.addEventListener(FlowElementMouseEvent.CLICK, onErrorCorrectionTextClick);
				} else {
					log.error("Attempt to bind a click handler to non-leaf element {0} [question: {1}]", inputElement, question);
				}
			}
		}
	}
	
	private function onErrorCorrectionTextClick(e:FlowElementMouseEvent):void {
		log.info("Click detected on an error detection question");
		
		if ((e.flowElement as TextComponentElement).hideChrome) {
			// Set hide chrome to false, and dispatch a fake UPDATE_COMPLETE event to force OverlayBehaviour to redraw its components
			(e.flowElement as TextComponentElement).hideChrome = false;
			
			var tf:TextFlow = e.flowElement.getTextFlow();
			tf.dispatchEvent(new UpdateCompleteEvent(UpdateCompleteEvent.UPDATE_COMPLETE, true, false, tf, tf.flowComposer.getControllerAt(0)));
		}
	}
	
}