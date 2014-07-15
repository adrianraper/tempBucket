package com.clarityenglish.ielts.view.candidates {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
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
		public var candidatesCaptionLabel:Label;
		
		[SkinPart]
		public var videoSelector:VideoSelector;
		
		public var channelCollection:ArrayCollection;
		
		public var hrefToUidFunction:Function;
		
		public function getCopyProvider():CopyProvider {
			return copyProvider;
		}
		
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
				case candidatesCaptionLabel:
					candidatesCaptionLabel.text = copyProvider.getCopyForId("candidatesCaptionLabel");
					break;
				case videoSelector:
					videoSelector.width = stage.stageWidth;
					break;
			}
		}
		
		protected function onScreenResize(event:Event):void {
			videoSelector.width = stage.stageWidth;
		}
	}
}