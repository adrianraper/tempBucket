package com.clarityenglish.alivepdf.pdf {
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	
	import org.alivepdf.encoding.PNGEncoder;
	import org.alivepdf.images.DoPNGImage;
	import org.alivepdf.layout.Resize;
	import org.alivepdf.layout.Size;
	import org.alivepdf.links.ILink;
	import org.alivepdf.pdf.PDF;
	
	public class PDF extends org.alivepdf.pdf.PDF {
		
		private static const PAGE_HEIGHT:int = Size.A4.dimensions[1];
		
		public function PDF(orientation:String = 'Portrait', unit:String = 'Mm', pageSize:Size = null, rotation:int = 0) {
			super(orientation, unit, pageSize, rotation);
		}
		
		public function addMultiPageImage(displayObject:DisplayObject, resizeMode:Resize = null, x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0, rotation:Number = 0, alpha:Number = 1, keepTransformation:Boolean = true, imageFormat:String = "PNG", quality:Number = 100, blendMode:String = "Normal", link:ILink = null):void {
			var bytes:ByteArray;
			var bitmapDataBuffer:BitmapData;
			var transformMatrix:Matrix;
			
			displayObjectbounds = displayObject.getBounds(displayObject);
			
			for (var pageY:int = 0; pageY < displayObjectbounds.height; pageY += PAGE_HEIGHT) {
				addPage();
				
				bitmapDataBuffer = new BitmapData(displayObject.width, displayObject.height, false);
				transformMatrix = new Matrix();
				transformMatrix.translate(0, -pageY);
				
				bitmapDataBuffer.draw(displayObject, transformMatrix);
				
				var id:int = getTotalProperties(streamDictionary) + 1;
				
				bytes = PNGEncoder.encode(bitmapDataBuffer);
				image = new DoPNGImage(bitmapDataBuffer, bytes, id);
				
				streamDictionary[id] = image;
				
				setAlpha(alpha, blendMode);
				placeImage(x, y, width, height, rotation, resizeMode, link);
			}
			
		}
		
	}
}
