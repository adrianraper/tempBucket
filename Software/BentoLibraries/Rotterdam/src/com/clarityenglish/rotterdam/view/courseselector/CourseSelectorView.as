package com.clarityenglish.rotterdam.view.courseselector {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.vo.content.Course;
	import com.clarityenglish.rotterdam.view.courseselector.events.CourseDeleteEvent;
	import com.clarityenglish.rotterdam.view.courseselector.events.CourseSelectEvent;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	
	import mx.collections.ICollectionView;
	import mx.collections.XMLListCollection;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.ItemClickEvent;
	import mx.managers.PopUpManager;
	
	import org.osflash.signals.Signal;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	import spark.components.BusyIndicator;
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.FormHeading;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.List;
	import spark.components.RadioButton;
	import spark.components.RadioButtonGroup;
	import spark.components.TextInput;
	import spark.components.ToggleButton;
	import spark.components.VGroup;
	import spark.effects.Animate;
	
	import ws.tink.spark.controls.Alert;
	
	public class CourseSelectorView extends BentoView {
		
		[SkinPart(required="true")]
		public var courseList:List;
		
		[SkinPart]
		public var createCourseButton:Button;
		
		[SkinPart]
		public var deleteCourseButton:Button;
		
		[SkinPart]
		public var courseListTitleLabel:Label;
		
		[SkinPart]
		public var busyIndicator:BusyIndicator;
		
		// gh#619
		[SkinPart]
		public var filterTextInput:TextInput;
		
		[SkinPart]
		public var sortRadioButtonGroup:RadioButtonGroup;
		
		[SkinPart]
		public var sortCreateDate:RadioButton;
		
		[SkinPart]
		public var sortChangeDate:RadioButton;
		
		[SkinPart]
		public var sortPopularity:RadioButton;
		
		[SkinPart]
		public var sortSize:RadioButton;
		
		[SkinPart]
		public var sortName:RadioButton;
		
		[SkinPart]
		public var showFiltersToggleButton:ToggleButton;
		
		[SkinPart]
		public var filterHeadingFormHeading:FormHeading;
		
		[SkinPart]
		public var sortHeadingFormHeading:FormHeading;
		
		[SkinPart]
		public var filtersPanel:Group;
		
		[SkinPart]
		public var filtersFromPanel:VGroup;
		
		[SkinPart]
		public var showFiltersAnimation:Animate;
		
		[SkinPart]
		public var hideFiltersAnimation:Animate;
		
		[SkinPart]
		public var filterOwner:CheckBox;
		
		[SkinPart]
		public var filterCollaborator:CheckBox;
		
		[SkinPart]
		public var filterPublisher:CheckBox;
		
		[SkinPart]
		public var sortDescendingCheckBox:CheckBox;
		
		public var createCourse:Signal = new Signal();
		public var selectCourse:Signal = new Signal(XML);
		public var deleteCourse:Signal = new Signal(XML);
		
		private var isCourseListCreated:Boolean;
		
		//private var sort:Sort;
		
		protected override function commitProperties():void {
			super.commitProperties();
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			courseList.dataProvider = new XMLListCollection(xhtml.courses.course);
			var sort:Sort = new Sort();
			var sortField:SortField = new SortField('@created', true, null);
			// TODO how to get the real locale?
			sortField.setStyle('locale', 'en-US');
			sort.fields = [sortField];
			
			(courseList.dataProvider as XMLListCollection).sort = sort;
			(courseList.dataProvider as XMLListCollection).refresh();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case createCourseButton:
					createCourseButton.addEventListener(MouseEvent.CLICK, onCreateCourse);
					createCourseButton.label = copyProvider.getCopyForId("createCourseButton");
					break;
				case courseList:
					courseList.dataGroup.doubleClickEnabled = true;
					courseList.addEventListener(CourseSelectEvent.COURSE_SELECT, onSelectCourse);
					courseList.addEventListener(CourseDeleteEvent.COURSE_DELETE, onDeleteCourse);
					courseList.addEventListener(FlexEvent.UPDATE_COMPLETE, onCourseListUpdateComplete);
					break;
				case courseListTitleLabel:
					courseListTitleLabel.text = copyProvider.getCopyForId("courseListTitleLabel");
					break;
				case filterTextInput:
					filterTextInput.prompt = copyProvider.getCopyForId("filterTagsPrompt");
					filterTextInput.addEventListener(Event.CHANGE, onChangeFilter);
					break;
				case filterOwner:
					instance.label = copyProvider.getCopyForId("filterOwnerCourses");
					instance.addEventListener(Event.CHANGE, onChangeFilter);
					break;
				case filterCollaborator:
					instance.label = copyProvider.getCopyForId("filterCollaboratorCourses");
					instance.addEventListener(Event.CHANGE, onChangeFilter);
					break;
				case filterPublisher:
					instance.label = copyProvider.getCopyForId("filterPublisherCourses");
					instance.addEventListener(Event.CHANGE, onChangeFilter);
					break;
				case sortRadioButtonGroup:
					sortRadioButtonGroup.addEventListener(ItemClickEvent.ITEM_CLICK, onChangeSort);
					break;
				case sortCreateDate:
					instance.label = copyProvider.getCopyForId("sortCreateDate");
					sortCreateDate.selected = true;
					break;
				case sortChangeDate:
					instance.label = copyProvider.getCopyForId("sortModifiedDate");
					break;
				case sortChangeDate:
					instance.label = copyProvider.getCopyForId("sortModifiedDate");
					break;
				case sortSize:
					instance.label = copyProvider.getCopyForId("sortSize");
					break;
				case sortPopularity:
					instance.label = copyProvider.getCopyForId("sortPopularity");
					break;
				case sortName:
					instance.label = copyProvider.getCopyForId("sortName");
					break;
				case sortDescendingCheckBox:
					instance.label = copyProvider.getCopyForId("sortDescending");
					sortDescendingCheckBox.addEventListener(Event.CHANGE, onChangeSort);
					sortDescendingCheckBox.selected = true;
					break;
				case showFiltersToggleButton:
					showFiltersToggleButton.label = copyProvider.getCopyForId("showFiltersToggleButton");
					showFiltersToggleButton.selected = false;
					showFiltersToggleButton.addEventListener(Event.CHANGE, onShowHideFilters);
					break;
				case filterHeadingFormHeading:
					filterHeadingFormHeading.label = copyProvider.getCopyForId("filtersHeading");
					break;
				case sortHeadingFormHeading:
					sortHeadingFormHeading.label = copyProvider.getCopyForId("sortHeading");
					break;
			}
		}
		
		protected function onShowHideFilters(event:Event):void {
			if ((event.target as ToggleButton).selected) {
				showFiltersAnimation.play();
				filtersFromPanel.visible = true
			} else {
				hideFiltersAnimation.play();
				filtersFromPanel.visible = false;
			}
		}
		// gh#619
		protected function onChangeSort(event:Event):void {
			var sortComparison:Function = null;
			switch (event.target) {
				case sortDescendingCheckBox:
					var sort:Sort = new Sort();
					sort.fields = (courseList.dataProvider as XMLListCollection).sort.fields;
					sort.compareFunction = (courseList.dataProvider as XMLListCollection).sort.compareFunction;
					(courseList.dataProvider as XMLListCollection).sort = sort;
					sort.reverse();
					(courseList.dataProvider as XMLListCollection).refresh();
					break;
				case sortRadioButtonGroup:
					switch (sortRadioButtonGroup.selection) {
						case sortCreateDate:
							var sortAttribute:String = "@created";
							var sortNumeric:Object = null; 
							break;
						case sortName:
							sortAttribute = "@caption";
							// Note that when you use a custom sort, sort.reverse doesn't work - so you need to add direction in here
							var sortComparisonDirection:Function = function(a:Object, b:Object, fields:Array, descending:Boolean):int { 
								// http://stackoverflow.com/questions/16067374/as3-sorting-alphabetically-and-numerically-simultaneously
								// This part should be extracted to a common String class
								var reA:RegExp = /[\d]/g;
								var reN:RegExp = /[\D]/g;
								var aA:String = a.@caption.toLowerCase().replace(reA, "");
								var bA:String = b.@caption.toLowerCase().replace(reA, "");
								if (aA === bA) {
									var aN:int = parseInt(a.@caption.toLowerCase().replace(reN, ""));
									var bN:int = parseInt(b.@caption.toLowerCase().replace(reN, ""));
									if (descending) {
										return aN === bN ? 0 : aN > bN ? 1 : -1;
									} else {
										return aN === bN ? 0 : aN < bN ? 1 : -1;
									}
								} else {
									if (descending) {
										return aA > bA ? 1 : -1;
									} else {
										return aA < bA ? 1 : -1;
									}
								}
							};
							sortComparison = function(a:Object, b:Object, fields:Array):int {
								return sortComparisonDirection(a, b, fields, sortDescendingCheckBox.selected);
							};
							sortNumeric = false;
							break;
						case sortPopularity:
							sortNumeric = true;
							sortAttribute = "@timesUsed";
							break;
						case sortSize:
							sortNumeric = true;
							sortAttribute = "@size";
							break;
						case sortChangeDate:
							sortNumeric = null;
							sortAttribute = "@lastSaved";
							break;
					}
					sort = new Sort();
					var sortField:SortField = new SortField(sortAttribute, sortDescendingCheckBox.selected, sortNumeric);
					sort.fields = [sortField];
					// TODO how to get the real locale?
					sortField.setStyle('locale', 'en-US');
					sort.compareFunction = sortComparison;
					(courseList.dataProvider as XMLListCollection).sort = sort;
					(courseList.dataProvider as XMLListCollection).refresh();
					break;
			}
		}
		
		// gh#619
		protected function onChangeFilter(event:Event):void {
			(courseList.dataProvider as XMLListCollection).filterFunction = function(item:XML):Boolean {
				var keepItem:Boolean = true;
				if (filterTextInput.text) {
					if (!((item.@caption.toLowerCase().indexOf(filterTextInput.text.toLowerCase()) >= 0) || 
						(item.hasOwnProperty("@description") && item.@description.toLowerCase().indexOf(filterTextInput.text.toLowerCase()) >= 0)))
						keepItem = false;
				}
				if (filterOwner.selected) {
					if (!(item.hasOwnProperty("@enabledFlag") && item.@enabledFlag & Course.EF_OWNER))
						keepItem = false;
				}
				if (filterCollaborator.selected) {
					if (!(item.hasOwnProperty("@enabledFlag") && item.@enabledFlag & Course.EF_COLLABORATOR))
						keepItem = false;
				}
				if (filterPublisher.selected) {
					if (!(item.hasOwnProperty("@enabledFlag") && item.@enabledFlag & Course.EF_PUBLISHER))
						keepItem = false;
				}
				return keepItem;
			};
			(courseList.dataProvider as XMLListCollection).refresh();
		}
		
		protected function onCreateCourse(event:MouseEvent):void {
			createCourse.dispatch();
		}
		
		public function onSelectCourse(event:CourseSelectEvent):void {
			if (courseList.selectedItem)
				selectCourse.dispatch(courseList.selectedItem);
		}
		
		protected function onDeleteCourse(event:CourseDeleteEvent):void {
			var alertMessage:String = copyProvider.getCopyForId("deleteCourseWarning");
			var alertTitle:String = copyProvider.getCopyForId("noUndoWarning");
			var alertYes:String = copyProvider.getCopyForId("yesButton");
			var alertNo:String = copyProvider.getCopyForId("noButton");
			Alert.show(alertMessage, alertTitle, Vector.<String>([ alertYes, alertNo ]), this, function(closeEvent:CloseEvent):void {
				if (closeEvent.detail == 0)
					deleteCourse.dispatch(event.course);
			});
		}
		
		// Add busy indicator before course list display in screen
		protected function onCourseListUpdateComplete(event:FlexEvent):void {
			if (isCourseListCreated && busyIndicator) {
				busyIndicator.visible = false;
				isCourseListCreated = false;
			} else {
				isCourseListCreated = true;
			}
		}
	}
}