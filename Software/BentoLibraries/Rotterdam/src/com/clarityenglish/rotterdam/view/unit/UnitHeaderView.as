package com.clarityenglish.rotterdam.view.unit {
	import com.clarityenglish.bento.view.base.BentoView;
	
	import spark.components.Label;
	
	public class UnitHeaderView extends BentoView {
		
		[SkinPart(required="true")]
		public var unitCaptionLabel:Label;
		
		private var _unit:XML;
		private var _unitChanged:Boolean;
		
		public function set unit(value:XML):void {
			_unit = value;
			_unitChanged = true;
			invalidateProperties();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_unitChanged) {
				unitCaptionLabel.text = _unit.@caption;
				_unitChanged = false;
			}
		}

	}
	
}
