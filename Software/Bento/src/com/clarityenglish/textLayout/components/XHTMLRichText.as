package com.clarityenglish.textLayout.components {
	import com.clarityenglish.textLayout.conversion.XHTMLImporter;
	import com.clarityenglish.textLayout.events.XHTMLEvent;
	import com.clarityenglish.textLayout.rendering.RenderFlow;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.Group;
	
	public class XHTMLRichText extends Group {
		
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
		
		public function XHTMLRichText() {
			super();
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
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			// If something has changed and we are ready then start parsing
			if ((_xhtmlChanged || _selectorChanged) && _xhtml && _xhtml.isExternalStylesheetsLoaded()) {
				// If there was a previously existing RenderFlow clean it up
				if (renderFlow) {
					removeElement(renderFlow);
				}
				
				// Import the new renderflow
				var importer:XHTMLImporter = new XHTMLImporter();
				renderFlow = importer.importToRenderFlow(_xhtml, _xhtml.selectOne(_selector));
				
				// The main RenderFlow should fill the viewport horizontally
				// TODO: This is causing some confusion with resizing RenderFlows and invalidateSize
				renderFlow.percentWidth = 100;
				
				addElement(renderFlow);
				
				_xhtmlChanged = _selectorChanged = false;
			}
		}
		
		protected override function measure():void {
			super.measure();
			
			if (renderFlow) {
				measuredHeight = renderFlow.height;
			}
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
		
	}
}
