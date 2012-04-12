package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.Base64Encoder;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class ExercisePrintCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var href:Href = note.getBody() as Href;
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			
			var urlRequest:URLRequest = new URLRequest(configProxy.getConfig().remoteGateway + "services/print.php");
			
			var urlVariables:URLVariables = new URLVariables();
			var encoder:Base64Encoder = new Base64Encoder();
			
			encoder.encode(href.url);
			urlVariables.u = encoder.toString();
			
			encoder.encode(href.rootPath);
			urlVariables.b = encoder.toString();
			
			urlRequest.data = urlVariables;
			urlRequest.method = URLRequestMethod.GET;
			
			navigateToURL(urlRequest, "_blank");
		}
		
	}
	
}