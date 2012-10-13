/*
Proxy - PureMVC
*/
package com.clarityenglish.rotterdam.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.vo.Course;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.Fault;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
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
		
		private var _currentCourse:XHTML;
		
		private var _currentUnit:XML;
		
		private var _unitCollection:ListCollectionView;
		private var _widgetCollection:ListCollectionView;
		
		public function CourseProxy(data:Object = null) {
			super(NAME, data);
		}
		
		public function get currentCourse():XHTML {
			return _currentCourse;
		}

		public function set currentCourse(value:XHTML):void {
			_currentCourse = value;
			
			_unitCollection = new XMLListCollection(courseNode.unit);
		}
		
		private function get courseNode():XML {	
			return _currentCourse.selectOne("script#model[type='application/xml'] course");
		}
		
		public function get unitCollection():ListCollectionView {
			return _unitCollection;
		}
		
		public function get currentUnit():XML {
			return _currentUnit;
		}
		
		public function set currentUnit(value:XML):void {
			_currentUnit = value;
			
			_widgetCollection = new XMLListCollection(value.*);
		}
		
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
		
		public function courseCreate(course:Course):void {
			new RemoteDelegate("courseCreate", [ course ], this).execute();
		}
		
		public function courseSave():void {
			if (currentCourse) {
				new RemoteDelegate("courseSave", [ currentCourse.href.filename, currentCourse.xml ], this).execute();
			} else {
				log.error("Attempted to save when there was no currentCourse set");
			}
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void {
			switch (operation) {
				case "courseCreate":
					sendNotification(RotterdamNotifications.COURSE_CREATED);
					break;
				case "courseSave":
					sendNotification(RotterdamNotifications.COURSE_SAVED);
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, fault:Fault):void {
			sendNotification(CommonNotifications.TRACE_ERROR, operation + ": " + fault.faultString);
		}
	
	}
}
