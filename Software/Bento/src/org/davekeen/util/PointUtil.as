package org.davekeen.util {
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class PointUtil {
		
		/**
		 * Convert the given point from oldSpace's coordinate system to newSpace's coordinate system.
		 * 
		 * @param point		The point to convert
		 * @param oldSpace	The old coordinate space; this will generally be the space currently containing the point
		 * @param newSpace	The new coordinate space
		 * @return 
		 */
		public static function convertPointCoordinateSpace(point:Point, oldSpace:DisplayObject, newSpace:DisplayObject):Point {
			return newSpace.globalToLocal(oldSpace.localToGlobal(point));
		}
		
		/**
		 * Convert the given rectangle from oldSpace's coordinate system to newSpace's coordinate system.  This will only affect the x and y coordinates
		 * of the Rectangle, never the width or height.
		 * 
		 * @param rectangle	The rectangle to convert
		 * @param oldSpace	The old coordinate space; this will generally be the space currently containing the rectangle
		 * @param newSpace	The new coordinate space
		 * @return 
		 */
		public static function convertRectangleCoordinateSpace(rectangle:Rectangle, oldSpace:DisplayObject, newSpace:DisplayObject):Rectangle {
			var newOrigin:Point = convertPointCoordinateSpace(new Point(rectangle.x, rectangle.y), oldSpace, newSpace);
			return new Rectangle(newOrigin.x, newOrigin.y, rectangle.width, rectangle.height);
		}
		
		public static function highlight(graphics:Graphics, rectangle:Rectangle):void {
			graphics.lineStyle(1, 0xFF0000, 1);
			graphics.drawRect(rectangle.x, rectangle.y, rectangle.width, rectangle.height);
		}
		
	}
	
}