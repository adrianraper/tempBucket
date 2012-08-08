package com.clarityenglish.ieltsair.zone {
	import com.clarityenglish.bento.view.base.BentoView;
	
	import flash.events.Event;
	
	/**
	 * The parent of all view for sections in the zone navigator.  It provides a courseClass, maps data to course and keeps the skin
	 * in sync with the selected course.
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
			
			dispatchEvent(new Event("dataChange"));
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
