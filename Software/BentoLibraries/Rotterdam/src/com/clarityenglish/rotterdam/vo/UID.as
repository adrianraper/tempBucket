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
		
		// gh#92
		public function get titleName():String {
			if (!this.title)
				return null;
			
			// gh#360
			switch (this.title) {
				case 1:
					return 'AuthorPlus';
					break;
				case 9:
					return 'TenseBuster';
					break;
				case 10:
					return 'BusinessWriting';
					break;
				case 33:
					return 'ActiveReading';
					break;
				case 39:
					return 'ClearPronunciation1';
					break;
				case 50:
					return 'ClearPronunciation2';
					break;
				case 52:
				case 53:
					return 'RoadToIELTS';
					break;
				case 49:
					return 'StudySkillsSuccess';
					break;
				case 20:
					return 'MyCanada';
					break;
				case 34:
					return 'Peacekeeper';
					break;
				case 38:
					return 'ItsYourJob';
					break;
				case 17:
					return 'LamourDesTemps';
					break;
				case 40:
					return 'EnglishForHotelStaff';
					break;
				case 44:
					return 'PracticalPlacementTest';
					break;
				case 48:
					return 'AccessUK';
					break;
				case 43:
					return 'CustomerServiceCommunicationSkills';
					break;
				case 45:
					return 'IssuesInEnglish2';
					break;
				case 46:
					return 'ConnectedSpeech';
					break;
			}
			
			return null;
		}
		
		public function toString():String {
			return (title) ? title.toString() : '' + (course) ? '.' + course.toString() : '' + (unit) ? '.' + unit.toString() : '' + (exercise) ? '.' + exercise.toString() : '';
		}
			
	}
}