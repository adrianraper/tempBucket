package com.clarityenglish.common.vo.content {
	
	/**
	* ...
	* @author DefaultUser (Tools -> Custom Arguments...)
	*/
	[RemoteClass(alias = "com.clarityenglish.common.vo.content.Course")]
	[Bindable]
	public dynamic class Course extends Content {
		
		/**
		 * The collection of units belonging to this course
		 */
		private var _units:Array;
		
		/**
		 * The author of this title
		 */
		public var author:String;
		
		// folder?
		// subfolder?
		// possibly taken care of on server
		
		public function Course() {
			units = new Array();
		}
		
		public function addUnit(unit:Unit):void {
			units.push(unit);
		}
		
		public function get units():Array { return _units; }
		
		public function set units(value:Array):void {
			super.children = value;
			
			_units = value;
		}
		
		/**
		 * Implementing a children field allows us to use this class directly as a dataprovider to a tree
		 */
		[Transient]
		override public function get children():Array { return units; }
		
		override public function set children(children:Array):void {
			units = children;
		}
		
		/* INTERFACE mx.core.IUID */
		
		override public function get uid():String {
			return parent.uid + "." + id;
		}
		
		override public function set uid(value:String):void { }
		
	}
	
}