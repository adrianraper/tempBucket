package com.clarityenglish.bento.model {
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.system.System;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * This is used for storing system wide data.  It may be that this proxy will prove unnecessary at some point and can be removed.
	 * 
	 * @author Dave
	 */
	public class BentoProxy extends Proxy implements IProxy {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const NAME:String = "BentoProxy";
		
		private var _menuXHTML:XHTML;
		
		private var _currentExercise:Exercise;
		
		private var dirtyObj:Object;
		
		[Bindable]
		public var selectedNode:XML;
		
		public function BentoProxy() {
			super(NAME);
			
			dirtyObj = {};
		}
		
		public function reset():void {
			// #472
			if (_menuXHTML) System.disposeXML(_menuXHTML.xml);
			_menuXHTML = null;
			_currentExercise = null;
			dirtyObj = {}; // gh#90
		}
		
		/**
		 * This gets the currently playing menu xml file
		 * 
		 * @return 
		 */
		public function get menuXHTML():XHTML {
			return _menuXHTML;
		}
		
		public function set menuXHTML(value:XHTML):void {
			if (_menuXHTML === value) return;
			
			if (_menuXHTML != null && value != null)
				throw new Error("Bento does not support multiple menu.xml files in a single execution");
			
			log.debug("Set menuXHTML in BentoProxy");
			
			_menuXHTML = value;
		}
		
		/**
		 * Shorthand to get the xml for the menu node of the full xhtml
		 * #338
		 */
		public function get menu():XML {
			return (_menuXHTML) ? _menuXHTML.head.script.(@id == "model" && @type == "application/xml").menu[0] : null;
		}
		
		/**
		 * This gets the exercise the user is currently in.  If there is no exercise (i.e. the user is not currently in an exercise) this will
		 * return null.
		 * 
		 * @return 
		 */
		public function get currentExercise():Exercise {
			return _currentExercise;
		}
		
		public function set currentExercise(value:Exercise):void {
			if (_currentExercise != null && value != null)
				throw new Error("Bento does not currently support running multiple exercises at the same time");
			
			_currentExercise = value;
		}
		
		/**
		 * This gets the exercise node in the menu xml matching the exercise the user is currently in.  If there is no exercise
		 * (i.e. the user is not currently in an exercise) this will return null.
		 * 
		 * @return 
		 */
		public function get currentExerciseNode():XML {
			if (!menuXHTML) {
				log.error("Attempt to use current exercise when there is no menu xml");
				return null;
			}
			
			if (!currentExercise) {
				log.error("Attempt to use current exercise when there is no current exercise");
				return null;
			}
			
			var copyProxy:CopyProxy;
			
			// Locate the exercise node in menuXHTML for currentExercise by matching the hrefs
			var matchingExerciseNodes:XMLList = menu..exercise.(@href == currentExercise.href.filename);
			if (matchingExerciseNodes.length() > 1) {
				copyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
				throw copyProxy.getBentoErrorForId("errorMultipleExerciseWithSameHref", { href: currentExercise.href });
			} else if (matchingExerciseNodes.length() == 0) {
				copyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
				throw copyProxy.getBentoErrorForId("errorCantFindExerciseWithHref", { href: currentExercise.href });
			}
			
			return matchingExerciseNodes[0];
		}
		
		public function get currentUnitNode():XML {
			return currentExerciseNode.parent();
		}
		
		public function get currentCourseNode():XML {
			return currentUnitNode.parent();
		}
		
		public function get currentMenuNode():XML {
			return currentCourseNode.parent();
		}
		
		public function get currentGroupNode():XML {
			if (!currentExerciseNode.hasOwnProperty("@group"))
				return null;
			
			var matchingGroups:XMLList = currentCourseNode.groups[0].group.(@id == currentExerciseNode.@group);
			return (matchingGroups.length() == 1) ? matchingGroups[0] : null;
		}
		
		public function getNextExerciseNode():XML {
			return getExerciseNodeWithOffset(1);
		}
		
		public function getPreviousExerciseNode():XML {
			return getExerciseNodeWithOffset(-1);
		}
		
		public function getExerciseNodeWithOffset(offset:int):XML {
			var otherExerciseNode:XML;
			
			// Keep going through potential exercises until we find one with Exercise.linkExerciseInMenu  or we reach !(parentMatch && groupMatch) - the end of the section
			while (!(parentMatch && groupMatch)) {
				// If the offset is less than 0 then we can't find a match
				if (currentExerciseNode.childIndex() + offset < 0)
					return null;
				
				otherExerciseNode = currentExerciseNode.parent().children()[currentExerciseNode.childIndex() + offset];
				
				// If there is no matching node then we can't find a match
				if (!otherExerciseNode)
					return null;
				
				var parentMatch:Boolean = (currentExerciseNode.parent() === otherExerciseNode.parent());
				var groupMatch:Boolean = (!currentExerciseNode.hasOwnProperty("@group") && !otherExerciseNode.hasOwnProperty("@group")) || (currentExerciseNode.@group == otherExerciseNode.@group);
				
				// If this exercise is valid to link to, then return it
				if (parentMatch && groupMatch && Exercise.linkExerciseInMenu(otherExerciseNode))
					return otherExerciseNode;
				
				// Increase the magnitude of the offset by one and try again
				offset += (offset / Math.abs(offset));
			}
			
			return null;
		}
		
		/**
		 * We need UID of the current exercise.
		 * @return 
		 * 
		 */
		public function getCurrentExerciseUID():String {
			if (!currentExercise) {
				log.error("Attempt to use current exercise UID when there is no current exercise");
				return "";
			}
			
			var eid:String = currentExerciseNode.@id;			
			var uid:String = currentUnitNode.@id;			
			var cid:String = currentCourseNode.@id;			
			var pid:String = currentMenuNode.@id;
			
			return pid + "." + cid + "." + uid + "." + eid;
		}
		
		/**
		 * Get the UID of any exercise from its href
		 * @return 
		 * 
		 */
		public function getExerciseUID(href:Href):String {
			if (!href) {
				log.error("Attempt to get exercise UID from an empty href");
				return "";
			}

			var matchingExerciseNodes:XMLList = menu..exercise.(@href == href.filename);
			if (matchingExerciseNodes.length() > 1) {
				throw new Error("Found multiple Exercise nodes in the menu xml matching " + href);
			} else if (matchingExerciseNodes.length() == 0) {
				throw new Error("Unable to find any Exercise nodes in the menu xml matching " + href);
			}

			var thisNode:XML = matchingExerciseNodes[0];
			
			var eid:String = thisNode.@id;			
			var uid:String = thisNode.parent().@id;			
			var cid:String = thisNode.parent().parent().@id;			
			var pid:String = thisNode.parent().parent().parent().@id;
			
			return pid + "." + cid + "." + uid + "." + eid;
		}
		
		/**
		 * gh#90, gh#182, #224 - set the 'type' as dirty.  This will cause a popup 'Are you sure' type message to popup when shutting the browser.
		 * 
		 * @param type
		 */
		public function setDirty(type:String):void {
			dirtyObj[type] = true;
			log.info("Set dirty: " + type);
		}
		
		/**
		 * gh#90, gh#182, #224 - set the 'type' as clean.  This will cause a popup 'Are you sure' type message to popup when shutting the browser.
		 * 
		 * @param type
		 */
		public function setClean(type:String):void {
			delete dirtyObj[type];
			log.info("Set clean: " + type);
		}
		
		public function get isDirty():Boolean {
			for (var type:String in dirtyObj)
				return true;
			
			return false;
		}
		
		public function getDirtyMessage():String {
			var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
			for (var type:String in dirtyObj)
				return copyProvider.getCopyForId(type + "Dirty");
			
			return null;
		}
		
	}
	
}