////////////////////////////////////////////////////////////////////////////////
//
// ADOBE SYSTEMS INCORPORATED
// Copyright 2007-2010 Adobe Systems Incorporated
// All Rights Reserved.
//
// NOTICE:  Adobe permits you to use, modify, and distribute this file 
// in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package flashx.textLayout.formats
{
	/**
     *  Defines values for the <code>float</code> property
	 *  of the InlineGraphicElement class. 
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0 
	 * @see flashx.textLayout.elements.InlineGrapicElement
	 */
	public final class Float
	{
        /** Graphic appears inline in the text (doesn't float). */
		public static const NONE:String = "none";		
        /** Graphic floats on the left side of the text. */
		public static const LEFT:String = "left";
        /** Graphic floats on the right side of the text. */
		public static const RIGHT:String = "right";
        /** Graphic floats on the leading side of the text 
         * (left if paragraph direction is "ltr", right if paragraph direction is "rtl"). 
		 */
		public static const START:String = "start";
        /** Graphic floats on the trailing side of the text 
        * (right if paragraph direction is "ltr", left if paragraph direction is "rtl"). 
		*/
		public static const END:String = "end";
	}
}
