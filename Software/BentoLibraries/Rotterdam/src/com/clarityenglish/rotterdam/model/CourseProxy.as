﻿/*
Proxy - PureMVC
*/
package com.clarityenglish.rotterdam.model {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.content.Course;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.AsyncToken;
	import mx.rpc.Fault;
	import mx.utils.XMLNotifier;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.facade.Facade;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * A proxy
	 */
	public class CourseProxy extends Proxy implements IProxy, IDelegateResponder {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const NAME:String = "CourseProxy";
		
		private var _currentUnit:XML;
		
		private var _unitCollection:ListCollectionView;
		private var _widgetCollection:ListCollectionView;
		
		private var xmlWatcher:XMLChangeWatcher;
		
		private var courseSessionTimer:Timer;

		// gh#91
		private var _editable:Boolean = false;
		private var _role:int = 0;
		private var _previewMode:Boolean = false;
		
		public function CourseProxy(data:Object = null) {
			super(NAME, data);
			
			xmlWatcher = new XMLChangeWatcher();
			xmlWatcher.addEventListener(XMLChangeWatcherEvent.XML_CHANGE, onXmlChange);
			
			courseSessionTimer = new Timer(60 * 1000);
			courseSessionTimer.addEventListener(TimerEvent.TIMER, onCourseSessionTimer);
		}
		
		// gh#13
		public function reset():void {
			
		}
		
		public function set xmlWatcherEnabled(value:Boolean):void {
			if (xmlWatcher) xmlWatcher.enabled = value;
		}
		
		public function beforeXHTMLLoad(facade:Facade, href:Href):void {
			if (href.type == Href.MENU_XHTML) {
				var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
				if (bentoProxy.menuXHTML) {
					XMLNotifier.getInstance().unwatchXML(bentoProxy.menuXHTML.xml, xmlWatcher);
				}
			}
		}
		
		public function afterXHTMLLoad(facade:Facade, href:Href):void {
			if (href.type == Href.MENU_XHTML) {
				var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
				if (bentoProxy.menuXHTML)
					XMLNotifier.getInstance().watchXML(bentoProxy.menuXHTML.xml, xmlWatcher);
			}
		}
		
		/**
		 * gh#90 - this listener detects real user initiated changes.  It filters out changes which happen automatically in the framework.
		 * 
		 * @param event
		 */
		protected function onXmlChange(event:XMLChangeWatcherEvent):void {
			// layoutheight is autogenerated by the free layout code and doesn't count as a real change
			if (event.changeType == "attributeChanged" && event.value == "layoutheight") return;
			
			// nodeChange without an actual change are usually autogenerated and don't count either
			if (event.changeType == "nodeChanged" && event.value == event.detail) return;
			
			// This was a real change!
			sendNotification(BBNotifications.ITEM_DIRTY, "xhtml");
		}
		
		/**
		 * This is called by CourseStartCommand and can be used to do Rotterdam specific stuff when a course (i.e. menu.xml file) is loaded.
		 */
		public function updateCurrentCourse():void {
			_unitCollection = new XMLListCollection(courseNode.unit);
			dispatchEvent(new Event("unitCollectionChanged"));
			
			// Make sure the same unit stays selected (if there is one)
			//Alice: For the newly created unit, the unit ID is empty
			if (currentUnit && courseNode.unit.hasOwnProperty("@id")) currentUnit = courseNode.unit.(@id == currentUnit.@id)[0];
			
			// gh#91 Set permission for this course
			if (courseNode.permission)
				setPermission(courseNode.permission);
			
			// gh#91 and set a default preview mode if you are a publisher (or the course is not editable?)
			// gh#91a
			isPreviewMode = isPublisher || !isEditable;
		}
		
		public function get currentCourse():XHTML {
			// The current course actually comes from the currently loaded menuXHTML, since for Rotterdam each menu.xml contains a single course (although this should
			// maybe return the course node for clarity)
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			return bentoProxy.menuXHTML;
		}
		
		private function get courseNode():XML {	
			return currentCourse.selectOne("script#model[type='application/xml'] course");
		}
		
		[Bindable(event="unitCollectionChanged")]
		public function get unitCollection():ListCollectionView {
			return _unitCollection;
		}
		
		public function get currentUnit():XML {
			return _currentUnit;
		}
		
		public function set currentUnit(value:XML):void {
			_currentUnit = value;
			
			_widgetCollection = (value) ? new XMLListCollection(value.*) : null;
			dispatchEvent(new Event("widgetCollectionChanged"));
		}
		
		[Bindable(event="widgetCollectionChanged")]
		public function get widgetCollection():ListCollectionView {
			return _widgetCollection;
		}
		
		public function widgetAdd(widget:XML):void {
			if (_widgetCollection) {
				log.info("Adding widget " + widget.toXMLString());
				_widgetCollection.addItem(widget);
			} else {
				log.error("Attempted to add a widget with no widget collection");
			}
		}
		
		public function widgetDelete(widget:XML):void {
			if (_widgetCollection) {
				log.info("Deleting widget " + widget.toXMLString());
				_widgetCollection.removeItemAt(widgetCollection.getItemIndex(widget));
			} else {
				log.error("Attempted to delete a widget with no widget collection");
			}
		}
		
		public function courseCreate(courseObj:Object):AsyncToken {
			return new RemoteDelegate("courseCreate", [ courseObj ], this).execute();
		}
		
		public function courseSave():AsyncToken {
			if (currentCourse) {
				var xmlString:String = currentCourse.xml.toXMLString();
				xmlString = xmlString.replace("<bento>", "<bento xmlns=\"http://www.w3.org/1999/xhtml\">");
				
				return new RemoteDelegate("courseSave", [ currentCourse.href.filename, xmlString ], this).execute();
			} else {
				log.error("Attempted to save when there was no currentCourse set");
				return null;
			}
		}
		
		public function courseDelete(course:XML):AsyncToken {
			return new RemoteDelegate("courseDelete", [ course ], this).execute();
		}
		
		public function courseStart():void {
			courseSessionTimer.start();
		}
		
		private function onCourseSessionTimer(event:TimerEvent):void {
			if (currentCourse) {
				new RemoteDelegate("courseSessionUpdate", [ courseNode.@id.toString() ], this).execute();
			}
		}
		
		public function courseEnd():void {
			courseSessionTimer.reset();
		}

		// gh#751
		public function get courseID():String {
			return (courseNode.hasOwnProperty("@id")) ? courseNode.@id.toString() : '';
		}
		
		// gh#122
		public function sendWelcomeEmail(course:XML, groupID:Number):AsyncToken {
			return new RemoteDelegate("sendWelcomeEmail", [ course, groupID ], this).execute();
		}

		// gh#91
		public function get isEditable():Boolean {
			return _editable;	
		}
		public function get isOwner():Boolean {
			return _role == Course.ROLE_OWNER;	
		}
		public function get isCollaborator():Boolean {
			return _role == Course.ROLE_COLLABORATOR;	
		}
		public function get isPublisher():Boolean {
			return _role == Course.ROLE_PUBLISHER;	
		}
		public function setPermission(permission:XMLList):void {
			if (permission) {
				if (permission.hasOwnProperty("@role"))
					_role = int(permission.@role);
				if (permission.hasOwnProperty("@editable"))
					_editable = (permission.@editable == "true") ? true : false;
			}
		}
		public function get isPreviewMode():Boolean {
			return _previewMode;
		}
		public function set isPreviewMode(mode:Boolean):void {
			if (_previewMode != mode)
				_previewMode = mode;
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void {
			switch (operation) {
				case "courseCreate":
					sendNotification(RotterdamNotifications.COURSE_CREATED, data);
					break;
				case "courseSave":
					sendNotification(RotterdamNotifications.COURSE_SAVED, data);
					break;
				case "courseDelete":
					sendNotification(RotterdamNotifications.COURSE_DELETED, data);
					break;
				case "courseSessionUpdate":
				case "sendWelcomeEmail":
					// No action
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, fault:Fault):void {
			var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
			
			sendNotification(CommonNotifications.TRACE_ERROR, operation + ": " + fault.faultString);
			
			// gh#598 Some save errors can be explained
			var thisError:BentoError = BentoError.create(fault);
			if (thisError.errorNumber == copyProxy.getCodeForId("errorSavingCourseDates") ||
				thisError.errorNumber == copyProxy.getCodeForId("errorSavingCourseToDb")) {
				sendNotification(CommonNotifications.BENTO_ERROR, BentoError.create(fault, false));
			} else {
				
				// gh#751 start a download as a precaution against failed save
				// Can I build the XML string directly into a .xml download without going through a file on the server? 
				// Can't do it directly here because Flash needs this to be a user click action
				//sendNotification(CommonNotifications.BENTO_ERROR, BentoError.create(fault, false));
				if (currentCourse) {
					var xmlString:String = currentCourse.xml.toXMLString();
					xmlString = xmlString.replace("<bento>", "<bento xmlns=\"http://www.w3.org/1999/xhtml\">");
				} else {
					xmlString = null;
				}
				sendNotification(RotterdamNotifications.COURSE_SAVE_ERROR, xmlString);
			}
		}
		
	}
}
import flash.events.Event;
import flash.events.EventDispatcher;

import mx.utils.IXMLNotifiable;

class XMLChangeWatcher extends EventDispatcher implements IXMLNotifiable {
	
	public var enabled:Boolean = true;
	
	public function xmlNotification(currentTarget:Object, type:String, target:Object, value:Object, detail:Object):void {
		if (enabled) dispatchEvent(new XMLChangeWatcherEvent(XMLChangeWatcherEvent.XML_CHANGE, type, value, detail));
	}
	
}

class XMLChangeWatcherEvent extends Event {
	
	public static var XML_CHANGE:String = "xmlChange";
	
	public var changeType:String;
	public var value:Object;
	public var detail:Object;
	
	public function XMLChangeWatcherEvent(type:String, changeType:String, value:Object, detail:Object) {
		super(type);
		
		this.changeType = changeType;
		this.value = value;
		this.detail = detail;
	}
	
	public override function toString():String {
		return formatToString("XMLChangeWatcherEvent", "changeType", "value", "detail");
	}
	
}