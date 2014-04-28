package com.clarityenglish.bento.vo.content {
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	/**
	 * @author
	 */
	public class ExerciseGenerator extends XHTML {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public function ExerciseGenerator(value:XML = null, href:Href = null) {
			super(value, href);
		}
		
		public function get authoring():XML {
			return selectOne("script#authoring[type='application/xml']");
		}
		
		public function get settings():XML {
			return authoring.hasOwnProperty("settings") ? authoring.settings[0] : null;
		}
		
		public function get questions():XML {
			return authoring.hasOwnProperty("questions") ? authoring.questions[0] : null;
		}
		
		public function hasSettingParam(paramName:String):Boolean {
			return (settings && settings.param.(@name == paramName).length() > 0);
		}
		
		public function getSettingParam(paramName:String):* {
			var value:* = (settings && settings.param.(@name == paramName).length() > 0) ? settings.param.(@name == paramName).@value : null;
			
			if (value == "true") return true;
			if (value == "false") return false;
			
			return value;
		}
		
	}
}