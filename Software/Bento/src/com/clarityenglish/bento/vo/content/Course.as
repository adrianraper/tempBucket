package com.clarityenglish.bento.vo.content {
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.model.Model;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.UIDUtil;
	
	import org.davekeen.util.ClassUtil;
	
	/**
	 * gh#1294 Mirror the exercise vo for hidden content compatability
	 */
	public class Course extends XHTML {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		// The values of enabledFlag come from Orchid
        // gh#1294 These are duplicates of Exercise - not sure if better to just reference Exercise from here...
		public static const EF_MENU_ON:Number = 1;
		public static const EF_NAVIGATE_ON:Number = 2;
		public static const EF_DISABLED:Number = 8;
		public static const EF_DISPLAY_OFF:Number = 128; // This means it is a branding exercise in an adaptive test
		public static const EF_EXIT_AFTER:Number = 256;
		
		public function Course(value:XML = null, href:Href = null) {
			super(value, href);
		}
		
		/**
		 * This is a static function that determines whether a course should be navigable to or not.
         * It runs off the course xml node in the menu.xml
		 *  
		 * @param courseNode
		 * @return 
		 * 
		 */
		public static function linkCourseInMenu(courseNode:XML):Boolean {
			if (!courseNode)
				return false;
			
			// enabledFlag is binary based for backwards compatability
			// You can link to a course if - it is not disabled and it has navigate on.
			return (!courseNode.hasOwnProperty("@enabledFlag") || ((courseNode.@enabledFlag & Course.EF_NAVIGATE_ON) == Course.EF_NAVIGATE_ON &&
																	!((courseNode.@enabledFlag & Course.EF_DISABLED) == Course.EF_DISABLED)));
		}
		
		/**
		 * This is a static function that determines whether a course should be displayed in the menu or not.
         * It runs off the course xml node in the menu.xml
		 *  
		 * @param courseNode
		 * @return 
		 * 
		 */
		public static function showCourseInMenu(courseNode:XML):Boolean {
			if (!courseNode)
				return false;
			
			// enabledFlag is binary based for backwards compatability
			// You can see a course on the menu - if it is menuOn and not displayOff.
			// If it is disabled, you will see it differently and not be able to click it.
			return (!courseNode.hasOwnProperty("@enabledFlag") || ((courseNode.@enabledFlag & Course.EF_MENU_ON) == Course.EF_MENU_ON &&
																	!((courseNode.@enabledFlag & Course.EF_DISPLAY_OFF) == Course.EF_DISPLAY_OFF)));
		}
		
		/**
		 * This is a static function that determines whether a course is enabled on the menu or not.
		 *  
		 * @param exerciseNode
		 * @return 
		 * 
		 */
		public static function courseEnabledInMenu(courseNode:XML):Boolean {
			if (!courseNode)
				return false;
			
			// enabledFlag is binary based for backwards compatability
			return (!courseNode.hasOwnProperty("@enabledFlag") || !((courseNode.@enabledFlag & Course.EF_DISABLED) == Course.EF_DISABLED));

		}
		
	}
}