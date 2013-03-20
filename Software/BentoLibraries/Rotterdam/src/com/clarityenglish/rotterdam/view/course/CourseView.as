package com.clarityenglish.rotterdam.view.course {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.view.course.events.UnitDeleteEvent;
	import com.clarityenglish.rotterdam.view.settings.SettingsView;
	import com.clarityenglish.rotterdam.view.unit.UnitHeaderView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.events.CloseEvent;
	import mx.events.IndexChangedEvent;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	import ws.tink.spark.controls.Alert;
	
	/*[SkinState("uniteditor")] - this is an optional skin state */
	[SkinState("unitplayer")]
	public class CourseView extends BentoView {
		
		[SkinPart]
		public var courseCaptionLabel:Label;
		
		[SkinPart(required="true")]
		public var unitList:List;
		
		[SkinPart]
		public var addUnitButton:Button;
		
		[SkinPart]
		public var courseSettingsButton:Button;
		
		[SkinPart]
		public var coursePublishButton:Button;
		
		[SkinPart]
		public var unitCopyButton:Button;
		
		[SkinPart]
		public var unitPasteButton:Button;
		
		[SkinPart]
		public var unitHeader:UnitHeaderView;
		
		[Bindable]
		public var unitListCollection:ListCollectionView;
		
		private var _isPreviewVisible:Boolean;
		//gh #211
		private var currentIndex:Number;
		private var unitListLength:Number;
		
		public var unitSelect:Signal = new Signal(XML);
		public var coursePublish:Signal = new Signal();
		
		private function get course():XML {	
			return _xhtml.selectOne("script#model[type='application/xml'] course");
		}
		
		public function set previewVisible(value:Boolean):void {
			if (_isPreviewVisible !== value) {
				_isPreviewVisible = value;
				invalidateSkinState();
			}
		}
		
		public function canPasteFromTarget(target:Object):Boolean {
			return target == unitList || target == unitPasteButton;
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			if (courseCaptionLabel) courseCaptionLabel.text = course.@caption;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_isPreviewVisible) {
				if (unitHeader.editButton)
					unitHeader.editButton.visible = false;
			} else {
				if (unitHeader.editButton)
					unitHeader.editButton.visible = true;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case unitList:									
					unitList.dragEnabled = unitList.dropEnabled = unitList.dragMoveEnabled = true;
					unitList.addEventListener(IndexChangeEvent.CHANGE, onUnitSelected);
					unitList.addEventListener(UnitDeleteEvent.UNIT_DELETE, onUnitDelete);
					
					// gh#14 - auto select a unit and gh#151 - autoselect the first enabled unit
					callLater(function():void {
						if (unitList.dataProvider && unitList.dataProvider.length > 0) {								
							for each (var unit:XML in (unitList.dataProvider as XMLListCollection).source) {
								if (!(unit.hasOwnProperty("@enabledFlag") && unit.@enabledFlag & 8)) {
									unitList.requireSelection = true;
									unitList.selectedItem = unit;
									//gh #211
									unitList.selectedIndex = 0;
									unitList.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
									break;
								}
							}
							
							// If we reach here then there are no enabled units - probably we want to display a graphic or something
						}
					});
					break;
				case addUnitButton:
					addUnitButton.addEventListener(MouseEvent.CLICK, onAddUnit);
					break;
				case courseSettingsButton:
					courseSettingsButton.addEventListener(MouseEvent.CLICK, onCourseSettings);
					break;
				case coursePublishButton:
					coursePublishButton.addEventListener(MouseEvent.CLICK, onCoursePublish);
					break;
				case unitCopyButton:
					unitCopyButton.addEventListener(MouseEvent.CLICK, onUnitCopy);
					break;
				case unitPasteButton:
					unitPasteButton.addEventListener(MouseEvent.CLICK, onUnitPaste);
					break;
			}
		}
		
		protected function onUnitSelected(event:IndexChangeEvent):void {
			unitSelect.dispatch(event.target.selectedItem);
		}
		
		protected function onUnitDelete(event:UnitDeleteEvent):void {
			//gh #211
			unitListLength = unitList.dataProvider.length;
			currentIndex = unitListCollection.getItemIndex(event.unit);

			Alert.show("Are you sure", "Delete", Vector.<String>([ "No", "Yes" ]), this, function(closeEvent:CloseEvent):void {
				if (closeEvent.detail == 1) {
					if (unitListLength > 1) {
						unitListCollection.removeItemAt(unitListCollection.getItemIndex(event.unit));
						
						//gh #211
						if (currentIndex != 0) {							
							unitList.selectedIndex = currentIndex-1;
						} 
						unitList.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));						
					} else {					
						var unitXML:XML = event.unit;
						var exerciseTotal:Number = unitXML.children().length();
						while (exerciseTotal > 0){
							delete unitXML.children()[0];
							exerciseTotal--;
						}
						unitXML.@caption = "My unit";
						unitSelect.dispatch(unitXML);
					}									
				}				
			});
		}
		
		private function onAddUnit(event:MouseEvent):void {
			// TODO: need to have the designs to know exactly how this will work but for now just use a random name.
			// Also this should use a notification and command instead of adding it directly to the collection.
			unitListCollection.addItem(<unit caption='New unit' />);
		}
		
		protected function onCourseSettings(event:MouseEvent):void {
			navigator.pushView(SettingsView);
		}
		
		protected function onCoursePublish(event:MouseEvent):void {
			coursePublish.dispatch();
		}
		
		protected function onUnitCopy(event:MouseEvent):void {
			dispatchEvent(new Event(Event.COPY, true));
		}
		
		protected function onUnitPaste(event:MouseEvent):void {
			// gh#110 - dispatch the event from the button rather than the view so that we can test for the target before actually doing the paste.  This means
			// that we can make sure pastes only happen when the list has the focus, or the button was clicked.
			unitPasteButton.dispatchEvent(new Event(Event.PASTE, true));
		}
		
		/**
		 * TODO: Switch between editing and viewing
		 */
		protected override function getCurrentSkinState():String {
			return (_isPreviewVisible) ? "unitplayer" : "uniteditor";
		}

	}
}