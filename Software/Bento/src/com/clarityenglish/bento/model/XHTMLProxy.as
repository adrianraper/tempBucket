package com.clarityenglish.bento.model {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.transform.XmlTransform;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.utils.Dictionary;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.rpc.ResultResponder;
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class XHTMLProxy extends Proxy implements IProxy {
		
		public static const NAME:String = "XHTMLProxy";
		
		/**
		 * If this is true then use a cachebuster (a randomly generated string) on the end of XML files so they don't get cached.
		 * TODO: This should be configurable in config.xml 
		 */
		private static const useCacheBuster:Boolean = true;
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
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
		
		public function reset():void {
			// #472
			for each (var resource:* in loadedResources)
				if (resource is XML)
					System.disposeXML(resource);
			
			loadedResources = new Dictionary();
			urlLoaders = new Dictionary();
		}
		
		public function hasLoadedResource(href:*):Boolean {
			return loadedResources[href];
		}
		
		public function loadXHTML(href:Href):void {
			if (!href) {
				log.error("loadXHTML received a null Href");
				return;
			}
			
			// If the resource has already been loaded then just return it
			if (loadedResources[href]) {
				log.debug("Href already loaded so returning cached copy {0}", href);
				notifyXHTMLLoaded(href);
				return;
			}
			
			// If the resource is already loading then do nothing
			for each (var loadingHref:Href in urlLoaders) {
				if (href === loadingHref) {
					log.debug("Href is already loading {0}", href);
					return;
				}
			}
			
			if (href.serverSide) {
				// Load the xml file through an AMFPHP serverside call to xhtmlLoad($href) GH #84
				new RemoteDelegate("xhtmlLoad", [ href ]).execute().addResponder(new ResultResponder(
					function(e:ResultEvent, data:AsyncToken):void {
						parseAndStoreXHTML(href, e.result.toString());
					},
					function(e:FaultEvent, data:AsyncToken):void {
						var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
						sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorParsingExercise", { filename: href.filename, message: e.fault.faultString } ));
					}
				));
			} else {
				// Load the xml file normally using a URLLoader
				log.debug("Loading href {0}", href);
				
				// Load it!
				var urlLoader:URLLoader = new URLLoader();
				urlLoader.addEventListener(Event.COMPLETE, onXHTMLLoadComplete);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onXHTMLLoadError);
				urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onXHTMLSecurityError);
				urlLoader.load(new URLRequest(href.url + ((useCacheBuster) ? "?" + new Date().time : "")));
				
				// Maintain a strong reference during loading so the loader isn't garbage collected, and so we have the original href
				urlLoaders[urlLoader] = href;
			}
		}

		private function notifyXHTMLLoaded(href:Href):void {
			if (href.type == Href.MENU_XHTML) {
				// If this is the menu xhtml store it in BentoProxy and send a special notification
				// Note that IELTS overrides this behaviour since it uses ProgressProxy to get menu xml instead.  However, Rotterdam editor still uses this.
				var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
				
				//sendNotification(BBNotifications.BENTO_RESET); // TODO: not sure if this has undesired consequences...
				
				bentoProxy.menuXHTML = loadedResources[href];
				sendNotification(BBNotifications.MENU_XHTML_LOADED, loadedResources[href]);
			}
			
			// Whether or not this is menu XHTML, we always want to send the XHTML_LOADED notification as it drives BentoMediators
			sendNotification(BBNotifications.XHTML_LOADED, { xhtml: loadedResources[href], href: href } );
		}
		
		private function onXHTMLLoadComplete(event:Event):void {
			var urlLoader:URLLoader = event.target as URLLoader;
			var href:Href = urlLoaders[urlLoader];
			delete urlLoaders[urlLoader];
			
			parseAndStoreXHTML(href, urlLoader.data);
		}
			
		private function parseAndStoreXHTML(href:Href, data:String):void {
			log.info("Successfully loaded XHTML from href {0}", href);
			
			try {
				var xml:XML = new XML(data);
				
				// Run all the transforms client side (these might well be empty methods)
				for each (var xmlTransform:XmlTransform in href.transforms)
					xmlTransform.transform(xml);
				
				// Store the resource
				switch (href.type) {
					case Href.MENU_XHTML:
					case Href.XHTML:
						loadedResources[href] = new XHTML(xml, href);
						break;
					case Href.EXERCISE:
						loadedResources[href] = new Exercise(xml, href);
						break;
				}
				
				notifyXHTMLLoaded(href);
			} catch (e:Error) {
				var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
				sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorParsingExercise", { filename: href.filename, message: e.message } ));
				return;
			}
		}
		
		private function onXHTMLLoadError(event:IOErrorEvent):void {
			var urlLoader:URLLoader = event.target as URLLoader;
			var href:Href = urlLoaders[urlLoader];
			
			log.info("IO error loading from href {0} - {1}", href, event.text);
			sendNotification(BBNotifications.XHTML_LOAD_IOERROR, { href: href } );
			
			delete urlLoaders[urlLoader];
		}
		
		private function onXHTMLSecurityError(event:SecurityErrorEvent):void {
			var urlLoader:URLLoader = event.target as URLLoader;
			var href:Href = urlLoaders[urlLoader];
			delete urlLoaders[urlLoader];
			
			log.info("Security error loading from href {0} - {1}", href, event.text);
		}
		
	}
}