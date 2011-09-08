package com.clarityenglish.textLayout.rendering {
	import com.clarityenglish.textLayout.elements.FloatableTextFlow;
	
	import flash.events.Event;
	
	import flashx.textLayout.compose.FlowDamageType;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.events.UpdateCompleteEvent;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.core.SpriteVisualElement;
	
	public class RenderFlow extends SpriteVisualElement {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public var node:XML;
		
		private var _textFlow:FloatableTextFlow;
		
		public var containingBlock:RenderFlow;
		
		public var inlineGraphicElementPlaceholder:InlineGraphicElement;
		
		public function RenderFlow(textFlow:FloatableTextFlow) {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			// Don't allow a null textFlow - this means that code in RenderFlow can rely on there being a _textFlow attribute
			if (!textFlow)
				log.error("A null TextFlow was passed to the RenderFlow");
			
			_textFlow = textFlow;
			
			// Add TextFlow listeners and make this DisplayObject the container
			_textFlow.addEventListener(UpdateCompleteEvent.UPDATE_COMPLETE, onUpdateComplete, false, 0, true);
			_textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, onInlineGraphicStatusChange, false, 0, true);
			_textFlow.flowComposer.addController(new ContainerController(this, width, NaN));
		}
		
		private function onAddedToStage(event:Event):void {
			
		}
		
		public override function get height():Number {
			return (_textFlow) ? _textFlow.flowComposer.getControllerAt(0).getContentBounds().height : 0;
		}
		
		public override function setLayoutBoundsSize(width:Number, height:Number, postLayoutTransform:Boolean = true):void {
			super.setLayoutBoundsSize(width,height,postLayoutTransform);
			
			_textFlow.flowComposer.getControllerAt(0).setCompositionSize(width, NaN);
			_textFlow.flowComposer.updateAllControllers();
		}
		
		protected function onInlineGraphicStatusChange(event:StatusChangeEvent):void {
			if (event.status == InlineGraphicElementStatus.READY || event.status == InlineGraphicElementStatus.SIZE_PENDING) {
				// When the graphic is loaded damage the text flow and lay out its geometry again
				// TODO: Right now this damages the whole document; it would be better to just damage the InlineGraphicElement, but I'm not quite sure how
				// to work out where it is (or its TextFlowLine would be fine too in which case we could use line.damage).
				var textFlow:TextFlow = event.target as TextFlow;
				_textFlow.flowComposer.damage(0, _textFlow.textLength, FlowDamageType.GEOMETRY);
				_textFlow.flowComposer.updateAllControllers();
			}
		}
		
		protected function onUpdateComplete(event:UpdateCompleteEvent):void {
			
		}
		
		/**
		 * When the RenderFlow is removed from the stage remove all listeners and nullify everything so that it can be garbage collected
		 * 
		 * @param event
		 */
		private function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			containingBlock = null;
			
			_textFlow.removeEventListener(UpdateCompleteEvent.UPDATE_COMPLETE, onUpdateComplete);
			_textFlow.removeEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, onInlineGraphicStatusChange);
			
			_textFlow.flowComposer.removeAllControllers();
			_textFlow.formatResolver = null;
			_textFlow = null;
		}
		
	}
}