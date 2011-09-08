package com.clarityenglish.textLayout.conversion {
	import com.clarityenglish.bento.css.ExerciseCSS;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.elements.FloatableTextFlow;
	import com.clarityenglish.textLayout.rendering.RenderFlow;
	import com.clarityenglish.textLayout.stylesheets.CssLibFormatResolver;
	import com.clarityenglish.textLayout.vo.XHTML;
	import com.newgonzo.web.css.CSS;
	import com.newgonzo.web.css.CSSSelector;
	import com.newgonzo.web.css.views.StyledCSSView;
	import com.newgonzo.web.css.views.XMLCSSView;
	
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	
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
		[Embed(source="/com/clarityenglish/bento/view/exercise/ui/defaults.css", mimeType="application/octet-stream")]
		private var defaultCss:Class;

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
		
		/**
		 * Parse XHTML into a RenderBlocks object, which contains everything the component needs in order to render
		 * 
		 * @param exercise
		 * @param section
		 * @return 
		 */
		/*public function importToRenderBlocks(exercise:Exercise, section:String):RenderBlocks {
			var textFlows:Vector.<TextFlow> = new Vector.<TextFlow>();
			var renderBlocks:RenderBlocks = new RenderBlocks();
			var html:XML = (section == "header") ? exercise.getHeader() : exercise.getSection(section);
			
			flowElementXmlBiMap = new FlowElementXmlBiMap();
			css = parseCss(exercise);
			
			// Get the left floaters
			// TODO: This needs to select everything apart from <img>, which floats differently
			// TODO: This needs to deal with float right too
			var leftFloatSelector:CSSSelector = new CSSSelector("[float=left]", new StyledCSSView(new XMLCSSView(), css));
			
			// Add the top level html node
			renderBlocks.addBlock(html);
			
			// Add the left floating html nodes
			for each (var node:XML in leftFloatSelector.query(html))
				renderBlocks.addBlock(node);
			
			var exerciseBlockImporter:ExerciseBlockImporter;
			var importedFlow:TextFlow;
			
			for each (var renderBlock:RenderBlock in renderBlocks) {
				// Create a block importer for each floating node.  Provide the floating nodes to 'ignoreNodes' so they don't get parsed.
				exerciseBlockImporter = TextConverter.getImporter(EXERCISE_BOX_FORMAT) as ExerciseBlockImporter;
				exerciseBlockImporter.flowElementXmlBiMap = flowElementXmlBiMap;
				exerciseBlockImporter.exercise = exercise;
				exerciseBlockImporter.css = css;
				exerciseBlockImporter.ignoreNodes = renderBlocks.getIgnoreNodes();
				
				renderBlock.textFlow = exerciseBlockImporter.importToFlow(renderBlock.html) as FloatableTextFlow;
				if (renderBlock.textFlow) {
					// Create the format resolver
					var formatResolver:CssLibFormatResolver = new CssLibFormatResolver(css, flowElementXmlBiMap);
					renderBlock.textFlow.formatResolver = formatResolver;
				}
			}
			
			return renderBlocks;
		}*/
		
		public function importToRenderFlow(xhtml:XHTML, node:XML):RenderFlow {
			flowElementXmlBiMap = new FlowElementXmlBiMap();
			css = parseCss(xhtml);
			
			// I need to work out what not to parse, which is fine (search for floating divs), but I have absolutely no idea
			// how to build up my render tree.  Maybe this needs to be in the importer??  Surely not...
			var blockImporter:XHTMLBlockImporter = TextConverter.getImporter(XHTML_BLOCK_FORMAT) as XHTMLBlockImporter;;
			var formatResolver:CssLibFormatResolver = new CssLibFormatResolver(css, flowElementXmlBiMap);
			
			blockImporter.formatResolver = formatResolver;
			blockImporter.flowElementXmlBiMap = flowElementXmlBiMap;
			blockImporter.css = css;
			 
			//blockImporter.exercise = exercise;
			//blockImporter.ignoreNodes = renderBlocks.getIgnoreNodes();
			
			var textFlow:FloatableTextFlow = blockImporter.importToFlow(node) as FloatableTextFlow;
			
			var renderFlow:RenderFlow = new RenderFlow(textFlow);
			
			return renderFlow;
		}
			
		/*
			var textFlows:Vector.<TextFlow> = new Vector.<TextFlow>();
			var renderBlocks:RenderBlocks = new RenderBlocks();
			var html:XML = (section == "header") ? exercise.getHeader() : exercise.getSection(section);
			
			flowElementXmlBiMap = new FlowElementXmlBiMap();
			css = parseCss(exercise);
			
			// Get the left floaters
			// TODO: This needs to select everything apart from <img>, which floats differently
			// TODO: This needs to deal with float right too
			var leftFloatSelector:CSSSelector = new CSSSelector("[float=left]", new StyledCSSView(new XMLCSSView(), css));
			
			// Add the top level html node
			renderBlocks.addBlock(html);
			
			// Add the left floating html nodes
			for each (var node:XML in leftFloatSelector.query(html))
			renderBlocks.addBlock(node);
			
			var exerciseBlockImporter:ExerciseBlockImporter;
			var importedFlow:TextFlow;
			
			for each (var renderBlock:RenderBlock in renderBlocks) {
				// Create a block importer for each floating node.  Provide the floating nodes to 'ignoreNodes' so they don't get parsed.
				exerciseBlockImporter = TextConverter.getImporter(EXERCISE_BOX_FORMAT) as ExerciseBlockImporter;
				exerciseBlockImporter.flowElementXmlBiMap = flowElementXmlBiMap;
				exerciseBlockImporter.exercise = exercise;
				exerciseBlockImporter.css = css;
				exerciseBlockImporter.ignoreNodes = renderBlocks.getIgnoreNodes();
				
				renderBlock.textFlow = exerciseBlockImporter.importToFlow(renderBlock.html) as FloatableTextFlow;
				if (renderBlock.textFlow) {
					// Create the format resolver
					var formatResolver:CssLibFormatResolver = new CssLibFormatResolver(css, flowElementXmlBiMap);
					renderBlock.textFlow.formatResolver = formatResolver;
				}
			}
			
			return renderBlocks;
		}
		
		*/
		
		/**
		 * Parse all the CSS into an as3csslib object
		 * 
		 * @param exercise
		 * @return 
		 */
		private function parseCss(xhtml:XHTML):CSS {
			var css:CSS = new ExerciseCSS();
			
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