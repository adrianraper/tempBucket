package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.vo.Href;
	
	import flash.events.MouseEvent;
	
	import org.davekeen.transitions.PatchedSlideViewTransition;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Label;
	
	public class QuestionZoneSectionView extends AbstractZoneSectionView {
		
		[SkinPart]
		public var readButton:Button;
		
		[SkinPart]
		public var downloadButton:Button;
		
		[SkinPart(required="true")]
		public var videoButton:Button;
		
		[SkinPart(required="true")]
		public var questionVideoLabel:Label;
		
		[SkinPart(required="true")]
		public var questionVideoInstructionLabel:Label;
		
		public var exerciseSelect:Signal = new Signal(XML);
		
		public function QuestionZoneSectionView() {
			super();
			actionBarVisible = false;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case readButton:
					readButton.addEventListener(MouseEvent.CLICK, onReadButtonClick);
					instance.label = copyProvider.getCopyForId("downloadButton");
					break;
				case downloadButton:
					downloadButton.addEventListener(MouseEvent.CLICK, onDownloadButtonClick);
					instance.label = copyProvider.getCopyForId("pdfButton");
					break;
				case videoButton:
					videoButton.addEventListener(MouseEvent.CLICK, onVideoButtonClick);
					instance.label = copyProvider.getCopyForId("videoButton");
					break;
				case questionVideoLabel:
					instance.text = copyProvider.getCopyForId("questionVideoLabel");
					break;
				case questionVideoInstructionLabel:
					instance.text = copyProvider.getCopyForId("questionVideoInstructionLabel");
					break;
			}
		}
		
		// gh#135 hidden content for Starting Out
		// TODO needs disabledpopupwatcher added
		protected override function commitProperties():void {
			super.commitProperties();
			
			for each (var questionZoneNode:XML in _course.unit.(@["class"] == "question-zone").exercise) {
				if (questionZoneNode.@href.indexOf(".xml") > 0) {
					readButton.enabled = !(questionZoneNode.hasOwnProperty("@enabledFlag") && (Number(questionZoneNode.@enabledFlag.toString()) & 8));
				}
				if (questionZoneNode.@href.indexOf(".pdf") > 0) { 
					downloadButton.enabled = !(questionZoneNode.hasOwnProperty("@enabledFlag") && (Number(questionZoneNode.@enabledFlag.toString()) & 8));
				}
				if (questionZoneNode.@href.indexOf(".rss") > 0) { 
					videoButton.enabled = !(questionZoneNode.hasOwnProperty("@enabledFlag") && (Number(questionZoneNode.@enabledFlag.toString()) & 8));
				}
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
			exerciseSelect.dispatch(questionZoneEBookNode);
		}
		
		protected function onDownloadButtonClick(event:MouseEvent):void {
			// as above for file type
			for each (var questionZonePDFNode:XML in _course.unit.(@["class"] == "question-zone").exercise) {
				if (questionZonePDFNode.@href.indexOf(".pdf") > 0)
					break;
			}
			exerciseSelect.dispatch(questionZonePDFNode);
		}
		
		/**
		 * When the 'Watch video' button is clicked push AdviceZoneVideoSectionView onto the navigator
		 */
		protected function onVideoButtonClick(event:MouseEvent):void {
			navigator.pushView(QuestionZoneVideoSectionView, _course, null, new PatchedSlideViewTransition());
		}
		
	}
}
