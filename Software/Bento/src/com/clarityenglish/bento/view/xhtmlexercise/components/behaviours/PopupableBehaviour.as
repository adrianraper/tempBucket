package com.clarityenglish.bento.view.xhtmlexercise.components.behaviours {
	import com.clarityenglish.bento.view.xhtmlexercise.events.FeedbackEvent;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Model;
	import com.clarityenglish.bento.vo.content.model.answer.Feedback;
	import com.clarityenglish.textLayout.components.behaviours.AbstractXHTMLBehaviour;
	import com.clarityenglish.textLayout.components.behaviours.IXHTMLBehaviour;
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.IEventDispatcher;
	import flash.net.sendToURL;
	
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.FlowElementMouseEvent;
	import flashx.textLayout.tlf_internal;
	
	import org.davekeen.util.Closure;
	
	import spark.components.Group;
	
	public class PopupableBehaviour extends AbstractXHTMLBehaviour implements IXHTMLBehaviour {
		
		public function PopupableBehaviour(container:Group) {
			super(container);
		}
		
		public function onTextFlowUpdate(textFlow:TextFlow):void { }
		
		public function onCreateChildren():void { }
		
		public function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void {
			var exercise:Exercise = xhtml as Exercise;
			
			if (!exercise.hasModel())
				return;
			
			for each (var popupNode:XML in exercise.model.popups) {
				for each (var clickNodeSource:XML in Model.sourceToNodes(exercise, popupNode.@click)) {
					var flowElement:FlowElement = flowElementXmlBiMap.getFlowElement(clickNodeSource);
					if (flowElement) {
						var eventMirror:IEventDispatcher = flowElement.tlf_internal::getEventMirror();
						if (eventMirror) {
							eventMirror.addEventListener(FlowElementMouseEvent.CLICK, Closure.create(this, onClick, popupNode.@source.toString()));
						} else {
							log.error("Attempt to bind a click handler to non-leaf element {0}", flowElement);
						}
					}
				}
			}
		}
		
		public function onTextFlowClear(textFlow:TextFlow):void { }
		
		private function onClick(e:FlowElementMouseEvent, source:String):void {
			var feedback:Feedback = new Feedback(<feedback source={source} />);
			container.dispatchEvent(new FeedbackEvent(FeedbackEvent.FEEDBACK_SHOW, feedback, true));
		}
		
	}
}