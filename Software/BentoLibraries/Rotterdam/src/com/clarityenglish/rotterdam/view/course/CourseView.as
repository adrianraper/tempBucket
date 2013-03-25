package com.clarityenglish.rotterdam.view.course {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.base.events.BentoEvent;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.rotterdam.view.course.events.UnitDeleteEvent;
	import com.clarityenglish.rotterdam.view.settings.SettingsView;
	import com.clarityenglish.rotterdam.view.unit.UnitHeaderView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.globalization.DateTimeFormatter;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.events.CloseEvent;
	import mx.events.IndexChangedEvent;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.List;
	import spark.components.ToggleButton;
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
		public var publishSettingsButton:Button;
		
		[SkinPart]
		public var oneClickPublishButton:Button;
		
		[SkinPart]
		public var unitCopyButton:Button;
		
		[SkinPart]
		public var unitPasteButton:Button;
		
		[SkinPart]
		public var unitHeader:UnitHeaderView;
		
		[SkinPart]
		public var publishCoursButton:ToggleButton;
		
		[SkinPart]
		public var publishSelectionGroup:spark.components.Group;
		
		[SkinPart]
		public var publishChangeButton:Button;
		
		[Bindable]
		public var unitListCollection:ListCollectionView;
		
		// gh#208 DK: should we pass the group from the mediator to here so that the view can create the default node
		// or should we just let the mediator do it?
		public var group:com.clarityenglish.common.vo.manageable.Group;
		
		private var _isPreviewVisible:Boolean;
		//gh #211
		private var currentIndex:Number;
		private var unitListLength:Number;
		
		//alice p
		private var outsideClick:Boolean = false;
		private var itemClick:Boolean = false;
		
		public var unitSelect:Signal = new Signal(XML);
		public var coursePublish:Signal = new Signal();
		//alice s
		public var helpPublish:Signal = new Signal();
		
		public function get course():XML {	
			return _xhtml.selectOne("script#model[type='application/xml'] course");
		}
		
		public function set previewVisible(value:Boolean):void {
			if (_isPreviewVisible !== value) {
				_isPreviewVisible = value;
				invalidateSkinState();
			}
		}
		
		// gh#208
		[Bindable(event="publishChanged")]
		public function get canPublish():Boolean {
			var temp:Boolean = (course.publication && course.publication.group.length() == 0) ? true : false;
			return temp;
		}
		
		public function canPasteFromTarget(target:Object):Boolean {
			return target == unitList || target == unitPasteButton;
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			if (courseCaptionLabel) courseCaptionLabel.text = course.@caption;
		}
		
		//alice p
		protected override function onAddedToStage(event:Event):void {
			stage.addEventListener(MouseEvent.CLICK, onStageClick);
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
				case publishSettingsButton:
					publishSettingsButton.addEventListener(MouseEvent.CLICK, onCourseSettings);
					break;
				case oneClickPublishButton:
					oneClickPublishButton.addEventListener(MouseEvent.CLICK, onCoursePublish);
					break;
				case unitCopyButton:
					unitCopyButton.addEventListener(MouseEvent.CLICK, onUnitCopy);
					break;
				case unitPasteButton:
					unitPasteButton.addEventListener(MouseEvent.CLICK, onUnitPaste);
					break;
				//alice p
				case publishCoursButton:
					publishCoursButton.addEventListener(MouseEvent.CLICK, onPublishCourse);
					break;
				case publishSelectionGroup:
					publishSelectionGroup.addEventListener(MouseEvent.CLICK, onPublishSelection);
					break
				case publishChangeButton:
					publishChangeButton.addEventListener(MouseEvent.CLICK, onCourseSettings);
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
			//alice S
			if (this.canPublish) {
				helpPublish.dispatch();
			}
			navigator.pushView(SettingsView);
			
			itemClick = true;
		}
		
		protected function onCoursePublish(event:MouseEvent):void {
			// gh#208
			// Check to see if you can use 1-click publish, only on an untouched course
			if (course.publication.group.length() == 0) {
				// create a default publication node
				var formatter:DateTimeFormatter = new DateTimeFormatter("en-US");
				formatter.setDateTimePattern("yyyy-MM-dd");
				var now:Date = new Date();
				var startDate:String = formatter.format(now);
				now.setFullYear(now.fullYear + 1);
				var endDate:String = formatter.format(now);
				
				course.publication.appendChild(<group id={group.id} seePastUnits='1' unitInterval='0' startDate={startDate} endDate={endDate} />);
				coursePublish.dispatch();
			}
			
			itemClick = true;
		}
		
		protected function onUnitCopy(event:MouseEvent):void {
			dispatchEvent(new Event(Event.COPY, true));
		}
		
		protected function onUnitPaste(event:MouseEvent):void {
			// gh#110 - dispatch the event from the button rather than the view so that we can test for the target before actually doing the paste.  This means
			// that we can make sure pastes only happen when the list has the focus, or the button was clicked.
			unitPasteButton.dispatchEvent(new Event(Event.PASTE, true));
		}
		
		// gh#208 
		public function publishChanged():void {
			dispatchEvent(new Event("publishChanged"));
		}
		
		/**
		 * TODO: Switch between editing and viewing
		 */
		protected override function getCurrentSkinState():String {
			return (_isPreviewVisible) ? "unitplayer" : "uniteditor";
		}
		
		//alice p
		protected function onPublishCourse(event:MouseEvent):void {
			publishSelectionGroup.visible = true;
			outsideClick = false;
		}
		
		//alice p
		protected function onPublishSelection(event:MouseEvent):void {
			if (!itemClick) {
				outsideClick = false;
			}
		}
		
		//alice p
		protected function onStageClick(event:MouseEvent):void {
			if (publishSelectionGroup) {
				if (outsideClick) {
					publishSelectionGroup.visible = false;
					publishCoursButton.skin.setCurrentState("up", true);
					publishCoursButton.selected = false;
				} else {
					outsideClick = true;
					itemClick = false;
				}
			}						
		}
		
	}
}