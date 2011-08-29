package com.clarityenglish.textLayout.conversion {
	import com.clarityenglish.bento.css.ExerciseCSS;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.conversion.rendering.RenderBlock;
	import com.clarityenglish.textLayout.conversion.rendering.RenderBlocks;
	import com.clarityenglish.textLayout.stylesheets.CssLibFormatResolver;
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
	
	public class ExerciseImporter {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		/**
		 * This identifier for the custom exercise XML importer
		 */
		private static const EXERCISE_BOX_FORMAT:String = "exercise_box_format";
		
		private var flowElementXmlBiMap:FlowElementXmlBiMap;
		
		/**
		 * There is a default stylesheet that all ExerciseRichText components use (I envision this mainly being used to implement convenience tags that don't exist in
		 * TextFormatLayout format such as b, i, u, etc)
		 */ 
		[Embed(source="/com/clarityenglish/bento/view/exercise/ui/defaults.css", mimeType="application/octet-stream")]
		private var defaultCss:Class;

		private var css:CSS;
		
		public function ExerciseImporter() {
			// Add the custom importer to the TextConverter format list
			if (!TextConverter.getImporter(EXERCISE_BOX_FORMAT))
				TextConverter.addFormat(EXERCISE_BOX_FORMAT, ExerciseBlockImporter, null, null);
		}
		
		public function getFlowElementXmlBiMap():FlowElementXmlBiMap {
			return flowElementXmlBiMap;
		}
		
		// TODO: This will probably return a Vector of RenderBoxes instead of TextFlow
		public function importToRenderBlocks(exercise:Exercise, section:String):RenderBlocks {
			var textFlows:Vector.<TextFlow> = new Vector.<TextFlow>();
			var renderBlocks:RenderBlocks = new RenderBlocks();
			var html:XML = (section == "header") ? exercise.getHeader() : exercise.getSection(section);
			
			flowElementXmlBiMap = new FlowElementXmlBiMap();
			css = parseCss(exercise);
			
			// Get the left floaters
			// TODO: This needs to select everything apart from <img>, which floats differently
			var leftFloatSelector:CSSSelector = new CSSSelector("[float=left]", new StyledCSSView(new XMLCSSView(), css));
			
			// Add the top level html node
			renderBlocks.addBlock(html);
			
			// Add the left floating html nodes
			for each (var node:XML in leftFloatSelector.query(html))
				renderBlocks.addBlock(node, RenderBlock.FLOAT_LEFT);
			
			var exerciseBlockImporter:ExerciseBlockImporter;
			var importedFlow:TextFlow;
			
			for each (var renderBlock:RenderBlock in renderBlocks) {
				// Create a block importer for each floating node.  Provide the floating nodes to 'ignoreNodes' so they don't get parsed.
				exerciseBlockImporter = TextConverter.getImporter(EXERCISE_BOX_FORMAT) as ExerciseBlockImporter;
				exerciseBlockImporter.flowElementXmlBiMap = flowElementXmlBiMap;
				exerciseBlockImporter.exercise = exercise;
				exerciseBlockImporter.css = css;
				exerciseBlockImporter.ignoreNodes = renderBlocks.getIgnoreNodes();
				
				renderBlock.textFlow = exerciseBlockImporter.importToFlow(renderBlock.html);
				if (renderBlock.textFlow) {
					// Create the format resolver
					var formatResolver:CssLibFormatResolver = new CssLibFormatResolver(css, flowElementXmlBiMap);
					renderBlock.textFlow.formatResolver = formatResolver;
				}
			}
			
			return renderBlocks;
		}
		
		private function parseCss(exercise:Exercise):CSS {
			// Parse the CSS
			var css:CSS = new ExerciseCSS();
			
			// Get the stylesheet - this is default.css stylesheet (embedded) plus any stylesheets specified in the exercise
			var styleStrings:Array = exercise.styleStrings; // Get the stylesheets in the exercise
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