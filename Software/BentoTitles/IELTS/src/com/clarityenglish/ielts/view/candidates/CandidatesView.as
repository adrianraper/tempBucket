package com.clarityenglish.ielts.view.candidates {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.controls.video.VideoSelector;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.events.IndexChangeEvent;
	
	public class CandidatesView extends BentoView {
		
		[SkinPart]
		public var candidatesIntroductionLabel:Label;
		
		[SkinPart]
		public var candidatesCaptionLabel:Label;
		
		[SkinPart]
		public var videoSelector:VideoSelector;

		[SkinPart]
		public var candidatesVideoTitleHGroup:HGroup;
		
		[SkinPart]
		public var candidatesVideoTitleFixedLabel:Label;
		
		[SkinPart]
		public var candidatesVideoTitleLabel:Label;
		
		[SkinPart]
		public var candidatesVideoDescriptionHGroup:HGroup;
		
		[SkinPart]
		public var candidatesVideoFixedLabel:Label;
		
		[SkinPart]
		public var candidatesVideoDescriptionLabel:Label;
		
		public var channelCollection:ArrayCollection;
		
		public var hrefToUidFunction:Function;
		
		override protected function onViewCreationComplete():void {
			super.onViewCreationComplete();
			
			this.stage.addEventListener(Event.RESIZE, onScreenResize);
		}
		
		override protected function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			videoSelector.videoCollection = new XMLListCollection(xhtml.xml.link);
			videoSelector.href = this.href;
			videoSelector.channelCollection = channelCollection;
			videoSelector.hrefToUidFunction = hrefToUidFunction;
		}
		
		override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case candidatesIntroductionLabel:
					candidatesIntroductionLabel.text = copyProvider.getCopyForId("candidatesIntroductionLabel");
					break;
				case candidatesCaptionLabel:
					candidatesCaptionLabel.text = copyProvider.getCopyForId("candidatesCaptionLabel");
					break;
				case videoSelector:
					videoSelector.width = stage.stageWidth;
					videoSelector.videoList.addEventListener(IndexChangeEvent.CHANGE, onIndexChange);
					break;
				case candidatesVideoTitleLabel:
					candidatesVideoTitleLabel.text = copyProvider.getCopyForId("candidatesVideoTitle0");
					break;
				case candidatesVideoTitleHGroup:
					candidatesVideoTitleHGroup.left = stage.stageWidth/2 - 290;
					break;
				case candidatesVideoTitleFixedLabel:
					candidatesVideoTitleFixedLabel.text = copyProvider.getCopyForId("candidatesVideoTitleFixedLabel");
					break;
				case candidatesVideoDescriptionHGroup:
					candidatesVideoDescriptionHGroup.left = stage.stageWidth/2 - 320;
					break;
				case candidatesVideoFixedLabel:
					candidatesVideoFixedLabel.text = copyProvider.getCopyForId("candidatesVideoFixedLabel");
					break;
				case candidatesVideoDescriptionLabel:
					candidatesVideoDescriptionLabel.text = copyProvider.getCopyForId("candidatesVideoDescription0");
					break;
			}
		}
		
		protected function onScreenResize(event:Event):void {
			videoSelector.width = stage.stageWidth;
			candidatesVideoTitleHGroup.left = stage.stageWidth/2 - 290;
			candidatesVideoDescriptionHGroup.left = stage.stageWidth/2 - 320;
		}
		
		protected function onIndexChange(event:Event):void {			
			candidatesVideoTitleLabel.text = copyProvider.getCopyForId("candidatesVideoTitle" + event.target.selectedIndex);
			candidatesVideoDescriptionLabel.text = copyProvider.getCopyForId("candidatesVideoDescription" + event.target.selectedIndex);
		}
	}
}