package com.clarityenglish.bento.vo.content {
	import com.clarityenglish.bento.vo.content.model.Model;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	/**
	 * @author
	 */
	public class Exercise extends XHTML {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var _model:Model;
		
		public function Exercise(value:XML = null) {
			super(value);
		}
		
		override public function set xml(value:XML):void {
			if (_xml !== value) {
				var modelNodes:XMLList = value.head.script.(hasOwnProperty("@id") && @id == "model" && hasOwnProperty("@type") && @type == "application/xml");
				if (modelNodes.length() > 0)
					_model = new Model(this, modelNodes[0]);
			}
			
			super.xml = value;
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
		
	}
}