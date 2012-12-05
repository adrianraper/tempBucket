package com.clarityenglish.rotterdam.vo {
	
	public class UID {
		
		/**
		 * The parts of a UID
		 */
		private var _title:Number;
		private var _course:Number;
		private var _unit:Number;
		private var _exercise:Number;
		
		public function UID(uid:String) {
			parseUID(uid);
		}
		
		public function get title():Number { 
			return _title; 
		}
		public function get course():Number { 
			return _course; 
		}
		public function get unit():Number { 
			return _unit; 
		}
		public function get exercise():Number { 
			return _exercise; 
		}
		public function set title(id:Number):void {
			_title = id;
		}
		public function set course(id:Number):void {
			_course = id;
		}
		public function set unit(id:Number):void {
			_unit = id;
		}
		public function set exercise(id:Number):void {
			_exercise = id;
		}
		
		public function parseUID(uid:String):void {
			
			var uidArray:Array = uid.split('.');
			
			if (uidArray.length > 0)
				_title = uidArray[0];
			if (uidArray.length > 1)
				_course = uidArray[1];
			if (uidArray.length > 2)
				_unit = uidArray[2];
			if (uidArray.length > 3)
				_exercise = uidArray[3];
			
		}
		
		public function toString():String {
			return (title) ? title.toString() : '' + (course) ? '.' + course.toString() : '' + (unit) ? '.' + unit.toString() : '' + (exercise) ? '.' + exercise.toString() : '';
		}
			
	}
}