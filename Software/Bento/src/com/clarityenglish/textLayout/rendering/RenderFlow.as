package com.clarityenglish.textLayout.rendering {
	import com.clarityenglish.textLayout.elements.FloatableTextFlow;
	import com.clarityenglish.textLayout.events.RenderFlowEvent;
	import com.clarityenglish.textLayout.util.TLFUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flashx.textLayout.compose.FlowDamageType;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.elements.OverflowPolicy;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.events.UpdateCompleteEvent;
	
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.ResizeEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.Group;
	import spark.components.ResizeMode;
	import spark.core.SpriteVisualElement;
	
	use namespace mx_internal;
	
	[Event(name="renderFlowUpdateComplete", type="com.clarityenglish.textLayout.events.RenderFlowEvent")]
	[Event(name="textFlowCleared", type="com.clarityenglish.textLayout.events.RenderFlowEvent")]
	public class RenderFlow extends UIComponent {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public var node:XML;
		
		private var _textFlow:FloatableTextFlow;
		
		private var childRenderFlows:Vector.<RenderFlow>;
		
		public var containingBlock:RenderFlow;
		
		public var inlineGraphicElementPlaceholder:InlineGraphicElement;
		
		public function RenderFlow(textFlow:FloatableTextFlow = null) {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			childRenderFlows = new Vector.<RenderFlow>();
			
			this.textFlow = textFlow;
		}
		
		public function set textFlow(value:FloatableTextFlow):void {
			if (value) {
				if (_textFlow)
					throw new Error("Changing the TextFlow of an existing RenderFlow is not permitted");
				
				_textFlow = value;
				
				// Add TextFlow listeners and make this DisplayObject the container
				_textFlow.addEventListener(UpdateCompleteEvent.UPDATE_COMPLETE, onUpdateComplete, false, 0, true);
				_textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, onInlineGraphicStatusChange, false, 0, true);
				_textFlow.flowComposer.addController(new ContainerController(this, width, NaN));
			}
		}
		
		public function hasTextFlow():Boolean {
			return _textFlow != null;
		}
		
		public function addChildRenderFlow(childRenderFlow:RenderFlow):void {
			// Maintain bi-directional relationship
			childRenderFlow.containingBlock = this;
			
			// Add the child render flow to the list (used so we know what the children are without having to go through the whole display list)
			childRenderFlows.push(childRenderFlow);
			
			// Finally actually add it to the display list
			addChild(childRenderFlow);
		}
		
		private function onAddedToStage(event:Event):void {
			if (!_textFlow) {
				log.error("No TextFlow in RenderFlow onAddedToStage");
				return;
			}
		}
		
		protected override function measure():void {
			super.measure();
			
			if (_textFlow)
				measuredHeight = _textFlow.flowComposer.getControllerAt(0).getContentBounds().height
		}
		
		public override function setLayoutBoundsSize(width:Number, height:Number, postLayoutTransform:Boolean = true):void {
			super.setLayoutBoundsSize(width, height, postLayoutTransform);
			
			// Go down the RenderFlow tree sizing the children where possible (i.e. when not dynamic)
			for each (var childRenderFlow:RenderFlow in childRenderFlows) {
				var calculatedWidth:Number;
				switch (childRenderFlow._textFlow.widthType) {
					case FloatableTextFlow.SIZE_FIXED:
						calculatedWidth = childRenderFlow._textFlow.width;
						break;
					case FloatableTextFlow.SIZE_PERCENTAGE:
						calculatedWidth = width * childRenderFlow._textFlow.percentWidth / 100;
						break;
				}
				
				var calculatedHeight:Number;
				switch (childRenderFlow._textFlow.heightType) {
					case FloatableTextFlow.SIZE_FIXED:
						calculatedHeight = childRenderFlow._textFlow.height;
						break;
					case FloatableTextFlow.SIZE_PERCENTAGE:
						calculatedHeight = height * childRenderFlow._textFlow.percentHeight / 100;
						break;
				}
				
				// This recurses down the tree
				childRenderFlow.setLayoutBoundsSize(calculatedWidth, calculatedHeight);
			}
			
			if (_textFlow) {
				// Set the size of the text flow container
				_textFlow.flowComposer.getControllerAt(0).setCompositionSize(width, height);
				
				// Compose and render the text flow
				_textFlow.flowComposer.updateAllControllers();
				
				// At this point the dimensions of the rendered flow are known, so if there is an IGE placeholder on the containing block set any dynamic dimensions
				matchPlaceholderToSize();
				
				drawBorderAndBackground();
			}
		}
		
		/**
		 * Draw the border based of the padding and margin properties.  In fact TLF doesn't implement any margins, only padding, so everything is converted to padding
		 * within FloatableTextFlow and then we perform calculations here in order to draw the border in the middle of the padding/margin (which is really all padding!)
		 * 
		 * Also draw any background colour as the rectangle fill.
		 */
		private function drawBorderAndBackground():void {
			var hasBorder:Boolean = (_textFlow.borderStyle != FloatableTextFlow.BORDER_STYLE_NONE);
			var hasBackgroundColor:Boolean = (_textFlow.backgroundColor != null);
			
			graphics.clear();
			
			if (inlineGraphicElementPlaceholder && (hasBorder || hasBackgroundColor)) {
				var borderX:Number = _textFlow.marginLeft + _textFlow.borderWidth / 2;
				var borderY:Number = _textFlow.marginTop + _textFlow.borderWidth / 2;
				var borderWidth:Number = inlineGraphicElementPlaceholder.width - _textFlow.marginLeft - _textFlow.marginRight - _textFlow.borderWidth;
				var borderHeight:Number = inlineGraphicElementPlaceholder.height - _textFlow.marginTop - _textFlow.marginBottom - _textFlow.borderWidth;
				
				graphics.lineStyle(_textFlow.borderWidth, _textFlow.borderColor, (hasBorder) ? 1 : 0);
				
				if (hasBackgroundColor)
					graphics.beginFill(_textFlow.backgroundColor);
				
				graphics.drawRoundRect(borderX, borderY, borderWidth, borderHeight, _textFlow.borderRadius, _textFlow.borderRadius);
				
				if (hasBackgroundColor)
					graphics.endFill();
			}
		}
		
		/**
		 * The sets the size of the placeholder for this component based on the sizing type and the dimensions, which allows the parent TextFlow to layout
		 * the floats correctly.
		 * 
		 * @param width
		 * @param height
		 */
		private function matchPlaceholderToSize():void {
			if (containingBlock && inlineGraphicElementPlaceholder) {
				var placeholderWidth:Number = 0;
				var placeholderHeight:Number = 0;
				
				switch (_textFlow.widthType) {
					case FloatableTextFlow.SIZE_FIXED:
						placeholderWidth = _textFlow.width;
						break;
					case FloatableTextFlow.SIZE_PERCENTAGE:
						placeholderWidth = width;
						break;
					case FloatableTextFlow.SIZE_DYNAMIC:
						placeholderWidth = _textFlow.flowComposer.getControllerAt(0).getContentBounds().width;
						break;
				}
				
				switch (_textFlow.heightType) {
					case FloatableTextFlow.SIZE_FIXED:
						placeholderHeight = _textFlow.height;
						break;
					case FloatableTextFlow.SIZE_PERCENTAGE:
						placeholderHeight = height;
						break;
					case FloatableTextFlow.SIZE_DYNAMIC:
						placeholderHeight = _textFlow.flowComposer.getControllerAt(0).getContentBounds().height;
						break;
				}
				
				// Set the placeholder size
				inlineGraphicElementPlaceholder.width = placeholderWidth;
				inlineGraphicElementPlaceholder.height = placeholderHeight;
			}
		}
		
		/**
		 * Go through the child RenderFlows ensuring that they are positioned over their placeholder IGEs
		 * 
		 * @param event
		 */
		protected function onUpdateComplete(event:UpdateCompleteEvent):void {
			for each (var childRenderFlow:RenderFlow in childRenderFlows) {
				if (childRenderFlow.inlineGraphicElementPlaceholder) {
					if (childRenderFlow.inlineGraphicElementPlaceholder.graphic.parent) {
						// Convert the position of the placeholder to the coordinate space of the RenderFlow
						var pos:Point = childRenderFlow.inlineGraphicElementPlaceholder.graphic.localToGlobal(new Point(0, 0));
						pos = globalToLocal(pos);
						
						// If we are using relative positioning apply the transform
						if (childRenderFlow._textFlow.position == FloatableTextFlow.POSITION_RELATIVE)
							pos.offset(childRenderFlow._textFlow.left, childRenderFlow._textFlow.top);
						
						// Apply the position to the child
						childRenderFlow.x = pos.x;
						childRenderFlow.y = pos.y;
					}
				}
			}
			
			// Invalidate the size of the component in case it has changed
			invalidateSize();
			
			// If this is the top-level RenderFlow (this will be the only one with no containingBlock) then tell the parent that it may
			// need to lay this out.  Specifically this will make scrollbars work properly.
			if (!containingBlock)
				invalidateParentSizeAndDisplayList();
			
			// Dispatch a RenderFlow version of the event in bubbling mode so that anything listening for it on the top level RenderFlow can respond
			dispatchEvent(new RenderFlowEvent(RenderFlowEvent.RENDER_FLOW_UPDATE_COMPLETE, true, false, event.textFlow, event.controller));
		}
		
		/**
		 * When a graphic resource (i.e. an img tag) is loaded we need to layout the textflow again as the geometry will have changed
		 * 
		 * @param event
		 */
		protected function onInlineGraphicStatusChange(event:StatusChangeEvent):void {
			if (event.status == InlineGraphicElementStatus.READY || event.status == InlineGraphicElementStatus.SIZE_PENDING) {
				var textFlow:TextFlow = event.target as TextFlow;
				_textFlow.flowComposer.damage(0, _textFlow.textLength, FlowDamageType.GEOMETRY);
				_textFlow.flowComposer.updateAllControllers();
				
				// Invalidate the size of this component so any higher level chrome can resize itself accordingly
				invalidateSize();
			}
		}
		
		/**
		 * When the RenderFlow is removed from the stage remove all listeners and nullify everything so that it can be garbage collected
		 *
		 * @param event
		 */
		private function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			childRenderFlows = null;
			containingBlock = null;
			
			if (_textFlow) {
				_textFlow.removeEventListener(UpdateCompleteEvent.UPDATE_COMPLETE, onUpdateComplete);
				_textFlow.removeEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, onInlineGraphicStatusChange);
				
				dispatchEvent(new RenderFlowEvent(RenderFlowEvent.TEXT_FLOW_CLEARED, true, false, _textFlow));
				
				_textFlow.flowComposer.removeAllControllers();
				_textFlow.formatResolver = null;
				_textFlow = null;
			}
		}
		
		/**
		 * Format the contents of the RenderFlow in a human-readable string for debugging
		 * 
		 * @return 
		 */
		public override function toString():String {
			return (TLFUtil.dumpTextFlow(_textFlow));
		}
	
	}
}
