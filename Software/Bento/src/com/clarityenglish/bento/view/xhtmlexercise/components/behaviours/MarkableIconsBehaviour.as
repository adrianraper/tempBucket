package com.clarityenglish.bento.view.xhtmlexercise.components.behaviours {
	import com.clarityenglish.bento.view.marking.events.MarkingEvent;
	import com.clarityenglish.bento.view.xhtmlexercise.events.MarkingOverlayEvent;
	import com.clarityenglish.bento.vo.content.model.answer.Answer;
	import com.clarityenglish.textLayout.components.behaviours.AbstractXHTMLBehaviour;
	import com.clarityenglish.textLayout.components.behaviours.IXHTMLBehaviour;
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	import com.clarityenglish.textLayout.elements.AudioElement;
	import com.clarityenglish.textLayout.elements.FloatableTextFlow;
	import com.clarityenglish.textLayout.elements.IComponentElement;
	import com.clarityenglish.textLayout.elements.InputElement;
	import com.clarityenglish.textLayout.elements.SelectElement;
	import com.clarityenglish.textLayout.elements.VideoElement;
	import com.clarityenglish.textLayout.rendering.RenderFlow;
	import com.clarityenglish.textLayout.util.TLFUtil;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.TextFlow;
	
	import org.davekeen.util.PointUtil;
	
	import spark.components.Group;
	
	/**
	 * This behaviour places ticks and crosses in the document.  At present this works using MarkingOverlayEvent - however, this is probably unnecessary
	 * and instead it should be based off the CSS classes which are also used to colour it.  Ideally the icons would also come from CSS allowing different
	 * exercise types to have different icons without hardcoding anything.
	 * 
	 * Having said all that it may be tricky to get CSS classes and information from the TextFlow so perhaps this is the best way after all.  (Unless we
	 * store a reference in onImportComplete which may be ok, but may cause memory leaks...)
	 * 
	 * @author Dave
	 */
	public class MarkableIconsBehaviour extends AbstractXHTMLBehaviour implements IXHTMLBehaviour {
		
		private var flowElementIcons:Dictionary;
		
		public function MarkableIconsBehaviour(container:Group):void {
			super(container);
			
			flowElementIcons = new Dictionary(true);
		}
		
		public function onCreateChildren():void { }
		
		public function onTextFlowUpdate(textFlow:TextFlow):void {
			// Make sure that there is an event listener for this text flow
			if (!textFlow.hasEventListener(MarkingOverlayEvent.FLOW_ELEMENT_MARKED)) textFlow.addEventListener(MarkingOverlayEvent.FLOW_ELEMENT_MARKED, onFlowElementMarked);
			if (!textFlow.hasEventListener(MarkingOverlayEvent.FLOW_ELEMENT_UNMARKED)) textFlow.addEventListener(MarkingOverlayEvent.FLOW_ELEMENT_UNMARKED, onFlowElementUnmarked);
			
			for (var flowElementObj:* in flowElementIcons) {
				var flowElement:FlowElement = flowElementObj as FlowElement;
				var flowElementIcon:FlowElementIcon = flowElementIcons[flowElementObj] as FlowElementIcon;
				
				var containingBlock:RenderFlow = flowElement.getTextFlow().flowComposer.getControllerAt(0).container as RenderFlow;
				
				// If the icon hasn't yet been created then create a new one and add it to the containing block
				if (!flowElementIcon.hasComponent()) {
					flowElementIcon.createComponent();
					containingBlock.addChild(flowElementIcon.getComponent());
				}
				
				// Set the icon properties based on the marking class
				switch (flowElementIcon.markingClass) {
					case Answer.CORRECT:
						flowElementIcon.setIcon(containingBlock.getStyle("correctIcon"), containingBlock.getStyle("correctIconWidth"), containingBlock.getStyle("correctIconHeight"));
						break;
					case Answer.INCORRECT:
						flowElementIcon.setIcon(containingBlock.getStyle("incorrectIcon"), containingBlock.getStyle("incorrectIconWidth"), containingBlock.getStyle("incorrectIconHeight"));
						break;
				}
				
				// Position the component to the right of the flow element, and centered vertically
				var bounds:Rectangle = TLFUtil.getFlowElementBounds(flowElement);
				if (bounds) {
					// Convert the bounds from their original coordinate space to the coordinate space of the container
					bounds = PointUtil.convertRectangleCoordinateSpace(bounds, containingBlock, container);
					
					flowElementIcon.getComponent().x = bounds.right; // marking goes to the right of the component
					//flowElementIcon.getComponent().y = bounds.y - ((flowElementIcon.getComponent().height - bounds.height) / 2); // centre the icon vertically on the component
					flowElementIcon.getComponent().y = bounds.bottom - flowElementIcon.getComponent().height; // centre the icon vertically on the component
					
					flowElementIcon.getComponent().visible = true;
				} else {
					flowElementIcon.getComponent().visible = false;
				}
			}
		}
		
		public function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void { }
		
		public function onTextFlowClear(textFlow:TextFlow):void {
			textFlow.removeEventListener(MarkingOverlayEvent.FLOW_ELEMENT_MARKED, onFlowElementMarked);
			textFlow.removeEventListener(MarkingOverlayEvent.FLOW_ELEMENT_UNMARKED, onFlowElementUnmarked);
			
			for (var flowElementObj:* in flowElementIcons) {
				var flowElementIcon:FlowElementIcon = flowElementIcons[flowElementObj] as FlowElementIcon;
				
				if (flowElementIcon.hasComponent())
					flowElementIcon.removeComponent();
			}
		}
		
		protected function onFlowElementMarked(event:MarkingOverlayEvent):void {
			// Ensure there is only ever one icon per flow element
			if (flowElementIcons[event.flowElement]) flowElementIcons[event.flowElement].removeComponent();
			
			flowElementIcons[event.flowElement] = new FlowElementIcon(event.flowElement, event.markingClass);
		}
		
		protected function onFlowElementUnmarked(event:MarkingOverlayEvent):void {
			var flowElementIcon:FlowElementIcon = flowElementIcons[event.flowElement] as FlowElementIcon; 
			
			if (flowElementIcon) {
				flowElementIcon.removeComponent();
				delete flowElementIcons[event.flowElement];
			}
		}
		
	}
}

import flashx.textLayout.elements.FlowElement;

import mx.controls.SWFLoader;
import mx.core.UIComponent;

class FlowElementIcon {
	
	private var _flowElement:FlowElement;
	
	private var _markingClass:String;
	
	private var _iconComponent:UIComponent;
	
	public function FlowElementIcon(flowElement:FlowElement, markingClass:String) {
		this._flowElement = flowElement;
		this._markingClass = markingClass;
	}
	
	public function get flowElement():FlowElement {
		return _flowElement;
	}
	
	public function get markingClass():String {
		return _markingClass;
	}
	
	public function setIcon(iconClass:Class, iconWidth:int, iconHeight:int):void {
		if (!hasComponent())
			throw new Error("Attempt to set icon properties before the icon component was created");
		
		(_iconComponent as SWFLoader).source = iconClass;
		(_iconComponent as SWFLoader).width = iconWidth;
		(_iconComponent as SWFLoader).height = iconHeight;
	}
	
	public function createComponent():void {
		_iconComponent = new SWFLoader();
	}
	
	public function hasComponent():Boolean {
		return (_iconComponent != null);
	}
	
	public function getComponent():UIComponent {
		return _iconComponent;
	}
	
	public function removeComponent():void {
		_iconComponent.parent.removeChild(_iconComponent);
		_iconComponent = null;
	}
	
}