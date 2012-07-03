package com.clarityenglish.bento.model {
	
	import com.adobe.serialization.json.JSON;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.CopyProxy;
	import com.pipwerks.SCORM;
	
	import flash.external.ExternalInterface;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * This is used for interacing with the LMS through SCORM.
	 * 
	 * @author Clarity
	 */
	public class SCORMProxy extends Proxy implements IProxy {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const NAME:String = "SCORMProxy";
		
		// #336
		public var scorm:SCORM;
		
		public function SCORMProxy() {
			super(NAME);
		}
		
		/**
		 * Establish SCORM communication with the API in the browser
		 * Get initial variables and leave it all ready for communication once the SCO is started
		 */
		public function initialise():Boolean {
			
			var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
			
			scorm = new SCORM();
			scorm.debugMode = true;
			
			// Initialise
			if (!scorm.connect()) {
				sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("SCORMcantInitialize", { errorCode: 100, errorMessage: 'SCORMError' }, true ));
				return false;
			} else {
				// TODO. Why doesn't this give me a good value?
				//var scormVersion:String = scorm.version;
			}
			
			// After initalisation you need to get the following information from the LMS for this SCO
			//scorm.version = scorm.getParameter('version');
			scorm.studentName = scorm.getParameter('studentName');
			scorm.studentID = scorm.getParameter('studentID');
			scorm.studentLanguage = scorm.getParameter('interfaceLanguage');
			scorm.entry = scorm.getParameter('entry');
			
			// Did any of these calls raise an error?
			
			scorm.objectiveCount = Number(scorm.getParameter('objective.count'));
			
			// launch_data is key, and you need to carefully check this as not all LMS support it
			scorm.launchData = this.parseSCORMdata(scorm.getParameter('launchData'));
			
			if (scorm.entry == 'resume')
				scorm.suspendData = scorm.getParameter('suspendData');
			
			return true;
		}

		/**
		 * Terminate SCORM communication and let the LMS know we are going
		 */
		public function terminate():void {
			scorm.disconnect();
		}
		
		/**
		 * Called when you have completed an exercise to tell SCORM about it.
		 * If this is the last exercise in a unit:
		 *   1) set completionStatus to 'completed' (maybe passed or failed if you know a mastery score from SCORM)
		 *   2) write the averageScore
		 * If not the last exercise:
		 *   1) add this score to the suspendData
		 *   2) set the bookmark
		 *   3) write the objective
		 */
		public function writeScore(exID:String, score:uint, lastExercise:Boolean = false):Boolean {
			
			if (lastExercise) {
				scorm.complete = true;
				scorm.setParameter('bookmark', '');
				scorm.setParameter('lessonStatus', 'completed');
				scorm.setParameter('rawScore', String(this.calculateAverageScore(scorm.suspendData)));
				scorm.setParameter('suspendData', '');
				
			} else {
				// TODO. Get the exercise caption from the id
				var exCaption:String = exID;
				
				scorm.complete = false;
				scorm.setParameter('bookmark', this.formatBookmark(exID));
				
				// You don't set the objective count in the LMS, it just tells you
				//scorm.setParameter('objective.count', String(scorm.objectiveCount++));
				scorm.setParameter('objective.id', exCaption, scorm.objectiveCount);
				scorm.setParameter('objective.status', 'completed', scorm.objectiveCount);
				scorm.setParameter('objective.score', String(score), scorm.objectiveCount);
				scorm.objectiveCount++;
				
				scorm.setParameter('suspendData', this.formatSuspendData(exID, score));
			}
			
			return true;
		}
		
		/**
		 * This figures out all the direct start for the SCORM SCO
		 */
		public function getBookmark():Object {
			// The bookmark is most specific, but if there isn't one go with the launchData
			// expecting ex=1234
			scorm.bookmark = this.parseSCORMdata(scorm.getParameter('bookmark'));
			if (scorm.bookmark) {
				// The bookmark will be an exercise which completely replaces the starting point
				// But we need to tell the navigation that we will go on after this exercise
				scorm.bookmark.next = 0;
				
				return scorm.bookmark;
				
			} else {
				return scorm.launchData;
				
			}
		}
		
		/**
		 * Calculate the average score from suspend data
		 */
		private function calculateAverageScore(data:String):Number {
			// "score-so-far,ex:1156153794430|0,ex:1156153794430|20"
			var totalScore:Number = 0;
			var totalCount:uint = 0;
			
			for each(var item:String in data.split(',')) {
				if (item == 'score-so-far')
					continue;
				
				var detail:Array = item.split('|');
				if (detail.length > 1) {
					totalScore += Number(detail[1]);
					totalCount++;
				}
			}
			
			if (totalCount > 0)
				return Math.round(totalScore / totalCount);
			
			return 0;
		}
		
		/**
		 * Format the bookmark
		 */
		private function formatBookmark(data:String):String {
			return 'ex=' + data;
		}
		/**
		 * Save the new suspend data to the LMS 
		 */
		private function formatSuspendData(exID:String, score:uint):String {
			if (!scorm.suspendData)
				scorm.suspendData = 'score-so-far';
			
			scorm.suspendData = scorm.suspendData + ',' + 'ex:' + exID + '|' + score;
			
			return scorm.suspendData;
		}

		
		/**
		 * Utility function to parse string of name value pairs from SCORM
		 *  expecting course=12345,unit=67890 or ex:12345
		 */
		public function parseSCORMdata(data:String, voDivider:String = "="):Object {
			if (!data)
				return null;
			
			var dataObject:Object = new Object();
			
			for each (var dataItem:String in data.split(",")) {
				
				var pair:Array = dataItem.split(voDivider);
				var name:String = pair[0];
				if (pair.length > 0) {
					var value:String = pair[1];
				} else {
					value = null;
				}
				
				switch (name) {
					case 'course':
					case 'courseID':
						dataObject.courseID = value;
						break;
					case 'ex':
					case 'exercise':
						dataObject.exerciseID = value;
						break;
					case 'unit':
						dataObject.unitID = value;
						break;
					case 'group':
						dataObject.groupID = value;
						break;
					case 'next':
						if (!value)
							value = '0';
						dataObject.next = value;
						break;
				}
			}
			
			return dataObject;
		}
			
	}
		
}