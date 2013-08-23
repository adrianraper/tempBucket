package com.clarityenglish.tensebusterair.unit.ui
{
	import caurina.transitions.Tweener;
	
	import spark.components.supportClasses.ButtonBase;
	import spark.primitives.Path;
	import spark.primitives.Rect;
	
	public class ProgressUnitButton extends ButtonBase
	{
		private var _coverage:Number;
		private var _courseIndex:Number = 0;
		private var _caption:String;
		private var isCoverageChange:Boolean;
		
		[SkinPart(required="true")]
		public var overallProgressPath:Rect;
		
		[SkinPart]
		public var leftSide:Path;
		
		[SkinPart]
		public var rightSide:Path;
		
		public function set coverage(value:Number):void {
			_coverage = value;
			isCoverageChange = true;
			invalidateProperties();	
		}
		
		[Bindable]
		public function get coverage():Number {
			//trace("coverage: "+_coverage);
			return _coverage;
		}
		
		public function set courseIndex(value:Number):void {
			_courseIndex = value;
		}
		
		[Bindable]
		public function get courseIndex():Number {
			return _courseIndex;
		}
		
		public function set caption(value:String):void {
			_caption = value;			
		}
		
		[Bindable]
		public function get caption():String {
			return _caption;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();		
			
			if (isCoverageChange) {
				if (coverage == 100) {
					rightSide.visible = true;
				}else {
					rightSide.visible = false;
				}
				
				if (coverage == 0) {
					leftSide.visible = false;
				} else {
					leftSide.visible = true;
				}
				
				overallProgressPath.width = coverage * overallProgressPath.width / 100;	
				
				isCoverageChange = false;
			}
		}
		
	}
}