package com.clarityenglish.common.vo.content {
	
	/**
	* ...
	* @author DefaultUser (Tools -> Custom Arguments...)
	*/
	[RemoteClass(alias = "com.clarityenglish.common.vo.content.Unit")]
	[Bindable]
	public dynamic class Unit extends Content {
		
		/**
		 * The collection of exercises contained in this unit
		 */
		private var _exercises:Array;
		
		public function Unit() {
			exercises = new Array();
		}
		
		public function addExercise(exercise:Exercise):void {
			exercises.push(exercise);
		}
		// v3.4 Added to allow Editing of Clarity Content to move exercises from one unit to another.
		public function removeExercise(exercise:Exercise):void {
			for (var i:uint = 0; i < exercises.length; i++) {
				if (exercises[i].id == exercise.id) {
					exercises.splice(i, 1);
					break;
				}
			}
		}
		
		public function get exercises():Array { return _exercises; }
		
		public function set exercises(value:Array):void {
			super.children = value;
			
			_exercises = value;
		}
		
		/**
		 * Implementing a children field allows us to use this class directly as a dataprovider to a tree
		 */
		[Transient]
		override public function get children():Array { return exercises; }
		
		override public function set children(children:Array):void {
			exercises = children;
		}
		
		/* INTERFACE mx.core.IUID */
		
		override public function get uid():String {
			return parent.uid + "." + id;
		}
		
		override public function set uid(value:String):void { }
		
	}
	
}