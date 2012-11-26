package com.clarityenglish.textLayout.conversion {
	import com.clarityenglish.textLayout.css.XHTMLCSS;
	import com.clarityenglish.textLayout.css.XHTMLCSSContext;
	import com.clarityenglish.textLayout.rendering.RenderFlow;
	import com.clarityenglish.textLayout.stylesheets.CssLibFormatResolver;
	import com.clarityenglish.textLayout.vo.XHTML;
	import com.newgonzo.web.css.CSS;
	import com.newgonzo.web.css.ICSSContext;
	import com.newgonzo.web.css.views.ICSSView;
	import com.newgonzo.web.css.views.XMLCSSView;
	
	import flashx.textLayout.conversion.TextConverter;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.w3c.css.sac.CSSParseError;

	public class XHTMLImporter {
		
		// GH #45
		public static var media:String;
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		/**
		 * This identifier for the custom xhtml block importer
		 */
		private static const XHTML_BLOCK_FORMAT:String = "xhtml_block_format";
		
		/**
		 * The default stylesheet implemented by browsers
		 */ 
		[Embed(source="/com/clarityenglish/textLayout/conversion/xhtmldefaults.css", mimeType="application/octet-stream")]
		private static var defaultCss:Class;

		/**
		 * as3csslib 
		 */
		private var css:CSS;
		
		public function XHTMLImporter() {
			// Add the custom importer to the TextConverter format list
			if (!TextConverter.getImporter(XHTML_BLOCK_FORMAT))
				TextConverter.addFormat(XHTML_BLOCK_FORMAT, XHTMLBlockImporter, null, null);
		}
		
		public function getCSS():CSS {
			return css;
		}
		
		public function importToRenderFlow(xhtml:XHTML, node:XML):RenderFlow {
			if (css) css.clear();
			
			css = parseCss(xhtml);
			
			var blockImporter:XHTMLBlockImporter = TextConverter.getImporter(XHTML_BLOCK_FORMAT) as XHTMLBlockImporter;
			var formatResolver:CssLibFormatResolver = new CssLibFormatResolver(css, xhtml.flowElementXmlBiMap);
			
			blockImporter.formatResolver = formatResolver;
			blockImporter.flowElementXmlBiMap = xhtml.flowElementXmlBiMap;
			blockImporter.css = css;
			blockImporter.rootPath = xhtml.rootPath;
			
			return blockImporter.importToRenderFlow(node);
		}
		
		/**
		 * Aid garbage collection by nullifying attributes 
		 * 
		 */
		public function clear():void {
			css = null;
		}
		
		/**
		 * Parse all the CSS into an as3csslib object
		 * 
		 * @param exercise
		 * @return 
		 */
		private function parseCss(xhtml:XHTML):CSS {
			var view:ICSSView = new XMLCSSView(media);
			var context:ICSSContext = new XHTMLCSSContext(view);
			var css:CSS = new XHTMLCSS(null, context);
			
			// Get the stylesheet - this is default.css stylesheet (embedded) plus any stylesheets specified in the exercise
			var styleStrings:Array = xhtml.styleStrings; // Get the stylesheets in the exercise
			styleStrings.unshift(new defaultCss()); // Make sure default.css is always the first stylesheet
			
			for each (var cssString:String in styleStrings)
				css.parse(cssString);
			
			for each (var error:CSSParseError in css.errors)
				log.error("CSS parsing: {0} ({1})", error.message, (error.error) ? error.error.message : "");
			
			for each (var warning:CSSParseError in css.warnings)
				log.warn("CSS parsing: {0} ({1})", error.message, (error.error) ? error.error.message : "");
			
			return css;
		}
		
	}
	
}