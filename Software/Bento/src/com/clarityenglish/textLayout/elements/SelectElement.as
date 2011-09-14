package com.clarityenglish.textLayout.elements {
	import com.clarityenglish.bento.vo.content.model.Answer;
	
	import flashx.textLayout.tlf_internal;
	
	import net.digitalprimates.collections.VectorListCollection;
	
	import spark.components.DropDownList;

	use namespace tlf_internal;
	
	public class SelectElement extends TextComponentElement implements IComponentElement {
		
		// TODO: Check for memory leaks
		private var _answers:Vector.<Answer>;
		
		public function SelectElement() {
			super();
		}
		
		protected override function get abstract():Boolean {
			return false;
		}
		
		public function set answers(value:Vector.<Answer>):void {
			_answers = value;
		}
		
		/** @private */
		tlf_internal override function get defaultTypeName():String
		{ return "select"; }
		
		public function createComponent():void {
			var dropDownList:DropDownList = new DropDownList();
			dropDownList.labelField = "value";
			dropDownList.dataProvider = new VectorListCollection(_answers);
			
			component = dropDownList;
		}
		
	}
	
}