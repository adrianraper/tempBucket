package com.clarityenglish.progressWidget.vo.progress 
{
	import com.clarityenglish.common.vo.Reportable;
	import com.clarityenglish.common.vo.content.Content;
	import org.davekeen.utils.ClassUtils;
	import com.clarityenglish.utils.TraceUtils;
	
	/**
	* ...
	* @author Adrian Raper
	*/
	[RemoteClass(alias = "com.clarityenglish.progessWidget.vo.progress.Coverage")]
	[Bindable]
	public class Coverage extends Content {
		
		/**
		 * Details of this item
		 */
		public var contentType:String;
		//public var summaryID:String;
		
		/*
		 * About the coverage
		 */
		private var _completed:Number;
		private var _total:Number;
		private var _ecompleted:Number;
		private var _etotal:Number;
		
		public function Coverage(content:*) {
			name = content.name;
			id = content.id;
			contentType = ClassUtils.getClassAsString(content);
			//TraceUtils.myTrace("made a new coverage called " + name + " type=" + contentType);
		}
		
		public function get completed():uint { return _completed; }
		public function set completed(value:uint):void {
			_completed = value;
		}
		public function get total():uint { return _total; }
		public function set total(value:uint):void {
			_total = value;
		}
		public function get everyonesCompleted():uint { return _ecompleted; }
		public function set everyonesCompleted(value:uint):void {
			_ecompleted = value;
		}
		public function get everyonesTotal():uint { return _etotal; }
		public function set everyonesTotal(value:uint):void {
			_etotal = value;
		}

		public function setCoverage(progress:Object):Boolean {
			if (progress) {
				completed = progress.completed;
				total = progress.total;
			} else {
				return false
			}
			//summaryID = progress.unitID;
			return true
		}
		// Add for everybodies' scores
		// We default numberOfUsers to 1 since for there to be a coverage record we must have had at least one user!
		public function setEveryonesCoverage(progress:Object, numberOfUsers:uint=1):Boolean {
			if (progress) {
				if (numberOfUsers == 0 || progress.total==0) {
					// this shouldn't be possible of course! but even so
					everyonesCompleted = 0;
					everyonesTotal = 0;
					//TraceUtils.myTrace("setEveryonesCoverage for " + id + " to zero");
				} else {
					everyonesCompleted = progress.completed;
					// Everyones total comes from the single user total * the number of users
					everyonesTotal = total * numberOfUsers;
					//everyonesTotal = progress.total;
					//everyonesPercent = (progress.completed / progress.total);
					//TraceUtils.myTrace("setEveryonesCoverage for " + id + " to completed=" + everyonesCompleted + " of " + everyonesTotal + " for " + numberOfUsers + " people.");
				}
			} else {
				return false
			}
			//summaryID = progress.unitID;
			return true
		}
		
		/*
		 * Formatting functions
		 */
		public function toString():String {
			return id + ": " + reportableLabel + " you completed " + completed + " of " + total + " everyone completed " + everyonesCompleted + " of " + everyonesTotal;
		}
		/* INTERFACE mx.core.IUID */
		
	}
}