package com.clarityenglish.bento.model {
	
	import com.clarityenglish.bento.vo.ExerciseMark;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.pipwerks.SCORM;
	
	import flash.external.ExternalInterface;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * This is used for interacting with the LMS through SCORM.
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
		 * Terminate SCORM communication with the LMS
		 */
		public function terminate():void {
			
			if (!scorm.complete)
				this.unfinishedSCO();
			
			scorm.disconnect();
		}
		
		/**
		 * Called when you have completed an exercise to tell SCORM about it.
		 * 
		 *   1) add this score to the suspendData
		 *   2) set the bookmark
		 *   3) write the objective
		 */
		public function writeScore(data:ExerciseMark):Boolean {
			
			var exID:String = data.UID.split('.').pop().toString();
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var exerciseNode:XML = bentoProxy.currentExerciseNode;
			// BUG or what? For AdviceZone videos, there is no currentExercise
			if (!exerciseNode)
				exerciseNode = bentoProxy.menuXHTML..exercise.(@id == exID)[0];
			
			// Notes from Orchid
			// SCORM says that this string should have no spaces in it! Why - I have no idea.
			// Also can't have question marks! What about other punctuation?
			// Moodle implementation has regex '^\\w{1,255}$' - so allowing letters, digits and underscores only.
			var formattingPattern:RegExp = / /g;
			var rawCaption:String = exerciseNode.@caption;
			var exCaption:String = rawCaption.replace(formattingPattern, '_');
			
			// You don't set objective count, you let the LMS do that
			//scorm.setParameter('objective.count', String(scorm.objectiveCount++));
			scorm.setParameter('objective.id', exCaption, scorm.objectiveCount);
			scorm.setParameter('objective.status', 'completed', scorm.objectiveCount);
			if (data.correctPercent >= 0)
				scorm.setParameter('objective.score', String(data.correctPercent), scorm.objectiveCount);
			
			// In case you write another objective without checking with the LMS first, update the count
			scorm.objectiveCount++;

			// As well as writing it out, save the suspend data
			scorm.suspendData = this.formatSuspendData(exID, data.correctPercent)
			scorm.setParameter('suspendData', scorm.suspendData);
			
			scorm.setParameter('bookmark', this.formatBookmark(exID));
			
			return true;
		}
		
		/**
		 * Handle exit of a completed SCO
		 * If this is the last exercise in a unit:
		 *   1) set completionStatus to 'completed' (maybe passed or failed if you know a mastery score from SCORM)
		 *   2) write the averageScore
		 */
		public function completeSCO():void {
			scorm.complete = true;
			scorm.setParameter('lessonStatus', 'complete');
			scorm.setParameter('rawScore', this.calculateAverageScore());
			scorm.setParameter('sessionTime', this.getSessionTime());
				
		}
		public function unfinishedSCO():void {
			scorm.complete = false;
			scorm.setParameter('lessonStatus', 'incomplete');
			
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
		 * How long has this session lasted?
		 * written as "hh:mm:ss.zz"
		 */
		private function getSessionTime():String {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			
			// Seconds, not milliseconds
			var sessionDuration:Number = Math.round((new Date().time - configProxy.getConfig().sessionStartTime)/1000);
			var sHours:Number = Math.floor(sessionDuration / 3600);
			var sMinutes:Number = Math.floor((sessionDuration - (sHours * 3600)) / 60);
			var sSeconds:Number = sessionDuration - (sHours * 3600) - (sMinutes * 60);
			
			return this.padNumber(sHours) + ":" + this.padNumber(sMinutes) + ":" + this.padNumber(sSeconds) + ".00";
		}
		/**
		 * Quick utility function to pad a number with leading zeros
		 */
		private function padNumber(s:Number, padding:uint = 2):String {
			var t:String = s.toString();
			while (t.length < padding) {
				t = '0' + t;
			}
			return t;
		}
		
		/**
		 * Calculate the average score from suspend data
		 */
		private function calculateAverageScore():String {
			
			// Pick up the suspend data (you must make sure that the last exercise has been added already)
			var suspendDataArray:Object = JSON.parse(scorm.suspendData);
			if (suspendDataArray.scoreSoFar) {
				var scores:Array = suspendDataArray.scoreSoFar.split(",");
				
				// Read each score and add them up.
				// If one exercise has been done twice, you include both scores
				// But if an exercise has a score of -1, it means it was view only, so don't count it
				var totalScore:Number = 0;
				var numberOfScores:Number = 0;
				for (var score:String in scores) {
					var thisScore:int = Number(scores[score].split('|')[1]);
					if (thisScore >= 0) {
						numberOfScores++;
						totalScore += thisScore;
					}
				}
			}
			
			if (numberOfScores <= 0)
				return '0';
			
			return String(Math.round(totalScore / numberOfScores));
		}
		/**
		 * Format the bookmark
		 */
		private function formatBookmark(data:String):String {
			return 'ex=' + data;
		}
		
		/**
		 * Format the suspend data
		 * #493 Convert to JSON
		 * '{"scoreSoFar":"1234|15,5678|32","percentComplete":50}'
		 */
		private function formatSuspendData(exID:String, score:uint):String {
			if (scorm.suspendData) {
				var suspendDataArray:Object = JSON.parse(scorm.suspendData);
			} else {
				suspendDataArray = {};
			}
			
			// Add this new score to the list of ones done so far
			if (suspendDataArray.scoreSoFar) {
				var scores:Array = suspendDataArray.scoreSoFar.split(",");
			} else {
				suspendDataArray.scoreSoFar = {};
				scores = new Array();
			}
			scores.push(exID + '|' + score);
			suspendDataArray.scoreSoFar = scores.join(",");
			
			// Count the unique exercises done so far in suspend data
			// It doesn't matter if I destroy the scores array as that has already been written out as a string to suspend data.
			scores.sort();
			for (var i:int = scores.length-1; i>0; --i){
				if (scores[i].split('|')[0] === scores[i-1].split('|')[0])
					scores.splice(i,1);
			}
			var uniqueCount:int = scores.length;

			// Now count the number of exercise nodes in this unit
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var exerciseNode:XML = bentoProxy.currentExerciseNode;
			// BUG or what? But for AdviceZone videos, there is no currentExercise
			if (!exerciseNode) {
				exerciseNode = bentoProxy.menuXHTML..exercise.(@id == exID)[0];			
				var unitNode:XML = exerciseNode.parent();
			} else {
				unitNode = bentoProxy.currentUnitNode;
			}
			
			// If your SCORM object uses group, then you need to limit the exercises in the unit to just that group
			if (scorm.launchData.groupID) {
				var exercises:XMLList = unitNode.exercise.(@group == scorm.launchData.groupID);
			} else {
				exercises = unitNode.exercise;
			}
			var numExercises:Number = exercises.length();
			
			if (numExercises == 0) {
				suspendDataArray.percentComplete = 0;
			} else {
				suspendDataArray.percentComplete = Math.round(100 * uniqueCount / numExercises);
			}
			
			trace("suspendData = " + JSON.stringify(suspendDataArray));
			return JSON.stringify(suspendDataArray);
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
							//value = 0;
						dataObject.next = value;
						break;
				}
			}
			
			return dataObject;
		}
			
	}
		
}