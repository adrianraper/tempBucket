package com.clarityenglish.tensebuster.view.unit
{
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	
	import mx.collections.XMLListCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	public class UnitView extends BentoView {
		
		[SkinPart]
		public var unitList:List;
		
		private var _course:XML;
		private var _courseChanged:Boolean; 
		
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
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_courseChanged) {
				unitList.dataProvider = new XMLListCollection(_course.unit);
				_courseChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case unitList:
					unitList.addEventListener(IndexChangeEvent.CHANGE, onUnitChange);
					break;
			}
		}
		
		protected function onUnitChange(event:IndexChangeEvent):void {
			var unit:XML =  event.currentTarget.selectedItem as XML;
			if (unit)
				unitSelect.dispatch(unit);
			
		}
	}
}