package com.clarityenglish.rotterdam.view.settings {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.controls.calendar.Calendar;
	import com.clarityenglish.textLayout.vo.XHTML;
	import com.sparkTree.Tree;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.ListCollectionView;
	import mx.controls.DateField;
	import mx.events.FlexEvent;
	import mx.events.ItemClickEvent;
	
	import org.davekeen.util.DateUtil;
	import org.davekeen.util.StringUtils;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.RadioButtonGroup;
	import spark.components.TabBar;
	import spark.components.TextInput;
	import spark.events.IndexChangeEvent;
	
	/**
	 * There is quite a lot of code duplication here that could be neatened up into a mini form framework that automatically links xml properties and components.
	 * in a Rails/Symfony style form system.  This might well be worth doing at some point, but for the moment just leave it hand coded.
	 */
	public class SettingsView extends BentoView {
		
		[SkinPart(required="true")]
		public var tabBar:TabBar;
		
		[SkinPart]
		public var aboutCourseNameTextInput:TextInput;
		
		[SkinPart]
		public var aboutAuthorTextInput:TextInput;
		
		[SkinPart]
		public var aboutEmailTextInput:TextInput;
		
		[SkinPart]
		public var aboutContactNumberTextInput:TextInput;
		
		[SkinPart]
		public var directStartURLLabel:Label;
		
		[SkinPart]
		public var groupTree:Tree;
		
		[SkinPart]
		public var unitIntervalTextInput:TextInput;
		
		[SkinPart]
		public var startDateField:DateField;
		
		[SkinPart]
		public var pastUnitsRadioButtonGroup:RadioButtonGroup;
		
		[SkinPart]
		public var calendar:Calendar;
		
		[SkinPart(required="true")]
		public var saveButton:Button;
		
		[SkinPart(required="true")]
		public var backButton:Button;
		
		[Bindable]
		public var groupTreesCollection:ListCollectionView;
		
		public var dirty:Signal = new Signal(); // GH #83
		public var saveCourse:Signal = new Signal();
		public var back:Signal = new Signal();
		
		private var isPopulating:Boolean;
		
		private function get course():XML {	
			return _xhtml.selectOne("script#model[type='application/xml'] course");
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
			
			// About data
			if (aboutCourseNameTextInput) aboutCourseNameTextInput.text = course.@caption;
			if (aboutAuthorTextInput) aboutAuthorTextInput.text = course.@author;
			if (aboutEmailTextInput) aboutEmailTextInput.text = course.@email;
			if (aboutContactNumberTextInput) aboutContactNumberTextInput.text = course.@contact;
			
			// gh#92
			var folderName:String = copyProvider.getCopyForId('pathCCB');
			var directStartURL:String = config.remoteStartFolder + folderName + '/Player.php' + '?prefix=' + config.prefix + '&course=' + course.@id;
			if (directStartURLLabel) directStartURLLabel.text = directStartURL;
			
			// Calendar
			if (selectedPublicationGroup) {
				if (unitIntervalTextInput && selectedPublicationGroup.hasOwnProperty("@unitInterval")) unitIntervalTextInput.text = selectedPublicationGroup.@unitInterval;
				if (startDateField && selectedPublicationGroup.hasOwnProperty("@startDate")) startDateField.selectedDate = DateUtil.ansiStringToDate(selectedPublicationGroup.@startDate);
				if (pastUnitsRadioButtonGroup && selectedPublicationGroup.hasOwnProperty("@seePastUnits")) pastUnitsRadioButtonGroup.selectedValue = (selectedPublicationGroup.@seePastUnits == "true");
			
				// If there is a calendar, start date and interval then add labels for the units at the appropriate dates GH #87
				if (calendar && selectedPublicationGroup.hasOwnProperty("@unitInterval") && selectedPublicationGroup.hasOwnProperty("@startDate")) {
					var labels:Array = [];
					for (var n:uint = 0; n < course.unit.length(); n++) {
						var date:Date = DateUtil.ansiStringToDate(selectedPublicationGroup.@startDate);
						date.date += n * selectedPublicationGroup.@unitInterval;
						labels.push( { date: date, label: "U" + (n + 1) });
					}
					calendar.dataProvider = new ArrayCollection(labels);
				}
			}
			
			isPopulating = false;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case tabBar:
					tabBar.dataProvider = new ArrayList([
						{ label: "Calendar", data: "calendar" },
						//{ label: "Email", data: "email" } - Email is disabled for the moment
						{ label: "About", data: "about" }
					]);
					
					tabBar.requireSelection = true;
					tabBar.addEventListener(IndexChangeEvent.CHANGE, onTabBarChange);
					
					// Start on the first tab
					callLater(function():void {
						tabBar.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
					});
					break;
				case aboutCourseNameTextInput:
					instance.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						if (!isPopulating) {
							course.@caption = StringUtils.trim(e.target.text);
							dirty.dispatch();
						}
					});
					break;
				case aboutAuthorTextInput:
					instance.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						if (!isPopulating) {
							course.@author = StringUtils.trim(e.target.text);
							dirty.dispatch();
						}
					});
					break;
				case aboutEmailTextInput:
					instance.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						if (!isPopulating) {
							course.@email = StringUtils.trim(e.target.text);
							dirty.dispatch();
						}
					});
					break;
				case aboutContactNumberTextInput:
					instance.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						if (!isPopulating) {
							course.@contact = StringUtils.trim(e.target.text);
							dirty.dispatch();
						}
					});
					break;
				case groupTree:
					groupTree.addEventListener(IndexChangeEvent.CHANGE, onCalendarTreeChange);
					break;
				case unitIntervalTextInput:
					unitIntervalTextInput.restrict = "0-9";
					unitIntervalTextInput.maxChars = 2;
					instance.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						if (!isPopulating) {
							selectedPublicationGroup.@unitInterval = StringUtils.trim(e.target.text);
							dirty.dispatch();
							invalidateProperties();
						}
					});
					break;
				case startDateField:
					instance.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						if (!isPopulating) {
							selectedPublicationGroup.@startDate = DateUtil.dateToAnsiString(e.target.selectedDate);
							//dirty.dispatch(); - I don't know why, but the mx DateField throws a VALUE_COMMIT at a weird time so its always dirty.  Disable for now.
							invalidateProperties();
						}
					});
					break;
				case pastUnitsRadioButtonGroup:
					pastUnitsRadioButtonGroup.addEventListener(ItemClickEvent.ITEM_CLICK, function(e:Event):void {
						if (!isPopulating) {
							selectedPublicationGroup.@seePastUnits = e.target.selectedValue;
							dirty.dispatch();
							invalidateProperties();
						}
					});
					break;
				case calendar:
					// Default the calendar to the current year and month
					calendar.firstOfMonth = new Date();
					break;
				case saveButton:
					saveButton.addEventListener(MouseEvent.CLICK, onSave);
					break;
				case backButton:
					backButton.addEventListener(MouseEvent.CLICK, onBack);
					break;
			}
		}
		
		protected function onCalendarTreeChange(event:IndexChangeEvent):void {
			invalidateProperties();
		}
		
		protected function onTabBarChange(event:IndexChangeEvent):void {
			invalidateSkinState();
		}
		
		protected function onSave(event:MouseEvent):void {
			saveCourse.dispatch();
		}
		
		protected function onBack(event:MouseEvent):void {
			back.dispatch();
		}
		
		/**
		 * The state of the skin is driven by the tab bar (calendar, email or about)
		 */
		protected override function getCurrentSkinState():String {
			if (tabBar && tabBar.selectedItem)
				return tabBar.selectedItem.data;
			
			return super.getCurrentSkinState();
		}
		
	}
}