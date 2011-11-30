package com.clarityenglish.textLayout.conversion {
	import com.clarityenglish.textLayout.css.XHTMLCSS;
	import com.clarityenglish.textLayout.rendering.RenderFlow;
	import com.clarityenglish.textLayout.stylesheets.CssLibFormatResolver;
	import com.clarityenglish.textLayout.vo.XHTML;
	import com.newgonzo.web.css.CSS;
	
	import flashx.textLayout.conversion.TextConverter;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.w3c.css.sac.CSSParseError;

	public class XHTMLImporter {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		/**
		 * This identifier for the custom xhtml block importer
		 */
		private static const XHTML_BLOCK_FORMAT:String = "xhtml_block_format";
		
		/**
		 * This maintains a bidirectional map between parsed FlowElements and their original XHTML source nodes. 
		 */
		private var flowElementXmlBiMap:FlowElementXmlBiMap;
		
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
		
		/**
		 * Get the bidirectional map between FlowElements and their original XHTML source nodes
		 * 
		 * @return 
		 */
		public function getFlowElementXmlBiMap():FlowElementXmlBiMap {
			return flowElementXmlBiMap;
		}
		
		public function getCSS():CSS {
			return css;
		}
		
		public function importToRenderFlow(xhtml:XHTML, node:XML):RenderFlow {
			if (css) css.clear();
			
			flowElementXmlBiMap = new FlowElementXmlBiMap();
			css = parseCss(xhtml);
			
			var blockImporter:XHTMLBlockImporter = TextConverter.getImporter(XHTML_BLOCK_FORMAT) as XHTMLBlockImporter;
			var formatResolver:CssLibFormatResolver = new CssLibFormatResolver(css, flowElementXmlBiMap);
			
			blockImporter.formatResolver = formatResolver;
			blockImporter.flowElementXmlBiMap = flowElementXmlBiMap;
			blockImporter.css = css;
			blockImporter.rootPath = xhtml.rootPath;
			
			return blockImporter.importToRenderFlow(node);
		}
		
		/**
		 * Aid garbage collection by nullifying attributes 
		 * 
		 */
		public function clear():void {
			flowElementXmlBiMap = null;
			css = null;
		}
		
		/**
		 * Parse all the CSS into an as3csslib object
		 * 
		 * @param exercise
		 * @return 
		 */
		private function parseCss(xhtml:XHTML):CSS {
			var css:CSS = new XHTMLCSS();
			
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