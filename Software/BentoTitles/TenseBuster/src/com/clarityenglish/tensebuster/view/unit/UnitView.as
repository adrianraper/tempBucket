package com.clarityenglish.tensebuster.view.unit
{
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.tensebuster.view.unit.ui.ProgressUnitButton;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.XMLListCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.DataGroup;
	import spark.components.Label;
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	public class UnitView extends BentoView {
		
		[SkinPart(required="true")]
		public var unitList:List;
		
		[SkinPart]
		public var unitInstructionLabel:Label;
		
		[SkinPart]
		public var progressUnitButton:ProgressUnitButton;
		
		private var _course:XML;
		private var _courseChanged:Boolean; 
		private var _courseIndex:Number = 0;
		private var courseArray:Array = ["Elementary", "Lower Intermediate", "Intermediate", "Upper Intermediate", "Advanced"];
		
		public var unitSelect:Signal = new Signal(XML);
		
		[Bindable(event="courseChanged")]
		public function get course():XML {
			return _course;
		}
		
		public function set course(value:XML):void {
			_course = value;
			_courseChanged = true;
			
			invalidateProperties();
			invalidateSkinState();
			
			dispatchEvent(new Event("courseChanged", true));
		}
		
		[Bindable]
		public function get courseIndex():Number {
			return _courseIndex;
		}
		
		public function set courseIndex(value:Number):void {
			_courseIndex = value;
		}
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();

			if (_courseChanged) {
				var courseCaption:String = _course.@caption;
				courseIndex = courseArray.indexOf(courseCaption);
				unitList.dataProvider = new XMLListCollection(_course.unit);
				_courseChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case unitList:
					unitList.addEventListener(MouseEvent.CLICK, onUnitChange);
					break;
				case unitInstructionLabel:
					unitInstructionLabel.text = copyProvider.getCopyForId("unitInstructionLabel");
					break;
			}
		}
		
		protected function onUnitChange(event:MouseEvent):void {
			var unit:XML =  event.currentTarget.selectedItem as XML;
			if (unit)
				unitSelect.dispatch(unit);
			
		}
	}
}