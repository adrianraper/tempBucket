package com.clarityenglish.common.vo.content {
	
	/**
	* ...
	* @author DefaultUser (Tools -> Custom Arguments...)
	*/
	[RemoteClass(alias = "com.clarityenglish.common.vo.content.Course")]
	[Bindable]
	public dynamic class Course extends Content {
		
		// gh#91 enabledFlag values
		public static const EF_VIEWER:int = 1;
		public static const EF_PUBLISHER:int = 2;
		public static const EF_OWNER:int = 4;
		public static const EF_EDITABLE:int = 8;
		public static const EF_COLLABORATOR:int = 16;
		
		// gh#91 role values
		public static const ROLE_OWNER = 1;
		public static const ROLE_COLLABORATOR = 2;
		public static const ROLE_PUBLISHER = 3;
		public static const ROLE_VIEWER = 4;

		/**
		 * The collection of units belonging to this course
		 */
		private var _units:Array;
		
		/**
		 * The author of this title
		 */
		public var author:String;
		
		// gh#89 what about other attributes of course that we now include?
		// public var unitInterval:uint;
		// public var startDate:String;
		
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