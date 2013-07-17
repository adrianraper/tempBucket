package com.clarityenglish.tensebuster.view.zone {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.XMLListCollection;
	import mx.controls.SWFLoader;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	import spark.primitives.Path;
	
	public class ZoneView extends BentoView {
		
		[SkinPart(required="true")]
		public var exerciseList:List;
		
		[SkinPart]
		public var numberIcon:SWFLoader;
		
		[SkinPart]
		public var exInstructionLabel:Label;
		
		[SkinPart]
		public var backToUnitButton:Button;
		
		private var _unit:XML;
		private var _unitChanged:Boolean;
		// gh#398
		private var _courseIndex:Number;
		private var _courseCaption:String;
		private var _courseClass:String;
		private var _unitCaption:String;
		private var caption:String;
		private var numberIconSource:String;
		private var courseArray:Array = ["Elementary", "Lower Intermediate", "Intermediate", "Upper Intermediate", "Advanced"];
		
		private var uidString:String;
		
		public var exerciseShow:Signal = new Signal(Href);
		public var exerciseSelect:Signal = new Signal(XML);
		public var backToUnit:Signal = new Signal();
	
		[Embed(source="skins/tensebuster/assets/zone/A10.png")]
		private var A13:Class;
		
		[Embed(source='skins/tensebuster/assets/zone/E10.png')]
		private var E13:Class;
		
		[Embed(source="skins/tensebuster/assets/zone/I10.png")]
		private var I13:Class;
		
		[Embed(source="skins/tensebuster/assets/zone/U10.png")]
		private var U13:Class;
		
		[Embed(source="skins/tensebuster/assets/zone/L10.png")]
		private var L13:Class;
		
		[Bindable(event="unitChanged")]
		public function get unit():XML {
			return _unit;
		}
		
		public function set unit(value:XML):void {
			if (value) {
				_unit= value;
				_unitChanged = true;
				
				invalidateProperties();
				invalidateSkinState();
				
				dispatchEvent(new Event("unitChanged", true));
			}		
		}
		
		[Bindable]
		public function get courseIndex():Number {
			return _courseIndex;
		}
		
		public function set courseIndex(value:Number):void {
			_courseIndex = value;
		}
		
		[Bindable]
		public function get courseClass():String {
			return _courseClass;
		}
		
		public function set courseClass(value:String):void {
			_courseClass = value;
			if (value)
				dispatchEvent(new Event("courseChange"));
		}
		
		[Bindable]
		public function get courseCaption():String {
			return _courseCaption;
		}
		
		
		public function set courseCaption(value:String):void {
			_courseCaption = value;
		}
		
		[Bindable("courseChange")]
		public function get courseIcon():Class {
			return getStyle(courseClass + "IconSmall");
		}
		
		[Bindable]
		public function get unitCaption():String {
			return _unitCaption;
		}
		
		
		public function set unitCaption(value:String):void {
			_unitCaption = value;
		}
		
		[Bindable("courseChange")]
		public function get unitIcon():Class {
			return getStyle(courseClass + "UnitIconSmall");
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_unitChanged) {
				exerciseList.dataProvider = new XMLListCollection(_unit.exercise);
				courseCaption = _unit.parent().@caption;
				unitCaption = _unit.@caption;
				courseClass = _unit.parent().@["class"];
				courseIndex = courseArray.indexOf(courseCaption);
				numberIconSource = courseCaption.charAt(0) + exerciseList.dataProvider.length;
				numberIcon.source = getSource(numberIconSource);
				_unitChanged = false;
			}
		}
		
		public function getSource(value:String):Class {
			switch (value) {
				case "A13":
					return A13;
					break;
				case "E13":
					return E13;
					break;
				case "I13":
					return I13;
					break;
				case "U13":
					return U13;
					break;
				case "L13":
					return L13;
					break;
				default:
					return null;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case exerciseList:
					exerciseList.addEventListener(MouseEvent.CLICK, onExerciseClick);
					break;
				case exInstructionLabel:
					exInstructionLabel.text = copyProvider.getCopyForId("exInstructionLabel");
					break;
				case backToUnitButton:
					backToUnitButton.addEventListener(MouseEvent.CLICK, onBackToUnitClick);
					break;
			}
		}
		
		protected function onExerciseClick(event:MouseEvent):void {
			var exercise:XML = event.currentTarget.selectedItem as XML;
			if (exercise) exerciseSelect.dispatch(exercise);
		}
		
		protected function onBackToUnitClick(event:MouseEvent):void {
			backToUnit.dispatch();
		}
		
	}
}