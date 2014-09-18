package com.clarityenglish.clearpronunciation.view.home {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.controls.video.UniversalVideoPlayer;
	import com.clarityenglish.controls.video.VideoSelector;
	import com.clarityenglish.textLayout.vo.XHTML;
	import com.hurlant.crypto.symmetric.NullPad;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.controls.Label;
	import mx.events.FlexEvent;
	import mx.events.IndexChangedEvent;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	public class HomeView extends BentoView {
		
		[SkinPart]
		public var unitList:List;
		
		[SkinPart(required="true")]
		public var courseList:List;
		
		[SkinPart]
		public var videoSelector:VideoSelector;
		
		[SkinPart]
		public var unitListInstuctionGroup:Group;
		
		[SkinPart]
		public var homeInstructionLabel:spark.components.Label;
		
		[Bindable]
		public var mediaFolder:String;
		
		public var selectUnit:Signal = new Signal(XML);
		public var channelCollection:ArrayCollection;
		
		private var _unitListCollection:ListCollectionView; 
		private var _selectedCourseID:String;
		private var _selectedCourseIDChanged:Boolean;
		private var _course:XMLList;
		private var _unit:XML;
		private var _selectedUnitIndex:Number;
		
		public function HomeView():void {
			super();
			actionBarVisible = false;
		}
		
		public function set course(value:XMLList):void {
			_course = value;
		}
		
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
		
		public function getCopyProvider():CopyProvider {
			return copyProvider;
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			courseList.dataProvider = new XMLListCollection(xhtml..menu.(@id == productCode).course);
			_course = xhtml..menu.(@id == productCode).course;
			
			// when return to home page, we want to display the selected course and unit
			if (_unit) {
				var index:Number = 0;
				for each (var course:XML in (courseList.dataProvider as XMLListCollection).source) {
					if (course.@id == _unit.parent().@id) {
						courseList.requireSelection = true;
						courseList.selectedItem = _unit.parent();
						courseList.selectedIndex = index;
						courseList.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
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
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (videoSelector) {
				videoSelector.href = href;
				videoSelector.channelCollection = channelCollection;
				videoSelector.videoCollection = new XMLListCollection(_course[0].unit[0].exercise);
				videoSelector.placeholderSource = href.rootPath + "/" + _course[0].unit[0].exercise.@placeholder;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case courseList:
					courseList.addEventListener(IndexChangeEvent.CHANGE, onCourseListIndexChange);
					break;
				case unitList:
					unitList.addEventListener(MouseEvent.CLICK, onUnitListClick);
					break;
				case homeInstructionLabel:
					homeInstructionLabel.text = copyProvider.getCopyForId("homeInstructionLabel");
					break;
			}
		}
		
		protected function onCourseListIndexChange(event:Event):void {
			unitList.requireSelection = false;
			
			if (courseList.selectedItem) {
				unitListInstuctionGroup.visible = false;
				if (courseList.selectedIndex == 0) {
					videoSelector.visible = true;
					//videoSelector.videoList.selectedIndex = 0;
					//videoSelector.videoList.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
					unitList.visible = false;
				} else {
					videoSelector.visible = false;
					videoSelector.videoPlayer.visible = false;
					unitList.visible = true;
					unitList.dataProvider = new XMLListCollection(courseList.selectedItem.unit);	
				}
				
			}
		}
		
		protected function onUnitListClick(event:Event):void {
			if (unitList.selectedItem)
				selectUnit.dispatch(unitList.selectedItem);
		}
	}
}