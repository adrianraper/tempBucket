package com.clarityenglish.textLayout.stylesheets {
	import com.clarityenglish.textLayout.stylesheets.applicators.CSSApplicator;
	import com.flashartofwar.fcss.styles.IStyle;
	import com.flashartofwar.fcss.stylesheets.FStyleSheet;
	import com.flashartofwar.fcss.stylesheets.IStyleSheet;
	
	import flash.utils.Dictionary;
	
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.IFormatResolver;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	
	public class FCSSFormatResolver implements IFormatResolver {
		
		private var styleSheet:IStyleSheet;
		
		private var textLayoutFormatCache:Dictionary;
		
		public function FCSSFormatResolver(... cssStrings) {
			textLayoutFormatCache = new Dictionary(true);
			styleSheet = new FStyleSheet()
			
			for each (var cssString:String in cssStrings)
				styleSheet.parseCSS(cssString);
		}
		
		/** 
		 * Invalidates any cached formatting information for a TextFlow so that formatting must be recomputed.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function invalidateAll(textFlow:TextFlow):void {
			textLayoutFormatCache = new Dictionary(true);
		}
		
		/** 
		 * Invalidates cached formatting information on this element because, for example, the <code>parent</code> changed, 
		 * or the <code>id</code> or the <code>styleName</code> changed or the <code>typeName</code> changed. 
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function invalidate(target:Object):void {
			delete textLayoutFormatCache[target];
			
			// recursively descend if this element is a FlowGroupElement.  Is this needed?
			var blockElem:FlowGroupElement = target as FlowGroupElement;
			if (blockElem)
				for (var idx:int = 0; idx < blockElem.numChildren; idx++)
					invalidate(blockElem.getChildAt(idx));
		}
		
		private function addStyleAttributes(textLayoutFormat:TextLayoutFormat, styleSelector:String, targetElement:Object):TextLayoutFormat {
			// Merge all styles with * first (if it doesn't exist this has no effect)
			var style:IStyle = styleSheet.getStyle("*", styleSelector);
			
			if (style) {
				// Apply the style using CSSApplicator which handles both TextLayoutFormat and also intrinsic class properties (e.g. float, width, height on <img>)
				if (!textLayoutFormat) textLayoutFormat = new TextLayoutFormat();
				new CSSApplicator(targetElement).applyStyle(textLayoutFormat, style);
			}
			
			return textLayoutFormat;
		}
		
		/** 
		 * Given a FlowElement or ContainerController object, return any format settings for it.
		 *
		 * @return format settings for the specified object.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function resolveFormat(element:Object):ITextLayoutFormat {
			// If the TextLayoutFormat for this element has already been cached then just return that.
			var textLayoutFormat:TextLayoutFormat = textLayoutFormatCache[element];
			if (textLayoutFormat)
				return textLayoutFormat;
			
			if (element is FlowElement) {
				textLayoutFormat = addStyleAttributes(textLayoutFormat, element.typeName, element);
				
				if (element.styleName != null)
					textLayoutFormat = addStyleAttributes(textLayoutFormat, "." + element.styleName, element);
				
				if (element.id != null)
					textLayoutFormat = addStyleAttributes(textLayoutFormat, "#" + element.id, element);
				
				textLayoutFormatCache[element] = textLayoutFormat;
			}
			
			return textLayoutFormat;
		}
		
		/** 
		 * Given a FlowElement or ContainerController object and the name of a format property, return the format value
		 * or <code>undefined</code> if the value is not found.
		 *
		 * @return the value of the specified format for the specified object.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function resolveUserFormat(element:Object, userFormat:String):* {
			// This is for the special formatting types such as linkNormalFormat, etc and listMarkerFormat, etc. I probably want to translate these into a:hover and stuff
			if (element is FlowElement) { 
				switch (userFormat) {
					// This isn't quite right - we still need to cache and we should be able to edit this with pseudo-selectors like a:hover, etc, but it kind of works
					// for the moment
					case "linkNormalFormat":
					case "linkHoverFormat":
					case "linkActiveFormat":
						return addStyleAttributes(element.format, "a", element);
					case "listMarkerFormat":
						trace(element);
						break;
				}
			}
			
			return null;
		}
		
		/** 
		 * Returns the format resolver when a TextFlow is copied.
		 *
		 * @return the format resolver for the copy of the TextFlow.
		 *
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function getResolverForNewFlow(oldFlow:TextFlow, newFlow:TextFlow):IFormatResolver {
			// Stylesheets are shared over all text flows so return this instance
			return this;
		}
		
	}
}
