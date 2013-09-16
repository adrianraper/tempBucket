package com.clarityenglish.textLayout.stylesheets.applicators {
	import com.newgonzo.web.css.CSSComputedStyle;
	import com.newgonzo.web.css.values.HSLColorValue;
	import com.newgonzo.web.css.values.RGBColorValue;
	
	import flashx.textLayout.formats.TextLayoutFormat;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.w3c.dom.css.ICSSValue;
	
	public class CSSApplicator {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var element:Object;
		
		// #366
		public static var fontSizeOffset:int = 0;
		
		public function CSSApplicator(element:Object) {
			this.element = element;
		}
		
		/**
		 * Apply the given style.  First this will attempt to apply it to the textLayoutFormat (this will usually be correct).  In the event that the properties
		 * don't exist in TextLayoutFormat we check if they are on the element itself (for things like float, width, height, etc).  If they are we do nothing
		 * as they will already have been applied during the import phase.  If the style doesn't exist on TextLayout format or the element we throw an exception.
		 * 
		 * @param target
		 * @param style
		 * @return 
		 */
		public function applyStyle(textLayoutFormat:TextLayoutFormat, style:CSSComputedStyle):void {
			for (var prop:String in style) {
				if (textLayoutFormat.hasOwnProperty(prop)) {
					textLayoutFormat[prop] = filterStyleValue(style, prop);
				}
			}
		}
		
		/**
		 * We may need to filter the values of various CSS properties before injecting them into TLF; this method filters the value before using it.
		 * This can probably be done much neater using custom PropertyManagers, but for the moment we'll do it here.
		 * 
		 * @param style
		 * @param property
		 * @return 
		 */
		private function filterStyleValue(style:CSSComputedStyle, property:String):* {
			// A special case - if the property is 'tabStops' we need to remove the commas.  Again, ideally a custom PropertyManager would be used
			// and would hopefully allow spaces as a seperator in the initial CSS.
			if (property == "tabStops")
				return style[property].toString().replace(/,/g, " ");
			
			var propertyCSSValue:ICSSValue = style.getPropertyCSSValue(property);
			
			// #366
			if (property == "fontSize") {
				return style[property] + fontSizeOffset;
			}
			
			switch (ClassUtil.getClass(propertyCSSValue)) {
				case RGBColorValue:
				case HSLColorValue:
					// Convert colour values back into #RRGGBB format
					return intToHex(style[property]);
				default:
					// Otherwise 
					return style[property];
			}
			
			return null;
		}
		
		/**
		 * as3csslib turns colours into integers, but TLF expects them in hexidecimal, so this is a method to convert an integer back into
		 * an HTML friendly colour string.
		 * 
		 * @param hexAsInt
		 * @return 
		 */
		private static function intToHex(hexAsInt:int):String {
			var hexAsString:String = hexAsInt.toString(16);
			
			while(hexAsString.length < 6)
				hexAsString = "0" + hexAsString;
			
			return "#" + hexAsString;
		}
	
	}
}
