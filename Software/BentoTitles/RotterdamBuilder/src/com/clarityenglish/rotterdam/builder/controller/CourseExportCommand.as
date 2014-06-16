package com.clarityenglish.rotterdam.builder.controller {
	
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import flash.net.URLRequest;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class CourseExportCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var node:XML;
		
		public override function execute(note:INotification):void {
			super.execute(note);

			node = note.getBody().node;

			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
			var uploadScript:String = configProxy.getConfig().remoteGateway + "/services/RotterdamUpload.php";

			var urlRequest:URLRequest = new URLRequest(uploadScript);
			urlRequest.method = Constants.URL_REQUEST_METHOD;
			
			var postVariables:URLVariables = new URLVariables();
			postVariables.nocache = Math.floor(Math.random() * 999999);
			urlRequest.data = postVariables;
			
			navigateToURL(urlRequest, "_blank");
		}
		
	}
	
}