package com.clarityenglish.bento.view.exercise.components.behaviours {
	import com.clarityenglish.bento.view.exercise.events.SectionEvent;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Answer;
	import com.clarityenglish.bento.vo.content.model.Model;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.textLayout.components.behaviours.AbstractXHTMLBehaviour;
	import com.clarityenglish.textLayout.components.behaviours.IXHTMLBehaviour;
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.IEventDispatcher;
	
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.FlowElementMouseEvent;
	import flashx.textLayout.tlf_internal;
	
	import org.davekeen.util.Closure;
	
	import spark.components.Group;
	
	public class AnswerableBehaviour extends AbstractXHTMLBehaviour implements IXHTMLBehaviour {
		
		public function AnswerableBehaviour(container:Group) {
			super(container);
		}
		
		public function onTextFlowUpdate(textFlow:TextFlow):void { }
		
		/*public function onTextFlowClear(textFlow:TextFlow):void { }
		
		public function onClick(event:MouseEvent, textFlow:TextFlow):void { }*/
		
		public function onCreateChildren():void { }
		
		public function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void {
			var exercise:Exercise = xhtml as Exercise;
			
			if (!exercise.hasModel())
				return;
			
			for each (var question:Question in exercise.model.questions) {
				switch (question.type) {
					case "MultipleChoiceQuestion":
					case "TargetSpottingQuestion":
						// Work out the source flow element(s) and attach click listeners to its event mirror
						for each (var answer:Answer in question.answers) {
							for each (var source:XML in Model.sourceToNodeArray(exercise, answer.source)) {
								var flowElement:FlowElement = flowElementXmlBiMap.getFlowElement(source);
								if (flowElement) {
									var eventMirror:IEventDispatcher = flowElement.tlf_internal::getEventMirror();
									
									if (eventMirror) {
										eventMirror.addEventListener(FlowElementMouseEvent.CLICK,
											Closure.create(this, function(e:FlowElementMouseEvent, question:Question, answer:Answer):void {
												log.debug("Click detected on " + question.type);
												container.dispatchEvent(new SectionEvent(SectionEvent.QUESTION_ANSWERED, question, answer));
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
					case "DropDownQuestion":
					case "GapFillQuestion":
						break;
					default:
						log.error("Unknown question type: " + question.type);
				}
			}
		}
		
	}
}
