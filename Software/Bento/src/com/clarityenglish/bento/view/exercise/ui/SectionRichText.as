package com.clarityenglish.bento.view.exercise.ui {
	import com.clarityenglish.bento.events.ExerciseEvent;
	import com.clarityenglish.bento.view.exercise.IExerciseSection;
	import com.clarityenglish.bento.view.exercise.ui.behaviours.AnswerableBehaviour;
	import com.clarityenglish.bento.view.exercise.ui.behaviours.DictionaryBehaviour;
	import com.clarityenglish.bento.view.exercise.ui.behaviours.DraggableBehaviour;
	import com.clarityenglish.bento.view.exercise.ui.behaviours.ISectionBehaviour;
	import com.clarityenglish.bento.view.exercise.ui.behaviours.OverlayBehaviour;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.conversion.ExerciseImporter;
	import com.clarityenglish.textLayout.conversion.rendering.RenderBlock;
	import com.clarityenglish.textLayout.conversion.rendering.RenderBlocks;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flashx.textLayout.compose.FlowDamageType;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.events.UpdateCompleteEvent;
	
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.flexlayouts.layouts.FlowLayout;
	
	import spark.components.Group;
	import spark.core.SpriteVisualElement;
	import spark.layouts.HorizontalLayout;
	
	[Event(name="questionAnswered", type="com.clarityenglish.bento.view.exercise.events.SectionEvent")]
	public class SectionRichText extends Group implements IExerciseSection {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		/**
		 * This holds the exercise that the ExerciseRichText is displaying
		 */
		private var _exercise:Exercise;
		private var _exerciseChanged:Boolean;
		
		/**
		 * This defines the section of the exercise displayed by this rich text area
		 */
		private var _section:String;
		private var _sectionChanged:Boolean;
		
		/**
		 * This holds the imported RenderBlocks (these are calculated whenever the Exercise changes)
		 */ 
		private var _renderBlocks:RenderBlocks;
		
		private var renderBlockHolder:Group;
		
		/**
		 * The array of registered behaviours implemented by this component 
		 */
		private var behaviours:Vector.<ISectionBehaviour>;
		
		public function SectionRichText() {
			// Create an empty vector to hold the textflows that are created
			_renderBlocks = new RenderBlocks();
			
			// Mixin behaviours
			behaviours = Vector.<ISectionBehaviour>([
				new OverlayBehaviour(this),
				new DictionaryBehaviour(this),
				new DraggableBehaviour(this),
				new AnswerableBehaviour(this),
			]);
			
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		/**
		 * A nice functional-style utility function for applying lambdas to all registered behaviours 
		 * 
		 * @param func
		 */
		private function applyToBehaviours(func:Function):void {
			for each (var behaviour:ISectionBehaviour in behaviours)
				func(behaviour);
		}
		
		/**
		 * Add event listeners
		 * 
		 * @param event
		 */
		private function onCreationComplete(event:FlexEvent):void {
			removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			
			addEventListener(MouseEvent.CLICK, onClick);
		}
		
		public function get exercise():Exercise {
			return _exercise;
		}
		
		public function set exercise(value:Exercise):void {
			if (_exercise !== value) {
				// Clean up if there was a previous exercise
				if (_exercise)
					_exercise.removeEventListener(ExerciseEvent.EXTERNAL_STYLESHEETS_LOADED, onExternalStylesLoaded);
				
				_exercise = value;
				_exerciseChanged = true;
				
				// Add an event listener for the styles changed (because a <link> node loaded)
				_exercise.addEventListener(ExerciseEvent.EXTERNAL_STYLESHEETS_LOADED, onExternalStylesLoaded)
				
				// Load any external stylesheets
				_exercise.loadStyleLinks();
				
				invalidateProperties();
			}
		}
		
		public function get section():String {
			return _section;
		}
		
		public function set section(value:String):void {
			if (_section !== value) {
				_section = value;
				_sectionChanged = true;
				invalidateProperties();
			}
		}
		
		private function get html():XML {
			// Get the section to display.  If the section is 'header' this is a special case which actually maps to the <header> node
			// (this is to try and keep the structure as close to HTML5 as possible)
			return (_section == "header") ? _exercise.getHeader() : _exercise.getSection(_section);
		}
		
		/**
		 * Create the default components
		 */
		protected override function createChildren():void {
			super.createChildren();
			
			if (!renderBlockHolder) {
				renderBlockHolder = new Group();
				renderBlockHolder.percentWidth = 100;
				
				var flowLayout:FlowLayout = new FlowLayout();
				//renderBlockHolder.layout = flowLayout;
				
				addElement(renderBlockHolder);
			}
			
			// Apply to registered behaviours
			applyToBehaviours(function(b:ISectionBehaviour):void { b.onCreateChildren(); } );
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			var renderBlock:RenderBlock;
			
			if ((_exerciseChanged || _sectionChanged) && _exercise && _exercise.isExternalStylesheetsLoaded()) {
				// Clean up after the last render if there was one
				if (_renderBlocks.length > 0) {
					// Apply to registered behaviours
					for each (renderBlock in _renderBlocks) {
						if (renderBlock.textFlow) {
							applyToBehaviours(function(b:ISectionBehaviour):void { b.onTextFlowClear(renderBlock.textFlow); } );
								
							renderBlock.textFlow.removeEventListener(UpdateCompleteEvent.UPDATE_COMPLETE, onUpdateComplete);
							renderBlock.textFlow.removeEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, onInlineGraphicStatusChange);
							renderBlock.textFlow.flowComposer.removeAllControllers();
							renderBlock.textFlow.formatResolver = null;
							
							// Images don't seem to clear themselves, so manually ensure that the textFlowContainer is empty
							while (renderBlock.textFlowContainer && renderBlock.textFlowContainer.numChildren > 0)
								renderBlock.textFlowContainer.removeChildAt(0);
							
							// Finally remove the text flow container alltogether
							renderBlockHolder.removeElement(renderBlock.textFlowContainer);
						}
					}
				}
				
				// Reset the render blocks
				_renderBlocks = new RenderBlocks();
				
				// If there is no definition for this section do nothing
				if (!html)
					return;
				
				var exerciseImporter:ExerciseImporter = new ExerciseImporter();
				_renderBlocks = exerciseImporter.importToRenderBlocks(_exercise, _section);
				
				if (_renderBlocks.length > 0) {
					for each (renderBlock in _renderBlocks) {
						if (renderBlock.textFlow) {
							// If there isn't a text flow container yet then we need to create one
							if (!renderBlock.textFlowContainer) {
								renderBlock.textFlowContainer = new SpriteVisualElement();
								renderBlock.textFlowContainer.percentWidth = 100;
								renderBlock.textFlowContainer.alpha = 0.5; // just for the moment...
								renderBlockHolder.addElement(renderBlock.textFlowContainer);
							}
							
							// Add listeners to the text flow
							renderBlock.textFlow.addEventListener(UpdateCompleteEvent.UPDATE_COMPLETE, onUpdateComplete, false, 0, true);
							renderBlock.textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, onInlineGraphicStatusChange, false, 0, true);
							
							// Apply to registered behaviours
							applyToBehaviours(function(b:ISectionBehaviour):void { b.onImportComplete(html, renderBlock.textFlow, _exercise, exerciseImporter.getFlowElementXmlBiMap()); } );
							
							// Use NaN for the height to get scrollbars to work
							renderBlock.textFlow.flowComposer.addController(new ContainerController(renderBlock.textFlowContainer, renderBlock.textFlowContainer.width, NaN));
						}
					}
					
					_exerciseChanged = _sectionChanged = false;
					
					// Invalidate the display list so everything gets redrawn on the next cycle
					invalidateDisplayList();
				}
			}
		}
		
		protected function onInlineGraphicStatusChange(event:StatusChangeEvent):void {
			if (event.status == InlineGraphicElementStatus.READY || event.status == InlineGraphicElementStatus.SIZE_PENDING) {
				// When the graphic is loaded damage the text flow and lay out its geometry again
				// TODO: Right now this damages the whole document; it would be better to just damage the InlineGraphicElement, but I'm not quite sure how
				// to work out where it is (or its TextFlowLine would be fine too in which case we could use line.damage).
				var textFlow:TextFlow = event.target as TextFlow;
				textFlow.flowComposer.damage(0, textFlow.textLength, FlowDamageType.GEOMETRY);
				invalidateDisplayList();
			}
		}
		
		protected override function measure():void {
			super.measure();
			
			for each (var renderBlock:RenderBlock in _renderBlocks) {
				if (renderBlock.textFlow) {
					var textHeight:int = Math.ceil(renderBlock.textFlow.flowComposer.getControllerAt(0).getContentBounds().height);
					measuredHeight = textHeight;
				}
			}
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			for each (var renderBlock:RenderBlock in _renderBlocks) {
				if (renderBlock.textFlow && renderBlock.textFlow.flowComposer.getControllerAt(0)) {
					// Use NaN for the height to try and get scrollbars to work and update the controllers
					renderBlock.textFlow.flowComposer.getControllerAt(0).setCompositionSize(renderBlock.textFlowContainer.width, NaN);
					renderBlock.textFlow.flowComposer.updateAllControllers();
					
					// The TextFlow height doesn't affect the content height, meaning that we need to explicitly set it
					// in order to wrap this in an s:Scroller.  If unscaledHeight is larger then do nothing, as potentially
					// something else has already made the component high enough.
					var textHeight:int = Math.ceil(renderBlock.textFlow.flowComposer.getControllerAt(0).getContentBounds().height);
					setContentSize(unscaledWidth, Math.max(textHeight, unscaledHeight));
				}
			}
		}
		
		/**
		 * When the external stylesheets are loaded mark the exercise as changed and invalidate the properties, which will cause
		 * commitProperties to run (as commitProperties takes no action unless _exercise.isExternalStylesheetsLoaded is true)
		 * 
		 * @param event
		 */
		protected function onExternalStylesLoaded(event:Event):void {
			_exerciseChanged = true;
			invalidateProperties();
		}
		
		protected function onUpdateComplete(event:UpdateCompleteEvent):void {
			// Trigger a call to updateOverlay once the text flow has updated.  We need to use callLater otherwise some properties aren't available.
			// We also call invalidateSize() so the parent can re-layout anything that needs to be.  Not actually sure if invalidateDisplayList()
			// is necessary, but it might help when wrapping in an s:Scroller.
			callLater(function():void {
				// Apply to registered behaviours
				applyToBehaviours(function(b:ISectionBehaviour):void { b.onTextFlowUpdate(event.target as TextFlow); } );
					
				invalidateSize();
				invalidateDisplayList();
			});
		}
		
		protected function onClick(event:MouseEvent):void {
			// Apply to registered behaviours
			//for each (var textFlow:TextFlow in _textFlows)
			for each (var renderBlock:RenderBlock in _renderBlocks)
				if (renderBlock.textFlow)
					applyToBehaviours(function(b:ISectionBehaviour):void { b.onClick(event, renderBlock.textFlow); } );
		}
		
	}
}