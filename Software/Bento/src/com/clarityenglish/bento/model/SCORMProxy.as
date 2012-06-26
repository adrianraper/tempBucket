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
				var scormVersion:String = scorm.version;
			}
			
			// After initalisation you need to get the following information from the LMS for this SCO
			scorm.version = scorm.getParameter('version');
			scorm.studentName = scorm.getParameter('studentName');
			scorm.studentID = scorm.getParameter('studentID');
			scorm.studentLanguage = scorm.getParameter('interfaceLanguage');
			scorm.entry = scorm.getParameter('entry');
			
			// Did any of these calls raise an error?
			
			var objectivesCount:uint = Number(scorm.getParameter('objective.count'));
			// Check to see if the LMS raised an error at that request? Equally, 0 or NaN means no objectives??
			if (objectivesCount>0) {
				scorm.objectives = new Object();
				scorm.objectives.count = objectivesCount
			};
			
			// launch_data is key, and you need to carefully check this as not all LMS support it
			// TODO: Encode as JSON?
			scorm.launchData = scorm.getParameter('launchData');
			/*
			_global.ORCHID.commandLine.course = launchData.course;
			if (launchData.unit != undefined) {
				_global.ORCHID.commandLine.startingPoint = "unit:" + launchData.unit;
			} else if (launchData.exercise != undefined) {
				_global.ORCHID.commandLine.startingPoint = "ex:" + launchData.exercise;
			} else {
				_global.ORCHID.commandLine.startingPoint = "menu";
			}
			*/
			
			// entry data says whether we should also get
			// suspend data
			scorm.suspendData = com.adobe.serialization.json.JSON.decode(scorm.getParameter('suspendData'));
			
			return true;
		}

		/**
		 * This figures out all the direct start for the SCORM SCO
		 */
		public function getBookmark():Object {
			// TODO: Work out the course and exercise ID from the launchData structure
			if (scorm.launchData.exerciseID)
				return scorm.launchData.exerciseID;
			if (scorm.launchData.course)
				return scorm.launchData.course;

			scorm.bookmark = scorm.getParameter('bookmark');
			return null;
		}
	}
		
}