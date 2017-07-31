package com.clarityenglish.common.vo.config {

import flash.xml.XMLNode;

import mx.logging.ILogger;
    import mx.logging.Log;
import mx.rpc.remoting.RemoteObject;

import org.davekeen.util.ClassUtil;
import flash.net.URLLoader;
import flash.net.URLRequest;


/**
	 * This holds configuration information that comes from any source.
	 * It includes licence control, user and account information.
	 */
	public class Endpoint {

        /**
         * Standard flex logger
         */
        private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));

        public var name:String;
        public var dbHost:Number;
        public var remoteGateway:String;
        public var remoteService:String;
        public var selected:Boolean;
        public var rejected:Boolean;
        public var channels:Array;
        public var params:Object;
        public var fullXML:XML;
        public var remoteObject:RemoteObject;
        public var waitForResult:Boolean;

        public function Endpoint() {
            this.channels = [];
            this.selected = this.rejected = false;
        }
    }
}