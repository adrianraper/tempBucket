package com.clarityenglish.bento.view.xhtmlexercise.components.behaviours {
	import com.clarityenglish.bento.view.xhtmlexercise.events.AudioStackEvent;
	import com.clarityenglish.bento.view.xhtmlexercise.events.MarkingButtonEvent;
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
		
		private var _isMarked:Boolean;
		private var isFirstLoad:Boolean = true;
		private var audioStack:Vector.<AudioElement> = new Vector.<AudioElement>();
		private var delayDisplayAudioStack:Vector.<AudioElement> = new Vector.<AudioElement>();
		
		public function get isMarked():Boolean {
			return _isMarked;
		}
		
		public function set isMarked(value:Boolean):void {
			if (_isMarked != value) {
				_isMarked = value;
			}
		}
		
		public function AudioFeedbackBehaviour(container:Group) {
			super(container);
		}
		
		public function onCreateChildren():void
		{
		}
		
		public function onTextFlowUpdate(textFlow:TextFlow):void {
			if (!textFlow.hasEventListener(MarkingButtonEvent.MARK_BUTTON_CLICKED)) textFlow.addEventListener(MarkingButtonEvent.MARK_BUTTON_CLICKED, onMarkButtonClicked);
			
			if (isFirstLoad && getAudioElements(textFlow).length > 0) {
				for each (var componentElement:IComponentElement in getAudioElements(textFlow)) {
					var audioElement:AudioElement = componentElement as AudioElement;  
					if (!audioElement.hasComponent()) {
						audioElement.createComponent();
					}
					audioStack.push(audioElement);
				}
				container.dispatchEvent(new AudioStackEvent(AudioStackEvent.Audio_Stack_Ready, audioStack, true));
				isFirstLoad = false;
			}

			for each (var delayAudioElement:AudioElement in delayDisplayAudioStack) {				
				var containingBlock:RenderFlow = delayAudioElement.getTextFlow().flowComposer.getControllerAt(0).container as RenderFlow;
				if (!delayAudioElement.hasComponent()) {
					delayAudioElement.controls = "compact";
					delayAudioElement.createComponent();
					containingBlock.addChild(delayAudioElement.getComponent());
				} else {
					delayAudioElement.removeCompoment();
					delayAudioElement.controls = "compact";
					delayAudioElement.createComponent();
					containingBlock.addChild(delayAudioElement.getComponent());
					var delayAudioPlayer:AudioPlayer = delayAudioElement.getComponent() as AudioPlayer;
				}
				
				// Position and size the component in line with its underlying text
				var bounds:Rectangle = delayAudioElement.getElementBounds();
				if (bounds) {
					if (!isNaN(bounds.width)) delayAudioElement.getComponent().width = bounds.width;
					if (!isNaN(bounds.height)) delayAudioElement.getComponent().height = bounds.height;
					delayAudioElement.getComponent().x = bounds.x;
					delayAudioElement.getComponent().y = bounds.y - 1; // for some reason -1 is necessary to get everything to line up
					
					// Make the component visible, unless hideChrome is set in which case hide the component leaving the underlying area visible
					delayAudioElement.getComponent().visible = !delayAudioElement.hideChrome;
				}
			}
			delayDisplayAudioStack.splice(0,delayDisplayAudioStack.length);
		}
		
		public function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void
		{
		}
		
		public function onTextFlowClear(textFlow:TextFlow):void {
			textFlow.removeEventListener(MarkingButtonEvent.MARK_BUTTON_CLICKED, onMarkButtonClicked);
			
			delayDisplayAudioStack.splice(0,delayDisplayAudioStack.length);
		}
		
		protected function onMarkButtonClicked (event:MarkingButtonEvent):void {
			delayDisplayAudioStack.push(event.delayAudioElement);
		}
		
		private function getAudioElements(textFlow:TextFlow):Array {
			var floatableTextFlow:FloatableTextFlow = textFlow as FloatableTextFlow;
			
			// Get all the elements that we will overlay
			if (floatableTextFlow) {
				return [ ].concat(
					floatableTextFlow.getElementsByClass(AudioElement));
			}
			
			return null;
		}
	}
}