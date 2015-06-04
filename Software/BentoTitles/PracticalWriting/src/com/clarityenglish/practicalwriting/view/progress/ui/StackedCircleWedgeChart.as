package com.clarityenglish.practicalwriting.view.progress.ui {
	import com.clarityenglish.bento.view.progress.ui.IStackedChart;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.practicalwriting.view.progress.event.StackedBarMouseOutEvent;
	import com.clarityenglish.practicalwriting.view.progress.event.StackedBarMouseOverEvent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	
	import spark.components.Label;
	
	public class StackedCircleWedgeChart extends UIComponent implements IStackedChart {
		
		private var _colours:Array = [];
		private var _field:String;
		private var _dataProvider:Object;
		private var length:Number = 0;
		private var arcArray:Array = new Array();
		
		private var semiCircleLabel:Label = new Label();
		
		public function StackedCircleWedgeChart()
		{
			super();
		}
		
		public function set field(value:String):void {
			_field = value;
			invalidateDisplayList();
		}
		
		public function set dataProvider(value:Object):void {
			_dataProvider = value;
			invalidateDisplayList();
		}
		
		public function set colours(value:Array):void {
			_colours = value;
			invalidateDisplayList();
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (!_field || !_dataProvider) return;			
			
			// Determine the total of all the values and store it
			var item:Object;
			var totalValues:Number = 0;
			for each (item in _dataProvider) {
				var itemDuration:Number = new Number(item.attribute(_field));
				totalValues +=  Math.floor(itemDuration / 60);
			}
				
			// clear the screen
			for each (item in arcArray) {
				this.removeChild(item as Sprite);
			}
			
			if (totalValues > 0) {
				var currentAngle:Number = 0, idx:int = 0;
				arcArray = [];
				for each (item in _dataProvider) {
					// Determine colour and width
					var myArc:Sprite = new Sprite();
					var barColour:Number = _colours[idx];
					var duration:Number = new Number(item.attribute(_field));
					var barValue:Number = Math.floor(duration / 60);
					if (totalValues != 0) {
						var barAngle:Number = Math.round((barValue * 180)/totalValues);
					} else {
						barAngle = 0;
					}
					
					if (barAngle + currentAngle > 180) {
						barAngle = 180 - currentAngle; 
					}
					// draw and add the arc to stage
					myArc.graphics.beginFill(barColour, 1);
					drawArc(myArc, -250, 0, 240, barAngle,currentAngle); //spriteName, startX, startY, radius, arcAngle, startAngle
					drawArc(myArc, -250, 0, 190, barAngle, currentAngle);
					myArc.graphics.endFill();
					this.addChild(myArc);
					
					arcArray.push(myArc);
					currentAngle = currentAngle + barAngle;
					idx++;
					
					// add event listener for each bar
					myArc.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
					myArc.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
					// as a parameter pass to event handler
					myArc.name = item.@caption;					
				} 
			} else {
				arcArray = [];
				
				var emptyArc:Sprite = new Sprite();
				emptyArc.graphics.beginFill(0xB3B3B3, 1);
				drawArc(emptyArc, -250, 0, 240, 180, 0); //spriteName, startX, startY, radius, arcAngle, startAngle
				drawArc(emptyArc, -250, 0, 190, 180, 0);
				emptyArc.graphics.endFill();
				arcArray.push(emptyArc);
				this.addChild(emptyArc);
			}
			
		}
		
		// draw the arc
		public function drawArc(arcRef:Sprite, sx:int, sy:int, radius:int, arc:int, startAngle:int=0):void{
			var segAngle:Number;
			var angle:Number;
			var angleMid:Number;
			var numOfSegs:Number;
			var ax:Number;
			var ay:Number;
			var bx:Number;
			var by:Number;
			var cx:Number;
			var cy:Number;
			
			// Move the pen
			arcRef.graphics.moveTo(sx, sy);
			
			// No need to draw more than 360
			if (Math.abs(arc) > 360) 
			{
				arc = 360;
			}
			
			numOfSegs = Math.ceil(Math.abs(arc) / 45);
			segAngle = arc / numOfSegs;
			segAngle = (segAngle / 180) * Math.PI;
			angle = (startAngle / 180) * Math.PI;
			
			// Calculate the start point
			ax = sx + Math.cos(angle) * radius;
			ay = sy + Math.sin(angle) * radius;
			
			// Draw the first line
			arcRef.graphics.lineTo(ax, ay);
			
			// Draw the arc
			for (var i:int=0; i<numOfSegs; i++) 
			{
				angle += segAngle;
				angleMid = angle - (segAngle / 2);
				bx = sx + Math.cos(angle) * radius;
				by = sy + Math.sin(angle) * radius;
				cx = sx + Math.cos(angleMid) * (radius / Math.cos(segAngle / 2));
				cy = sy + Math.sin(angleMid) * (radius / Math.cos(segAngle / 2));
				arcRef.graphics.curveTo(cx, cy, bx, by);
			}
			
			// Close the wedge
			arcRef.graphics.lineTo(sx, sy);
		}
		
		protected function onMouseOver(event:MouseEvent):void {
			dispatchEvent(new StackedBarMouseOverEvent(StackedBarMouseOverEvent.WEDGE_OVER, true,  event.target.name));
		}
		
		protected function onMouseOut(event:MouseEvent):void {
			dispatchEvent(new StackedBarMouseOutEvent(StackedBarMouseOutEvent.WEDGE_OUT, true));
		}

	}
}