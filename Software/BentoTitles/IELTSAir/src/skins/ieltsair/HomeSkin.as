package skins.ieltsair {
	import com.clarityenglish.ielts.view.home.ui.CourseBarRenderer;
	
	import skins.ielts.home.CourseButtonSkin;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.skins.mobile.supportClasses.MobileSkin;
	
	public class HomeSkin extends MobileSkin {
		
		public var readingCourseButton:Button;
		
		public var writingCourseButton:Button;
		
		public var speakingCourseButton:Button;
		
		public var listeningCourseButton:Button;
		
		public var readingCoverageBar:CourseBarRenderer;
		
		public var listeningCoverageBar:CourseBarRenderer;
		
		public var speakingCoverageBar:CourseBarRenderer;
		
		public var writingCoverageBar:CourseBarRenderer;
		
		public var welcomeLabel:Label;
		
		public var noticeLabel:Label;
		
		public function HomeSkin() {
			super();
		}
		
		protected override function createChildren():void {
			super.createChildren();
			
			if (!readingCourseButton) {
				readingCourseButton = new Button();
				readingCourseButton.width = 488;
				readingCourseButton.height = 92;
				readingCourseButton.setStyle("title", "Reading");
				addChild(readingCourseButton);
			}
			
			if (!writingCourseButton) {
				writingCourseButton = new Button();
				writingCourseButton.width = 488;
				writingCourseButton.height = 92;
				writingCourseButton.setStyle("title", "Writing");
				addChild(writingCourseButton);
			}
			
			if (!speakingCourseButton) {
				speakingCourseButton = new Button();
				speakingCourseButton.width = 488;
				speakingCourseButton.height = 92;
				speakingCourseButton.setStyle("title", "Speaking");
				addChild(speakingCourseButton);
			}
			
			if (!listeningCourseButton) {
				listeningCourseButton = new Button();
				listeningCourseButton.width = 488;
				listeningCourseButton.height = 92;
				listeningCourseButton.setStyle("title", "Listening");
				addChild(listeningCourseButton);
			}
		}
		
		protected override function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void {
			super.layoutContents(unscaledWidth,unscaledHeight);
			
			if (readingCourseButton) {
				readingCourseButton.x = 488;
				readingCourseButton.y = 172;
			}
			
			if (writingCourseButton) {
				writingCourseButton.x = 488;
				writingCourseButton.y = 277;
			}
			
			if (speakingCourseButton) {
				speakingCourseButton.x = 488;
				speakingCourseButton.y = 386;
			}
			
			if (listeningCourseButton) {
				listeningCourseButton.x = 488;
				listeningCourseButton.y = 492;
			}
		}
		
	}
}
