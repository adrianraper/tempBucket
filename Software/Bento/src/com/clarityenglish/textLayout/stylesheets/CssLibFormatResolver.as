package com.clarityenglish.textLayout.stylesheets {
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	import com.clarityenglish.textLayout.stylesheets.applicators.CSSApplicator;
	import com.newgonzo.web.css.CSS;
	import com.newgonzo.web.css.CSSComputedStyle;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.IFormatResolver;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.w3c.css.sac.CSSParseError;
	
	public class CssLibFormatResolver extends EventDispatcher implements IFormatResolver {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		/**
		 * Main as3csslib class 
		 */
		private var css:CSS;
		
		/**
		 * This is a map of FlowElements to their original node in the XML document allowing us to run CSS selectors against them
		 */
		private var flowElementXmlBiMap:FlowElementXmlBiMap;
		
		/**
		 * Maintain a cache of already calculated textLayoutFormats 
		 */
		private var textLayoutFormatCache:Dictionary;
		
		public function CssLibFormatResolver(css:CSS, flowElementXmlBiMap:FlowElementXmlBiMap) {
			this.css = css;
			this.flowElementXmlBiMap = flowElementXmlBiMap;
			
			textLayoutFormatCache = new Dictionary(true);
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
		
		private function applyStyle(textLayoutFormat:TextLayoutFormat, targetElement:Object, userFormat:String = null):TextLayoutFormat {
			// Get the original node
			var node:XML = flowElementXmlBiMap.getXML(targetElement as FlowElement);
			if (node) {
				var style:CSSComputedStyle = css.style(node);
				if (style) {
					if (!textLayoutFormat) textLayoutFormat = new TextLayoutFormat();
					new CSSApplicator(targetElement).applyStyle(textLayoutFormat, style);
					
					return textLayoutFormat;
				}
			}
			
			return null;
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
			
			if (element is FlowElement)
				textLayoutFormat = applyStyle(textLayoutFormat, element);
			
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
					case "linkNormalFormat":
					case "linkHoverFormat":
					case "linkActiveFormat":
						// This isn't quite right - we still need to cache and we should be able to edit this with pseudo-selectors like a:hover, etc, but it kind of works
						// for the moment
						return applyStyle(element.format, element);
					case "listMarkerFormat":
						// It should also be possible to style this using CSS
						return element.listMarkerFormat;
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
			// At least for now stylesheets are shared over all text flows so return this instance
			return this;
		}
		
	}
}
