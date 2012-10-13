package com.clarityenglish.ieltsair.view.zone {
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.ielts.view.zone.ExerciseEvent;
	import com.clarityenglish.textLayout.components.AudioPlayer;
	
	import flash.events.Event;
	
	import mx.collections.XMLListCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.List;
	
	public class ExamPracticeZoneSectionView extends AbstractZoneSectionView {
		
		[SkinPart(required="true")]
		public var list:List;
		
		public var exerciseSelect:Signal = new Signal(Href);
		
		public function ExamPracticeZoneSectionView() {
			super();
			actionBarVisible = false;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			list.dataProvider = new XMLListCollection(_course.unit.(@["class"] == "exam-practice").exercise);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case list:
					list.addEventListener(ExerciseEvent.EXERCISE_SELECTED, onExerciseSelected);
					break;
			}
		}
		
		protected function onExerciseSelected(event:ExerciseEvent):void {
			exerciseSelect.dispatch(href.createRelativeHref(Href.EXERCISE, event.hrefFilename));
		}
		
		public function stopAllAudio():void {
			AudioPlayer.stopAllAudio();
		}
		
		protected override function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);
			stopAllAudio();
		}
		
	}
}
