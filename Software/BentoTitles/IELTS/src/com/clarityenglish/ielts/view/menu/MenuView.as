package com.clarityenglish.ielts.view.menu {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.ielts.view.module.ModuleView;
	import com.clarityenglish.ielts.view.progress.ProgressView;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.TabBar;
	
	[SkinState("module")]
	[SkinState("progress")]
	[SkinState("account")]
	public class MenuView extends BentoView {
		
		[SkinPart]
		public var course1Button:Button;
		
		[SkinPart]
		public var course2Button:Button;
		
		[SkinPart]
		public var course3Button:Button;
		
		[SkinPart]
		public var course4Button:Button;
		
		[SkinPart]
		public var tabBar:TabBar;
		
		[SkinPart]
		public var moduleView:ModuleView;
		
		[SkinPart]
		public var progressView:ProgressView;
		
		public var courseSelected:Signal = new Signal(String);
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_xhtml) {
				// Label the course selection buttons from the XML
				var n:uint = 1;
				for each (var course:XML in menu..course) {
					var courseButton:Button = this["course" + n + "Button"];
					courseButton.label = course.@caption;
					courseButton.visible = true;
					n++;
				}
				
				// Set the first course by default
				//moduleView.course = menu..course[0];
				moduleView.courseName = menu..course[0].@caption;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case course1Button:
				case course2Button:
				case course3Button:
				case course4Button:
					// TODO: This should maybe send something other than the label (i.e. the course xml?? but can deal with that later)
					instance.addEventListener(MouseEvent.CLICK, onCourseSelected);
					break;
				case tabBar:
					tabBar.dataProvider = new ArrayCollection( [
						{ label: "Academic module", data: "module" },
						{ label: "My Progress", data: "progress" },
						{ label: "My Account", data: "account" },
					] );
					tabBar.requireSelection = true;
					tabBar.addEventListener(Event.CHANGE, onTabIndexChange);
					break;
				case moduleView:
					// Pass on the same href to the module view
					instance.href = href;
					break;
			}
		}
		
		/**
		 * The skin state is (for the moment) determined by the tab selection
		 * 
		 * @return 
		 */
		protected override function getCurrentSkinState():String {
			return (tabBar && tabBar.selectedItem) ? tabBar.selectedItem.data : null;
		}
		
		/**
		 * When the tab is changed invalidate the skin state to force getCurrentSkinState() to get called again
		 * 
		 * @param event
		 */
		protected function onTabIndexChange(event:Event):void {
			invalidateSkinState();
		}
		
		/**
		 * The user has selected a course so update the module view
		 * 
		 * @param e
		 */
		protected function onCourseSelected(e:Event):void {
			var caption:String = e.target.label;
			//moduleView.course = _xhtml.selectOne("course[caption='" + caption + "']");
			moduleView.courseName = caption;
		}
		
	}
	
}