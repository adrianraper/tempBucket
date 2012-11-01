package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.events.ExerciseEvent;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.textLayout.components.AudioPlayer;
	
	import flash.events.Event;
	
	import mx.collections.XMLListCollection;
	import mx.controls.SWFLoader;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Label;
	import spark.components.List;
	
	public class ExamPracticeZoneSectionView extends AbstractZoneSectionView {
		
		[SkinPart(required="true")]
		public var list:List;
		
		[SkinPart]
		public var leftArrow:SWFLoader;
		
		[SkinPart]
		public var rightArrow:SWFLoader;
		
		[SkinPart(required="true")]
		public var practiceZoneLabel:Label;
		
		[SkinPart(required="true")]
		public var practiceZoneInstructionLabel:Label;
		
		[SkinPart]
		public var practiceZoneNoTestLabel:Label;
		
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
				//issue:#11 Lanuage Code
				case practiceZoneLabel:
					instance.text = copyProvider.getCopyForId("practiceZoneCaption");
					break;
				case practiceZoneInstructionLabel:
					instance.text = copyProvider.getCopyForId("practiceZoneInstruction");
					break;
				case practiceZoneNoTestLabel:
					var replaceObj:Object = new Object();
					replaceObj.courseClass = this.courseClass;
					instance.text = copyProvider.getCopyForId("practiceZoneNoTest", replaceObj);
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
