package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.controls.video.VideoSelector;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	
	import org.davekeen.util.StringUtils;
	
	public class QuestionZoneVideoSectionView extends AbstractZoneSectionView {
		
		private static var dummy:StringUtils; // For some reason Flash Builder gets confused about importing StringUtils, so just have this here to fix it
		
		[SkinPart(required="true")]
		public var videoSelector:VideoSelector;
		
		public var channelCollection:ArrayCollection;
		
		public function QuestionZoneVideoSectionView() {
			super();
			actionBarVisible = false;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			// Only provide rss files to the video selector
			videoSelector.href = href;
			videoSelector.channelCollection = channelCollection;
			videoSelector.videoCollection = new XMLListCollection(_course.unit.(@["class"] == "question-zone").exercise.(StringUtils.endsWith(@href, ".rss")));
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				
			}
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
