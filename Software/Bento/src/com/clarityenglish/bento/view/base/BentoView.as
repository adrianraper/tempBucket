package com.clarityenglish.bento.view.base {
	import com.clarityenglish.bento.view.base.events.BentoEvent;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.View;
	import spark.components.supportClasses.SkinnableComponent;
	
	/**
	 * This is the parent class of all views in Bento.
	 * 
	 * @author Dave
	 */
	[Event(name="hrefChanged", type="com.clarityenglish.bento.view.base.events.BentoEvent")]
	[Event(name="xhtmlReady", type="com.clarityenglish.bento.view.base.events.BentoEvent")]
	public class BentoView extends View {
		
		/**
		 * Standard flex logger
		 */
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		/**
		 * The Href that this view is running off 
		 */
		private var _href:Href;
		private var _hrefChanged:Boolean = false;
		
		/**
		 * The XHTML file loaded from the Href 
		 */
		protected var _xhtml:XHTML;
		private var _xhtmlChanged:Boolean;
		
		// #234
		protected var _productVersion:String;
		
		// GH #39
		protected var _productCode:String;
		protected var _licenceType:uint;
		
		public var media:String = "screen";
		
		// Used to drive onViewCreationComplete in the mediator
		private var _isCreationComplete:Boolean;
		
		/**
		 * Configuration properties commonly used in views
		 * #333
		 */
		public var config:Config;
		
		protected var copyProvider:CopyProvider;
		
		public function BentoView() {
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
			addEventListener(FlexEvent.PREINITIALIZE, onPreinitialize, false, 0, true);
		}
		
		internal function get isCreationComplete():Boolean {
			return _isCreationComplete;
		}

		internal function set isCreationComplete(value:Boolean):void {
			_isCreationComplete = value;
			if (value) onViewCreationComplete();
		}

		public function setCopyProvider(copyProvider:CopyProvider):void {
			this.copyProvider = copyProvider;
		}
		
		/**
		 * We may need to change the skin based on the media type
		 * 
		 * @param event
		 */
		protected function onPreinitialize(event:FlexEvent):void {
			removeEventListener(FlexEvent.PREINITIALIZE, onPreinitialize);
			
			switch (media) {
				case "print":
					setStyle("skinClass", getStyle("printingSkinClass"));
					break;
			}
			
		}
		
		protected override function createChildren():void {
			super.createChildren();
			
			// A rather neat way to allow action and navigation content to be defined in skins
			if (skin) {
				if (skin.hasOwnProperty("actionContent"))
					actionContent = skin["actionContent"];
				
				if (skin.hasOwnProperty("navigationContent"))
					navigationContent = skin["navigationContent"];
			}
		}
		
		protected function onAddedToStage(event:Event):void {
			
		}
		
		protected function onRemovedFromStage(event:Event):void {
			_href = null;
			_xhtml = null;
		}
		
		/**
		 * This is fired when all skin parts are available, each time the view is added to the screen.  It can be used to assign copy.
		 */
		protected function onViewCreationComplete():void {
			
		}
		
		[Bindable]
		public function get href():Href {
			return _href;
		}
		
		public function set href(value:Href):void {
			_href = value;
			_hrefChanged = true;
			
			invalidateProperties();
		}
		
		public function set xhtml(value:XHTML):void {
			_xhtml = value;
			_xhtmlChanged = true;
			
			invalidateProperties();
		}
		
		[Bindable(event="productVersionChanged")]
		public function get productVersion():String {
			return _productVersion;
		}
		
		public function set productVersion(value:String):void {
			if (_productVersion != value) {
				_productVersion = value;
				dispatchEvent(new Event("productVersionChanged"));
			}
		}
		
		[Bindable(event="productCodeChanged")]
		public function get productCode():String {
			return _productCode;
		}
		
		public function set productCode(value:String):void {
			if (_productCode != value) {
				_productCode = value;
				dispatchEvent(new Event("productCodeChanged"));
			}
		}
		
		[Bindable(event="licenceTypeChanged")]
		public function get licenceType():uint {
			return _licenceType;
		}
		
		public function set licenceType(value:uint):void {
			if (_licenceType != value) {
				_licenceType = value;
				dispatchEvent(new Event("licenceTypeChanged"));
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_hrefChanged)
				dispatchEvent(new BentoEvent(BentoEvent.HREF_CHANGED));
			
			if (_xhtmlChanged) {
				updateViewFromXHTML(_xhtml);
				dispatchEvent(new BentoEvent(BentoEvent.XHTML_READY));
			}
			
			_hrefChanged = _xhtmlChanged = false;
		}
		
		protected function updateViewFromXHTML(xhtml:XHTML):void {
			
		}
		
		/**
		 * Shorthand to access the menu node within the model
		 * 
		 * @return 
		 */
		protected function get menu():XML {
			// #338 The model no longer holds head and script for the menu
			return (_xhtml) ? _xhtml.head.script.(@id == "model" && @type == "application/xml").menu[0] : null;
		}
		
	}
	
}