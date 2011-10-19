package com.clarityenglish.textLayout.components {
	import com.clarityenglish.textLayout.components.behaviours.IXHTMLBehaviour;
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	import com.clarityenglish.textLayout.conversion.XHTMLImporter;
	import com.clarityenglish.textLayout.events.RenderFlowEvent;
	import com.clarityenglish.textLayout.events.XHTMLEvent;
	import com.clarityenglish.textLayout.rendering.RenderFlow;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.UpdateCompleteEvent;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.Group;
	
	public class XHTMLRichText extends Group {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		/**
		 * The complete XHTML document 
		 */
		private var _xhtml:XHTML;
		private var _xhtmlChanged:Boolean;
		
		/**
		 * The selector of the node that this XHTMLRichText is supposed to render.  This is a CSS style selector; for example #someid, header, body, etc.
		 * If the selector returns more than one node an error message will be logged and only the first node will be used.  
		 */
		private var _selector:String;
		private var _selectorChanged:Boolean;
		
		/**
		 * The inital containing block
		 */
		private var renderFlow:RenderFlow;
		
		/**
		 * The array of registered behaviours implemented by this component 
		 */
		private var _behaviours:Vector.<IXHTMLBehaviour>;
		
		private var _flowElementXmlBiMap:FlowElementXmlBiMap;
		
		public function XHTMLRichText() {
			super();
		}
		
		/**
		 * A nice functional-style utility function for applying lambdas to all registered behaviours 
		 * 
		 * @param func
		 */
		private function applyToBehaviours(func:Function):void {
			for each (var behaviour:IXHTMLBehaviour in _behaviours)
				func(behaviour);
		}
		
		/**
		 * Set the XHTML object that this component will render
		 * 
		 * @param value
		 */
		public function set xhtml(value:XHTML):void {
			if (_xhtml !== value) {
				// Clean up if there was a previous exercise
				if (_xhtml)
					_xhtml.removeEventListener(XHTMLEvent.EXTERNAL_STYLESHEETS_LOADED, onExternalStylesLoaded);
				
				_flowElementXmlBiMap = null;
				
				_xhtml = value;
				_xhtmlChanged = true;
				
				// Add an event listener for the styles changed (because a <link> node loaded)
				_xhtml.addEventListener(XHTMLEvent.EXTERNAL_STYLESHEETS_LOADED, onExternalStylesLoaded)
				
				// Load any external stylesheets
				_xhtml.loadStyleLinks();
				
				invalidateProperties();
			}
		}
		
		public function set nodeId(value:String):void {
			if (_selector != value) {
				_selector = value;
				_selectorChanged = true;
				invalidateProperties();
			}
		}
		
		public function set behaviours(value:Array):void {
			if (_behaviours)
				return;
			
			_behaviours = new Vector.<IXHTMLBehaviour>();
			
			for each (var behaviourClass:Class in value) {
				if (behaviourClass) {
					_behaviours.push(new behaviourClass(this));
				} else {
					log.error("Unable to instantiate behaviour " + behaviourClass);
				}
			}
		}
		
		public function get flowElementXmlBiMap():FlowElementXmlBiMap {
			return _flowElementXmlBiMap;
		}
		
		/**
		 * When the external stylesheets are loaded mark the xhtml as changed and invalidate the properties, which will cause
		 * commitProperties to run (as commitProperties takes no action unless _exercise.isExternalStylesheetsLoaded is true).
		 * Effectively this is just a way to cause the XHTML to be rerendered.
		 * 
		 * @param event
		 */
		protected function onExternalStylesLoaded(event:Event):void {
			_xhtmlChanged = true;
			invalidateProperties();
		}
		
		protected override function createChildren():void {
			super.createChildren();
			
			// Apply to registered behaviours
			applyToBehaviours(function(b:IXHTMLBehaviour):void { b.onCreateChildren(); } );
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			// If something has changed and we are ready then start parsing
			if ((_xhtmlChanged || _selectorChanged) && _xhtml && _xhtml.isExternalStylesheetsLoaded()) {
				// If there was a previously existing RenderFlow clean it up
				if (renderFlow) {
					if (renderFlow.parent)
						removeElement(renderFlow);
					
					renderFlow.removeEventListener(RenderFlowEvent.RENDER_FLOW_UPDATE_COMPLETE, onUpdateComplete);
					renderFlow.removeEventListener(RenderFlowEvent.TEXT_FLOW_CLEARED, onTextFlowCleared);
				}
				
				// Import the XHTML into the initial RenderFlow
				var importer:XHTMLImporter = new XHTMLImporter();
				var node:XML = _xhtml.selectOne(_selector);
				if (node) {
					// Parse the XHTML into a RenderFlow
					renderFlow = importer.importToRenderFlow(_xhtml, node);
					_flowElementXmlBiMap = importer.getFlowElementXmlBiMap();
					importer.clear();
					importer = null;
					
					// Add any event listeners to the RenderFlow (in general these will bubble up from child RenderFlows too)
					renderFlow.addEventListener(RenderFlowEvent.RENDER_FLOW_UPDATE_COMPLETE, onUpdateComplete);
					renderFlow.addEventListener(RenderFlowEvent.TEXT_FLOW_CLEARED, onTextFlowCleared);
					
					// The main RenderFlow should always fill the viewport horizontally
					renderFlow.percentWidth = 100;
					renderFlow.y = 1;
					
					// Add the RenderFlow to the display list
					addElement(renderFlow);
					
					// Apply to registered behaviours
					applyToBehaviours(function(b:IXHTMLBehaviour):void { b.onImportComplete(_xhtml, _flowElementXmlBiMap); } );
				}
				
				_xhtmlChanged = _selectorChanged = false;
			}
		}
		
		protected override function measure():void {
			super.measure();
			
			if (renderFlow) {
				measuredHeight = renderFlow.height + 3;
			}
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
		
		protected function onUpdateComplete(event:RenderFlowEvent):void {
			// Apply to registered behaviours
			applyToBehaviours(function(b:IXHTMLBehaviour):void { b.onTextFlowUpdate(event.textFlow); } );
		}
		
		protected function onTextFlowCleared(event:RenderFlowEvent):void {
			// Apply to registered behaviours
			applyToBehaviours(function(b:IXHTMLBehaviour):void { b.onTextFlowClear(event.textFlow); } );
		}
		
	}
}
