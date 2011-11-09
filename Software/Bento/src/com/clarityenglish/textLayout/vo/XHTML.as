package com.clarityenglish.textLayout.vo {
	import com.clarityenglish.textLayout.events.XHTMLEvent;
	import com.newgonzo.web.css.CSS;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;

	use namespace flash_proxy;
	
	public dynamic class XHTML extends Proxy implements IEventDispatcher {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		/**
		 * If this is true then use a cachebuster (a randomly generated string) on the end of CSS files so they don't get cached.
		 * TODO: This should be configurable in config.xml 
		 */
		private static const useCacheBuster:Boolean = true;
		
		public static const XML_CHANGE_EVENT:String = "xmlChange";
		
		private var dispatcher:EventDispatcher;
		
		/**
		 * The XML document 
		 */
		protected var _xml:XML;
		
		private var isLoadingStyleLinks:Boolean
		private var externalStyleSheetsLoaded:Boolean;
		
		/**
		 * This is appended to any filenames so that paths can be relative to the xhtml document 
		 */
		public var rootPath:String;
		
		public function XHTML(value:XML = null, rootPath:String = null) {
			dispatcher = new EventDispatcher(this);
			
			this.rootPath = rootPath;
			
			if (value)
				xml = value;
		}
		
		/**
		 * Return a clone of this XHTML object.  This includes a deep copy of the embedded XML.
		 * 
		 * @return 
		 */
		public function clone():XHTML {
			return new XHTML(_xml.copy(), rootPath);
		}
		
		public function set xml(value:XML):void {
			if (_xml !== value) {
				// This is a little bit of a hack, but use string functions to remove the namespace.
				var xmlString:String = value.toXMLString();
				xmlString = xmlString.replace(" xmlns=\"http://www.w3.org/1999/xhtml\"", "");
				_xml = new XML(xmlString);
				
				dispatchEvent(new Event(XML_CHANGE_EVENT));
			}
		}
		
		[Bindable(event="xmlChange")]
		public function get xml():XML {
			return _xml;
		}
		
		/**
		 * The Proxy allows us to use E4X syntax directly on the XHTML class
		 * 
		 * @param name
		 * @param rest
		 * @return 
		 */
		override flash_proxy function callProperty(name:*, ...rest):*  {
			switch(String(name)) {
				case "name": return _xml.name();
				case "children": return _xml.children();
				case "descendants": return _xml.descendants();
				case "replace": return _xml.replace(rest[0], rest[1]);
				case "attribute": return _xml.attribute(rest[0]);
				case "attributes": return _xml.attributes();
			}
			
			return null;
		}
		
		/**
		 * The Proxy allows us to use E4X syntax directly on the XHTML class
		 * 
		 * @param name
		 * @return 
		 */
		override flash_proxy function getProperty(name:*):* {
			if (flash_proxy::isAttribute(name))
				return _xml.@[String(name)];
				
			return _xml[String(name)];
		}
		
		/**
		 * The Proxy allows us to use E4X syntax directly on the XHTML class
		 * 
		 * @param name
		 * @return 
		 */
		flash_proxy override function getDescendants(name:*):* {
			return _xml.descendants(String(name));
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
					linkLoader.load(new URLRequest((rootPath ? rootPath + "/" : "") + linkNode.@href.toString() + (useCacheBuster ? "?" + new Date().time : "")));
				}
			}
		}
		
		protected function onStyleSheetLoaded(event:Event):void {
			event.target.removeEventListener(Event.COMPLETE, onStyleSheetLoaded);
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, onStyleSheetIOError);
			
			var linkLoader:LinkLoader = event.target as LinkLoader;
			
			// Store the loaded url in a string as we are about to replace it and want to display it in the log message
			var loadedUrl:String = ((rootPath) ? rootPath + "/" : "") + linkLoader.linkNode.@href.toString();
			
			// Replace the <link> node with a <style> node containing the contents
			delete linkLoader.linkNode.@rel;
			delete linkLoader.linkNode.@href;
			linkLoader.linkNode.setName("style");
			linkLoader.linkNode.appendChild(new XML("<![CDATA[" + linkLoader.data + "]]>"));
			
			externalStyleSheetsLoaded = true;
			isLoadingStyleLinks = false;
			
			log.info("External stylesheet loaded from {0}", loadedUrl);
			
			dispatchEvent(new XHTMLEvent(XHTMLEvent.EXTERNAL_STYLESHEETS_LOADED));
		}
		
		protected function onStyleSheetIOError(event:IOErrorEvent):void {
			event.target.removeEventListener(Event.COMPLETE, onStyleSheetLoaded);
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, onStyleSheetIOError);
			
			isLoadingStyleLinks = false;
			
			log.error("Error loading external stylesheet {0}", ((rootPath) ? rootPath + "/" : "") + event.target.linkNode.@href.toString());
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
		 * Return the node (in the body) with the given id.  If more than one node exists with the same id the first one is returned.
		 * 
		 * @return 
		 */
		[Bindable(event="xmlChange")]
		public function getElementById(id:String):XML {
			var nodes:XMLList = _xml.body..*.(hasOwnProperty("@id") && @id == id);
			return (nodes.length() > 0) ? nodes[0] : null;
		}
		
		[Bindable(event="xmlChange")]
		public function select(expression:String):Array {
			var cssSelector:CSS = new CSS(expression + " {}");
			return cssSelector.select(_xml);
		}
		
		[Bindable(event="xmlChange")]
		public function selectOne(expression:String):XML {
			var results:Array =  select(expression);
			if (results.length > 1)
				log.error("selectOne(" + expression + ") returned more than 1 result.  Returning the first result");
			
			return (results.length == 0) ? null : results[0];
		}
		
		public static function hasClass(node:XML, classString:String):Boolean {
			if (classString.indexOf(" ") >= 0)
				throw new Error("Only a single class can be manipulated at a time");
			
			var classes:Array = node.@["class"].toString().split(" ");
			return (classes.indexOf(classString) >= 0);
		}
		
		public static function addClass(node:XML, classString:String):void {
			if (classString.indexOf(" ") >= 0)
				throw new Error("Only a single class can be manipulated at a time");
			
			if (!hasClass(node, classString)) {
				var classes:Array = node.@["class"].toString().split(" ");
				classes.push(classString);
				node.@["class"] = classes.join(" ");
			}
		}
		
		public static function addClasses(node:XML, classes:Array):void {
			for each (var classString:String in classes)
				addClass(node, classString);
		}
		
		public static function removeClass(node:XML, classString:String):void {
			if (classString.indexOf(" ") >= 0)
				throw new Error("Only a single class can be manipulated at a time");
			
			if (hasClass(node, classString)) {
				var classes:Array = node.@["class"].toString().split(" ");
				classes = classes.filter(function(className:String, index:int, array:Array):Boolean {
					return className != classString;
				});
				node.@["class"] = classes.join(" ");
			}
		}
		
		public static function removeClasses(node:XML, classes:Array):void {
			for each (var classString:String in classes)
				removeClass(node, classString);
		}
		
		public static function toggleClass(node:XML, classString:String):void {
			if (classString.indexOf(" ") >= 0)
				throw new Error("Only a single class can be manipulated at a time");
			
		}
		
		/**
		 * IEventDispatcher
		 * 
		 * @param type
		 * @param listener
		 * @param useCapture
		 * @param priority
		 * @param useWeakReference
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
			dispatcher.addEventListener(type, listener, useCapture, priority);
		}
		
		/**
		 * IEventDispatcher 
		 * 
		 * @param event
		 * @return 
		 */
		public function dispatchEvent(event:Event):Boolean{
			return dispatcher.dispatchEvent(event);
		}
		
		/**
		 * IEventDispatcher
		 *  
		 * @param type
		 * @return 
		 */
		public function hasEventListener(type:String):Boolean{
			return dispatcher.hasEventListener(type);
		}
		
		/**
		 * IEventDispatcher
		 *  
		 * @param type
		 * @param listener
		 * @param useCapture
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
			dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * IEventDispatcher
		 *  
		 * @param type
		 * @return 
		 */
		public function willTrigger(type:String):Boolean {
			return dispatcher.willTrigger(type);
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