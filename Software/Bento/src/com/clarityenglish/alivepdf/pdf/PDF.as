package com.clarityenglish.alivepdf.pdf {
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	
	import org.alivepdf.encoding.PNGEncoder;
	import org.alivepdf.images.DoPNGImage;
	import org.alivepdf.layout.Size;
	import org.alivepdf.pdf.PDF;
	
	public class PDF extends org.alivepdf.pdf.PDF {
		
		private static const PAGE_HEIGHT:int = 2000;
		
		public function PDF(orientation:String = 'Portrait', unit:String = 'Mm', pageSize:Size = null, rotation:int = 0) {
			super(orientation, unit, pageSize, rotation);
		}
		
		public function addMultiPageImage(displayObject:DisplayObject):void {
			displayObjectbounds = displayObject.getBounds(displayObject);
			
			for (var y:int = 0; y < displayObjectbounds.height; y += PAGE_HEIGHT) {
				// Create a new page
				addPage();
				
				// Make a bitmap image of this page
				var bitmapData:BitmapData = new BitmapData(displayObjectbounds.width, PAGE_HEIGHT);
				
				var matrix:Matrix = new Matrix();
				matrix.translate(0, y);
				
				bitmapData.draw(displayObject, matrix);
				
				var byteArray:ByteArray = PNGEncoder.encode(bitmapData);
				image = new DoPNGImage(bitmapData, byteArray, y);
				
				placeImage(0, 0, displayObjectbounds.width, PAGE_HEIGHT, 0, null, null);
			}
		}
		
	}
}