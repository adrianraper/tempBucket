package com.clarityenglish.ielts.view.zone {
        import com.clarityenglish.bento.events.ExerciseEvent;
        import com.clarityenglish.bento.vo.Href;
        import com.clarityenglish.common.model.interfaces.CopyProvider;
        import com.clarityenglish.controls.video.VideoSelector;
        
        import mx.collections.ArrayCollection;
        import mx.collections.XMLListCollection;
        
        import org.osflash.signals.Signal;
        
        import spark.components.Label;
	
	public class AdviceZoneSectionView extends AbstractZoneSectionView {
		
		[SkinPart(required="true")]
		public var videoSelector:VideoSelector;
		
		[SkinPart(required="true")]
		public var adviceVideoLabel:Label;
		
		[SkinPart(required="true")]
		public var adviceVideoInstructionLabel:Label;
		
		public var channelCollection:ArrayCollection;
		
		public var exerciseSelect:Signal = new Signal(Href);
		
		public function AdviceZoneSectionView() {
			super();
			actionBarVisible = false;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			videoSelector.href = href;
			videoSelector.channelCollection = channelCollection;
			videoSelector.videoCollection = new XMLListCollection(_course.unit.(@["class"] == "advice-zone").exercise);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case videoSelector:
					videoSelector.addEventListener(ExerciseEvent.EXERCISE_SELECTED, onExerciseSelected);
					break;
				case adviceVideoLabel:
					instance.text = copyProvider.getCopyForId("adviceVideoLabel");
					break;
				case adviceVideoInstructionLabel:
					instance.text = copyProvider.getCopyForId("adviceVideoInstructionLabel");
					break;	
			}
		}

		/**
		 * In the context of this view, "exercise selected" actually means clicking on the script button for videos that have an associated script.
		 * This will end up launching a PDF.
		 * 
		 * @param event
		 */
		protected function onExerciseSelected(event:ExerciseEvent):void {
			exerciseSelect.dispatch(href.createRelativeHref(Href.EXERCISE, event.hrefFilename));
		}
		
	}
}
