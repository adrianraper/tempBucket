package com.clarityenglish.ieltsair.zone {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.controls.BentoVideoSelector;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	
	public class AdviceZoneVideoSectionView extends AbstractZoneSectionView {
		
		[SkinPart(required="true")]
		public var videoSelector:BentoVideoSelector;
		
		public var channelCollection:ArrayCollection;
		
		public function AdviceZoneVideoSectionView() {
			super();
			actionBarVisible = false;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			videoSelector.viewHref = href;
			videoSelector.channelCollection = channelCollection;
			videoSelector.videoList.dataProvider = new XMLListCollection(_course.unit.(@["class"] == "advice-zone").exercise);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				
			}
		}
		
	}
}
