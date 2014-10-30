package com.clarityenglish.clearpronunciation.view.unit {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.view.unit.ui.WidgetList;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	
	import spark.components.Label;
	
	public class UnitView extends BentoView {
		
		[SkinPart]
		public var practiseSoundsList:WidgetList;
		
		[SkinPart]
		public var makeSoundsList:WidgetList;
		
		[SkinPart]
		public var practiseSoundsLabel:Label;
		
		[SkinPart]
		public var makeSoundsLabel:Label;
		
		protected var _widgetCollection:ListCollectionView;
		
		private var _widgetCollectionChanged:Boolean;
		private var _channelCollection:ArrayCollection;
		private var _practiseSoundsCollection:XMLListCollection;
		private var _makeSoundsListCollection:XMLListCollection;
		private var _isPlatformiPad:Boolean;
		
		
		[Bindable(event="widgetCollectionChanged")]
		public function get widgetCollection():ListCollectionView {
			return _widgetCollection;
		}
		
		public function set widgetCollection(value:ListCollectionView):void {
			// gh#731
			if (value !== _widgetCollection && value) {
				_widgetCollection = null;
				dispatchEvent(new Event("widgetCollectionChanged"));
				
				callLater(function():void {
					_widgetCollection = value;
					dispatchEvent(new Event("widgetCollectionChanged"));
					
					_widgetCollectionChanged = true;
					invalidateProperties();
				});
			}
		}
		
		[Bindable(event="practiseSoundsCollectionChanged")]
		public function get practiseSoundsCollection():XMLListCollection {
			return _practiseSoundsCollection;
		}
		
		public function set practiseSoundsCollection(value:XMLListCollection):void {
			if (value !== _practiseSoundsCollection) {
				_practiseSoundsCollection = null;
				dispatchEvent(new Event("practiseSoundsCollectionChanged"));
				
				callLater(function():void {
					_practiseSoundsCollection = value;
					dispatchEvent(new Event("practiseSoundsCollectionChanged"));
				});
			}
		}
		
		[Bindable(event="makeSoundsListCollectionChanged")]
		public function get makeSoundsListCollection():XMLListCollection {
			return _makeSoundsListCollection;
		}
		
		public function set makeSoundsListCollection(value:XMLListCollection):void {
			if (value !== _makeSoundsListCollection) {
				_makeSoundsListCollection = null;
				dispatchEvent(new Event("makeSoundsListCollectionChanged"));
				
				callLater(function():void {
					_makeSoundsListCollection = value;
					dispatchEvent(new Event("makeSoundsListCollectionChanged"));
				});
			}
		}
		
		[Bindable]
		public function get channelCollection():ArrayCollection {
			return _channelCollection;
		}
		
		public function set channelCollection(value:ArrayCollection):void {
			_channelCollection = value;
		}
		
		[Bindable]
		public function get isPlatformiPad():Boolean {
			return _isPlatformiPad;
		}
		
		public function set isPlatformiPad(value:Boolean):void {
			_isPlatformiPad = value;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case practiseSoundsList:
				case makeSoundsList:
					instance.href = href;
					instance.channelCollection = channelCollection;
					break;
				case practiseSoundsLabel:
					practiseSoundsLabel.text = copyProvider.getCopyForId("practiseSoundsLabel");
					break;
				case makeSoundsLabel:
					makeSoundsLabel.text = copyProvider.getCopyForId("makeSoundsLabel");
					break;
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (widgetCollection && _widgetCollectionChanged) {
				//practiseSoundsList.dataProvider = widgetCollection;
				for (var i:Number = 0; i < widgetCollection.length; i++) {
					if (widgetCollection[i]["@class"] == "practiseSounds") {
						practiseSoundsCollection = new XMLListCollection(widgetCollection[i].exercise);
					} else if (widgetCollection[i]["@class"] == "makeSounds" && !isPlatformiPad) {
						makeSoundsListCollection = new XMLListCollection(widgetCollection[i].exercise);
					}
				}
			}
		}
	}
}