package com.clarityenglish.rotterdam.controller {
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	import com.clarityenglish.rotterdam.vo.UID;
	import com.clarityenglish.textLayout.vo.XHTML;
	import com.clarityenglish.utils.crypt.Crypt;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class ContentOpenCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var uid:UID = new UID(note.getBody().toString());
			
			// First build a URL to point to the title and content
			// gh#92 Combination of UID and rotterdam.xml holds the productCode to path translation
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;

			var area:String = configProxy.getConfig().remoteStartFolder;
			
			// UID contains expected productCode to name translation
			// Then rotterdam.xml contains path information for a particular installation
			// gh#310
			if (uid.title == 52) {
				var startPage:String = 'Start-AC.php';
			} else if (uid.title == 53) {
				startPage = 'Start-GT.php';
			} else {
				startPage = 'Start.php';
			}
			// temporary prefix until Start pages all confirmed
			startPage = 'CCB-' + startPage;

			if (uid.titleName) {
				var progName:String = uid.titleName;
			} else {
				log.error("title productCode " + uid.title + " is new");
				// gh#1451
				progName = String(uid.title);
			}
			var startFolder:String = copyProvider.getCopyForId("path" + progName) + "/";

			// What parameters do we need to pass?
			var parameters:Array = new Array();
			var prefix:String = "prefix=" + configProxy.getAccount().prefix;
			parameters.push(prefix);
			
			// gh#371 capitalisation
			var user:String = "userName=" + loginProxy.user.name;
			parameters.push(user);

			if (loginProxy.user.email) {
				var email:String = "email=" + loginProxy.user.email;
				parameters.push(email);
			}
			if (loginProxy.user.studentID) {
				var id:String = "studentID=" + loginProxy.user.studentID;
				parameters.push(id);
			}
			
			var password:String = "password=" + loginProxy.user.password;
			parameters.push(password);
			
			if (uid.course) {
				var course:String = "course=" + uid.course;
				parameters.push(course);
			}
			
			// gh#238
			if (uid.unit && !uid.exercise) {
				var startingPoint:String = "startingPoint=unit:" + uid.unit;
				parameters.push(startingPoint);
			} else if (uid.unit && uid.exercise) {
				startingPoint = "startingPoint=ex:" + uid.exercise;
				parameters.push(startingPoint);
			}
			
			// gh#371
			var playerParameters:Object = configProxy.getOtherParameters();
			if (playerParameters.resize) parameters.push("resize=" + playerParameters.resize);
			
			var crypt:Crypt = new Crypt();
			var argList:String = "?data=" + crypt.encryptURL(parameters.join("&"));
			trace("plain arglist=" + parameters.join("&"));
			trace("encrypted=" + crypt.encryptURL(parameters.join("&")));

			// Then run this as a new browser window
			// TODO: At some point BentoTitles could open their exercises directly in Rotterdam Player
			// gh#92
			navigateToURL(new URLRequest(area + startFolder + startPage + argList), "_blank");
			// log.info("Opening content for uid=" + uid.toString());
		}
	}
	
}