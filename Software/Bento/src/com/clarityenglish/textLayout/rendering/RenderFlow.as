package com.clarityenglish.textLayout.rendering {
	import com.clarityenglish.textLayout.elements.FloatableTextFlow;
	import com.clarityenglish.textLayout.util.TLFUtil;
	
	import flash.events.Event;
	
	import flashx.textLayout.compose.FlowDamageType;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.events.UpdateCompleteEvent;
	
	import mx.core.mx_internal;
	import mx.events.ResizeEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.ResizeMode;
	import spark.core.SpriteVisualElement;
	
	use namespace mx_internal;
	
	public class RenderFlow extends SpriteVisualElement {
		
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
			resizeMode = ResizeMode.NO_SCALE;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			childRenderFlows = new Vector.<RenderFlow>();
			
			this.textFlow = textFlow;
		}
		
		public function set textFlow(value:FloatableTextFlow):void {
			if (value) {
				_textFlow = value;
				
				// Add TextFlow listeners and make this DisplayObject the container
				_textFlow.addEventListener(UpdateCompleteEvent.UPDATE_COMPLETE, onUpdateComplete, false, 0, true);
				_textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, onInlineGraphicStatusChange, false, 0, true);
				_textFlow.flowComposer.addController(new ContainerController(this, width, NaN));
			}
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
			
			// Set the width based on the TextFlow properties
			if (_textFlow.width) {
				if (_textFlow.isPercentWidth()) {
					log.error("Percent widths not yet supported");
				} else {
					_textFlow.flowComposer.getControllerAt(0).setCompositionSize(_textFlow.width, NaN);
				}
			}
		}
		
		public override function get height():Number {
			return (_textFlow) ? _textFlow.flowComposer.getControllerAt(0).getContentBounds().height : 0;
		}
		
		public override function setLayoutBoundsSize(width:Number, height:Number, postLayoutTransform:Boolean = true):void {
			// TODO: Having this in causes strange visual artifacts when resizing; however, not having it in will probably cause layout issues.
			// Leave it commented for now, but it will probably have to go back in.
			super.setLayoutBoundsSize(width, height, postLayoutTransform);
			
			if (_textFlow) {
				_textFlow.flowComposer.getControllerAt(0).setCompositionSize(width, NaN);
				updateRenderFlowTree();
			}
		}
		
		/**
		 * This simple looking method is the real workhorse, going through the RenderFlow tree heirarchy and rendering all the TextFlows
		 */
		internal function updateRenderFlowTree():void {
			// Walk the tree before doing anything; this ensures that things happen from the deepest node first up to the root last
			for each (var childRenderFlow:RenderFlow in childRenderFlows)
				childRenderFlow.updateRenderFlowTree();
			
			// Compose and render the text flow
			_textFlow.flowComposer.updateAllControllers();
			
			// At this point the width and height of the rendered flow is known, so if there is an IGE placeholder on the containing block set its size
			if (containingBlock && inlineGraphicElementPlaceholder) {
				// If the width is set in the TextFlow then this is fixed width otherwise calculate it dynamically from the content width.
				// TODO: percentage widths
				if (_textFlow.width) {
					inlineGraphicElementPlaceholder.width = _textFlow.width;
				} else {
					inlineGraphicElementPlaceholder.width = _textFlow.flowComposer.getControllerAt(0).getContentBounds().width;
				}
				
				// TODO: css defined heights
				inlineGraphicElementPlaceholder.height = _textFlow.flowComposer.getControllerAt(0).getContentBounds().height;
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
						childRenderFlow.x = childRenderFlow.inlineGraphicElementPlaceholder.graphic.parent.x;
						childRenderFlow.y = childRenderFlow.inlineGraphicElementPlaceholder.graphic.parent.y;
					} else {
						// I'm not sure why the graphic sometimes has no parent; it seems to work anyway
						//log.info("Unable to place render flow as the graphic has no parent");
					}
				}
			}
			
			// Invalidate the size of the component in case it has changed
			invalidateSize();
			
			// If this is the top-level RenderFlow (this will be the only one with no containingBlock) then tell the parent that it may
			// need to lay this out.  Specifically this will make scrollbars work properly.
			if (!containingBlock)
				invalidateParentSizeAndDisplayList();
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
				
				_textFlow.flowComposer.removeAllControllers();
				_textFlow.formatResolver = null;
				_textFlow = null;
			}
		}
		
		public override function toString():String {
			return (TLFUtil.dumpTextFlow(_textFlow));
		}
	
	}
}
