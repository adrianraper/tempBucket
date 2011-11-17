package com.clarityenglish.bento.model {
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * This is used for storing system wide data.  It may be that this proxy will prove unnecessary at some point and can be removed.
	 * 
	 * @author Dave
	 */
	public class BentoProxy extends Proxy implements IProxy {
		
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
		
	}
	
}