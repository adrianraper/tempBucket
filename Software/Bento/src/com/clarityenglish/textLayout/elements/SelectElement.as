package com.clarityenglish.textLayout.elements {
	import com.clarityenglish.bento.vo.content.model.answer.Answer;
	
	import flashx.textLayout.tlf_internal;
	
	import mx.collections.XMLListCollection;
	
	import net.digitalprimates.collections.VectorListCollection;
	
	import spark.components.DropDownList;

	use namespace tlf_internal;
	
	public class SelectElement extends TextComponentElement implements IComponentElement {
		
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
		
		public function createComponent():void {
			text = getLongestOption() + "____.";
			
			var dropDownList:DropDownList = new DropDownList();
			dropDownList.dataProvider = new XMLListCollection(_options);
			
			component = dropDownList;
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