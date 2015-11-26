package com.clarityenglish.bento.model {
	
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.pipwerks.SCORM;
	
	import flash.external.ExternalInterface;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
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
		
		// gh#879
		[Bindable]
		private var totalExercise:Number;
		
		// #336
		public var scorm:SCORM;


        // gh#1405
        private var _initialised:Boolean = false;
        private var _email:String = '';
		
		public function SCORMProxy() {
			super(NAME);
		}

        public function get initialised():Boolean {
            return _initialised;
        }
        public function set initialised(value:Boolean):void {
            if (value != _initialised)
                _initialised = value;
        }
        public function get email():String {
            if (_email == '') {
                // simplify the name to be more like email if we are just making one up
                var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
                var regex:RegExp = /[\W]+/gim;
                _email = scorm.studentName.replace(regex, '') + '@scorm.' + configProxy.getRootID();
            }
            return _email;
        }
        public function set email(value:String):void {
            _email = value;
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
			
			scorm.objectiveCount = Number(scorm.getParameter('objective.count'));
			
			// launch_data is key, and you need to carefully check this as not all LMS support it
			scorm.launchData = this.parseSCORMdata(scorm.getParameter('launchData'));
			
			if (scorm.entry == 'resume')
				scorm.suspendData = scorm.getParameter('suspendData');			

            // gh#1405
            this.initialised = true;
			return true;
		}

		/**
		 * Terminate SCORM communication with the LMS
		 */
		public function terminate():void {
			scorm.disconnect();
		}
		
		/**
		 * Called when you have completed an exercise to tell SCORM about it.
		 * 
		 *   1) add this score to the suspendData
		 *   2) set the bookmark
		 *   3) write the objective
		 */
		public function writeScore(exID:String, score:uint, hasQuestion:Boolean = true):Boolean {
			
			// TODO. Get the exercise caption from the id
			// Notes from Orchid
			// SCORM says that this string should have no spaces in it! Why - I have no idea.
			// Also can't have question marks! What about other punctuation?
			// Moodle implementation has regex '^\\w{1,255}$' - so allowing letters, digits and underscores only.
			var exCaption:String = exID;

            // gh#1405 You can't set the objectives count
			//scorm.setParameter('objective.count', String(scorm.objectiveCount++));
            var newObjectiveCount:uint = Number(scorm.getParameter('objective.count'));
			scorm.setParameter('objective.id', exCaption, newObjectiveCount);
			scorm.setParameter('objective.status', 'completed', newObjectiveCount);
			scorm.setParameter('objective.score', String(score), newObjectiveCount);
			scorm.setParameter('suspendData', this.formatSuspendData(exID, score, hasQuestion));			
			scorm.setParameter('bookmark', this.formatBookmark(exID));

            // Just to see if that worked, force a count from the LMS...
            newObjectiveCount = Number(scorm.getParameter('objective.count'));

            // gh#881
			checkScormComplete();
			
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
			scorm.setParameter('lessonStatus', 'completed');
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
			
			var sessionDuration:Number = new Date().time - configProxy.getConfig().sessionStartTime;
			// gh#877 correct the time calculation formula
			var sHours:Number = Math.round(sessionDuration / 3600000);
			var sMinutes:Number =  Math.round((sessionDuration - (sHours * 3600000)) / 60000);
			var sSeconds:Number = Math.round((sessionDuration - (sHours * 3600000) - (sMinutes * 60000))/1000);
			
			// gh#877
			if (sHours < 10) {
				var sHoursString:String = "0" + sHours.toString();
			} else {
				sHoursString = sHours.toString();
			}
			
			if (sMinutes < 10) {
				var sMinutesString:String = "0" + sMinutes.toString();
			} else {
				sMinutesString = sMinutes.toString();
			}
			
			if (sSeconds < 10) {
				var sSecondsString:String = "0" + sSeconds.toString();
			} else {
				sSecondsString = sSeconds.toString();
			}

			return sHoursString + ":" + sMinutesString + ":" + sSecondsString;
		}
		
		/**
		 * Calculate the average score from suspend data
		 */
		private function calculateAverageScore():String {
			
			// Pick up the suspend data (you must make sure that the last exercise has been added already)
			
			var suspendDataArray:Object = JSON.parse(scorm.suspendData)? JSON.parse(scorm.suspendData) : JSON.parse(scorm.getParameter("suspendData"));
			
			if (suspendDataArray.scoreSoFar) {
				var scores:Array = suspendDataArray.scoreSoFar.split(",");
				
				// Read each score and add them up.
				// If one exercise has been done twice, you include both scores
				var totalScore:Number = 0;
				var numberOfScores:Number = 0;
				// gh#877 correct the "for" iteration which i is index not the score in scores 
				for (var i:String in scores) {
					numberOfScores++;
					totalScore += Number(scores[i].split('|')[1]);
					log.info("score3: "+scores[i]);
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
		 * '{"scoreSoFar":"ex:1234|15,ex:5678|32","percentComplete":50}'
		 */
		private function formatSuspendData(exID:String, score:uint, hasQuestion:Boolean):String {
			if (scorm.suspendData) {
				var suspendDataArray:Object = JSON.parse(scorm.suspendData);
			} else {
				suspendDataArray = {};
			}
			
			// Add this new score to the list of ones done so far
			if (suspendDataArray.scoreSoFar) {
				var scores:Array = suspendDataArray.scoreSoFar.split(",");
			} else {
				scores = new Array();
			}
			
			for (var i:String in scores) {
				if (("ex:"+exID) == scores[i].split("|")[0]) {
					var isIDExist:Boolean = true;
				}
			}
			
			if (!isIDExist && hasQuestion) {
				scores.push('ex:' + exID + '|' + score);
				suspendDataArray.scoreSoFar = scores.join(",");
			}
			
			// Update the percent complete. 
			// I need to get the bit of menu.xml relevant to this SCORM object and count the number of exercises in it.
			// Then I can work out the % using scoreSoFar.
			/*if (suspendDataArray.percentComplete) {
				suspendDataArray.percentComplete = 51;
			} else {
				suspendDataArray.percentComplete = 10;
			}*/
			// gh#881
			if (suspendDataArray.noQuestionExercises) {
				var noQuestionExercises:Array = suspendDataArray.noQuestionExercises.split(",");
			} else {
				noQuestionExercises = new Array();
			}
			
			for (var j:String in noQuestionExercises) {
				if (exID == noQuestionExercises[j]) {
					var isNoQuestionIDExist:Boolean = true;
				}
			}
			
			if (!isNoQuestionIDExist && !hasQuestion) {
				noQuestionExercises.push(exID);
				suspendDataArray.noQuestionExercises = noQuestionExercises.join(",");
			}
			
			// gh#879
			suspendDataArray.percentComplete = Math.round(scores.length / (totalExercise - noQuestionExercises.length) * 100);
			
			scorm.suspendData = JSON.stringify(suspendDataArray);
			return JSON.stringify(suspendDataArray);
		}

		
		/**
		 * Utility function to parse string of name value pairs from SCORM
		 *  expecting course=12345,unit=67890 or ex:12345
		 *  gh#1080 or state:progress
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
					case 'state':
						dataObject.state = value;
				}
			}
			
			return dataObject;
		}
		
		// gh#879
		public function setTotalExercise(value:Number):void {
			totalExercise = value;
		}
		
		// gh#879
		public function isScormCompleted():Boolean {
			return (scorm.getParameter('lessonStatus') == "completed");
		}
		
		// gh#881
		public function checkScormComplete():void {
			// in formatSuspendData(), latest suspend data hasn't been written into scorm, so we should call completeSCO afterwards.
			if (scorm.suspendData) {
				var suspendDataArray:Object = JSON.parse(scorm.suspendData);
				
				// if percent complete equal 100%, we should call completeSCO to get the final report for time spending and score
				if (suspendDataArray.percentComplete == 100) {
					completeSCO();
				}
			}
		}
	}
		
}