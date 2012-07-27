package com.clarityenglish.ieltsair.zone {
	import com.clarityenglish.bento.vo.Href;
	
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	
	public class QuestionZoneSectionView extends AbstractZoneSectionView {
		
		[SkinPart(required="true")]
		public var readButton:Button;
		
		[SkinPart(required="true")]
		public var videoButton:Button;
		
		public var exerciseSelect:Signal = new Signal(Href);
		
		public function QuestionZoneSectionView() {
			super();
			actionBarVisible = false;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case readButton:
					readButton.addEventListener(MouseEvent.CLICK, onReadButtonClick);
					break;
				case videoButton:
					videoButton.addEventListener(MouseEvent.CLICK, onVideoButtonClick);
					break;
			}
		}
		
		protected function onReadButtonClick(event:MouseEvent):void {
			// Question Zone can have more than one exercise (eBook and pdf), so dangerous to assume order
			// Also a bit dubious, but can we base it on the file type?
			//var questionZoneExerciseNode:XML =  _course.unit.(@["class"] == "question-zone").exercise[0];
			for each (var questionZoneEBookNode:XML in _course.unit.(@["class"] == "question-zone").exercise) {
				if (questionZoneEBookNode.@href.indexOf(".xml") > 0) 
					break;
			}
			exerciseSelect.dispatch(href.createRelativeHref(Href.EXERCISE, questionZoneEBookNode.@href));
		}
		
		protected function onVideoButtonClick(event:MouseEvent):void {
			
		}
		
	}
}
