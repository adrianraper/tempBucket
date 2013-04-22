package com.clarityenglish.rotterdam.view.unit {
	import com.clarityenglish.bento.view.base.BentoView;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import org.davekeen.util.StringUtils;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.TextInput;
	
	public class UnitHeaderView extends BentoView {
		
		/*[SkinPart(required="true")]
		public var unitCaptionLabel:Label;
		
		[SkinPart]
		public var editButton:Button;*/
		
		[SkinPart]
		public var unitCaptionTextInput:TextInput;
		
		/*[SkinPart]
		public var doneButton:Button;*/
		
		private var _unit:XML;
		private var _unitChanged:Boolean;
		
		private var _editing:Boolean;
		
		public function set unit(value:XML):void {
			_unit = value;
			_unitChanged = true;
			invalidateProperties();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_unitChanged) {
				//if (unitCaptionLabel) unitCaptionLabel.text = _unit.@caption;
				if (unitCaptionTextInput) unitCaptionTextInput.text = _unit.@caption;
				_unitChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				/*case editButton:
					editButton.addEventListener(MouseEvent.CLICK, onEdit);
					break;
				case doneButton:
					doneButton.addEventListener(MouseEvent.CLICK, onDone);
					break;*/
				case unitCaptionTextInput:
					unitCaptionTextInput.addEventListener(FlexEvent.ENTER, onDone);
					unitCaptionTextInput.addEventListener(FocusEvent.FOCUS_OUT, onDone);
					break;
			}
		}
		
		/*protected function onEdit(event:MouseEvent):void {
			_editing = true;
			invalidateSkinState();
			
			callLater(function():void {
				unitCaptionTextInput.text = _unit.@caption;
				unitCaptionTextInput.setFocus();
				unitCaptionTextInput.selectAll();
			});
		}*/
		
		protected function onDone(event:Event):void {
			_unit.@caption = StringUtils.trim(unitCaptionTextInput.text);
			
			_editing = false;
			invalidateSkinState();
			
			callLater(function():void {
				_unitChanged = true;
				invalidateProperties();
			});
		}
		
		protected override function getCurrentSkinState():String {
			return _editing ? "editing" : super.getCurrentSkinState();
		}
		
	}
	
}
