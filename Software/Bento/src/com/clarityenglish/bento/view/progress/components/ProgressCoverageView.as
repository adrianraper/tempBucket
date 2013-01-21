package com.clarityenglish.bento.view.progress.components {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.progress.ui.CoverageUnitRenderer;
	import com.clarityenglish.bento.view.progress.ui.ProgressBarRenderer;
	import com.clarityenglish.bento.view.progress.ui.ProgressCourseButtonBar;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import mx.collections.XMLListCollection;
	import mx.core.ClassFactory;
	
	import org.osflash.signals.Signal;
	
	import spark.components.DataGroup;
	import spark.events.IndexChangeEvent;
	
	/**
	 * TODO: This class is way too specific; we don't want to be specifying course classes in here since we want it to be shared between all titles.
	 */
	public class ProgressCoverageView extends BentoView {
		
		[SkinPart]
		public var progressCourseButtonBar:ProgressCourseButtonBar;
		
		[SkinPart(required="true")]
		public var progressBar:ProgressBarRenderer;
		
		[SkinPart]
		public var dataGroup:DataGroup;
		
		// This is just horrible, but there is no easy way to get the current course into ZoneAccordianButtonBarSkin without this.
		// NOTHING ELSE SHOULD USE THIS VARIABLE!!!
		// The horribleness comes from referring to this view from a renderer in the skin, so although we already have
		// a decent courseClass in this view, we keep this name. I think.
		[Bindable]
		public static var horribleHackCourseClass:String;
		
		private var _courseClass:String;
		private var _courseChanged:Boolean;
		
		public var courseSelect:Signal = new Signal(String);
		
		/**
		 * This can be called from outside the view to make the view display a different course
		 *
		 * @param XML A course node from the menu
		 *
		 */
		public function set courseClass(value:String):void {
			_courseClass = value;
			_courseChanged = true;
			
			// This is a horrible hack
			horribleHackCourseClass = courseClass;
			
			invalidateProperties();
		}
		
		[Bindable]
		public function get courseClass():String {
			return _courseClass;
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			progressCourseButtonBar.courses = menu.course;
		}
		
		protected override function onViewCreationComplete():void {
			super.onViewCreationComplete();
			
			if (progressCourseButtonBar) progressCourseButtonBar.copyProvider = copyProvider;
			if (progressBar) progressBar.copyProvider = copyProvider;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_courseChanged) {				
				// Update the components of the view that change their data
				if (progressBar && courseClass) {
					progressBar.courseClass = courseClass;
					progressBar.type = "coverage";
					progressBar.data = menu;
				}
				
				if (dataGroup) {
					dataGroup.dataProvider = new XMLListCollection(menu.course.(@["class"] == courseClass).unit);
					dataGroup.itemRendererFunction = dataGroup.itemRendererFunction; // Flex bug workaround: SDK-32018
				}
				
				// #176. Make sure the buttons in the progressCourseBar component reflect current state
				if (progressCourseButtonBar) progressCourseButtonBar.courseClass = courseClass;
				
				_courseChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case progressCourseButtonBar:
					progressCourseButtonBar.addEventListener(IndexChangeEvent.CHANGE, onCourseSelect);
					break;
				case dataGroup:
					// The datagroup defaults to CoverageExerciseComponent (which will be the case for most titles).  If this needs to be changed, such as
					// in IELTS then it can be overridden in the skin.
					dataGroup.itemRenderer = new ClassFactory(CoverageUnitRenderer);
					break;
			}
		}
		
		/**
		 * The user has changed the course to be displayed
		 *
		 * @param String course class name
		 */
		public function onCourseSelect(event:IndexChangeEvent):void {
			courseSelect.dispatch(event.target.selectedItem.courseClass.toLowerCase());
		}
	
	}

}
