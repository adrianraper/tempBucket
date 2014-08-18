package com.clarityenglish.rotterdam.view.courseselector {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.vo.content.Course;
	import com.clarityenglish.rotterdam.view.courseselector.events.CourseDeleteEvent;
	import com.clarityenglish.rotterdam.view.courseselector.events.CourseSelectEvent;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
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
	import spark.components.Form;
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
		public var filtering:Form;
		
		[SkinPart]
		public var sorting:Form;
		
		[SkinPart]
		public var showFiltersAnimation:Animate;
		
		[SkinPart]
		public var hideFiltersAnimation:Animate;
		
		[SkinPart]
		public var cloakFiltersAnimation:Animate;
		
		[SkinPart]
		public var uncloakFiltersAnimation:Animate;
		
		[SkinPart]
		public var filterOwner:CheckBox;
		
		[SkinPart]
		public var filterCollaborator:CheckBox;
		
		[SkinPart]
		public var filterPublisher:CheckBox;
		
		[SkinPart]
		public var sortDescendingToggleButton:ToggleButton;
		
		public var createCourse:Signal = new Signal();
		public var selectCourse:Signal = new Signal(XML);
		public var deleteCourse:Signal = new Signal(XML);
		
		private var isCourseListCreated:Boolean;
		
		private var cloakTimer:Timer;
		
		public var viewMemory:XML;
		
		protected override function commitProperties():void {
			super.commitProperties();
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			courseList.dataProvider = new XMLListCollection(xhtml.courses.course);
			if (courseList.dataProvider.length == 0)
				return;
			
			// gh#956 Only if these elements exist in the skin
			if (sortDescendingToggleButton) {
				var initialSortField:String = 'created';
				var initialSortDescending:Boolean = true;
				var initialFiltersHidden:Boolean = false;
				var initialFilterOwner:Boolean = false;
				var initialFilterCollaborator:Boolean = false;
				var initialFilterPublisher:Boolean = false;
				var initialFilterText:String = '';
				if (viewMemory.hasOwnProperty('courseSelector')) {
					if (viewMemory.courseSelector.hasOwnProperty('@sortField'))
						initialSortField = viewMemory.courseSelector.@sortField;
					if (viewMemory.courseSelector.hasOwnProperty('@sortDescending'))
						initialSortDescending = (viewMemory.courseSelector.@sortDescending == "true");
					if (viewMemory.courseSelector.hasOwnProperty('@filtersHidden'))
						initialFiltersHidden = (viewMemory.courseSelector.@filtersHidden == "true");
					if (viewMemory.courseSelector.hasOwnProperty('@filterOwner'))
						initialFilterOwner = (viewMemory.courseSelector.@filterOwner == "true");
					if (viewMemory.courseSelector.hasOwnProperty('@filterCollaborator'))
						initialFilterCollaborator = (viewMemory.courseSelector.@filterCollaborator == "true");
					if (viewMemory.courseSelector.hasOwnProperty('@filterPublisher'))
						initialFilterPublisher = (viewMemory.courseSelector.@filterPublisher == "true");
					if (viewMemory.courseSelector.hasOwnProperty('filter'))
						initialFilterText = viewMemory.courseSelector.filter[0];
				}
				
				// gh#956 Use the remembered preferences
				switch (initialSortField) {
					case 'totalTimesUsed':
						sortPopularity.selected = true;
						break;
					case 'size':
						sortSize.selected = true;
						break;
					case 'lastSaved':
						sortChangeDate.selected = true;
						break;
					case 'caption':
						sortName.selected = true;
						break;
					default:
						sortCreateDate.selected = true;
						break;
				}
				sortDescendingToggleButton.selected = !initialSortDescending;
				showFiltersToggleButton.selected = !initialFiltersHidden;
				onShowHideFilters(null);
				
				filterOwner.selected = initialFilterOwner;
				filterCollaborator.selected = initialFilterCollaborator;
				filterPublisher.selected = initialFilterPublisher;
				if (initialFilterText)
					filterTextInput.text = initialFilterText;
				onChangeFilter(null);
				
				var sort:Sort = new Sort();
				var sortField:SortField = new SortField('@' + initialSortField, initialSortDescending, null);
				// TODO how to get the real locale?
				sortField.setStyle('locale', 'en-US');
				sort.fields = [sortField];
				
				(courseList.dataProvider as XMLListCollection).sort = sort;
				(courseList.dataProvider as XMLListCollection).refresh();
			}
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
				case sortDescendingToggleButton:
					sortDescendingToggleButton.addEventListener(Event.CHANGE, onChangeSort);
					break;
				case showFiltersToggleButton:
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
		
		// gh#619
		protected function onShowHideFilters(event:Event):void {
			if (showFiltersToggleButton.selected) {
				if (cloakTimer)
					cloakTimer.removeEventListener(TimerEvent.TIMER, cloakTimerHandler);
				filtering.visible = sorting.visible = sortDescendingToggleButton.visible = true;
				showFiltersAnimation.play();
			} else {
				hideFiltersAnimation.play();
				cloakTimer = new Timer(1000, 1);
				cloakTimer.addEventListener(TimerEvent.TIMER, cloakTimerHandler);
				cloakTimer.start();
			}			
			
			// gh#956
			viewMemory.courseSelector.@filtersHidden = String(!showFiltersToggleButton.selected);
		}
		private function cloakTimerHandler(event:TimerEvent):void {
			filtering.visible = sorting.visible = sortDescendingToggleButton.visible = false;
			cloakTimer.removeEventListener(TimerEvent.TIMER, cloakTimerHandler);
		}
		
		// gh#619
		protected function onChangeSort(event:Event):void {
			var sortComparison:Function = null;
			switch (event.target) {
				case sortDescendingToggleButton:
					var sort:Sort = new Sort();
					sort.fields = (courseList.dataProvider as XMLListCollection).sort.fields;
					sort.compareFunction = (courseList.dataProvider as XMLListCollection).sort.compareFunction;
					(courseList.dataProvider as XMLListCollection).sort = sort;
					sort.reverse();
					(courseList.dataProvider as XMLListCollection).refresh();
					
					// gh#956
					viewMemory.courseSelector.@sortDescending = String(!sortDescendingToggleButton.selected);
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
								return sortComparisonDirection(a, b, fields, !sortDescendingToggleButton.selected);
							};
							sortNumeric = false;
							break;
						case sortPopularity:
							sortNumeric = true;
							sortAttribute = "@totalTimesUsed";
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
					var sortField:SortField = new SortField(sortAttribute, !sortDescendingToggleButton.selected, sortNumeric);
					sort.fields = [sortField];
					// TODO how to get the real locale?
					sortField.setStyle('locale', 'en-US');
					sort.compareFunction = sortComparison;
					(courseList.dataProvider as XMLListCollection).sort = sort;
					(courseList.dataProvider as XMLListCollection).refresh();
					
					// gh#956
					viewMemory.courseSelector.@sortField = sortAttribute.substr(1);
					break;
			}
		}
		
		// gh#619
		protected function onChangeFilter(event:Event):void {
			(courseList.dataProvider as XMLListCollection).filterFunction = function(item:XML):Boolean {
				var keepItem:Boolean = false;
				// Filtering by what you can do adds matching items
				if (filterOwner.selected) {
					if ((item.hasOwnProperty("@enabledFlag") && item.@enabledFlag & Course.EF_OWNER))
						keepItem = true;
				}
				if (filterCollaborator.selected) {
					if ((item.hasOwnProperty("@enabledFlag") && item.@enabledFlag & Course.EF_COLLABORATOR))
						keepItem = true;
				}
				if (filterPublisher.selected) {
					if ((item.hasOwnProperty("@enabledFlag") && item.@enabledFlag & Course.EF_PUBLISHER))
						keepItem = true;
				}
				if (!filterOwner.selected && !filterCollaborator.selected && !filterPublisher.selected)
					keepItem = true;
				
				// If you type any text, that gets rid of unmatching items
				if (filterTextInput.text) {
					if (!((item.@caption.toLowerCase().indexOf(filterTextInput.text.toLowerCase()) >= 0) || 
						(item.hasOwnProperty("@description") && item.@description.toLowerCase().indexOf(filterTextInput.text.toLowerCase()) >= 0)))
						keepItem = false;
				}
				return keepItem;
			};
			(courseList.dataProvider as XMLListCollection).refresh();
			
			// gh#956
			viewMemory.courseSelector.@filterOwner = String(filterOwner.selected);
			viewMemory.courseSelector.@filterCollaborator = String(filterCollaborator.selected);
			viewMemory.courseSelector.@filterPublisher = String(filterPublisher.selected);
			viewMemory.courseSelector.filter = filterTextInput.text;
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