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
		public var exerciseList:List;
		
		private var _unit:XML;
		private var _unitChanged:Boolean;
		
		private var uidString:String;
		
		public var exerciseShow:Signal = new Signal(Href);
		public var exerciseSelect:Signal = new Signal(XML);
		
		[Bindable(event="unitChanged")]
		public function get unit():XML {
			return _unit;
		}
		
		public function set unit(value:XML):void {
			_unit= value;
			_unitChanged = true;
			
			invalidateProperties();
			invalidateSkinState();
			
			dispatchEvent(new Event("unitChanged", true));
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_unitChanged) {
				exerciseList.dataProvider = new XMLListCollection(_unit.exercise);
				_unitChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case exerciseList:
					exerciseList.addEventListener(MouseEvent.CLICK, onExerciseClick);
					break;
			}
		}
		
		protected function onExerciseClick(event:MouseEvent):void {
			var exercise:XML = event.currentTarget.selectedItem as XML;
			if (exercise) exerciseSelect.dispatch(exercise);
		}
		
	}
}