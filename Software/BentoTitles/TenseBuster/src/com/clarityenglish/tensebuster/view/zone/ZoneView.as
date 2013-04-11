package com.clarityenglish.tensebuster.view.zone {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.XMLListCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	public class ZoneView extends BentoView {
		
		[SkinPart(required="true")]
		public var unitList:List;
		
		[SkinPart(required="true")]
		public var exerciseList:List;
		
		private var _course:XML;
		private var _courseChanged:Boolean;
		
		public var exerciseShow:Signal = new Signal(Href);
		public var exerciseSelect:Signal = new Signal(XML);
		
		[Bindable(event="courseChanged")]
		public function get course():XML {
			return _course;
		}
		
		public function set course(value:XML):void {
			_course = value;
			_courseChanged = true;
			
			invalidateProperties();
			invalidateSkinState();
			
			dispatchEvent(new Event("courseChanged", true));
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_courseChanged) {
				
				unitList.dataProvider = new XMLListCollection(_course.unit);
				
				_courseChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case unitList:
					unitList.addEventListener(IndexChangeEvent.CHANGE, onUnitChange);
					break;
				case exerciseList:
					exerciseList.addEventListener(MouseEvent.CLICK, onExerciseClick);
					break;
			}
		}
		
		protected function onUnitChange(event:IndexChangeEvent):void {
			exerciseList.dataProvider = new XMLListCollection(unitList.selectedItem.exercise);
		}
		
		protected function onExerciseClick(event:MouseEvent):void {
			var exercise:XML = event.currentTarget.selectedItem as XML;
			if (exercise) exerciseSelect.dispatch(exercise);
		}
		
	}
}