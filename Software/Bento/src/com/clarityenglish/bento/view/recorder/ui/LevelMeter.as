package com.clarityenglish.bento.view.recorder.ui {
	import caurina.transitions.Tweener;
	
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	
	import mx.core.IDataRenderer;
	import mx.core.UIComponent;
	
	public class LevelMeter extends UIComponent implements IDataRenderer {
		
		private var amplitude:Number;
		
		protected var track:Sprite;
		protected var clipIndicator:Sprite;
		protected var levelGradient:Sprite;
		
		private var gradientMask:Sprite;
		
		public function LevelMeter() {
			super();
		}
		
		public function set data(value:Object):void {
			amplitude = value as Number;
			
			invalidateProperties();
		}
		
		public function get data():Object {
			return amplitude;
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			track = new Sprite();
			addChild(track);
			
			clipIndicator = new Sprite();
			clipIndicator.alpha = 0;
			addChild(clipIndicator);
			
			levelGradient = new Sprite();
			levelGradient.y = 10;
			addChild(levelGradient);
			
			gradientMask = new Sprite();
			levelGradient.mask = gradientMask;
			addChild(gradientMask);
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if (amplitude) {
				gradientMask.graphics.clear();
				gradientMask.graphics.beginFill(0, 0);
				gradientMask.graphics.drawRect(0, levelGradient.y + levelGradient.height - levelGradient.height * amplitude, levelGradient.width, levelGradient.height * amplitude);
				gradientMask.graphics.endFill();
				
				if (amplitude > 1) {
					Tweener.removeTweens(clipIndicator);
					clipIndicator.alpha = 1;
					Tweener.addTween(clipIndicator, { alpha: 0, time: 0.6, delay: 1 } );
				}
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			track.graphics.clear();
			track.graphics.beginFill(0xFF000000, 1);
			track.graphics.drawRect(0, 0, unscaledWidth, 9);
			track.graphics.endFill();
			
			track.graphics.beginFill(0xFF000000, 1);
			track.graphics.drawRect(0, 10, unscaledWidth, unscaledHeight - 10);
			track.graphics.endFill();
			
			clipIndicator.graphics.clear();
			clipIndicator.graphics.beginFill(0xFFFF0000, 1);
			clipIndicator.graphics.drawRect(0, 0, unscaledWidth, 9);
			clipIndicator.graphics.endFill();
			
			levelGradient.graphics.clear();
			levelGradient.graphics.beginGradientFill(GradientType.LINEAR, [ 0xFFFFFF00, 0xFF39B54A ], [ 1.0, 1.0 ], [ 0, 220 ], verticalGradientMatrix(0, - unscaledHeight / 4, unscaledWidth, unscaledHeight - 10), SpreadMethod.PAD, InterpolationMethod.LINEAR_RGB);
			levelGradient.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight - 10);
			levelGradient.graphics.endFill();
		}
		
	}

}