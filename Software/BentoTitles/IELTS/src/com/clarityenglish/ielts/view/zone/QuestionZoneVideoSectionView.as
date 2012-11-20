package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.vo.ExerciseMark;
	import com.clarityenglish.controls.video.VideoSelector;
	import com.clarityenglish.controls.video.events.VideoScoreEvent;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	
	import org.davekeen.util.StringUtils;
	import org.osflash.signals.Signal;
	
	public class QuestionZoneVideoSectionView extends AbstractZoneSectionView {
		
		private static var dummy:StringUtils; // For some reason Flash Builder gets confused about importing StringUtils, so just have this here to fix it
		
		[SkinPart(required="true")]
		public var videoSelector:VideoSelector;
		
		public var hrefToUidFunction:Function;
		
		public var channelCollection:ArrayCollection;
		
		public var videoScore:Signal = new Signal(ExerciseMark);
		
		public function QuestionZoneVideoSectionView() {
			super();
			actionBarVisible = false;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			// Only provide rss files to the video selector
			videoSelector.href = href;
			videoSelector.hrefToUidFunction = hrefToUidFunction;
			videoSelector.channelCollection = channelCollection;
			videoSelector.videoCollection = new XMLListCollection(_course.unit.(@["class"] == "question-zone").exercise.(StringUtils.endsWith(@href, ".rss")));
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case videoSelector:
					videoSelector.addEventListener(VideoScoreEvent.VIDEO_SCORE, onVideoScore);
					break;
			}
		}
		
		protected function onVideoScore(event:VideoScoreEvent):void {
			videoScore.dispatch(event.exerciseMark);
		}
		
		/**
		 * Whenever this view is removed from the stage (which happens when you move to a different section of the app) pop the navigator back to the first view, which
		 * is the original question zone page.
		 */
		protected override function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);
			navigator.popToFirstView();
		}
		
	}
}
