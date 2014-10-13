package com.clarityenglish.clearpronunciation.view.progress {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.progress.ui.ProgressBarRenderer;
	import com.clarityenglish.bento.view.progress.ui.ProgressCourseButtonBar;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	
	import org.davekeen.util.StringUtils;
	import org.osflash.signals.Signal;
	
	import spark.components.Label;
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
		public var completeLabel:Label;
		
		[SkinPart]
		public var notCompleteLabel:Label;
		
		[SkinPart]
		public var othersLabel:Label;
		
		[SkinPart]
		public var coverageInstructionLabel:Label;
		
		[Bindable]
		public var unitListCollection:ListCollectionView;
		
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
		
		public function getCopyProvider():CopyProvider {
			return copyProvider;
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			var courseXMLList:XMLList = new XMLList();
			for each (var course:XML in menu.course) {
				if (course.@["class"] != "introduction") {
					courseXMLList += course;
				}
			}
			if (progressCourseButtonBar) progressCourseButtonBar.courses = courseXMLList;
		}
		
		protected override function onViewCreationComplete():void {
			super.onViewCreationComplete();
			
			if (progressCourseButtonBar) progressCourseButtonBar.copyProvider = copyProvider;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_courseChanged && menu) {	
				if (progressBar) {
					progressBar.label = copyProvider.getCopyForId("progressBarCoverage", { course: StringUtils.capitalize(courseClass)});
					progressBar.data = menu.course.(@["class"] == courseClass).@coverage;
				}
				
				unitListCollection = new XMLListCollection(menu.course.(@["class"] == courseClass).unit);
				
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
				case completeLabel:
					completeLabel.text = copyProvider.getCopyForId("completeLabel");
					break;
				case notCompleteLabel:
					notCompleteLabel.text = copyProvider.getCopyForId("notCompleteLabel");
					break;
				case othersLabel:
					othersLabel.text = copyProvider.getCopyForId("othersLabel");
					break;
				case coverageInstructionLabel:
					coverageInstructionLabel.text = copyProvider.getCopyForId("coverageInstructionLabel");
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