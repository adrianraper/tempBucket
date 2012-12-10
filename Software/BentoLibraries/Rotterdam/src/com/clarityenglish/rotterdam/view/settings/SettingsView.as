package com.clarityenglish.rotterdam.view.settings {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayList;
	import mx.controls.DateChooser;
	import mx.events.FlexEvent;
	
	import org.davekeen.util.StringUtils;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.TabBar;
	import spark.components.TextInput;
	import spark.events.IndexChangeEvent;
	
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
		
		[SkinPart(required="true")]
		public var saveButton:Button;
		
		[SkinPart(required="true")]
		public var backButton:Button;
		
		[SkinPart]
		public var startDateChooser:DateChooser;
		
		public var saveCourse:Signal = new Signal();
		public var back:Signal = new Signal();
		
		private function get course():XML {	
			return _xhtml.selectOne("script#model[type='application/xml'] course");
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// This makes sure that commitProperties is called after menu.xml has loaded so everything can be filled in
			invalidateProperties();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (startDateChooser) startDateChooser.selectedDate = course.hasOwnProperty("@startDate") ? new Date(course.@startDate) : new Date();
			
			// About data
			if (aboutCourseNameTextInput) aboutCourseNameTextInput.text = course.@caption;
			if (aboutAuthorTextInput) aboutAuthorTextInput.text = course.@author;
			if (aboutEmailTextInput) aboutEmailTextInput.text = course.@email;
			if (aboutContactNumberTextInput) aboutContactNumberTextInput.text = course.@contact;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case tabBar:
					tabBar.dataProvider = new ArrayList([
						{ label: "About", data: "about" },
						{ label: "Calendar", data: "calendar" },
						//{ label: "Email", data: "email" } - Email is disabled for the moment
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
						course.@caption = StringUtils.trim(e.target.text);
					});
					break;
				case aboutAuthorTextInput:
					instance.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						course.@author = StringUtils.trim(e.target.text);
					});
					break;
				case aboutEmailTextInput:
					instance.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						course.@email = StringUtils.trim(e.target.text);
					});
					break;
				case aboutContactNumberTextInput:
					instance.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						course.@contact = StringUtils.trim(e.target.text);
					});
					break;
				case saveButton:
					saveButton.addEventListener(MouseEvent.CLICK, onSave);
					break;
				case backButton:
					backButton.addEventListener(MouseEvent.CLICK, onBack);
					break;
				case startDateChooser:
					startDateChooser.addEventListener(Event.CHANGE, function(e:Event):void {
						course.@startDate = startDateChooser.selectedDate.time;
					});
					break;
			}
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