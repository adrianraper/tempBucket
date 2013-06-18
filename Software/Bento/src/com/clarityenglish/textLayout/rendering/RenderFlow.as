package com.clarityenglish.textLayout.rendering {
	import com.clarityenglish.textLayout.elements.FloatableTextFlow;
	import com.clarityenglish.textLayout.events.RenderFlowEvent;
	import com.clarityenglish.textLayout.events.RenderFlowMouseEvent;
	import com.clarityenglish.textLayout.util.TLFUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import flashx.textLayout.compose.FlowDamageType;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.events.UpdateCompleteEvent;
	
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	use namespace mx_internal;
	
	[Event(name="renderFlowUpdateComplete", type="com.clarityenglish.textLayout.events.RenderFlowEvent")]
	[Event(name="textFlowCleared", type="com.clarityenglish.textLayout.events.RenderFlowEvent")]
	[Event(name="renderFlowClick", type="com.clarityenglish.textLayout.events.RenderFlowMouseEvent")]
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
			
			addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
		}
		
		protected override function measure():void {
			super.measure();
			
			if (_textFlow) {
				measuredHeight = _textFlow.flowComposer.getControllerAt(0).getContentBounds().height;
			}
		}
		
		public override function setLayoutBoundsSize(width:Number, height:Number, postLayoutTransform:Boolean = true):void {
			super.setLayoutBoundsSize(width, height, postLayoutTransform);
			
			// Go down the RenderFlow tree sizing the children where possible (i.e. when not dynamic)
			for each (var childRenderFlow:RenderFlow in childRenderFlows) {
				// gh#369 - for now the rule is that fixed widths get passed down
				if (childRenderFlow._textFlow.widthType == FloatableTextFlow.SIZE_DYNAMIC && _textFlow.widthType == FloatableTextFlow.SIZE_FIXED) {
					childRenderFlow._textFlow.width = _textFlow.width - _textFlow.borderLeftWidth - _textFlow.borderRightWidth;
				}
				
				var calculatedWidth:Number;
				switch (childRenderFlow._textFlow.widthType) {
					case FloatableTextFlow.SIZE_FIXED:
						calculatedWidth = childRenderFlow._textFlow.width;
						break;
					case FloatableTextFlow.SIZE_PERCENTAGE:
						calculatedWidth = width * childRenderFlow._textFlow.percentWidth / 100;
						break;
				}
				
				// Implement width for block level elements
				if (childRenderFlow._textFlow.display == FloatableTextFlow.DISPLAY_BLOCK) {
					// TODO: what is this for???
					if (childRenderFlow._textFlow.marginLeft) calculatedWidth -= childRenderFlow._textFlow.marginLeft;
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
				
				// gh#363
				if (childRenderFlow._textFlow.marginTop) calculatedHeight += childRenderFlow._textFlow.marginTop;
				if (childRenderFlow._textFlow.marginRight) calculatedWidth += childRenderFlow._textFlow.marginRight;
				if (childRenderFlow._textFlow.marginBottom) calculatedHeight += childRenderFlow._textFlow.marginBottom;
				if (childRenderFlow._textFlow.marginLeft) calculatedWidth += childRenderFlow._textFlow.marginLeft;
				
				// gh#364
				if (childRenderFlow._textFlow.borderTopWidth) calculatedHeight += childRenderFlow._textFlow.borderTopWidth;
				if (childRenderFlow._textFlow.borderRightWidth) calculatedWidth += childRenderFlow._textFlow.borderRightWidth;
				if (childRenderFlow._textFlow.borderBottomWidth) calculatedHeight += childRenderFlow._textFlow.borderBottomWidth;
				if (childRenderFlow._textFlow.borderLeftWidth) calculatedWidth += childRenderFlow._textFlow.borderLeftWidth;
				
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
						// gh#363
						if (_textFlow.marginRight) placeholderWidth += _textFlow.marginRight;
						if (_textFlow.marginLeft) placeholderWidth += _textFlow.marginLeft;
						break;
					case FloatableTextFlow.SIZE_PERCENTAGE:
						placeholderWidth = width;
						break;
					case FloatableTextFlow.SIZE_DYNAMIC:
						placeholderWidth = _textFlow.flowComposer.getControllerAt(0).getContentBounds().width;
						// gh#363
						if (_textFlow.marginRight) placeholderWidth += _textFlow.marginRight;
						if (_textFlow.marginLeft) placeholderWidth += _textFlow.marginLeft;
						break;
				}
				
				switch (_textFlow.heightType) {
					case FloatableTextFlow.SIZE_FIXED:
						placeholderHeight = _textFlow.height;
						// gh#363
						if (_textFlow.marginTop) placeholderHeight += _textFlow.marginTop;
						if (_textFlow.marginBottom) placeholderHeight += _textFlow.marginBottom;
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
			
			// If this is the top-level RenderFlow (this will be the only one with no containingBlock) then tell the parent that it may
			// need to lay this out.  Specifically this will make scrollbars work properly.  This is done in both onUpdateComplete and 
			// matchPlaceholderToSize which is probably not quite right, but due to the way that invalidate works does no harm.
			if (!containingBlock)
				invalidateParentSizeAndDisplayList();
		}
		
		/**
		 * Draw the border based of the padding and margin properties.  In fact TLF doesn't implement any margins, only padding, so everything is converted to padding
		 * within FloatableTextFlow and then we perform calculations here in order to draw the border in the middle of the padding/margin (which is really all padding!)
		 * 
		 * Also draw any background colour as the rectangle fill.
		 */
		private function drawBorderAndBackground():void {
			var hasBorder:Boolean = _textFlow.hasBorder();
			var hasBackgroundColor:Boolean = (_textFlow.backgroundColor != null);
			
			graphics.clear();
			
			if (inlineGraphicElementPlaceholder && (hasBorder || hasBackgroundColor)) {
				var borderBoxX:Number = _textFlow.marginLeft + _textFlow.borderLeftWidth + _textFlow.borderRightWidth / 2;
				var borderBoxY:Number = _textFlow.marginTop + _textFlow.borderTopWidth + _textFlow.borderBottomWidth / 2;
				var borderBoxWidth:Number = inlineGraphicElementPlaceholder.width - _textFlow.marginLeft - _textFlow.marginRight - ((_textFlow.borderLeftWidth + _textFlow.borderRightWidth) / 2);
				var borderBoxHeight:Number = inlineGraphicElementPlaceholder.height - _textFlow.marginTop - _textFlow.marginBottom - ((_textFlow.borderTopWidth + _textFlow.borderBottomWidth) / 2);
				
				// TODO: Note that unlike a real browser, we don't draw any border-radius unless all edges are shown (this would be complicated to implement and is super rare)
				var borderBoxRadius:Number = (_textFlow.hasAllBorders()) ? _textFlow.borderRadius : 0;
				
				// First draw the background color, if there is one
				if (hasBackgroundColor) {
					graphics.beginFill(_textFlow.backgroundColor);
					graphics.drawRoundRect(borderBoxX, borderBoxY, borderBoxWidth, borderBoxHeight, borderBoxRadius, borderBoxRadius);
					graphics.endFill();
				}
				
				if (hasBorder) {
					if (borderBoxRadius) {
						// If there is a radius then get the stroke style from borderLeft* and just use that for every edge
						graphics.lineStyle(_textFlow.borderLeftWidth, _textFlow.borderLeftColor, 1);
						graphics.drawRoundRect(borderBoxX, borderBoxY, borderBoxWidth, borderBoxHeight, borderBoxRadius, borderBoxRadius);
					} else {
						// Otherwise draw each edge one at a time
						if (_textFlow.borderTopStyle != FloatableTextFlow.BORDER_STYLE_NONE && _textFlow.borderTopWidth > 0) {
							graphics.lineStyle(_textFlow.borderBottomWidth, _textFlow.borderBottomColor, 1);
							graphics.moveTo(borderBoxX, borderBoxY);
							graphics.lineTo(borderBoxX + borderBoxWidth, borderBoxY);
						}
						
						if (_textFlow.borderRightStyle != FloatableTextFlow.BORDER_STYLE_NONE && _textFlow.borderRightWidth > 0) {
							graphics.lineStyle(_textFlow.borderRightWidth, _textFlow.borderRightColor, 1);
							graphics.moveTo(borderBoxX + borderBoxWidth, borderBoxY);
							graphics.lineTo(borderBoxX + borderBoxWidth, borderBoxY + borderBoxHeight);
						}
						
						if (_textFlow.borderBottomStyle != FloatableTextFlow.BORDER_STYLE_NONE && _textFlow.borderBottomWidth > 0) {
							graphics.lineStyle(_textFlow.borderBottomWidth, _textFlow.borderBottomColor, 1);
							graphics.moveTo(borderBoxX, borderBoxY + borderBoxHeight);
							graphics.lineTo(borderBoxX + borderBoxWidth, borderBoxY + borderBoxHeight);
						}
						
						if (_textFlow.borderLeftStyle != FloatableTextFlow.BORDER_STYLE_NONE && _textFlow.borderLeftWidth > 0) {
							graphics.lineStyle(_textFlow.borderLeftWidth, _textFlow.borderLeftColor, 1);
							graphics.moveTo(borderBoxX, borderBoxY);
							graphics.lineTo(borderBoxX, borderBoxY + borderBoxHeight);
						}
					}
				}
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
						
						switch (childRenderFlow._textFlow.position) {
							case FloatableTextFlow.POSITION_RELATIVE:
								// If we are using relative positioning apply the transform gh#374
								if (!isNaN(childRenderFlow._textFlow.left)) pos.x += childRenderFlow._textFlow.left;
								if (!isNaN(childRenderFlow._textFlow.top)) pos.y += childRenderFlow._textFlow.top;
								break;
						}
						
						// Apply the position to the child
						childRenderFlow.x = pos.x;
						childRenderFlow.y = pos.y;
					}
				}
			}
			
			// Invalidate the size of the component in case it has changed
			invalidateSize();
			
			// If this is the top-level RenderFlow (this will be the only one with no containingBlock) then tell the parent that it may
			// need to lay this out.  Specifically this will make scrollbars work properly.  This is done in both onUpdateComplete and 
			// matchPlaceholderToSize which is probably not quite right, but due to the way that invalidate works does no harm.
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
		 * Dispatch click events on the render flow for any observer to react to.  For example, this is used in the DictionaryBehaviour.
		 * 
		 * @param event
		 */
		protected function onClick(event:MouseEvent):void {
			dispatchEvent(new RenderFlowMouseEvent(RenderFlowMouseEvent.RENDER_FLOW_CLICK, _textFlow, event));
		}
		
		/**
		 * When the RenderFlow is removed from the stage remove all listeners and nullify everything so that it can be garbage collected
		 *
		 * @param event
		 */
		private function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			removeEventListener(MouseEvent.CLICK, onClick);
			
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
