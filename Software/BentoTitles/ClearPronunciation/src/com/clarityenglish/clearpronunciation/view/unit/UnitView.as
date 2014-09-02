package com.clarityenglish.clearpronunciation.view.unit {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.view.unit.ui.WidgetList;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	
	public class UnitView extends BentoView {
		
		[SkinPart]
		public var practiseSoundsList:WidgetList;
		
		[SkinPart]
		public var makeSoundsList:WidgetList;
		
		protected var _widgetCollection:ListCollectionView;
		
		private var _widgetCollectionChanged:Boolean;
		private var _channelCollection:ArrayCollection;
		
		[Bindable(event="widgetCollectionChanged")]
		public function get widgetCollection():ListCollectionView {
			return _widgetCollection;
		}
		
		public function set widgetCollection(value:ListCollectionView):void {
			// gh#731
			if (value !== _widgetCollection) {
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
		
		[Bindable]
		public function get channelCollection():ArrayCollection {
			return _channelCollection;
		}
		
		public function set channelCollection(value:ArrayCollection):void {
			_channelCollection = value;
		}
		
		/*protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			widgetCollection = new XMLListCollection(xhtml.xml.course.unit.exercise);
		}*/
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case practiseSoundsList:
				case makeSoundsList:
					instance.href = href;
					instance.channelCollection = channelCollection;
					break;
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (widgetCollection && _widgetCollectionChanged) {
				//practiseSoundsList.dataProvider = widgetCollection;
				for (var i:Number = 0; i < widgetCollection.length; i++) {
					if (widgetCollection[i]["@class"] == "practiseSounds") {
						practiseSoundsList.dataProvider = new XMLListCollection(widgetCollection[i].exercise);
					} else if (widgetCollection[i]["@class"] == "makeSounds") {
						makeSoundsList.dataProvider = new XMLListCollection(widgetCollection[i].exercise);
					}
				}
			}
		}
	}
}