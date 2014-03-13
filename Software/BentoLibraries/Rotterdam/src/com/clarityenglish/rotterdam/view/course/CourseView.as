package com.clarityenglish.rotterdam.view.course {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.rotterdam.view.course.events.UnitDeleteEvent;
	import com.clarityenglish.rotterdam.view.course.ui.PublishButton;
	import com.clarityenglish.rotterdam.view.schedule.ScheduleView;
	import com.clarityenglish.rotterdam.view.settings.SettingsView;
	import com.clarityenglish.rotterdam.view.unit.UnitHeaderView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.globalization.DateTimeFormatter;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.events.CloseEvent;
	import mx.events.EffectEvent;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.List;
	import spark.components.ToggleButton;
	import spark.effects.Animate;
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
		public var scheduleButton:PublishButton;
		
		[SkinPart]
		public var oneClickPublishButton:PublishButton;
		
		[SkinPart]
		public var unitCopyButton:Button;
		
		[SkinPart]
		public var unitPasteButton:Button;
		
		[SkinPart]
		public var unitHeader:UnitHeaderView;
		
		[SkinPart]
		public var publishCourseButton:ToggleButton;
		
		[SkinPart]
		public var publishSelectionGroup:spark.components.Group;
		
		[SkinPart]
		public var publishChangeButton:Button;
		
		[SkinPart]
		public var settingsButton:Button;
		
		[Bindable]
		public var unitListCollection:ListCollectionView;
		
		[SkinPart]
		public var anim:Animate;
		
		// gh#208 DK: should we pass the group from the mediator to here so that the view can create the default node
		// or should we just let the mediator do it?
		public var group:com.clarityenglish.common.vo.manageable.Group;
		
		private var _isPreviewVisible:Boolean = false;
		private var _course:XML;
		private var _isFirstPublish:Boolean;
		private var courseChanged:Boolean;
		// gh#211
		private var currentIndex:Number;
		private var unitListLength:Number;
		
		private var isOutsideClick:Boolean;
		private var isItemClick:Boolean;
		private var isHidden:Boolean;
		//private var isPreview:Boolean;
		// gh#91
		public var isOwner:Boolean;
		public var isCollaborator:Boolean;
		public var isPublisher:Boolean;
		
		public var unitSelect:Signal = new Signal(XML);
		public var coursePublish:Signal = new Signal();
		public var helpPublish:Signal = new Signal();
		public var unitDuplicate:Signal = new Signal();

		[Bindable]
		public function get course():XML {
			return _course;
		}
		
		public function set course(value:XML):void {
			if (_course != value) {
				_course = value;
				courseChanged = true;
				invalidateProperties();
			}
		}
		
		public function set previewVisible(value:Boolean):void {
			if (_isPreviewVisible !== value) {
				_isPreviewVisible = value;
				invalidateSkinState();
			}
		}
		
		[Bindable]
		public function get isFirstPublish():Boolean {
			return _isFirstPublish;
		}
		
		public function set isFirstPublish(value:Boolean):void {
			_isFirstPublish = value;
		}
		// gh#208
		/*[Bindable(event="publishChanged")]
		public function get canPublish():Boolean {
			if (course)
				return (course.publication && course.publication.group.length() == 0) ? true : false;
			return false;
		}*/
		
		public function canPasteFromTarget(target:Object):Boolean {
			return target == unitList || target == unitPasteButton;
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			course = _xhtml.selectOne("script#model[type='application/xml'] course");
			if (courseCaptionLabel) courseCaptionLabel.text = course.@caption;
		}
		
		// gh#208
		protected override function onAddedToStage(event:Event):void {
			stage.addEventListener(MouseEvent.CLICK, onStageClick);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			// gh#91 DKHELP
			//if (isPublisher)
			//	previewVisible = true;
			if (courseChanged) {
				if (course) {
					isFirstPublish = (course.publication && course.publication.group.length() == 0) ? true : false;
					publishCourseButton.visible = isFirstPublish;
					publishChangeButton.visible = !isFirstPublish;
					oneClickPublishButton.visible = isFirstPublish;
				}
				courseChanged = false;
			}
			
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
									
									// gh#211
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
					addUnitButton.label = copyProvider.getCopyForId("addUnitButton");
					break;
				case scheduleButton:
					instance.addEventListener(MouseEvent.CLICK, onSchedule);
					instance.label = copyProvider.getCopyForId("publishSettingsButton");
					instance.text = copyProvider.getCopyForId("publishSettingsLabel");
					break;
				case oneClickPublishButton:
					oneClickPublishButton.addEventListener(MouseEvent.CLICK, onCoursePublish);
					oneClickPublishButton.label = copyProvider.getCopyForId("oneClickPublishButton");
					oneClickPublishButton.text = copyProvider.getCopyForId("oneClickLabel");
					break;
				case unitCopyButton:
					unitCopyButton.addEventListener(MouseEvent.CLICK, onUnitCopy);
					unitCopyButton.label = copyProvider.getCopyForId("unitCopyButton");
					break;
				/*gh #204
				case unitPasteButton:
					unitPasteButton.addEventListener(MouseEvent.CLICK, onUnitPaste);
					break;*/
				//gh #208
				case publishCourseButton:
					publishCourseButton.addEventListener(MouseEvent.CLICK, onPublishCourse);
					publishCourseButton.label = copyProvider.getCopyForId("publishCourseButton");
					break;
				case publishSelectionGroup:
					publishSelectionGroup.addEventListener(MouseEvent.CLICK, onPublishSelection);
					break
				case publishChangeButton:
					publishChangeButton.addEventListener(MouseEvent.CLICK, onSchedule);
					publishChangeButton.label = copyProvider.getCopyForId("publishChangeButton");
					break;
				case settingsButton:
					instance.addEventListener(MouseEvent.CLICK, onSettingsClick);
					instance.label = copyProvider.getCopyForId("settingButton");
					break;
				case anim:
					anim.addEventListener(EffectEvent.EFFECT_END, onAnimEnd);
					break;
			}
		}
		
		protected function onUnitSelected(event:IndexChangeEvent):void {
			unitSelect.dispatch(event.target.selectedItem);
		}
		
		protected function onUnitDelete(event:UnitDeleteEvent):void {
			// gh#211
			unitListLength = unitList.dataProvider.length;
			currentIndex = unitListCollection.getItemIndex(event.unit);
			
			var alertMessage:String = copyProvider.getCopyForId("deleteUnitWarning");
			var alertTitle:String = copyProvider.getCopyForId("noUndoWarning");
			var alertYes:String = copyProvider.getCopyForId("yesButton");
			var alertNo:String = copyProvider.getCopyForId("noButton");
			Alert.show(alertMessage, alertTitle, Vector.<String>([ alertYes, alertNo ]), this, function(closeEvent:CloseEvent):void {
				if (closeEvent.detail == 0) {
					if (unitListLength > 1) {
						unitListCollection.removeItemAt(unitListCollection.getItemIndex(event.unit));
						
						// gh#211
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
						unitXML.@caption = copyProvider.getCopyForId("newUnitCaption");
						unitSelect.dispatch(unitXML);
					}									
				}				
			});
		}
		
		private function onAddUnit(event:MouseEvent):void {
			// TODO: need to have the designs to know exactly how this will work but for now just use a random name.
			// Also this should use a notification and command instead of adding it directly to the collection.
			var newUnitCaption:String = copyProvider.getCopyForId("newUnitCaption");
			unitListCollection.addItem(<unit caption={newUnitCaption} />);
		}
		
		protected function onSchedule(event:MouseEvent):void {
			// gh#225
			if (this.isFirstPublish && config.illustrationCloseFlag) {
				helpPublish.dispatch();
			}
			// gh#705
			navigator.pushView(ScheduleView);
			
			isItemClick = true;
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
				course.publication.appendChild(<group id={group.id} seePastUnits='true' unitInterval='0' startDate={startDate} endDate={endDate} />);
				courseChanged = true;
				invalidateProperties();
				coursePublish.dispatch();
			}
			
			isItemClick = true;
		}
		
		protected function onUnitCopy(event:MouseEvent):void {
			unitDuplicate.dispatch();
		}
		
		/*gh #240
		protected function onUnitPaste(event:MouseEvent):void {
			// gh#110 - dispatch the event from the button rather than the view so that we can test for the target before actually doing the paste.  This means
			// that we can make sure pastes only happen when the list has the focus, or the button was clicked.
			unitPasteButton.dispatchEvent(new Event(Event.PASTE, true));
		}*/
		
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
		
		// gh#208
		protected function onPublishCourse(event:MouseEvent):void {
			publishSelectionGroup.alpha = 1;
			isHidden = false;
			isOutsideClick = false;
		}
		
		// gh#208
		protected function onPublishSelection(event:MouseEvent):void {
			if (!isItemClick) {
				isOutsideClick = false;
			}
		}
		
		// gh#208
		protected function onStageClick(event:MouseEvent):void {
			if (publishSelectionGroup) {
				if (isOutsideClick) {
					anim.play(null, true);
					isHidden = true;
					publishCourseButton.skin.setCurrentState("up", true);
					publishCourseButton.selected = false;
					
				} else {
					isOutsideClick = true;
					isItemClick = false;
				}
			}						
		}
		
		protected function onAnimEnd(event:Event):void {
			if (isHidden) 
				publishSelectionGroup.alpha = 0;
		}
		
		protected function onSettingsClick(event:MouseEvent):void {
			navigator.pushView(SettingsView);
		}
		
	}
}