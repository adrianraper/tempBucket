package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.events.ExerciseEvent;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.textLayout.components.AudioPlayer;
	
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.XMLListCollection;
	import mx.controls.SWFLoader;
	import mx.events.ScrollEvent;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Label;
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	public class ExamPracticeZoneSectionView extends AbstractZoneSectionView {
		
		[SkinPart(required="true")]
		public var list:List;
		
		[SkinPart]
		public var leftArrow:SWFLoader;
		
		[SkinPart]
		public var rightArrow:SWFLoader;
		
		[SkinPart(required="true")]
		public var examZoneLabel:Label;
		
		[SkinPart(required="true")]
		public var examZoneInstructionLabel:Label;
		
		[SkinPart]
		public var examZoneNoTestLabel:Label;
		
		public var exerciseSelect:Signal = new Signal(Href);
		
		private var viewportPropertyWatcher:ChangeWatcher;
		
		// gh#11
		public function get assetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getDefaultLanguageCode().toLowerCase() + '/';
		}
		public function get languageAssetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getLanguageCode().toLowerCase() + '/';
		}
		
		public function ExamPracticeZoneSectionView() {
			super();
			actionBarVisible = false;
		} 
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			list.dataProvider = new XMLListCollection(_course.unit.(@["class"] == "exam-practice").exercise);
			
			if (this.courseClass == "listening") {
				examZoneInstructionLabel.text = copyProvider.getCopyForId("examZoneInstructionLabel1");
			} else {
				examZoneInstructionLabel.text = copyProvider.getCopyForId("examZoneInstructionLabel2");
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case list:
					viewportPropertyWatcher = ChangeWatcher.watch(list.scroller.viewport, "horizontalScrollPosition", onViewportPropertyChange);
					list.addEventListener(ExerciseEvent.EXERCISE_SELECTED, onExerciseSelected);
					break;
				// gh#11
				case examZoneLabel:
					instance.text = copyProvider.getCopyForId("examZoneLabel");
					break;
				case examZoneNoTestLabel:
					var replaceObj:Object = new Object();
					replaceObj.courseClass = this.courseClass;
					instance.text = copyProvider.getCopyForId("examZoneNoTestLabel", replaceObj);
					break;
			}
		}

		protected function onViewportPropertyChange(event:Event):void {
			// TODO: This calls stopAllAudio for every point of the scroll which is a little inefficient.  If we get performance issue this needs to be looked at
			// (but unfortunately there is no easy way to detect a scroll in Flex 4 which is why we are going for a ChangeWatcher).
			AudioPlayer.stopAllAudio(); // gh#12
		}
		
		protected function onExerciseSelected(event:ExerciseEvent):void {
			exerciseSelect.dispatch(href.createRelativeHref(Href.EXERCISE, event.hrefFilename));
		}
		
		public function stopAllAudio():void {
			AudioPlayer.stopAllAudio();
		}
		
		protected override function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);
			if (viewportPropertyWatcher) viewportPropertyWatcher.unwatch();
			stopAllAudio();
		}
		
	}
}
