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
		
		// gh#704
		[SkinPart]
		public var aboutCourseDescriptionTextArea:TextArea;
		
		[SkinPart]
		public var aboutCourseNameTextInput:TextInput;
		
		[SkinPart]
		public var aboutAuthorTextInput:TextInput;
		
		[SkinPart]
		public var aboutEmailTextInput:TextInput;
		
		[SkinPart]
		public var aboutContactNumberTextInput:TextInput;
		
		[SkinPart]
		public var directStartURLLabel:TextInput;
		
		[SkinPart]
		public var courseNameLabel:Label;
		
		[SkinPart]
		public var courseDescriptionLabel:Label;
		
		[SkinPart]
		public var authorLabel:Label;
		
		[SkinPart]
		public var contactEmailLabel:Label;
		
		[SkinPart]
		public var directURLLabel:Label;
		
		[SkinPart]
		public var permissionsLabel:Label;
		
		[SkinPart]
		public var ownerLabel:Label;
		
		[SkinPart]
		public var ownerText:Label;
		
		[SkinPart]
		public var collaboratorsLabel:Label;
		
		[SkinPart]
		public var publishersLabel:Label;
		
		[SkinPart]
		public var collaboratorsText:List;
		
		[SkinPart]
		public var publishersText:List;
		
		[SkinPart]
		public var addCollaboratorButton:Button;
		
		[SkinPart]
		public var transferOwnershipButton:Button;
		
		[SkinPart]
		public var addPublisherButton:Button;
		
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
		private var XMLLinker:Object;
		
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
			if (ownerText) ownerText.text = course.privacy.owner.@name;
			if (courseEditableCheckBox) courseEditableCheckBox.selected = (course.privacy.editable.@value == 'true');
			// TODO. Collaborators can also have group and root nodes - merge those in
			if (collaboratorsText) collaboratorsText.dataProvider = new XMLListCollection(course.privacy.collaborators.user.@name);
			if (publishersText) publishersText.dataProvider = new XMLListCollection(course.privacy.publishers.user.@name);
				
			// Only enable the save button if x settings are valid
			if (saveButton) {
				var isValid:Boolean = true;
				saveButton.enabled = isValid;
			}
			
			isPopulating = false;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case courseSettingsLabel:
					instance.text = copyProvider.getCopyForId("courseSettingsLabel");
					break;
				case permissionsLabel:
					instance.text = copyProvider.getCopyForId("permissionsLabel");
					break;
				case ownerLabel:
					instance.text = copyProvider.getCopyForId("ownerLabel");
					break;
				case collaboratorsLabel:
					instance.text = copyProvider.getCopyForId("collaboratorsLabel");
					break;
				case publishersLabel:
					instance.text = copyProvider.getCopyForId("publishersLabel");
					break;
				case courseEditableCheckBox:
					courseEditableCheckBox.label = copyProvider.getCopyForId("courseEditableLabel");
					instance.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						if (!isPopulating) {
							course.privacy.editable.@value = e.target.selected;
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
				case addCollaboratorButton:
					instance.addEventListener(MouseEvent.CLICK, onSave);
					instance.label = copyProvider.getCopyForId("addCollaboratorButton");
					break;
				case transferOwnershipButton:
					instance.addEventListener(MouseEvent.CLICK, onSave);
					instance.label = copyProvider.getCopyForId("transferOwnershipButton");
					break;
				case addPublisherButton:
					instance.addEventListener(MouseEvent.CLICK, onSave);
					instance.label = copyProvider.getCopyForId("addPublisherButton");
					break;
				case courseNameLabel:
					instance.text = copyProvider.getCopyForId("courseNameLabel");
					break;
				case courseDescriptionLabel:
					instance.text = copyProvider.getCopyForId("courseDescriptionLabel");
					break;
				case authorLabel:
					instance.text = copyProvider.getCopyForId("authorLabel");
					break;
				case contactEmailLabel:
					instance.text = copyProvider.getCopyForId("contactEmailLabel");
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