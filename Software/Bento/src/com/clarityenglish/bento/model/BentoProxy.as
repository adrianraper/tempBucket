package com.clarityenglish.bento.model {
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.hamcrest.object.nullValue;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * This is used for storing system wide data.  It may be that this proxy will prove unnecessary at some point and can be removed.
	 * 
	 * @author Dave
	 */
	public class BentoProxy extends Proxy implements IProxy {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const NAME:String = "BentoProxy";
		
		private var _menuXHTML:XHTML;
		
		private var _currentExercise:Exercise;
		
		public function BentoProxy() {
			super(NAME);
		}
		
		public function get menuXHTML():XHTML {
			return _menuXHTML;
		}
		
		public function set menuXHTML(value:XHTML):void {
			if (_menuXHTML != null && value != null)
				throw new Error("Bento does not support multiple menu.xml files in a single execution");
			
			_menuXHTML = value;
		}
		
		public function get currentExercise():Exercise {
			return _currentExercise;
		}
		
		public function set currentExercise(value:Exercise):void {
			if (_currentExercise != null && value != null)
				throw new Error("Bento does not currently support running multiple exercises at the same time");
			
			_currentExercise = value;
		}
		
		public function getNextExerciseNode():XML {
			return getExerciseNodeWithOffset(1);
		}
		
		public function getPreviousExerciseNode():XML {
			return getExerciseNodeWithOffset(-1);
		}
		
		private function getExerciseNodeWithOffset(offset:int):XML {
			if (!currentExercise) {
				log.error("Attempt to go to next exercise when there is no current exercise");
				return null;
			}
			
			// Locate the exercise node in menuXHTML for currentExercise by matching the hrefs
			var matchingExerciseNodes:XMLList = menuXHTML..exercise.(@href == currentExercise.href.filename);
			if (matchingExerciseNodes.length() > 1) {
				throw new Error("Found multiple Exercise nodes in the menu xml matching " + currentExercise.href);
			} else if (matchingExerciseNodes.length() == 0) {
				throw new Error("Unable to find any Exercise nodes in the menu xml matching " + currentExercise.href);
			}
			
			var exerciseNode:XML = matchingExerciseNodes[0];
			
			// Keep going through potential exercises until we find one with Exercise.showExerciseInMenu  or we reach !(parentMatch && groupMatch) - the end of the section
			while (!(parentMatch && groupMatch)) {
				// If the offset is less than 0 then we can't find a matching exercise node so return null
				if (exerciseNode.childIndex() + offset < 0)
					return null;
				
				var otherExerciseNode:XML = exerciseNode.parent().children()[exerciseNode.childIndex() + offset];
				var parentMatch:Boolean = (exerciseNode.parent() === otherExerciseNode.parent());
				var groupMatch:Boolean = (!exerciseNode.hasOwnProperty("@group") && !otherExerciseNode.hasOwnProperty("@group")) || (exerciseNode.@group == otherExerciseNode.@group);
				
				// If this exercise is valid then return it
				if (Exercise.showExerciseInMenu(otherExerciseNode))
					return otherExerciseNode;
				
				// Increase the magnitude of the offset by one and try again
				offset += (offset / Math.abs(offset));
			}
			
			return null;
		}
		
	}
	
}