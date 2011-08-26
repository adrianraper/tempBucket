/**
* Pimp your Flex app using WSBackgroundPixelSkin [without images - pure CSS and AS]
* 
* @author    Jens Krause [www.websector.de]
* @update    07/10/07
* @see        http://www.websector.de/blog/2007/07/06/pimp-your-flex-app-using-wsbackgroundpixelskin/
* 
* Feel free to use the source - its licensed under the Mozilla Public License 1.1. (http://www.mozilla.org/MPL/MPL-1.1.html)
* 
*/

package de.websector.skins
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	
	//import org.osflash.thunderbolt.Logger;
	
	[Style(name="bgPattern", type="Array", format="Array", inherit="no")]
	[Style(name="bgColors", type="Array", format="Number", inherit="no")]
	[Style(name="bgPixelMeasure", type="uint", format="Number", inherit="no")]
			
				
	public class WSBackgroundPixelSkin extends UIComponent
	{
		private var _bgPattern: Array = [0, 1];
		private var _bgColors: Array = [0];
		private var _bgPixelMeasure: uint = 10;
		
		private var _bgBitmapData: BitmapData;
		private var _bgBitmap: Bitmap;
		private var _patternBitmapData: BitmapData;

		private var _patternWidth: uint;
		private var _patternHeight: uint;
		
		private var _styleNameChanged: Boolean = true;
		private var _bgPatternChanged: Boolean = true;
		private var _bgColorsChanged: Boolean = true;
		private var _bgPixelMeasureChanged: Boolean = true;		
		private var _patternChanged: Boolean = true;
		
				    		
		public function WSBackgroundPixelSkin()
		{
			super();
		}

	    /**
	     * Overrides styleChanged() to detect changes style definitions 
	     * @param styleProp		The name of the style property
	     * 
	     */		
	    override public function styleChanged(styleProp: String):void 
	    {
	    	super.styleChanged(styleProp); 		
	    	
	    	switch (styleProp)
	    	{
	    		case "bgPattern":
	    			_bgPatternChanged = true;
	    			invalidateDisplayList();
	    		case "bgColors":
	    			_bgColorsChanged = true;
	    			invalidateDisplayList();
	    		case "bgPixelMeasure":
	    			_bgPixelMeasureChanged = true;
	    			invalidateDisplayList();
	    		case "styleName":
					_styleNameChanged = true;
	    			invalidateDisplayList();
	    		break;
	    		default:	    	
	    	}	      	
	    } 
	    
		/**
		 * Overrides updateDisplayList() to update the component based on the style setting 
		 * @param unscaledWidth		height of the component
		 * @param unscaledHeight	width of the component
		 * 
		 */		    
		override protected function updateDisplayList(unscaledWidth: Number, unscaledHeight: Number):void
		{			
			super.updateDisplayList(unscaledWidth, unscaledHeight);	
	    				
			this.width = unscaledWidth;
			this.height = unscaledHeight;		
			//
			// check to see if style "bgPattern" changed
			if (_bgPatternChanged) 
			{
				_bgPattern = (getStyle("bgPattern") is Array) ? getStyle("bgPattern") : [getStyle("bgPattern")];
				_patternChanged = true;
				_bgPatternChanged = false;
			}
			//
			// check to see if style "bgColors" changed
			if (_bgColorsChanged)  
			{
				_bgColors = getStyle("bgColors");
				_patternChanged = true;
				_bgColorsChanged = false;				
			}
			//
			// check to see if style "bgPixelMeasure" changed			
			if (_bgPixelMeasureChanged) 
			{
				_bgPixelMeasure = Number(getStyle("bgPixelMeasure"));
				_patternChanged = true;	
				_bgPixelMeasureChanged = false;			
			}													
			//
			// check to see if new "styleName" or styles above changed			
			if (_patternChanged || _styleNameChanged) 
			{
				createPattern();
				_patternChanged = false;
				_styleNameChanged = false;
			}
			//
			// draw wallpaper on valid height and width only		
			if (height > 0 && width > 0) drawWallpaper();
			
		}
		
		/**
		 * Creates a bitmap pattern based on style definition
		 * when styles changed only
		 * 
		 */		
		private function createPattern():void
		{
			_patternWidth = _bgPattern[0].length * _bgPixelMeasure;
			_patternHeight = _bgPattern.length * _bgPixelMeasure;
			
			if (_patternBitmapData) _patternBitmapData.dispose();
			
			_patternBitmapData = new BitmapData(_patternWidth, _patternHeight, false, 0);		
		
			for (var i: uint = 0; i < _bgPattern.length; i++)
			{
				for (var j: uint = 0; j < _bgPattern[i].length; j++)
				{
					var rect: Rectangle = new Rectangle(_bgPixelMeasure * j, 
														_bgPixelMeasure * i, 
														_bgPixelMeasure, 
														_bgPixelMeasure);
					
					var colorIndex: String = _bgPattern[i].charAt(j);
					// parse color based on hexadec. values (0-F)
					_patternBitmapData.fillRect(rect, _bgColors[parseInt("0x" + colorIndex)]);					
				}
			}
		}

		/**
		 * Draws a wallpaper based on its bitmap pattern 
		 *  
		 */			
		private function drawWallpaper():void
		{
			if (_bgBitmap) 
			{
				_bgBitmapData.dispose();
				removeChild(_bgBitmap);
			}
			
			_bgBitmapData = new BitmapData(width, height, false, 0);			

			var maxX: uint = Math.floor(width / _patternWidth);
			var maxY: uint = Math.floor(height / _patternHeight);
			var bgMatrix: Matrix = new Matrix();
			
			for (var i: uint = 0; i <= maxX; i++)
			{
				for (var j: uint = 0; j <= maxY; j++)
				{
					bgMatrix.tx = _patternWidth * i;
					bgMatrix.ty = _patternHeight * j;
					_bgBitmapData.draw(_patternBitmapData, bgMatrix);
				}			
			}	
						
			_bgBitmap = new Bitmap(_bgBitmapData);
			addChild(_bgBitmap);					
		}
	}	
}