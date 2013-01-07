package com.clarityenglish.rotterdam.controller {
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	import com.clarityenglish.rotterdam.vo.UID;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
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
			var startPage:String = 'Start.php';
			if (uid.titleName) {
				var progName:String = uid.titleName;
			} else {
				log.error("title productCode " + uid.title + " is new");
				progName = uid.title as String;
			}
			var startFolder:String = copyProvider.getCopyForId("path" + progName) + "/";

			// what parameters do we need to pass?
			var parameters:Array = new Array();
			var prefix:String = "prefix=" + configProxy.getAccount().prefix;
			parameters.push(prefix);
			
			var user:String = "username=" + loginProxy.user.name;
			parameters.push(user);
			
			var password:String = "password=" + loginProxy.user.password;
			parameters.push(password);
			
			if (uid.course) {
				var course:String = "course=" + uid.course;
				parameters.push(course);
			}
			
			if (uid.unit) {
				var startingPoint:String = "startingPoint=unit:" + uid.unit;
				parameters.push(startingPoint);
			} else if (uid.exercise) {
				startingPoint = "startingPoint=ex:" + uid.unit;
				parameters.push(startingPoint);
			}
			
			var argList:String = "?" + parameters.join("&");
			
			// Then run this as a new browser window
			// TODO: At some point BentoTitles could open their exercises directly in Rotterdam Player
			// gh#92
			navigateToURL(new URLRequest(area + startFolder + startPage + argList), "_blank");
			log.info("Opening content for uid=" + uid.toString());
		}
		
	}
	
}