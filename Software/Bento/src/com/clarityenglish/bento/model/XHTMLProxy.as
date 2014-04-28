package com.clarityenglish.bento.model {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.ExerciseGenerator;
	import com.clarityenglish.bento.vo.content.transform.DirectStartDisableTransform;
	import com.clarityenglish.bento.vo.content.transform.RandomizedTestTransform;
	import com.clarityenglish.bento.vo.content.transform.XmlTransform;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.vo.config.BentoError;
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
	import mx.utils.ObjectUtil;
	
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.rpc.ResultResponder;
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class XHTMLProxy extends Proxy implements IProxy {
		
		public static const NAME:String = "XHTMLProxy";
		
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
		
		/**
		 * This maintains a list of transforms that server-side XHTML loads should be checked against 
		 */
		private var transformDefinitions:Vector.<TransformDefinition>;
		
		/**
		 * A function that is called before a new XHTML file is loaded  
		 */
		public var beforeXHTMLLoadFunction:Function;
		
		/**
		 * A function that is called after an XHTML file is loaded  
		 */
		public var afterXHTMLLoadFunction:Function;
		
		public function XHTMLProxy() {
			super(NAME);
			
			loadedResources = new Dictionary();
			urlLoaders = new Dictionary();
			transformDefinitions = new Vector.<TransformDefinition>();
			
			// gh#476 You can't set cacheBuster here as config has not been read yet
		}
		
		/**
		 * Clears all stateful data from this instance of the XHTMLProxy.
		 */
		public function reset():void {
			// 472
			for each (var resource:* in loadedResources)
				if (resource is XML)
					System.disposeXML(resource);
			
			loadedResources = new Dictionary();
			urlLoaders = new Dictionary();
		}
		
		public function hasLoadedResource(href:*):Boolean {
			return loadedResources[href];
		}
		
		/**
		 * Register a set of transforms that will be automatically applied to a server-side xhtmlLoad call based on the href type and the href filename.  If
		 * forTypes or forFilename is ommitted, then the transforms will match all types and/or filenames.
		 * 
		 * @param transforms An array of XmlTransforms
		 * @param forTypes An array of types (these are constants in Href; e.g. Href.MENU_XHTML)
		 * @param forFilename A regexp that the filename must match
		 */
		public function registerTransforms(transforms:Array, forTypes:Array = null, forFilename:RegExp = null):void {
			transformDefinitions.push(new TransformDefinition(transforms, forTypes, forFilename));
		}
		
		public function reloadXHTML():void {
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			
			if (!bentoProxy.menuXHTML) {
				log.error("reloadXHTML was called when no menu xhtml was loaded");
				return;
			}
			
			// Clear the entry from the cache and reload
			if (loadedResources[bentoProxy.menuXHTML.href])
				delete loadedResources[bentoProxy.menuXHTML.href];
			
			loadXHTML(bentoProxy.menuXHTML.href);
		}
		
		public function loadXHTML(href:Href):void {
			if (!href) {
				log.error("loadXHTML received a null Href");
				return;
			}
			
			// If the resource has already been loaded then just return it
			if (loadedResources[href]) {
				// log.debug("Href already loaded so returning cached copy {0}", href);
				notifyXHTMLLoaded(href, true);
				return;
			}
			
			// If the resource is already loading then do nothing
			for each (var loadingHref:Href in urlLoaders) {
				if (href === loadingHref) {
					log.debug("Href is already loading {0}", href);
					return;
				}
			}
			
			// gh#476 
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var useCacheBuster:Boolean = configProxy.getConfig().useCacheBuster;
			
			if (beforeXHTMLLoadFunction !== null) beforeXHTMLLoadFunction(facade, href);
			// gh#265
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			if (href.serverSide) {
				// Determine if the href matches any of the registered transforms and if so add those transforms
				href.resetTransforms();
				// gh#761 Because the configProxy.getDirectStart() doesn't be set value in xxStartupCommand, so I put DirectStartDisableTransform here 
				if (ObjectUtil.getClassInfo(configProxy.getDirectStart()).properties.length > 0)
					registerTransforms([new DirectStartDisableTransform(configProxy.getDirectStart())], [ Href.MENU_XHTML ]);				
				// gh#265				
				if (href.type == Href.EXERCISE) {
					// gh#1115 transformDefinitions.splice(0, transformDefinitions.length);
					var transforms:Array = [new RandomizedTestTransform()];
					registerTransforms(transforms, [ Href.EXERCISE ]);
					// gh#660, gh#1030 pick up from exercise
					//href.options = {totalNumber: configProxy.getRandomizedTestQuestionTotalNumber()};
				}
				
				for each (var transformDefinition:TransformDefinition in transformDefinitions)
					transformDefinition.injectTransforms(href);
					
				// Load the xml file through an AMFPHP serverside call to xhtmlLoad($href) gh#84
				new RemoteDelegate("xhtmlLoad", [ href ]).execute().addResponder(new ResultResponder(
					function(e:ResultEvent, data:AsyncToken):void {
						parseAndStoreXHTML(href, e.result.toString());
					},
					function(e:FaultEvent, data:AsyncToken):void {
						// This should implement the full spectrum of errors for loading normal or menu xml.  There are two special cases for errors when loading
						// menu xml, but in fact perhaps we should throw BBNotifications.MENU_XHTML_NOT_LOADED for any menu.xml loading error?
						var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
						var bentoError:BentoError = BentoError.create(e.fault);

						switch (bentoError.errorNumber) {
							case copyProxy.getCodeForId("errorTitleBlockedByHiddenContent"):
							case copyProxy.getCodeForId("errorCourseDoesNotExist"):
								sendNotification(CommonNotifications.BENTO_ERROR, bentoError);
								break;
							case copyProxy.getCodeForId("errorConcurrentCourseAccess"): // gh#142
								bentoError.isFatal = false;
								sendNotification(CommonNotifications.BENTO_ERROR, bentoError);
								break;
							default:
								if (href.type == Href.MENU_XHTML) {
									sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorParsingExercise", { filename: href.filename, message: e.fault.faultString } ));
								} else {
									sendNotification(CommonNotifications.INVALID_DATA, bentoError);
								}
						}
						
						sendNotification(BBNotifications.MENU_XHTML_NOT_LOADED);
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

		/**
		 * This is called when XHTML has been loaded, either directly or from the server-side.  The cached parameter is used to make sure that MENU_XHTML_LOADED
		 * is only sent once per menu.xml file.
		 * 
		 * @param href
		 * @param cached
		 */
		private function notifyXHTMLLoaded(href:Href, cached:Boolean = false):void {
			if (afterXHTMLLoadFunction !== null) afterXHTMLLoadFunction(facade, href);
			
			if (href.type == Href.MENU_XHTML) {
				// If this is the menu xhtml store it in BentoProxy and send a special notification
				var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
				
				//sendNotification(BBNotifications.BENTO_RESET); // TODO: not sure if this has undesired consequences...
				
				bentoProxy.menuXHTML = loadedResources[href];
				if (!cached) sendNotification(BBNotifications.MENU_XHTML_LOADED, loadedResources[href]);
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
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var useCacheBuster:Boolean = configProxy.getConfig().useCacheBuster;
			
			try {
				var xml:XML = new XML(data);
				
				// Run all the transforms client side (these might well be empty methods)
				for each (var xmlTransform:XmlTransform in href.transforms)
					xmlTransform.transform(xml);

				// Store the resource
				switch (href.type) {
					case Href.MENU_XHTML:
					case Href.XHTML:
						loadedResources[href] = new XHTML(xml, href, useCacheBuster);
						break;
					case Href.EXERCISE:
						loadedResources[href] = new Exercise(xml, href);
						break;
					case Href.EXERCISE_GENERATOR:
						loadedResources[href] = new ExerciseGenerator(xml, href);
						break;
				}
				
				notifyXHTMLLoaded(href);
			} catch (e:Error) {
				var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
				// alice: in order to target the error I add this new error type errorParsingExerciseDetection1
				sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorParsingExerciseDetection1", { filename: href.filename, message1: href.transforms.length, message2: e.message } ));
				return;
			}
		}
		
		private function onXHTMLLoadError(event:IOErrorEvent):void {
			var urlLoader:URLLoader = event.target as URLLoader;
			var href:Href = urlLoaders[urlLoader];
			
			log.info("IO error loading from href {0} - {1}", href, event.text);
			sendNotification(BBNotifications.XHTML_LOAD_IOERROR, { href: href } );
			sendNotification(BBNotifications.MENU_XHTML_NOT_LOADED);
			delete urlLoaders[urlLoader];
		}
		
		private function onXHTMLSecurityError(event:SecurityErrorEvent):void {
			var urlLoader:URLLoader = event.target as URLLoader;
			var href:Href = urlLoaders[urlLoader];
			
			log.info("Security error loading from href {0} - {1}", href, event.text);
			sendNotification(BBNotifications.MENU_XHTML_NOT_LOADED);
			delete urlLoaders[urlLoader];
		}
		
	}
}

import com.clarityenglish.bento.vo.Href;
import com.clarityenglish.bento.vo.content.transform.XmlTransform;

class TransformDefinition {
	
	private var transforms:Array;
	private var forTypes:Array;
	private var forFilename:RegExp;
	
	public function TransformDefinition(transforms:Array, forTypes:Array, forFilename:RegExp) {
		this.transforms = transforms;
		this.forTypes = forTypes;
		this.forFilename = forFilename;
	}
	
	public function injectTransforms(href:Href):void {
		// If a type is specified then check that the href matches, otherwise return
		if (forTypes && forTypes.indexOf(href.type) == -1)
			return;
		
		// If a filename regexp is specified then check that the href matches, otherwise return
		if (forFilename && forFilename.exec(href.filename) == null)
			return;
		
		// If we have reached here then we want to add the transforms
		for each (var transform:XmlTransform in transforms)
			href.transforms.push(transform);
	}
	
}