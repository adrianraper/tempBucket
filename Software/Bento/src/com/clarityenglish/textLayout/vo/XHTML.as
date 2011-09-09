package com.clarityenglish.textLayout.vo {
	import com.clarityenglish.textLayout.events.XHTMLEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	public class XHTML extends EventDispatcher {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const XML_CHANGE_EVENT:String = "xmlChange";
		
		private var _xml:XML;
		
		/*private var _model:Model;*/
		
		private var isLoadingStyleLinks:Boolean
		private var externalStyleSheetsLoaded:Boolean;
		
		public function XHTML(value:XML = null) {
			if (value)
				xml = value;
		}
		
		public function set xml(value:XML):void {
			if (_xml !== value) {
				_xml = value;
				
				/*var modelNodes:XMLList = _xml.head.script.(hasOwnProperty("@id") && @id == "model" && hasOwnProperty("@type") && @type == "application/xml");
				if (modelNodes.length() > 0)
					_model = new Model(this, modelNodes[0]);*/
				
				dispatchEvent(new Event(XML_CHANGE_EVENT));
			}
		}
		
		/**
		 * Determine if the model exists in this exercise
		 * 
		 * @return 
		 */
		/*[Bindable(event="xmlChange")]
		public function hasModel():Boolean {
		return _model !== null;
		}*/
		
		/**
		 * Return the model
		 */
		/*[Bindable(event="xmlChange")]
		public function get model():Model {
		return _model;
		}*/
		
		[Bindable(event="xmlChange")]
		public function get xml():XML {
			return _xml;
		}
		
		public function isExternalStylesheetsLoaded():Boolean {
			return externalStyleSheetsLoaded;
		}
		
		/**
		 * Exercise XML files can contain <link> nodes referencing external stylesheets.  We want to load those link nodes and replace them
		 * with <style> nodes containing the contents of the link. 
		 */
		public function loadStyleLinks():void {
			if (isLoadingStyleLinks)
				return;
			
			isLoadingStyleLinks = true;
			
			// Get all the link elements referencing external stylesheets
			var linkNodes:XMLList = _xml.head.link.(@rel == "stylesheet");
			
			if (linkNodes.length() == 0) {
				externalStyleSheetsLoaded = true;
				dispatchEvent(new XHTMLEvent(XHTMLEvent.EXTERNAL_STYLESHEETS_LOADED))
			} else {
				
				// Note to self
				if (linkNodes.length() > 1)
					throw new Error("DAVE!  You haven't put support for multiple stylesheets in yet");
				
				// Otherwise load the links
				for each (var linkNode:XML in linkNodes) {
					var linkLoader:LinkLoader = new LinkLoader(linkNode);
					linkLoader.addEventListener(Event.COMPLETE, onStyleSheetLoaded);
					linkLoader.addEventListener(IOErrorEvent.IO_ERROR, onStyleSheetIOError);
					linkLoader.load(new URLRequest(linkNode.@href));
				}
			}
		}
		
		protected function onStyleSheetLoaded(event:Event):void {
			event.target.removeEventListener(Event.COMPLETE, onStyleSheetLoaded);
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, onStyleSheetIOError);
			
			var linkLoader:LinkLoader = event.target as LinkLoader;
			
			// Replace the <link> node with a <style> node containing the contents
			delete linkLoader.linkNode.@rel;
			delete linkLoader.linkNode.@href;
			linkLoader.linkNode.setName("style");
			linkLoader.linkNode.appendChild(new XML("<![CDATA[" + linkLoader.data + "]]>"));
			
			externalStyleSheetsLoaded = true;
			isLoadingStyleLinks = false;
			
			log.info("External stylesheet loaded");
			
			dispatchEvent(new XHTMLEvent(XHTMLEvent.EXTERNAL_STYLESHEETS_LOADED));
		}
		
		protected function onStyleSheetIOError(event:IOErrorEvent):void {
			event.target.removeEventListener(Event.COMPLETE, onStyleSheetLoaded);
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, onStyleSheetIOError);
			
			isLoadingStyleLinks = false;
			
			log.error("Error loading external stylesheet " + event.target.linkNode.@href);
		}
		
		/**
		 * Get the style area
		 * 
		 * @return 
		 */
		[Bindable(event="xmlChange")]
		public function get styleStrings():Array {
			var styleStrings:Array = [ ];
			for each (var styleNode:XML in _xml.head.style)
			styleStrings.push(styleNode.text().toString());
			
			return styleStrings;
		}
		
		/**
		 * Return the body tag
		 * 
		 * @return 
		 */
		[Bindable(event="xmlChange")]
		public function get body():XML {
			return _xml.body[0];
		}
		
		/**
		 * Determine if the header exists in this exercise
		 * 
		 * @return 
		 */
		[Bindable(event="xmlChange")]
		public function hasHeader():Boolean {
			return _xml.body.header.length() > 0;
		}
		
		/**
		 * Return the header
		 * 
		 * @return 
		 */
		[Bindable(event="xmlChange")]
		public function getHeader():XML {
			return (hasHeader()) ? _xml.body.header[0] : null;
		}
		
		/**
		 * Determine if the given section exists in this exercise
		 * 
		 * @param section
		 * @return 
		 */
		/*[Bindable(event="xmlChange")]
		public function hasSection(section:String):Boolean {
			return _xml.body.section.(@id == section).length() > 0;
		}*/
		
		/**
		 * Return the section
		 * 
		 * @return 
		 */
		/*[Bindable(event="xmlChange")]
		public function getSection(sectionId:String):XML {
			return (hasSection(sectionId)) ? _xml.body.section.(@id == sectionId)[0] : null;
		}*/
		
		/**
		 * Return the node (in the body) with the given id.  If more than one node exists with the same id the first one is returned.
		 * 
		 * @return 
		 */
		[Bindable(event="xmlChange")]
		public function getElementById(id:String):XML {
			var nodes:XMLList = _xml.body..*.(hasOwnProperty("@id") && @id == id);
			return (nodes.length() > 0) ? nodes[0] : null;
		}
		
	}
}
import flash.net.URLLoader;
import flash.net.URLRequest;

class LinkLoader extends URLLoader {
	
	private var _linkNode:XML;
	
	public function LinkLoader(linkNode:XML, request:URLRequest = null) {
		super(request);
		
		this._linkNode = linkNode;
	}
	
	public function get linkNode():XML {
		return _linkNode;
	}
	
}