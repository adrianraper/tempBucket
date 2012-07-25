package com.clarityenglish.ieltsair.zone {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.controls.BentoVideoSelector;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	
	public class AdviceZoneSectionView extends BentoView {
		
		[SkinPart(required="true")]
		public var videoSelector:BentoVideoSelector;
		
		public var channelCollection:ArrayCollection;
		
		public function AdviceZoneSectionView() {
			super();
			actionBarVisible = false;
		}
		
		private function get _course():XML {
			return data as XML;
		}
		
		[Bindable(event="dataChange")]
		public function get courseClass():String {
			return (_course) ? _course.@["class"].toString() : null;
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
