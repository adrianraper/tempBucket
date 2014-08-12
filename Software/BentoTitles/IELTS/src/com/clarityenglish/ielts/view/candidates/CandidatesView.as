package com.clarityenglish.ielts.view.candidates {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.controls.video.VideoSelector;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	import mx.core.FlexGlobals;
	
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.events.IndexChangeEvent;
	
	public class CandidatesView extends BentoView {
		
		[SkinPart]
		public var candidatesCaptionLabel:Label;
		
		[SkinPart]
		public var videoSelector:VideoSelector;
		
		[SkinPart]
		public var tabletVideoSelector:VideoSelector;
		
		[Bindable]
		public var isPlatformTablet:Boolean;
		
		public var channelCollection:ArrayCollection;
		
		public var hrefToUidFunction:Function;
		
		public function getCopyProvider():CopyProvider {
			return copyProvider;
		}
		
		public function setPlatformTablet(value:Boolean):void {
			isPlatformTablet = value;
		}
		
		override protected function onViewCreationComplete():void {
			super.onViewCreationComplete();
			
			this.stage.addEventListener(Event.RESIZE, onScreenResize);
		}
		
		override protected function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			if (videoSelector) {
				videoSelector.videoCollection = new XMLListCollection(xhtml.xml.link);
				videoSelector.href = this.href;
				videoSelector.channelCollection = channelCollection;
				videoSelector.hrefToUidFunction = hrefToUidFunction;
			}
			
			if (tabletVideoSelector) {
				tabletVideoSelector.videoCollection = new XMLListCollection(xhtml.xml.link);
				tabletVideoSelector.href = this.href;
				tabletVideoSelector.channelCollection = channelCollection;
				tabletVideoSelector.hrefToUidFunction = hrefToUidFunction;
			}
		}
		
		override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case candidatesCaptionLabel:
					candidatesCaptionLabel.text = copyProvider.getCopyForId("candidatesCaptionLabel");
					break;
				case videoSelector:
				case tabletVideoSelector:
					instance.width = FlexGlobals.topLevelApplication.width;
					instance.height = FlexGlobals.topLevelApplication.height;
					break;
			}
		}
		
		override protected function getCurrentSkinState():String {
			if (isPlatformTablet) {
				return super.getCurrentSkinState() + "Tablet";
			}
			
			return super.getCurrentSkinState();
		}
		
		protected function onScreenResize(event:Event):void {
			videoSelector.width = stage.stageWidth;
		}
	}
}