package com.clarityenglish.textLayout.elements {
	import com.clarityenglish.components.SpinnerDropDownList;
	
	import flash.events.Event;
	
	import flashx.textLayout.tlf_internal;
	
	import mx.collections.XMLListCollection;
	import mx.events.FlexEvent;
	
	import skins.bento.components.SpinnerDropDownListSkin;
	
	import spark.components.DropDownList;

	use namespace tlf_internal;
	
	public class SelectElement extends TextComponentElement implements IComponentElement {
		
		/**
		 * An optional function that creates the element 
		 */
		public static var elementFactoryFunction:Function;
		
		/**
		 * For simplicity this component receives any child option tags as an XMLList so we keep any attributes
		 */
		private var _options:XMLList;
		
		public function SelectElement() {
			super();
		}
		
		protected override function get abstract():Boolean {
			return false;
		}
		
		public function set options(value:XMLList):void {
			_options = value;
		}
		
		/** @private */
		tlf_internal override function get defaultTypeName():String
		{ return "select"; }
		
		public function get selectedItem():XML {
			return (component) ? (component as DropDownList).selectedItem : null;
		}
		
		public function set selectedItem(value:XML):void {
			if (component)
				(component as DropDownList).selectedItem = value;
		}
		
		public function createComponent():void {
			text = getLongestOption() + "____.";
			
			// Default to a normal DropDownList, but also allow a custom elementFactoryFunction to be defined (used to create the Spinner for AIR apps)
			var dropDownList:DropDownList = (elementFactoryFunction == null) ? new DropDownList() : elementFactoryFunction();
			dropDownList.dataProvider = new XMLListCollection(_options);
			
			component = dropDownList;
			
			// Duplicate some events on the event mirror so other things can listen to the FlowElement
			component.addEventListener(Event.CHANGE, function(e:Event):void { getEventMirror().dispatchEvent(e.clone()); } );
		}
		
		private function getLongestOption():String {
			var longestOption:String = "";
			for each (var option:XML in _options)
				if (option.toString().length > longestOption.length)
					longestOption = option.toString();
			
			return longestOption;
		}
		
	}
	
}