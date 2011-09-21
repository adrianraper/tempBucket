package com.clarityenglish.bento.view.base {
	import com.clarityenglish.bento.view.base.events.BentoEvent;
	import com.clarityenglish.bento.vo.Href;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	/**
	 * This is the parent class of all views in Bento.
	 * 
	 * @author Dave
	 */
	[Event(name="hrefChanged", type="com.clarityenglish.bento.view.base.events.BentoEvent")]
	public class BentoView extends SkinnableComponent {
		
		private var _hrefChanged:Boolean = false;
		private var _href:Href;
		
		public function get href():Href {
			return _href;
		}

		public function set href(value:Href):void {
			_href = value;
			_hrefChanged = true;
			
			invalidateProperties();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_hrefChanged) {
				dispatchEvent(new BentoEvent(BentoEvent.HREF_CHANGED));
				_hrefChanged = false;
			}
		}
		
	}
	
}