package com.clarityenglish.bento.model {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.vo.Href;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class XHTMLProxy extends Proxy implements IProxy {
		
		public static const NAME:String = "XHTMLProxy";
		
		/**
		 * A cache of hrefs to loaded XHTML files 
		 */
		private var loadedResources:Dictionary;
		
		/**
		 * Whilst URLLoaders are loading we need to maintain a strong reference to them, otherwise they will be garbage collected
		 */
		private var urlLoaders:Dictionary;
		
		public function XHTMLProxy() {
			super(NAME);
			
			loadedResources = new Dictionary();
			urlLoaders = new Dictionary();
		}
		
		public function loadXHTML(href:Href):void {
			// If the resource has already been loaded then just return it
			if (loadedResources[href]) {
				notifyXHTMLLoaded(href);
				return;
			}
			
			// Otherwise load it
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onXHTMLLoadComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onXHTMLLoadError);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onXHTMLSecurityError);
			urlLoader.load(new URLRequest(href.url));
			
			// Maintain a strong reference during loading so the loader isn't garbage collected
			urlLoaders[urlLoader] = true;
		}
		
		private function notifyXHTMLLoaded(href:Href):void {
			sendNotification(BBNotifications.XHTML_LOADED, { xhtml: loadedResources[href], href: href } );
		}
		
		private function onXHTMLLoadComplete(event:Event):void {
			var urlLoader:URLLoader = event.target as URLLoader;
			delete urlLoaders[urlLoader];
			
			trace("load complete");
		}
		
		private function onXHTMLLoadError(event:IOErrorEvent):void {
			var urlLoader:URLLoader = event.target as URLLoader;
			delete urlLoaders[urlLoader];
			
			trace("io error " + event.text);
		}
		
		private function onXHTMLSecurityError(event:SecurityErrorEvent):void {
			var urlLoader:URLLoader = event.target as URLLoader;
			delete urlLoaders[urlLoader];
			
			trace("security error");
		}
		
	}
}