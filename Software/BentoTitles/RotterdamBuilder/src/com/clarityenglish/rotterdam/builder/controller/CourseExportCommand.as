package com.clarityenglish.rotterdam.builder.controller {
	
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	
	import mx.core.FlexGlobals;
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
		
		public override function execute(note:INotification):void {
			super.execute(note);

			var node:XML = (note.getBody() as XML);
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
			var exportScript:String = configProxy.getConfig().remoteGateway + "/services/RotterdamExport.php";

			if (FlexGlobals.topLevelApplication.parameters.sessionid) exportScript += "?PHPSESSID=" + FlexGlobals.topLevelApplication.parameters.sessionid;

			var prefix:String = configProxy.getAccount().prefix;
			var id:String = (node.hasOwnProperty("@id")) ? node.@id.toString() : '';

			var urlRequest:URLRequest = new URLRequest(exportScript);
			urlRequest.method = URLRequestMethod.POST;
			
			var postVariables:URLVariables = new URLVariables();
			postVariables.id = id;
			postVariables.prefix = prefix;
			urlRequest.data = postVariables;
			
			navigateToURL(urlRequest);
		}
	}
	
}