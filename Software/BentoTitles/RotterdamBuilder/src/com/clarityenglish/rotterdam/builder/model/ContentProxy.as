package com.clarityenglish.rotterdam.builder.model {
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.AsyncToken;
	
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * @author Dave
	 */
	public class ContentProxy extends Proxy implements IProxy {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const NAME:String = "ContentProxy";
		
		public function ContentProxy() {
			super(NAME);
		}
		
		public function getContent():AsyncToken {
			return new RemoteDelegate("getContent").execute();
		}
		
	}

}
