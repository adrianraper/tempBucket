package com.clarityenglish.resultsmanager.view.management.ui {
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.view.interfaces.CopyReceiver;
	import com.clarityenglish.common.vo.content.Content;
	import com.clarityenglish.common.vo.content.Course;
	import com.clarityenglish.common.vo.content.Exercise;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.content.Unit;
	import com.clarityenglish.resultsmanager.vo.manageable.Group;
	import com.clarityenglish.resultsmanager.vo.manageable.Manageable;
	import com.clarityenglish.resultsmanager.vo.manageable.User;
	import com.clarityenglish.resultsmanager.Constants;
	import com.clarityenglish.resultsmanager.view.management.events.ContentEvent;
	import com.clarityenglish.resultsmanager.view.management.events.ReportEvent;
	import com.clarityenglish.utils.TraceUtils;
	
	import eu.orangeflash.managers.CMManager;
	
	import flash.display.InteractiveObject;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import org.davekeen.utils.ClassUtils;
	
	/**
	 * ...
	 * @author Clarity
	 */
	public class ContentCMManager extends CMManager implements CopyReceiver {
		
		private var generateReportMenuItem:ContextMenuItem;
		private var editExerciseMenuItem:ContextMenuItem;
		private var deleteExerciseMenuItem:ContextMenuItem;
		private var resetContentMenuItem:ContextMenuItem;
		private var directStartMenuItem:ContextMenuItem;
		private var insertExerciseBeforeMenuItem:ContextMenuItem;
		private var insertExerciseAfterMenuItem:ContextMenuItem;
		// v3.5.1 Preview of the content programs
		private var previewMenuItem:ContextMenuItem;
		private var copyProvider:CopyProvider;
		
		public function ContentCMManager(target:InteractiveObject) {
			super(target);
			
			generateReportMenuItem = add("", function(e:Event):void { dispatchEvent(new ReportEvent(ReportEvent.SHOW_REPORT_WINDOW, null, null, true)); } );
			editExerciseMenuItem = add("", function(e:Event):void { dispatchEvent(new ContentEvent(ContentEvent.EDIT_EXERCISE, null, null, null, null, true)); }, true );
			//deleteExerciseMenuItem = add("", function(e:Event):void { dispatchEvent(new ContentEvent(ContentEvent.DELETE_EXERCISE, null, null, null, null, true)); } );
			insertExerciseBeforeMenuItem = add("", function(e:Event):void { dispatchEvent(new ContentEvent(ContentEvent.INSERT_CONTENT_BEFORE, null, null, null, null, true)); } );
			insertExerciseAfterMenuItem = add("", function(e:Event):void { dispatchEvent(new ContentEvent(ContentEvent.INSERT_CONTENT_AFTER, null, null, null, null, true)); } );
			resetContentMenuItem = add("", function(e:Event):void { dispatchEvent(new ContentEvent(ContentEvent.RESET_CONTENT, null, null, null, null, true)); } );
			directStartMenuItem = add("", function(e:Event):void { dispatchEvent(new ContentEvent(ContentEvent.DIRECT_START_LINK, null, null, null, null, true)); }, true );
			previewMenuItem = add("", function(e:Event):void { dispatchEvent(new ContentEvent(ContentEvent.PREVIEW, null, null, null, null, true)); } );
		}
		
		public function setCopyProvider(copyProvider:CopyProvider):void {
			this.copyProvider = copyProvider;
			generateReportMenuItem.caption = copyProvider.getCopyForId("generateReportMenuItem");
			editExerciseMenuItem.caption = copyProvider.getCopyForId("editExerciseMenuItem");
			//deleteExerciseMenuItem.caption = copyProvider.getCopyForId("deleteExerciseMenuItem");
			insertExerciseBeforeMenuItem.caption = copyProvider.getCopyForId("insertExerciseBeforeMenuItem");
			insertExerciseAfterMenuItem.caption = copyProvider.getCopyForId("insertExerciseAfterMenuItem");
			// v3.5 Also set in the configureMenuItems
			resetContentMenuItem.caption = copyProvider.getCopyForId("resetContentMenuItem");
			directStartMenuItem.caption = copyProvider.getCopyForId("directStartMenuItem");
			previewMenuItem.caption = copyProvider.getCopyForId("previewMenuItem");
		}

		// v3.4 Added new function
		public function configureMenuItems():void {
			// Only authors can do any kind of editing.
			editExerciseMenuItem.visible 
										//= deleteExerciseMenuItem.visible
										= insertExerciseBeforeMenuItem.visible
										= insertExerciseAfterMenuItem.visible
										= resetContentMenuItem.visible
										= Constants.userType == User.USER_TYPE_AUTHOR;
										
			// v3.5 You might change the reset label for some selections, so make sure you always go back to the default
			resetContentMenuItem.caption = copyProvider.getCopyForId("resetContentMenuItem");
		}
		
		// When right-clicking is context sensitive
		public function enableBySelectedContent(selectedItems:Array):void {
			var manageable:Manageable;
			// Set visible menu items based on user type.  Its not really necessary for this to happen everytime, but there
			// isn't really any other obvious place to put it and its a cheap operation anyway.
			configureMenuItems();
			//MonsterDebugger.trace(this, selectedItems);
			if (selectedItems.length == 0) {
				// If no item is selected in the tree disable the menu
				generateReportMenuItem.enabled = editExerciseMenuItem.enabled
												//= deleteExerciseMenuItem.enabled
												= insertExerciseBeforeMenuItem.enabled
												= insertExerciseAfterMenuItem.enabled
												= resetContentMenuItem.enabled
												= directStartMenuItem.enabled
												= previewMenuItem.enabled
												= false;
												
			// v3.4 Currently you can't multi select on the content tree. Lets see if we really want to change this later.
			} else if (selectedItems.length > 1) {
				// Reports can be generated on multiple Reportables if they are all of the same type
				generateReportMenuItem.enabled = (ClassUtils.checkObjectClasses(selectedItems) != null);
				
				// You can't get direct link for more than one item
				directStartMenuItem.enabled = false;
				previewMenuItem.enabled = false;
				
				// v3.4 You can delete multiple exercises, but not mixed content
				// For now, remove delete altogether
				/*
				var deleteEnabled:Boolean = true;
				for each (var manageable:Manageable in selectedItems) {
					if (!manageable is Exercise) {
						deleteEnabled = false;
						break;
					}
				}
				deleteExerciseMenuItem.enabled = deleteEnabled;
				*/
					
				// v3.4 You can't edit multiple exercises, or insert multiples
				editExerciseMenuItem.enabled = false;
				insertExerciseBeforeMenuItem.enabled = false;
				insertExerciseAfterMenuItem.enabled = false;
				
				// v3.4 You can reset multiple content so long as at least one item is edited
				// v3.5 or moved. Oh pointless as multi-select not allowed.
				var resetEnabled:Boolean = false;
				for each (manageable in selectedItems) {
					//if ((manageable as Content).enabledFlag && Content.CONTENT_EDITED_CONTENT) {
					if (((manageable as Content).enabledFlag & Exercise.ENABLED_FLAG_EDITED) == Exercise.ENABLED_FLAG_EDITED ||
						((manageable as Content).enabledFlag & Exercise.ENABLED_FLAG_MOVED) == Exercise.ENABLED_FLAG_MOVED) {;
						resetEnabled = true;
						break;
					}
				}
				resetContentMenuItem.enabled = resetEnabled;
				
			} else {
				var selectedItem:Content = selectedItems[0] as Content;
											 
				// If a single Content item is selected then we can always generate a report
				generateReportMenuItem.enabled = true;
				// and we can always find a direct link
				directStartMenuItem.enabled = true;
				previewMenuItem.enabled = true;
				
				// v3.4 Editing Clarity Content
				// If you are an author, you can delete exercises (and perhaps you should be able to delete units too)
				//deleteExerciseMenuItem.enabled = (selectedItem is Exercise);
				
				// and reset any content that has been edited
				// TODO - I am sure this shoud be in some kind of loop, or that you can simply always reset.
				//// TraceUtils.myTrace("click to reset, eF=" + selectedItem.enabledFlag);
				// v3.5 Work on it for exercises, units and courses
				if (selectedItem is Exercise) {
					resetContentMenuItem.enabled = ((selectedItem.enabledFlag & Exercise.ENABLED_FLAG_EDITED) == Exercise.ENABLED_FLAG_EDITED ||
													(selectedItem.enabledFlag & Exercise.ENABLED_FLAG_MOVED) == Exercise.ENABLED_FLAG_MOVED ||
													(selectedItem.enabledFlag & Exercise.ENABLED_FLAG_INSERTED) == Exercise.ENABLED_FLAG_INSERTED);
					// v3.5 If the single selected item is an inserted exercise, lets call this delete rather than reset.
					if ((selectedItem.enabledFlag & Exercise.ENABLED_FLAG_INSERTED) == Exercise.ENABLED_FLAG_INSERTED) {
						resetContentMenuItem.caption = copyProvider.getCopyForId("deleteExerciseMenuItem");
					}
					
					
				} else if (selectedItem is Unit) {
					resetEnabled = false;
					for each (var exercise:Exercise in (selectedItem as Unit).children) {
						//if ((manageable as Content).enabledFlag && Content.CONTENT_EDITED_CONTENT) {
						if ((exercise.enabledFlag & Exercise.ENABLED_FLAG_EDITED) == Exercise.ENABLED_FLAG_EDITED ||
							(exercise.enabledFlag & Exercise.ENABLED_FLAG_INSERTED) == Exercise.ENABLED_FLAG_INSERTED ||
							(exercise.enabledFlag & Exercise.ENABLED_FLAG_MOVED) == Exercise.ENABLED_FLAG_MOVED) {
							resetEnabled = true;
							break;
						}
					}
					resetContentMenuItem.enabled = resetEnabled;
				} else if (selectedItem is Course) {
					resetEnabled = false;
					for each (var unit:Unit in (selectedItem as Course).children) {
						for each (exercise in unit.children) {
							//if ((manageable as Content).enabledFlag && Content.CONTENT_EDITED_CONTENT) {
							if ((exercise.enabledFlag & Exercise.ENABLED_FLAG_EDITED) == Exercise.ENABLED_FLAG_EDITED ||
								(exercise.enabledFlag & Exercise.ENABLED_FLAG_INSERTED) == Exercise.ENABLED_FLAG_INSERTED ||
								(exercise.enabledFlag & Exercise.ENABLED_FLAG_MOVED) == Exercise.ENABLED_FLAG_MOVED) {
								resetEnabled = true;
								break;
							}
						}
					}
					resetContentMenuItem.enabled = resetEnabled;
				}

				// and edit an exercise if the eF doesn't block it
				editExerciseMenuItem.enabled = ((selectedItem is Exercise) && !((selectedItem as Exercise).enabledFlag & Content.CONTENT_NONEDITABLE));
				
				// Nothing stops you inserting content I don't think
				insertExerciseBeforeMenuItem.enabled = (selectedItem is Exercise);
				insertExerciseAfterMenuItem.enabled = (selectedItem is Exercise);
				
			}

		}
		
	}
	
}