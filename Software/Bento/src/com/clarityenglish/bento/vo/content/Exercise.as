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
		
	}
}