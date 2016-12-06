package com.clarityenglish.testadmin.view.login.components {

	import flash.display.*;
	import flash.geom.*;
	
	import mx.skins.ProgrammaticSkin;
	import mx.utils.ColorUtil;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;

	public class FlatButtonSkin extends ProgrammaticSkin  {

		public function FlatButtonSkin() {
			super();
		}

		override protected function updateDisplayList(w:Number, h:Number): void {

			var topCornerRadius:Number = 0;
			var bottomCornerRadius:Number = 0;
			
			// Depending on the skin's current name, set values for this skin.
			switch (name) {
				case "upSkin":
					var outlineColors:Array = [0x00A79D, 0x2BB673];
					break;
				case "disabledSkin":
					outlineColors = [0x696969, 0xCACACA];
					break;
				case "overSkin":
					var fillColors:Array = [0x00A79D, 0x2BB673];
					outlineColors = null;
					break;
				case "downSkin":	
					fillColors = [0x2BB673, 0x00A79D];
					outlineColors = null;
					break;
			}

			var _fillType:String = GradientType.LINEAR;
			var _alphas:Array = [1, 1];
			var _ratios:Array = [0, 255];
			var m:Matrix = new Matrix();
			m.createGradientBox(w, h, 0);
			var spreadMethod:String = SpreadMethod.PAD;
			
			this.graphics.clear();
			if (outlineColors) {
				// need a background to trigger mouseover
				this.graphics.beginFill(0xffffff);
				this.graphics.lineStyle(1, 0);
				this.graphics.lineGradientStyle(_fillType, outlineColors, _alphas, _ratios, m, spreadMethod);				
				this.graphics.drawRoundRectComplex(0, 0, w, h, topCornerRadius, topCornerRadius, bottomCornerRadius, bottomCornerRadius);
			} else {
				this.graphics.beginGradientFill(_fillType, fillColors, _alphas, _ratios, m, spreadMethod);
				this.graphics.drawRoundRectComplex(0, 0, w, h, topCornerRadius, topCornerRadius, bottomCornerRadius, bottomCornerRadius);
				this.graphics.endFill();
			}
			
			/*
			// the shadow
			var filter:BitmapFilter = getBitmapFilter();
			var myFilters:Array = new Array();
			myFilters.push(filter);
			filters = myFilters;
			*/
			
		}
		private function getBitmapFilter():BitmapFilter {
			var color:Number = 0x000000;
			var angle:Number = 45;
			var alpha:Number = 0.8;
			var blurX:Number = 4;
			var blurY:Number = 4;
			var distance:Number = 1;
			var strength:Number = 0.45;
			var inner:Boolean = false;
			var knockout:Boolean = false;
			var quality:Number = BitmapFilterQuality.HIGH;
			return new DropShadowFilter(distance,
				angle,
				color,
				alpha,
				blurX,
				blurY,
				strength,
				quality,
				inner,
				knockout);
		}

	}
} 