package com.clarityenglish.rotterdam.view.settings {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.controls.calendar.Calendar;
	import com.clarityenglish.rotterdam.view.settings.events.SettingsEvent;
	import com.clarityenglish.textLayout.vo.XHTML;
	import com.sparkTree.Tree;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.IViewCursor;
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.controls.DateField;
	import mx.core.ClassFactory;
	import mx.events.FlexEvent;
	import mx.events.ItemClickEvent;
	
	import org.davekeen.util.DateUtil;
	import org.davekeen.util.StringUtils;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.Form;
	import spark.components.FormHeading;
	import spark.components.FormItem;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.List;
	import spark.components.RadioButton;
	import spark.components.RadioButtonGroup;
	import spark.components.TabBar;
	import spark.components.TextArea;
	import spark.components.TextInput;
	import spark.events.IndexChangeEvent;
	
	/**
	 * There is quite a lot of code duplication here that could be neatened up into a mini form framework that automatically links xml properties and components.
	 * in a Rails/Symfony style form system.  This might well be worth doing at some point, but for the moment just leave it hand coded.
	 */
	public class SettingsView extends BentoView {
		
		[SkinPart]
		public var courseSettingsLabel:Label;
		
		[SkinPart]
		public var permissionsForm:Form;
		
		[SkinPart]
		public var aboutForm:Form;
		
		[SkinPart]
		public var aboutCourseFormHeading:FormHeading;
		
		[SkinPart]
		public var permissionsFormHeading:FormHeading;
		
		[SkinPart]
		public var courseNameFormItem:FormItem;
		
		[SkinPart]
		public var aboutCourseNameTextInput:TextInput;
		
		// gh#704
		[SkinPart]
		public var aboutCourseDescriptionTextArea:TextArea;
		
		[SkinPart]
		public var aboutAuthorTextInput:TextInput;
		
		[SkinPart]
		public var aboutEmailTextInput:TextInput;
		
		[SkinPart]
		public var aboutContactNumberTextInput:TextInput;
		
		[SkinPart]
		public var directStartURLLabel:Label;
		
		[SkinPart]
		public var courseDescriptionFormItem:FormItem;
		
		[SkinPart]
		public var authorFormItem:FormItem;
		
		[SkinPart]
		public var contactEmailFormItem:FormItem;
		
		[SkinPart]
		public var directURLLabel:Label;
		
		[SkinPart]
		public var ownerLabel:Label;
		
		[SkinPart]
		public var ownerFormItem:FormItem;
		
		[SkinPart]
		public var collaboratorsFormItem:FormItem;
		
		[SkinPart]
		public var publishersFormItem:FormItem;
		
		[SkinPart]
		public var collaboratorsText:List;
		
		[SkinPart]
		public var publishersText:List;
		
		[SkinPart]
		public var groupCollaboratorsCheckBox:CheckBox;
		
		[SkinPart]
		public var rootCollaboratorsCheckBox:CheckBox;
		
		[SkinPart]
		public var rootPublishersCheckBox:CheckBox;
		
		[SkinPart]
		public var groupPublishersCheckBox:CheckBox;
		
		[SkinPart]
		public var courseEditableFormItem:FormItem;
		
		[SkinPart]
		public var courseEditableCheckBox:CheckBox;
		
		[SkinPart(required="true")]
		public var saveButton:Button;
		
		[SkinPart(required="true")]
		public var backButton:Button;
		
		public var dirty:Signal = new Signal(); // gh#83
		public var saveCourse:Signal = new Signal();
		public var back:Signal = new Signal();
		public var sendEmail:Signal = new Signal(); //gh#122
		
		private var isPopulating:Boolean;
		
		// gh#91
		public var isOwner:Boolean;
		
		public function SettingsView() {
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
			// gh#704
			if (aboutCourseDescriptionTextArea) aboutCourseDescriptionTextArea.text = course.@description;
			if (aboutAuthorTextInput) aboutAuthorTextInput.text = course.@author;
			if (aboutEmailTextInput) aboutEmailTextInput.text = course.@email;
			if (aboutContactNumberTextInput) aboutContactNumberTextInput.text = course.@contact;
			
			// gh#92
			var folderName:String = copyProvider.getCopyForId('pathCCB');
			var directStartURL:String = config.remoteStartFolder + folderName + '/Player.php' + '?prefix=' + config.prefix + '&course=' + course.@id;
			if (directStartURLLabel) directStartURLLabel.text = directStartURL;
		
			// gh#91
			// All permissions stuff if ONLY changeable by owner
			if (permissionsForm && !isOwner) 
				permissionsForm.enabled = false;
			
			if (aboutForm) {
				if (course.permission.@editable != 'true') {
					aboutForm.enabled = false;
				} else {
					aboutForm.enabled = true;
				}
			}
			
			if (ownerLabel) {
				ownerLabel.text = course.privacy.owner.user.@name;
				if (aboutAuthorTextInput && aboutAuthorTextInput.text == '')
					aboutAuthorTextInput.text = ownerLabel.text;
			}
			if (courseEditableCheckBox) courseEditableCheckBox.selected = (course.permission.@editable == 'true');
			/*
			 * This starts adding to the actual XML rather than just items in the list box
			if (collaboratorsText) {
				var groupList:XMLListCollection = new XMLListCollection(course.privacy.collaborators.group); 
				var rootList:XMLListCollection = new XMLListCollection(course.privacy.collaborators.root);
				if (rootList)
					groupList.addAll(rootList);
				collaboratorsText.dataProvider = groupList;
				// TODO It would be great to add 'teachers in ' to the group/root name
				collaboratorsText.labelField = '@name';
			}
			*/
			if (rootCollaboratorsCheckBox) {
				rootCollaboratorsCheckBox.selected = (course.privacy.collaborators.@root == 'true');
				groupCollaboratorsCheckBox.enabled = !rootCollaboratorsCheckBox.selected;
			}
			if (groupCollaboratorsCheckBox) groupCollaboratorsCheckBox.selected = (course.privacy.collaborators.@group == 'true');
			
			/*
			if (publishersText) {
				publishersText.dataProvider = new XMLListCollection(course.privacy.publishers.group);
				publishersText.labelField = '@name';
			}
			*/
			if (rootPublishersCheckBox) {
				rootPublishersCheckBox.selected = (course.privacy.publishers.@root == 'true');
				groupPublishersCheckBox.enabled = !rootPublishersCheckBox.selected;
			}
			if (groupPublishersCheckBox) groupPublishersCheckBox.selected = (course.privacy.publishers.@group == 'true');
			
			// Only enable the save button if the settings are valid
			if (saveButton && isOwner) {
				var isValid:Boolean = true;
			} else {
				isValid = false;
			}
			saveButton.enabled = isValid;
			
			isPopulating = false;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case aboutCourseFormHeading:
					instance.label = copyProvider.getCopyForId("aboutCourseLabel");
					break;
				case permissionsFormHeading:
					instance.label = copyProvider.getCopyForId("permissionsLabel");
					break;
				case courseSettingsLabel:
					instance.text = copyProvider.getCopyForId("courseSettingsLabel");
					break;
				case ownerFormItem:
					instance.label = copyProvider.getCopyForId("ownerLabel");
					break;
				case courseEditableFormItem:
					instance.label = copyProvider.getCopyForId("courseEditableLabel");
					break;
				case collaboratorsFormItem:
					instance.label = copyProvider.getCopyForId("collaboratorsLabel");
					break;
				case publishersFormItem:
					instance.label = copyProvider.getCopyForId("publishersLabel");
					break;
				case courseEditableCheckBox:
					instance.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						if (!isPopulating) {
							course.permission.@editable = String(e.target.selected);
							dirty.dispatch();
							invalidateProperties();
						}
					});
					break;
				// gh#91
				case rootCollaboratorsCheckBox:
					instance.label = copyProvider.getCopyForId("rootCollaboratorsLabel");
					instance.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						if (!isPopulating) {
							course.privacy.collaborators.@root = String(e.target.selected);
							// If you selected root, then group can't be changed
							groupCollaboratorsCheckBox.enabled = !e.target.selected;
							dirty.dispatch();
							invalidateProperties();
						}
					});
					break;
				case groupCollaboratorsCheckBox:
					instance.label = copyProvider.getCopyForId("groupCollaboratorsLabel");
					instance.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						if (!isPopulating) {
							course.privacy.collaborators.@group = String(e.target.selected);
							dirty.dispatch();
							invalidateProperties();
						}
					});
					break;
				case rootPublishersCheckBox:
					instance.label = copyProvider.getCopyForId("rootPublishersLabel");
					instance.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						if (!isPopulating) {
							course.privacy.publishers.@root = String(e.target.selected);
							// If you selected root, then group can't be changed
							groupPublishersCheckBox.enabled = !e.target.selected;
							dirty.dispatch();
							invalidateProperties();
						}
					});
					break;
				case groupPublishersCheckBox:
					instance.label = copyProvider.getCopyForId("groupPublishersLabel");
					instance.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						if (!isPopulating) {
							course.privacy.publishers.@group = String(e.target.selected);
							dirty.dispatch();
							invalidateProperties();
						}
					});
					break;
				case aboutCourseNameTextInput:
					instance.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						if (!isPopulating) {
							course.@caption = StringUtils.trim(e.target.text);
							dirty.dispatch();
							invalidateProperties();
						}
					});
					break;
				// gh#704
				case aboutCourseDescriptionTextArea:
					instance.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						if (!isPopulating) {
							course.@description = StringUtils.trim(e.target.text);
							dirty.dispatch();
							invalidateProperties();
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
				case saveButton:
					instance.addEventListener(MouseEvent.CLICK, onSave);
					instance.label = copyProvider.getCopyForId("normalSaveButton");
					break;
				case backButton:
					instance.addEventListener(MouseEvent.CLICK, onBack);
					instance.label = copyProvider.getCopyForId("cancelButton");
					break;
				case courseNameFormItem:
					instance.label = copyProvider.getCopyForId("courseNameLabel");
					break;
				case courseDescriptionFormItem:
					instance.label = copyProvider.getCopyForId("courseDescriptionLabel");
					break;
				case authorFormItem:
					instance.label = copyProvider.getCopyForId("authorLabel");
					break;
				case contactEmailFormItem:
					instance.label = copyProvider.getCopyForId("contactEmailLabel");
					break;
				case directURLLabel:
					instance.text = copyProvider.getCopyForId("directURLLabel");
					break;
			}
		}
		
		protected function onSave(event:MouseEvent):void {
			// gh#91 Surely groups is done by scheduleView - nothing to do with settings anymore
			/*
			// Remove any groups without all the required information
			for each (var group:XML in course.publication.group) {
				if (!group.hasOwnProperty("@id") ||
					!group.hasOwnProperty("@seePastUnits") ||
					!group.hasOwnProperty("@unitInterval") ||
					!group.hasOwnProperty("@startDate")) {
					delete (group.parent().children()[group.childIndex()]);
				}
			}
			*/
			
			// Merge the temporary course into the real XHTML
			mergeCourseToXHTML();
			
			// Save
			saveCourse.dispatch();
			back.dispatch();
		}
		
		protected function onBack(event:MouseEvent):void {
			back.dispatch();
		}
		
		protected function onMouseFocusChange(event:FocusEvent):void {
		}
		
	}
}