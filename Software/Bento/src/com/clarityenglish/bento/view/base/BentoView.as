package com.clarityenglish.bento.view.base {
	import com.clarityenglish.bento.view.base.events.BentoEvent;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	/**
	 * This is the parent class of all views in Bento.
	 * 
	 * @author Dave
	 */
	[Event(name="hrefChanged", type="com.clarityenglish.bento.view.base.events.BentoEvent")]
	[Event(name="xhtmlReady", type="com.clarityenglish.bento.view.base.events.BentoEvent")]
	public class BentoView extends SkinnableComponent {
		
		/**
		 * Standard flex logger
		 */
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var _href:Href;
		private var _hrefChanged:Boolean = false;
		
		protected var _xhtml:XHTML;
		private var _xhtmlChanged:Boolean;

		public function BentoView() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
		}
		
		protected function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
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
			return (_xhtml) ? _xhtml.head.script.(@id == "model" && @type == "application/xml").menu[0] : null;
		}
		
	}
	
}