package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.ielts.IELTSApplication;
	import com.clarityenglish.ielts.view.zone.ZoneView;
	
	import flash.events.Event;
	
	import spark.components.supportClasses.Skin;
	
	/**
	 * The parent of all view for sections in the zone navigator.  It provides a courseClass, maps data to course and keeps the skin
	 * in sync with the selected course.
	 */
	public class AbstractZoneSectionView extends BentoView {
		
		private var _isPlatformiPad:Boolean;
		private var _isPlatformTablet:Boolean;
		
		[Bindable]
		public function get isPlatformiPad():Boolean {
			return _isPlatformiPad;
		}
		
		public function set isPlatformiPad(value:Boolean):void {
			_isPlatformiPad = value;
		}

		[Bindable]
		public function get isPlatformTablet():Boolean {
			return _isPlatformTablet;
		}

		public function set isPlatformTablet(value:Boolean):void {
            _isPlatformTablet = value;
		}
		
		public function AbstractZoneSectionView() {
			super();
		}
		
		public function get isTestDrive():Boolean {
			return (productVersion == IELTSApplication.TEST_DRIVE);
		}
		
		protected function get _course():XML {
			return data as XML;
		}
		
		public override function set data(value:Object):void {
			super.data = value;
			
			invalidateSkinState();
			
			dispatchEvent(new Event("dataChange"));
		}
		
		protected override function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			
			// The first time a ZoneSectionView is added to the stage we need to pick up its course from the parent ZoneView.  After that the course
			// is updated from the mediator and COURSE_SHOW notifications.
			var zoneView:ZoneView = navigator.parentDocument.parent as ZoneView;
			if (!zoneView) throw new Error("An AbstractZoneSectionView can only live in a ZoneView navigator");
			data = zoneView.course;
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
