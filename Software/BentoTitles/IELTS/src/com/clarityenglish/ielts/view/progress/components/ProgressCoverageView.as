package com.clarityenglish.ielts.view.progress.components {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.progress.ui.CoverageGroupRenderer;
	import com.clarityenglish.bento.view.progress.ui.CoverageUnitRenderer;
	import com.clarityenglish.bento.view.progress.ui.ProgressBarRenderer;
	import com.clarityenglish.bento.view.progress.ui.ProgressCourseButtonBar;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	
	import org.davekeen.util.StringUtils;
	import org.osflash.signals.Signal;
	
	import spark.components.DataGroup;
	import spark.components.Label;
	import spark.events.IndexChangeEvent;
	import mx.core.ClassFactory;
	
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
		public var progressCoverageDateGroup:DataGroup;
		
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
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			if (progressCourseButtonBar) progressCourseButtonBar.courses = menu.course;
		}
		
		protected override function onViewCreationComplete():void {
			super.onViewCreationComplete();
			
			if (progressCourseButtonBar) progressCourseButtonBar.copyProvider = copyProvider;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_courseChanged && menu) {	
				if (progressBar) {
					progressBar.label = copyProvider.getCopyForId("progressBarCoverage", { course: copyProvider.getCopyForId(StringUtils.capitalize(courseClass)) });
					progressBar.data = menu.course.(@["class"] == courseClass).@coverage;
				}
				
				unitListCollection = new XMLListCollection(menu.course.(@["class"] == courseClass).unit);
				
				// #176. Make sure the buttons in the progressCourseBar component reflect current state
				if (progressCourseButtonBar) progressCourseButtonBar.courseClass = courseClass;
				if (progressCoverageDateGroup) {
					progressCoverageDateGroup.dataProvider = unitListCollection;
					progressCoverageDateGroup.itemRendererFunction = getItemRenderer;
				}
				
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
		
		private function getItemRenderer(item:Object):ClassFactory {
			if (item.@["class"] == "practice-zone") {
				return new ClassFactory(CoverageGroupRenderer);
			} else {
				return new ClassFactory(CoverageUnitRenderer);
			}
		}
	
	}

}
