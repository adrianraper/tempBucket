package com.clarityenglish.rotterdam.view.schedule {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.resultsmanager.vo.manageable.Group;
	import com.clarityenglish.controls.calendar.Calendar;
	import com.clarityenglish.rotterdam.view.schedule.events.PublishEvent;
	import com.clarityenglish.rotterdam.view.schedule.ui.CalendarTreeItemRenderer;
	import com.clarityenglish.textLayout.vo.XHTML;
	import com.sparkTree.Tree;

	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;

	import mx.collections.ArrayCollection;
	import mx.collections.IViewCursor;
	import mx.collections.ListCollectionView;
	import mx.controls.DateField;
	import mx.core.ClassFactory;
	import mx.events.FlexEvent;
	import mx.events.ItemClickEvent;

	import org.davekeen.util.DateUtil;
	import org.davekeen.util.StringUtils;
	import org.osflash.signals.Signal;

	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.RadioButton;
	import spark.components.RadioButtonGroup;
	import spark.components.TextInput;
	import spark.events.IndexChangeEvent;

	/**
	 * There is quite a lot of code duplication here that could be neatened up into a mini form framework that automatically links xml properties and components.
	 * in a Rails/Symfony style form system.  This might well be worth doing at some point, but for the moment just leave it hand coded.
	 */
	public class ScheduleView extends BentoView {
		
		[SkinPart]
		public var scheduleLabel:Label;
		
		[SkinPart]
		public var notificationsLabel:Label;
		
		[SkinPart]
		public var groupTree:Tree;
		
		[SkinPart]
		public var unitIntervalTextInput:TextInput;
		
		[SkinPart]
		public var startDateField:DateField;
		
		[SkinPart]
		public var endDateField:DateField;
		
		[SkinPart]
		public var pastUnitsRadioButtonGroup:RadioButtonGroup;
		
		[SkinPart]
		public var unitIntervalGroup:spark.components.Group;
		
		[SkinPart]
		public var unitIntervalRadioButtonGroup:RadioButtonGroup;
		
		[SkinPart]
		public var yesRadioButton:RadioButton;
		
		[SkinPart]
		public var noRadioButton:RadioButton;
		
		[SkinPart]
		public var selectGroupLabel:Label;
		
		[SkinPart]
		public var startDateLabel:Label;
		
		[SkinPart]
		public var endDateLabel:Label;
		
		[SkinPart]
		public var endDateDetailLabel:Label;
		
		[SkinPart]
		public var unitIntervalLabel:Label;
		
		[SkinPart]
		public var seePastUnitsLabel:Label;
		
		[SkinPart]
		public var allUnitsAvailableRadioButton:RadioButton;
		
		[SkinPart]
		public var oneUnitAtOnceRadioButton:RadioButton;
		
		// gh#122
		[SkinPart]
		public var sendAlertEmailCheckbox:CheckBox;
		
		[SkinPart]
		public var welcomeEmailLabel:Label;
		
		[SkinPart]
		public var welcomeEmailButton:Button;
		
		[SkinPart]
		public var calendar:Calendar;
		
		[SkinPart(required="true")]
		public var saveButton:Button;
		
		[SkinPart(required="true")]
		public var backButton:Button;
		
		[Bindable]
		public var groupTreesCollection:ListCollectionView;
		
		public var dirty:Signal = new Signal(); // gh#83
		public var saveCourse:Signal = new Signal();
		public var back:Signal = new Signal();
		public var sendEmail:Signal = new Signal(); //gh#122
		
		private var isPopulating:Boolean;
		
		public function ScheduleView() {
			super();
		}
		
		// gh#152 - the settings view actually works on a copy of the course
		private var _cachedCourse:XML;
		private function get course():XML {
			if (!_cachedCourse) _cachedCourse = _xhtml.selectOne("script#model[type='application/xml'] > menu > course").copy();
			return _cachedCourse;
		}
		
		/**
		 * This integrates the cached course into the real XHTML and clears the cache
		 */
		private function mergeCourseToXHTML():void {
			_xhtml.selectOne("script#model[type='application/xml'] > menu").setChildren(course);
			_cachedCourse = null;
		}
		
		/**
		 * Get the publication group currently selected in the XML, and if there isn't one then create it
		 */
		private function get selectedPublicationGroup():XML {
			if (groupTree && groupTree.selectedItem != null) {
				var results:XMLList = course.publication.group.(@id == groupTree.selectedItem.id);
				if (results.length() == 0) {
					// Create a new group node and return it
					course.publication.appendChild(<group id={groupTree.selectedItem.id} />);
					return course.publication.group.(@id == groupTree.selectedItem.id)[0];
				} else {
					return results[0];
				}
			} else {
				return null;
			}
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// This makes sure that commitProperties is called after menu.xml has loaded so everything can be filled in
			invalidateProperties();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			isPopulating = true;
			
			// gh#122 Notifications data
			if (sendAlertEmailCheckbox) {
				sendAlertEmailCheckbox.enabled = (selectedPublicationGroup);
				sendAlertEmailCheckbox.selected = (course.hasOwnProperty("@sendNotifications")) ? (course.@sendNotifications == 'true' ? true : false) : false;
			}
			if (welcomeEmailButton) welcomeEmailButton.enabled = (selectedPublicationGroup && selectedPublicationGroup.hasOwnProperty("@startDate"));
			
			// schedule dates
			if (startDateField) startDateField.selectedDate = (selectedPublicationGroup && selectedPublicationGroup.hasOwnProperty("@startDate")) ? DateUtil.ansiStringToDate(selectedPublicationGroup.@startDate) : null;
			if (endDateField) endDateField.selectedDate = (selectedPublicationGroup && selectedPublicationGroup.hasOwnProperty("@endDate") && (selectedPublicationGroup.@endDate != null)) ? DateUtil.ansiStringToDate(selectedPublicationGroup.@endDate) : null;
			if (unitIntervalTextInput) unitIntervalTextInput.text = (selectedPublicationGroup && selectedPublicationGroup.hasOwnProperty("@unitInterval") && (selectedPublicationGroup.@unitInterval != 0)) ? selectedPublicationGroup.@unitInterval : null;
			if (unitIntervalRadioButtonGroup) unitIntervalRadioButtonGroup.selectedValue = (selectedPublicationGroup && selectedPublicationGroup.hasOwnProperty("@unitInterval"))? (selectedPublicationGroup.@unitInterval == 0) : null;
			if (pastUnitsRadioButtonGroup) {
				pastUnitsRadioButtonGroup.selectedValue = (selectedPublicationGroup && selectedPublicationGroup.hasOwnProperty("@seePastUnits")) ? (selectedPublicationGroup.@seePastUnits == "true") : null;
				pastUnitsRadioButtonGroup.enabled = (selectedPublicationGroup && selectedPublicationGroup.hasOwnProperty("@unitInterval"))? (selectedPublicationGroup.@unitInterval != 0) : null;
			}
			
			// If there is a calendar, start date and interval then add labels for the units at the appropriate dates gh#87
			if (calendar) {
				if (selectedPublicationGroup && selectedPublicationGroup.hasOwnProperty("@unitInterval") && selectedPublicationGroup.hasOwnProperty("@startDate")) {
					var labels:Array = [];
					for (var n:uint = 0; n < course.unit.length(); n++) {
						var date:Date = DateUtil.ansiStringToDate(selectedPublicationGroup.@startDate);
						date.date += n * selectedPublicationGroup.@unitInterval;
						labels.push( { date: date, label: "U" + (n + 1) });
					}
					calendar.dataProvider = new ArrayCollection(labels);
				} else {
					calendar.dataProvider = null;
				}
			}
			
			// Only enable the save button if calendar settings are valid
			if (saveButton) {
				// Firstly get all the groups, all the way down the tree
				var allGroups:Array = [];
				var cursor:IViewCursor = groupTreesCollection.createCursor();
				while (!cursor.afterLast) {
					var group:com.clarityenglish.resultsmanager.vo.manageable.Group = cursor.current as com.clarityenglish.resultsmanager.vo.manageable.Group;
					allGroups.push(group);
					allGroups = allGroups.concat(group.getSubGroups());
					cursor.moveNext();
				}
				
				// Now go through the groups, checking each is valid
				var isValid:Boolean = true;
				for each (group in allGroups) {
					if (hasSettings(group) && !areSettingsValid(group)) {
						isValid = false;
						break;
					}
				}
				saveButton.enabled = isValid;
			}
			
			isPopulating = false;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case scheduleLabel:
					instance.text = copyProvider.getCopyForId("scheduleLabel");
					break;
				case notificationsLabel:
					instance.text = copyProvider.getCopyForId("notificationsLabel");
					break;
				case groupTree:
					var itemRenderer:ClassFactory = new ClassFactory(CalendarTreeItemRenderer);
					itemRenderer.properties = {
						hasSettings: hasSettings,
						areSettingsValid: areSettingsValid
					};
					groupTree.itemRenderer = itemRenderer;
					
					groupTree.addEventListener(IndexChangeEvent.CHANGE, function(e:Event):void { invalidateProperties(); });
					groupTree.addEventListener(PublishEvent.CALENDER_SETTINGS_DELETE, onCalendarSettingsDelete);
					break;
				case unitIntervalTextInput:
					unitIntervalTextInput.restrict = "0-9";
					unitIntervalTextInput.maxChars = 2;
					
					instance.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, function(e:Event):void {
							if (!isPopulating) {
								unitIntervalTextInput.focusManager.deactivate();
								selectedPublicationGroup.@unitInterval = StringUtils.trim(e.target.text);
								calendarSettingsChanged();
							}
					});						
					break;
				case startDateField:
					instance.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						if (!isPopulating) {
							if (e.target.selectedDate) selectedPublicationGroup.@startDate = DateUtil.dateToAnsiString(e.target.selectedDate);
							calendarSettingsChanged(false);
						}
					});
					break;
				case endDateField:
					instance.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						if (!isPopulating) {
							if (selectedPublicationGroup) {
								selectedPublicationGroup.@endDate = (e.target.selectedDate != null) ? DateUtil.dateToAnsiString(e.target.selectedDate) : null;
								calendarSettingsChanged(false);
							}										
						}
					});
					//endDateField.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onMouseFocusChange);
					break;
				case unitIntervalRadioButtonGroup:
					unitIntervalRadioButtonGroup.addEventListener(ItemClickEvent.ITEM_CLICK, function(e:Event):void {
						if (!isPopulating) {
							if (e.target.selectedValue) {
								selectedPublicationGroup.@unitInterval = 0;
								selectedPublicationGroup.@seePastUnits = true;
								pastUnitsRadioButtonGroup.enabled = false;
								pastUnitsRadioButtonGroup.selectedValue = true;
								calendarSettingsChanged();
							} else {
								pastUnitsRadioButtonGroup.enabled = true;
							}							
						}
					});
					break;
				case pastUnitsRadioButtonGroup:
					instance.addEventListener(ItemClickEvent.ITEM_CLICK, function(e:Event):void {
						if (!isPopulating) {
							selectedPublicationGroup.@seePastUnits = e.target.selectedValue;
							calendarSettingsChanged();
						}
					});
					break;
				// gh#122
				case sendAlertEmailCheckbox:
					instance.addEventListener(MouseEvent.CLICK, function(e:Event):void {
						if (!isPopulating) {
							course.@sendNotifications = e.target.selected;
							dirty.dispatch();
						}
					});
					instance.label = copyProvider.getCopyForId("sendAlertEmailCheckbox");
					break;
				case seePastUnitsLabel:
					instance.text = copyProvider.getCopyForId("seePastUnitsLabel");
					break;
				case yesRadioButton:
					instance.label = copyProvider.getCopyForId("yesButton");
					break;
				case noRadioButton:
					instance.label = copyProvider.getCopyForId("noButton");
					break;
				case calendar:
					// Default the calendar to the current year and month
					calendar.firstOfMonth = new Date();
					break;
				case saveButton:
					instance.addEventListener(MouseEvent.CLICK, onSave);
					instance.label = copyProvider.getCopyForId("savePublishButton");
					break;
				case backButton:
					instance.addEventListener(MouseEvent.CLICK, onBack);
					instance.label = copyProvider.getCopyForId("cancelButton");
					break;
				case welcomeEmailButton:
					instance.addEventListener(MouseEvent.CLICK, onSendWelcomeEmail);
					instance.label = copyProvider.getCopyForId("welcomeEmailButton");
					break;
				case selectGroupLabel:
					selectGroupLabel.text = copyProvider.getCopyForId("selectGroupLabel");
					break;
				case startDateLabel:
					instance.text = copyProvider.getCopyForId("startDateLabel");
					break;
				case endDateLabel:
					instance.text = copyProvider.getCopyForId("endDateLabel");
					break;
				case endDateDetailLabel:
					instance.text = copyProvider.getCopyForId("endDateDetailLabel");
					break;
				case unitIntervalLabel:
					unitIntervalLabel.text = copyProvider.getCopyForId("unitIntervalLabel");
					break;
				case allUnitsAvailableRadioButton:
					instance.label = copyProvider.getCopyForId("allUnitsAvailableRadioButton");
					break;
				case oneUnitAtOnceRadioButton:
					instance.label = copyProvider.getCopyForId("oneUnitAtOnceRadioButton");
					break;
				case welcomeEmailLabel:
					welcomeEmailLabel.text = copyProvider.getCopyForId("welcomeEmailLabel");
					break;
			}
		}
		
		protected function onCalendarSettingsDelete(event:PublishEvent):void {
			var results:XMLList = course.publication.group.(@id == event.group.id);
			if (results && results.length() > 0) {
				var result:XML = results[0];
				delete (result.parent().children()[result.childIndex()]);
				calendarSettingsChanged();
			}
		}
		
		protected function onTabBarChange(event:IndexChangeEvent):void {
			invalidateSkinState();
		}

		// gh#122 Trigger the backend to send out a welcome email now to all students in the selected group
		protected function onSendWelcomeEmail(event:MouseEvent):void {
			// Nothing to do if this group doesn't have a publication date
			var results:XMLList = course.publication.group.(@id == selectedPublicationGroup.@id);
			if (results && results.length() > 0) {
				var groupID:Number = selectedPublicationGroup.@id;
				sendEmail.dispatch(course, groupID);
			} else {
				// TODO. How to raise an error? Or do you just disable the button until this condition is fulfilled/
			}
		}

		protected function onSave(event:MouseEvent):void {
			// Remove any groups without all the required information
			for each (var group:XML in course.publication.group) {
				if (!group.hasOwnProperty("@id") ||
					!group.hasOwnProperty("@seePastUnits") ||
					!group.hasOwnProperty("@unitInterval") ||
					!group.hasOwnProperty("@startDate")) {
					delete (group.parent().children()[group.childIndex()]);
				}
			}
			
			groupTree.selectedItem = null;
			groupTree.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
			
			// Merge the temporary course into the real XHTML
			mergeCourseToXHTML();
			
			// Save
			saveCourse.dispatch();
			back.dispatch();
		}
		
		protected function onBack(event:MouseEvent):void {
			back.dispatch();
		}
		
		protected function onClearEndDate(event:MouseEvent):void {
			selectedPublicationGroup.@endDate = null;
			invalidateProperties();
		}
		
		/**
		 * Whenever a calendar setting is changed this is called.  It sets the settings dirty, invalidates properties (unless explicitly told not to) and refreshes
		 * the group tree.
		 * 
		 * @param doInvalidateProperties
		 */
		private function calendarSettingsChanged(doInvalidateProperties:Boolean = true):void {
			dirty.dispatch();
			/*if (doInvalidateProperties)*/ invalidateProperties();
			groupTree.refreshRenderers();
		}
		
		/**
		 * A group has settings if it exists and has at least one other attribute apart from @id.  This is used by the CalendarTreeItemRenderer to figure out
		 * what icons/buttons to display.
		 * 
		 * @param group
		 */
		private function hasSettings(group:com.clarityenglish.resultsmanager.vo.manageable.Group):Boolean {
			var results:XMLList = course.publication.group.(@id == group.id);
			if (results && results.length() > 0) {
				for each (var attribute:XML in results[0].attributes()) {
					if (attribute.name() != "id" && attribute.valueOf() != null)
						return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Determine if the settings for the given group are valid or not.  This is used by the CalendarTreeItemRenderer to figure out what icons/buttons to display,
		 * and also to determine whether or not we are allowed to save.
		 * 
		 * @param group
		 * @return 
		 */
		private function areSettingsValid(group:com.clarityenglish.resultsmanager.vo.manageable.Group):Boolean {
			var results:XMLList = course.publication.group.(@id == group.id);
			if (results && results.length() > 0) {
				var result:XML = results[0];
				if (result.hasOwnProperty("@id") &&
					result.hasOwnProperty("@seePastUnits") &&
					result.hasOwnProperty("@unitInterval") &&
					result.hasOwnProperty("@startDate")) {
						if (result.hasOwnProperty("@endDate") && result.@endDate != null) {
							return (DateUtil.ansiStringToDate(result.@startDate) < DateUtil.ansiStringToDate(result.@endDate));
						}		
						return true;
					}
			}
			return false;
		}
		
		protected function onMouseFocusChange(event:FocusEvent):void {
			if (endDateField.text == "") {
				endDateField.selectedDate = null;
				selectedPublicationGroup.@endDate = null;					
			}
			endDateField.focusManager.deactivate();
		}
		
	}
}