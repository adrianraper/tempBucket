package com.clarityenglish.ieltsair.zone {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.controls.BentoVideoSelector;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	
	public class ExamPracticeZoneSectionView extends AbstractZoneSectionView {
		
		public function ExamPracticeZoneSectionView() {
			super();
			actionBarVisible = false;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				
			}
		}
		
	}
}
