package com.clarityenglish.rotterdam.clearpronunciation.view.home {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.textLayout.vo.XHTML;
	import com.hurlant.crypto.symmetric.NullPad;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.events.IndexChangedEvent;
	
	import org.osflash.signals.Signal;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	public class HomeView extends BentoView {
		
		[SkinPart]
		public var unitList:List;
		
		[SkinPart(required="true")]
		public var courseList:List;
		
		public var selectUnit:Signal = new Signal(XML);

		private var _unitListCollection:ListCollectionView; 
		private var _selectedCourseID:String;
		private var _selectedCourseIDChanged:Boolean;
		private var _unit:XML;
		private var _selectedUnitIndex:Number;
		
		[Bindable]
		public function get unit():XML {
			return _unit;
		}
		
		public function set unit(value:XML):void {
			_unit = value;
		}
		
		[Bindable]
		public function get selectedUnitIndex():Number {
			return _selectedUnitIndex;
		}
		
		public function set selectedUnitIndex(value:Number):void {
			_selectedUnitIndex = value;
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			courseList.dataProvider = new XMLListCollection(xhtml..menu.(@id == productCode).course);
			
			if (_unit) {
				var index:Number = 0;
				for each (var course:XML in (courseList.dataProvider as XMLListCollection).source) {
					if (course.@id == _unit.parent().@id) {
						courseList.requireSelection = true;
						courseList.selectedItem = _unit.parent();
						courseList.selectedIndex = index;
						courseList.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
						break;
					}
					index++;
				}
				
				index = 0;
				for each (var unit:XML in (unitList.dataProvider as XMLListCollection).source) {
					if (unit.@id == _unit.@id) {
						unitList.requireSelection = true;
						unitList.selectedItem = unit;
						unitList.selectedIndex = index;
						break;
					}
					index++;
				}
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case courseList:
					courseList.addEventListener(MouseEvent.CLICK, onCourseListClick);
					courseList.addEventListener(IndexChangeEvent.CHANGE, onCourseListIndexChange);
					break;
				case unitList:
					unitList.addEventListener(MouseEvent.CLICK, onUnitListClick);
					break;
			}
		}
		
		protected function onCourseListIndexChange(event:Event):void {
			unitList.requireSelection = false;
		}
		
		protected function onCourseListClick(event:Event):void {
			if (courseList.selectedItem)
				unitList.dataProvider = new XMLListCollection(courseList.selectedItem.unit);	
		}
		
		protected function onUnitListClick(event:Event):void {
			if (unitList.selectedItem)
				selectUnit.dispatch(unitList.selectedItem);
		}
	}
}