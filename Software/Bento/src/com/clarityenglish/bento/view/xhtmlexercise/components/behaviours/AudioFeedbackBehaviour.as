package com.clarityenglish.bento.view.xhtmlexercise.components.behaviours {
	import com.clarityenglish.bento.view.xhtmlexercise.events.MarkingButtonEvent;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.components.AudioPlayer;
	import com.clarityenglish.textLayout.components.behaviours.AbstractXHTMLBehaviour;
	import com.clarityenglish.textLayout.components.behaviours.IXHTMLBehaviour;
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	import com.clarityenglish.textLayout.elements.AudioElement;
	import com.clarityenglish.textLayout.elements.FloatableTextFlow;
	import com.clarityenglish.textLayout.elements.IComponentElement;
	import com.clarityenglish.textLayout.rendering.RenderFlow;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.geom.Rectangle;
	
	import flashx.textLayout.elements.TextFlow;
	
	import spark.components.Group;
	
	public class AudioFeedbackBehaviour extends AbstractXHTMLBehaviour implements IXHTMLBehaviour {
		private var audioStack:Vector.<AudioElement> = new Vector.<AudioElement>();
		private var feedbackAudioStack:Vector.<AudioElement> = new Vector.<AudioElement>();
		
		public function AudioFeedbackBehaviour(container:Group) {
			super(container);
		}
		
		public function onCreateChildren():void {
		}
		
		public function onTextFlowUpdate(textFlow:TextFlow):void {
			if (!textFlow.hasEventListener(MarkingButtonEvent.MARK_BUTTON_CLICKED)) textFlow.addEventListener(MarkingButtonEvent.MARK_BUTTON_CLICKED, onMarkButtonClicked);
			
			for each (var feedbackAudioElement:AudioElement in feedbackAudioStack) {
				var containingBlock:RenderFlow = feedbackAudioElement.getTextFlow().flowComposer.getControllerAt(0).container as RenderFlow;

				feedbackAudioElement.createComponent();
				
				// in OverlayBehaviour, in order to detect feedback audio we didn't block creating component there but we didn't add the component to the containing block 
				containingBlock.addChild(feedbackAudioElement.getComponent());
				
				// Position and size the component in line with its underlying text
				var bounds:Rectangle = feedbackAudioElement.getElementBounds();
				if (bounds) {
					if (!isNaN(bounds.width)) feedbackAudioElement.getComponent().width = bounds.width;
					if (!isNaN(bounds.height)) feedbackAudioElement.getComponent().height = bounds.height;
					feedbackAudioElement.getComponent().x = bounds.x;
					feedbackAudioElement.getComponent().y = bounds.y - 1; // for some reason -1 is necessary to get everything to line up
					
					// Make the component visible, unless hideChrome is set in which case hide the component leaving the underlying area visible
					feedbackAudioElement.getComponent().visible = !feedbackAudioElement.hideChrome;
				}
			}
			feedbackAudioStack.splice(0,feedbackAudioStack.length);
		}
		
		public function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void {
		}
		
		public function onTextFlowClear(textFlow:TextFlow):void {
			textFlow.removeEventListener(MarkingButtonEvent.MARK_BUTTON_CLICKED, onMarkButtonClicked);
			
			feedbackAudioStack.splice(0,feedbackAudioStack.length);
		}
		
		protected function onMarkButtonClicked (event:MarkingButtonEvent):void {
			feedbackAudioStack.push(event.audioELement);
		}
	}
}