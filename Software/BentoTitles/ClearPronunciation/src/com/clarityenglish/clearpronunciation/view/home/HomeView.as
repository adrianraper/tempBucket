package com.clarityenglish.clearpronunciation.view.home {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.clearpronunciation.view.home.event.ListItemSelectedEvent;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.controls.video.UniversalVideoPlayer;
	import com.clarityenglish.controls.video.VideoSelector;
	import com.clarityenglish.textLayout.vo.XHTML;
	import com.hurlant.crypto.symmetric.NullPad;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.controls.Label;
	import mx.core.ClassFactory;
	import mx.events.FlexEvent;
	import mx.events.IndexChangedEvent;
	
	import org.osflash.signals.Signal;
	
	import skins.clearpronunciation.home.ui.UnitListItemRenderer;
	import skins.rotterdam.course.UnitListContainerSkin;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	public class HomeView extends BentoView {
		
		[SkinPart]
		public var consonantsLeftList:List;
		
		[SkinPart]
		public var consonantsRightList:List;
		
		[SkinPart]
		public var vowelsLeftList:List;
		
		[SkinPart]
		public var vowelsRightList:List;
		
		[SkinPart]
		public var diphthongsList:List;
		
		[SkinPart(required="true")]
		public var courseList:List;
		
		[SkinPart]
		public var videoSelector:VideoSelector;
		
		[SkinPart]
		public var unitListInstuctionGroup:Group;
		
		[SkinPart]
		public var homeInstructionLabel:spark.components.Label;
		
		[SkinPart]
		public var consonantsListHGroup:HGroup;
		
		[SkinPart]
		public var vowelsListHGroup:HGroup;
		
		[SkinPart]
		public var dispthongsGroup:Group;
		
		[Bindable]
		public var mediaFolder:String;
		
		[Bindable]
		public var unitList:List;
		
		[Bindable]
		public var listGroup:Object;
		
		public var exerciseShow:Signal = new Signal(XML);
		public var channelCollection:ArrayCollection;
		
		private var consonantsLeftXMLListCollection:XMLListCollection = new XMLListCollection();
		private var consonantsRightXMLListCollection:XMLListCollection = new XMLListCollection();
		private var vowelsLeftXMLListCollection:XMLListCollection = new XMLListCollection();
		private var vowelsRightXMLListCollection:XMLListCollection = new XMLListCollection();
		private var _unitListCollection:ListCollectionView; 
		private var _selectedCourseID:String;
		private var _selectedCourseIDChanged:Boolean;
		private var _course:XMLList;
		private var _unit:XML;
		private var _selectedUnitIndex:Number;
		private var _selectedCourseIndex:Number;
		
		public function HomeView():void {
			super();
			actionBarVisible = false;
		}
		
		[Bindable]
		public function get course():XMLList {
			return _course;
		}
		
		public function set course(value:XMLList):void {
			_course = value;
		}
		
		[Bindable]
		public function get selectedCourseIndex():Number {
			return _selectedCourseIndex;
		}
		
		public function set selectedCourseIndex(value:Number):void {
			_selectedCourseIndex = value;
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
			
			for each (var consonantsUnit:XML in xhtml..menu.(@id == productCode).course.(@["class"] == "consonants").unit) {
				if (consonantsUnit.childIndex() < 7) {
					consonantsLeftXMLListCollection.addItem(consonantsUnit);
				} else {
					consonantsRightXMLListCollection.addItem(consonantsUnit);
				}	
			}
			consonantsLeftList.dataProvider = consonantsLeftXMLListCollection;
			consonantsRightList.dataProvider = consonantsRightXMLListCollection;
			
			for each (var vowelsUnit:XML in xhtml..menu.(@id == productCode).course.(@["class"] == "vowels").unit) {
				if (vowelsUnit.childIndex() < 4) {
					vowelsLeftXMLListCollection.addItem(vowelsUnit);
				} else {
					vowelsRightXMLListCollection.addItem(vowelsUnit);
				}
			}
			vowelsLeftList.dataProvider = vowelsLeftXMLListCollection;
			vowelsRightList.dataProvider = vowelsRightXMLListCollection;
			
			diphthongsList.dataProvider = new XMLListCollection(xhtml..menu.(@id == productCode).course.(@["class"] == "diphthongs").unit);
			
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
				unitList = getUnitList(courseList.selectedIndex);
				for each (var unit:XML in (unitList.dataProvider as XMLListCollection).source) {
					if (unit.@id == _unit.@id) {
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
				case consonantsLeftList:
				case consonantsRightList:
				case vowelsLeftList:
				case vowelsRightList:
				case diphthongsList:
					instance.addEventListener(MouseEvent.CLICK, onUnitListClick);
					instance.addEventListener(ListItemSelectedEvent.SELECTED, onItemSelected);
					var unitListItemRenderer:ClassFactory = new ClassFactory(UnitListItemRenderer);
					unitListItemRenderer.properties = { copyProvider: copyProvider};
					instance.itemRenderer = unitListItemRenderer;
					break;
				case homeInstructionLabel:
					homeInstructionLabel.text = copyProvider.getCopyForId("homeInstructionLabel");
					break;
			}		
		}
		
		protected function onCourseListIndexChange(event:Event):void {
			listGroup = getListGroup(courseList.selectedIndex);
			selectedCourseIndex = courseList.selectedIndex;
			// when select another course, close the drop down list if it is open.
			consonantsRightList.selectedItem = null;
			consonantsLeftList.selectedItem = null;
			vowelsRightList.selectedItem = null;
			vowelsLeftList.selectedItem = null;
			diphthongsList.selectedItem = null;
			
			if (courseList.selectedItem) {
				unitListInstuctionGroup.visible = false;
				if (courseList.selectedIndex == 0) {
					videoSelector.visible = true;
					//videoSelector.videoList.selectedIndex = 0;
					//videoSelector.videoList.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
					listGroup.visible = false;
				} else {
					videoSelector.visible = false;
					videoSelector.videoPlayer.visible = false;
					listGroup.visible = true;
				}
				
			}
		}
		
		// Because the unit list is separated into left and right, we need to figure out which list is selected and hence to hide the other one.
		protected function onUnitListClick(event:MouseEvent):void {
			if (event.currentTarget == consonantsLeftList) {
				consonantsRightList.selectedItem = null;
			} else if (event.currentTarget == consonantsRightList) {
				consonantsLeftList.selectedItem = null;
			} else if (event.currentTarget == vowelsLeftList) {
				vowelsRightList.selectedItem = null;
			} else if (event.currentTarget == vowelsRightList) {
				vowelsLeftList.selectedItem = null;
			}
		}
		
		protected function onItemSelected(event:ListItemSelectedEvent):void {
			trace("selected item: "+event.item);
			exerciseShow.dispatch(event.item);
		}
		
		// get selected list
		private function getUnitList(value:Number):List {
			switch (value) {
				case 1:
					if (_unit.childIndex() < 7) {
						return consonantsLeftList;
					} else {
						return consonantsRightList;
					}
				case 2:
					if (_unit.childIndex() < 4) {
						return vowelsLeftList;
					} else {
						return vowelsRightList;
					}	
				case 3:
					return diphthongsList;
				default:
					return consonantsLeftList;
			}
		}
		
		// show correct unitlist group according to selected course index
		private function getListGroup(value:Number):Object {
			switch (value) {
				case 1:
					return consonantsListHGroup;
				case 2:
					return vowelsListHGroup;
				case 3:
					return dispthongsGroup;
				default:
					return consonantsListHGroup;
			}
		}
	}
}