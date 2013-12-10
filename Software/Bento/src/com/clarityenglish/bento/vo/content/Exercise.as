package com.clarityenglish.bento.vo.content {
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.model.Model;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.UIDUtil;
	
	import org.davekeen.util.ClassUtil;
	
	/**
	 * @author
	 */
	public class Exercise extends XHTML {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var _uid:String;
		
		private var _model:Model;
		
		// gh#740
		private var _isExerciseMarked:Boolean = false;
		
		// The values of enabledFlag come from Orchid
		public static const EF_MENU_ON:Number = 1;
		public static const EF_NAVIGATE_ON:Number = 2;
		public static const EF_RANDOM_ON:Number = 4;
		public static const EF_DISABLED:Number = 8;
		public static const EF_EDITED:Number = 16;
		public static const EF_NONEDITABLE:Number = 32;
		public static const EF_AUTOPLAY:Number = 64;
		public static const EF_DISPLAY_OFF:Number = 128; // This means it is a branding exercise in an adaptive test
		public static const EF_EXIT_AFTER:Number = 256;
		
		public function Exercise(value:XML = null, href:Href = null) {
			super(value, href);
			
			// Give every Exercise a unique UID so that we can identify them
			_uid = UIDUtil.createUID();
		}
		
		public function get uid():String {
			return _uid;
		}
		
		override public function set xml(value:XML):void {
			if (_xml !== value) {
				super.xml = value;
				
				// If there is a model in this xhtml then wrap it in the Model class and cache it
				var modelNode:XML = selectOne("script#model[type='application/xml']");
				if (modelNode)
					_model = new Model(this, modelNode);
				
			}
		}
		
		/**
		 * Determine if the model exists in this exercise
		 * 
		 * @return 
		 */
		[Bindable(event="xmlChange")]
		public function hasModel():Boolean {
			return _model !== null;
		}
		
		/**
		 * Return the model
		 */
		[Bindable(event="xmlChange")]
		public function get model():Model {
			return _model;
		}
		
		/**
		 * Determine if the given section exists in this exercise
		 * 
		 * @param section
		 * @return 
		 */
		[Bindable(event="xmlChange")]
		public function hasSection(section:String):Boolean {
			return _xml.body.section.(@id == section).length() > 0;
		}
		
		/**
		 * Return the section
		 * 
		 * @return 
		 */
		[Bindable(event="xmlChange")]
		public function getSection(sectionId:String):XML {
			return (hasSection(sectionId)) ? _xml.body.section.(@id == sectionId)[0] : null;
		}
		
		/**
		 * TODO: #20 - for the moment this is hardcoded to false, but it should come from the parameters
		 *  
		 * @return 
		 * 
		 */
		public function isCaseSensitive():Boolean {
			return false;
		}
		
		/**
		 * Does this exercise have any questions?  This is mostly used to figure out whether to display the marking button and when to write scores.
		 */
		public function hasQuestions():Boolean {
			// gh#347, 336
			return (model.questions.length > 0 && model.hasSettingParam("delayedMarking"));
		}
		
		public function getRule():String {
			return model.getRule();
		}
		
		/**
		 * This is a static function that determines whether an exercise should be navigable to or not. It runs off the exercise xml node in the menu
		 * xml, not the exercise file itself.
		 *  
		 * @param exerciseNode
		 * @return 
		 * 
		 */
		public static function linkExerciseInMenu(exerciseNode:XML):Boolean {
			if (!exerciseNode)
				return false;
			
			// enabledFlag is binary based for backwards compatability
			// You can link to an exercise if - it is not disabled and it has navigate on.
			return (!exerciseNode.hasOwnProperty("@enabledFlag") || ((exerciseNode.@enabledFlag & Exercise.EF_NAVIGATE_ON) == Exercise.EF_NAVIGATE_ON &&
																	!((exerciseNode.@enabledFlag & Exercise.EF_DISABLED) == Exercise.EF_DISABLED)));
		}
		
		/**
		 * This is a static function that determines whether an exercise should be displayed in the menu or not. It runs off the exercise xml node in the menu
		 * xml, not the exercise file itself.
		 *  
		 * @param exerciseNode
		 * @return 
		 * 
		 */
		public static function showExerciseInMenu(exerciseNode:XML):Boolean {
			if (!exerciseNode)
				return false;
			
			// enabledFlag is binary based for backwards compatability
			// You can see an exercise on the menu - if it is menuOn and not displayOff.
			// If it is disabled, you will see it differently and not be able to click it.
			return (!exerciseNode.hasOwnProperty("@enabledFlag") || ((exerciseNode.@enabledFlag & Exercise.EF_MENU_ON) == Exercise.EF_MENU_ON &&
																	!((exerciseNode.@enabledFlag & Exercise.EF_DISPLAY_OFF) == Exercise.EF_DISPLAY_OFF)));
		}
		
		/**
		 * This is a static function that determines whether an exercise is enabled on the menu or not.
		 *  
		 * @param exerciseNode
		 * @return 
		 * 
		 */
		public static function exerciseEnabledInMenu(exerciseNode:XML):Boolean {
			if (!exerciseNode)
				return false;
			
			// enabledFlag is binary based for backwards compatability
			return (!exerciseNode.hasOwnProperty("@enabledFlag") || !((exerciseNode.@enabledFlag & Exercise.EF_DISABLED)==Exercise.EF_DISABLED));

		}
		
		// gh#740 use to judge whether an exercise is marked in ExerciseProxy
		[Bindable]
		public function get isExerciseMarked():Boolean {
			return _isExerciseMarked;
		}
		
		public function set isExerciseMarked(value:Boolean):void {
			_isExerciseMarked = value;
		}
		
	}
}