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
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.IEventDispatcher;
	
	import flashx.textLayout.compose.FlowDamageType;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.FlowElementMouseEvent;
	import flashx.textLayout.events.UpdateCompleteEvent;
	import flashx.textLayout.tlf_internal;
	
	import org.davekeen.util.Closure;
	
	import spark.components.Group;
	
	public class AnswerableBehaviour extends AbstractXHTMLBehaviour implements IXHTMLBehaviour {
		
		public function AnswerableBehaviour(container:Group) {
			super(container);
		}
		
		public function onTextFlowUpdate(textFlow:TextFlow):void { }
		
		/*public function onClick(event:MouseEvent, textFlow:TextFlow):void { }*/
		
		public function onCreateChildren():void { }
		
		public function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void {
			var exercise:Exercise = xhtml as Exercise;
			
			if (!exercise.hasModel())
				return;
			
			var source:XML, answer:Answer, eventMirror:IEventDispatcher, inputElement:InputElement;
			
			for each (var question:Question in exercise.model.questions) {
				switch (question.type) {
					case "MultipleChoiceQuestion":
					case "TargetSpottingQuestion":
						// Work out the source flow element(s) and attach click listeners to its event mirror
						for each (answer in question.answers) {
							for each (source in Model.sourceToNodeArray(exercise, answer.source)) {
								var flowElement:FlowElement = flowElementXmlBiMap.getFlowElement(source);
								if (flowElement) {
									eventMirror = flowElement.tlf_internal::getEventMirror();
									
									if (eventMirror) {
										eventMirror.addEventListener(FlowElementMouseEvent.CLICK,
											Closure.create(this, function(e:FlowElementMouseEvent, question:Question, answer:Answer):void {
												log.debug("Click detected on " + question.type);
												container.dispatchEvent(new SectionEvent(SectionEvent.QUESTION_ANSWERED, question, answer, true));
											}, question, answer)
										);
									} else {
										log.error("Attempt to bind a click handler to non-leaf element {0} [question: {1}, answer {2}]", flowElement, question, answer);
									}
								}
							}
						}
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