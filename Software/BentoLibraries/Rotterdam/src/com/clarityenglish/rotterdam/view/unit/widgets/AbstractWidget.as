package com.clarityenglish.rotterdam.view.unit.widgets {
	import almerblank.flex.spark.components.SkinnableItemRenderer;
	
	import com.clarityenglish.rotterdam.view.unit.layouts.IUnitLayoutElement;
	
	/**
	 * TODO: Implement an xml notification watcher (setNotifications) to watch for changes and fire events that will trigger bindings on the getters.
	 * For example, [Bindable("titleAttrChanged")].
	 */
	[SkinState("normal")]
	[SkinState("editing")]
	public class AbstractWidget extends SkinnableItemRenderer implements IUnitLayoutElement {
		
		protected var _xml:XML;
		
		[Bindable]
		public function get xml():XML {
			return _xml;
		}

		public function set xml(value:XML):void {
			_xml = value;
		}
		
		public function get column():uint {
			return _xml.@column;
		}
		
		public function get span():uint {
			return _xml.@span;
		}
		
		public function get title():String {
			return _xml.@title;
		}
		
		public function AbstractWidget() {
			super();
		}
		
		protected override function getCurrentSkinState():String {
			// TODO: Needs to support normal and editing
			return "editing";
		}
		
	}
}
