package com.clarityenglish.ieltsair.zone {
	import com.clarityenglish.bento.view.base.BentoView;
	
	/**
	 * All classes that live within the zone TabbedViewNavigator should extend this class. 
	 */
	public class AbstractZoneSectionView extends BentoView {
		
		public function AbstractZoneSectionView() {
			super();
		}
		
		protected function get _course():XML {
			return data as XML;
		}
		
		public override function set data(value:Object):void {
			super.data = value;
			invalidateSkinState();
		}
		
		[Bindable(event="dataChange")]
		public function get courseClass():String {
			return (_course) ? _course.@["class"].toString() : null;
		}
		
		protected override function getCurrentSkinState():String {
			return (courseClass) ? courseClass : super.getCurrentSkinState();
		}
		
	}
}
