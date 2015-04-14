/*
Proxy - PureMVC
*/
package com.clarityenglish.resultsmanager.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.common.vo.manageable.Manageable;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.resultsmanager.ApplicationFacade;
	import com.clarityenglish.resultsmanager.Constants;
	import com.clarityenglish.resultsmanager.RMNotifications;
	import com.clarityenglish.resultsmanager.controller.ImportManageablesCommand;
	import com.clarityenglish.resultsmanager.view.management.events.ManageableEvent;
	import com.clarityenglish.utils.TraceUtils;
	
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	
	import mx.events.PropertyChangeEvent;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	//import nl.demonsters.debugger.MonsterDebugger;
	
	/**
	 * A proxy
	 */
	public class ManageableProxy extends Proxy implements IProxy, IDelegateResponder {
		namespace embed;
		embed static var userDummy:User;
		embed static var groupDummy:Group;
		
		public static const NAME:String = "ManageableProxy";
		
		private var _manageables:Array;
		
		public function ManageableProxy(data:Object = null) {
			super(NAME, data);
			
			// v3.4 In a bid to not overload AMF or anything else, lets getContent after we have got manageables, not at the same time.
			getAllManageables();
		}
		
		public function get manageables():Array { return _manageables; }
		
		public function set manageables(value:Array):void {
			_manageables = value;
		}
		
		public function getAllManageables():void {
			new RemoteDelegate("getAllManageables", [], this).execute();
		}
		
		public function addGroup(group:Group, parent:Group):void {
			new RemoteDelegate("addGroup", [ group, parent ], this).execute();
		}
		
		public function addUser(user:User, parent:Group):void {
			//// TraceUtils.myTrace("addUser=" + user.toString());
			new RemoteDelegate("addUser", [ user, parent ], this).execute();
			// v3.4 There are three ways in which an author can appear in a group. This is one of them.
			// If the user being added is an author, I want to initialise the group for Edited Content
			if (user.userType == User.USER_TYPE_AUTHOR) {
				//MonsterDebugger.trace(this, "adding an author to " + parent.id);
				//var myGroupID:String = Constants.groupID.toString();
				// v3.5 This is the wrong path. It should be less than this.
				//var editedContentLocation:String = '../../../ap/' + Constants.prefix + '/Courses/EditedContent-' + parent.id;
				var editedContentLocation:String = '../../../ap/' + Constants.prefix;
				new RemoteDelegate("initEditedContent", [ editedContentLocation, parent.id ], this).execute();
			}
		}
		
		public function updateGroups(groups:Array):void {
			new RemoteDelegate("updateGroups", [ groups ], this).execute();
		}
		
		public function updateUsers(users:Array):void {
			//// TraceUtils.myTrace("updateUser=" + users[0].toString());
			new RemoteDelegate("updateUsers", [ users ], this).execute();
			// v3.4 There are three ways in which an author can appear in a group. This is one of them.
			// If the user being updated is changing to an author, I want to initialise the group for Edited Content
			if (users.length == 1 && users[0].userType == User.USER_TYPE_AUTHOR) {
				var parent:Group = (users[0] as User).parent as Group;
				//MonsterDebugger.trace(this, "updating an author in " + parent.id);
				// v3.5 This is the wrong path. It should be less than this.
				//var editedContentLocation:String = '../../../ap/' + Constants.prefix + '/Courses/EditedContent-' + parent.id;
				var editedContentLocation:String = '../../../ap/' + Constants.prefix;
				new RemoteDelegate("initEditedContent", [ editedContentLocation, parent.id ], this).execute();
			}
		}
		
		public function moveManageables(manageables:Array, parent:Group):void {
			new RemoteDelegate("moveManageables", [ manageables, parent ], this).execute();
			// v3.4 There are three ways in which an author can appear in a group. This is one of them.
			// If the manageable being moved is an author, I want to initialise the group for Edited Content
			for each (var manageable:Manageable in manageables) {
				//gh#170 adding manageable is user justment
				if (manageable is User) {
					if ((manageable as User).userType == User.USER_TYPE_AUTHOR) {
						//MonsterDebugger.trace(this, "moving an author into " + parent.id);
						// v3.5 This is the wrong path. It should be less than this.
						//var editedContentLocation:String = '../../../ap/' + Constants.prefix + '/Courses/EditedContent-' + parent.id;
						var editedContentLocation:String = '../../../ap/' + Constants.prefix;
						new RemoteDelegate("initEditedContent", [ editedContentLocation, parent.id ], this).execute();
						// I only needed to find one, so break now
						break;
					}
				}
			}
		}
		
		public function deleteManageables(manageablesArray:Array):void {
			new RemoteDelegate("deleteManageables", [ manageablesArray ], this).execute();
		}
		
		public function exportManageables(manageablesArray:Array):void {
			exportArchiveManageables(manageablesArray);
		}
		
		public function archiveManageables(manageablesArray:Array):void {
			exportArchiveManageables(manageablesArray, true);
		}
		
		private function exportArchiveManageables(manageablesArray:Array, archive:Boolean = false):void {
			// Normalize the array to remove duplicates
			manageablesArray = Manageable.normalizeManageables(manageablesArray);
			
			// Split the export into group and user ids
			var groupIDs:Array = new Array();
			var userIDs:Array = new Array();
			
			for each (var manageable:Manageable in manageablesArray) {
				if (manageable is Group) {
					groupIDs.push(manageable.id);
				} else {
					// v3.4 Multi-group users
					//userIDs.push(manageable.id);
					userIDs.push((manageable as User).userID);
				}
			}
			
			var urlRequest:URLRequest = new URLRequest(Constants.AMFPHP_BASE + "services/ExportXML.php");
			urlRequest.method = Constants.URL_REQUEST_METHOD;
			
			var postVariables:URLVariables = new URLVariables();
			postVariables.nocache = Math.floor(Math.random() * 999999);
			postVariables.groupIDs = groupIDs.join(",");
			postVariables.userIDs = userIDs.join(",");
			if (archive) postVariables.archive = "true";
			
			urlRequest.data = postVariables;
			
			// Call the export script
			navigateToURL(urlRequest);
		}
		
		public function importManageablesFromFile(parentGroup:Group):void {
			new RemoteDelegate("importXMLFromUpload", [ parentGroup ], this).execute();
		}
		
		// v3.6.1 Allow moving and importing
		//public function importManageables(groups:Array, users:Array, parentGroup:Group):void {
		public function importManageables(groups:Array, users:Array, parentGroup:Group, moveExistingStudents:String = ManageableEvent.IMPORT_FROM_EXCEL_WITH_MOVE):void {
			//// TraceUtils.myTrace("first user is " + users[0].name + " parent is " + parentGroup.name);
			//new RemoteDelegate("importManageables", [ groups, users, parentGroup ], this).execute();
			//// TraceUtils.myTrace("managableProxy with move=" + moveExistingStudents);
			new RemoteDelegate("importManageables", [ groups, users, parentGroup, moveExistingStudents ], this).execute();
		}
		
		public function getExtraGroups(user:User):void {
			new RemoteDelegate("getExtraGroups", [ user ], this).execute();
		}
		
		public function setExtraGroups(user:User, groups:Array):void {
			new RemoteDelegate("setExtraGroups", [ user, groups ], this).execute();
		}
		
		/* Non-server functions */
		
		/**
		 * Given an array of ids return the array of groups matching those ids.  IDs which are not found are not included in the results
		 * and if no ids are found an empty array is returned.
		 * 
		 * @param	ids
		 * @return
		 */
		public function getGroupsByIds(ids:Array):Array {
			if (!manageables)
				throw new Error("Attempt to call a non-server function on ManageableProxy before manageables was retrieved");
			
			// We need to make sure the ids array contains strings (since we now use String for id as we were getting a strange bug for larger numbers)
			ids = ids.map(function(id:Object, index:int, array:Array):String { return id.toString(); } );
			
			var groups:Array = new Array();
			
			for each (var manageable:Manageable in manageables)
				groups = groups.concat(manageable.getSubGroups(ids));
			
			return groups;
		}
		
		public function getUserTypeCounts():Array {
			if (!manageables)
				throw new Error("Attempt to call a non-server function on ManageableProxy before manageables was retrieved");
			
			// First get all the users
			var users:Array = new Array();
			for each (var manageable:Manageable in manageables)
				users = users.concat(manageable.getSubUsers());
				
			// Now go through counting
			var results:Array = new Array();
			for each (var user:User in users) {
				var userType:Number = user.userType;
				// AR Just in case the userType is very special! (DMS=-1)
				if (userType>=0) {
					if (!results[userType]) results[userType] = 0;
					results[userType]++;
				}
			}
			//// TraceUtils.myTrace("userType.results=" + results.toString());
			return results;
		}
		
		public function getExpiredUsers(parentGroups:Array = null):Array {
			// If the groups are given search within those, otherwise search within the root groups
			var groups:Array = (parentGroups) ? parentGroups : manageables;
			
			var expiredUsers:Array = new Array();
			for each (var group:Group in groups) {
				expiredUsers = expiredUsers.concat(group.getSubUsers(User.USER_TYPE_STUDENT).filter(function(user:User, idx:int, array:Array):Boolean {
					return user.isExpired();
				} ));

			}
			
			return expiredUsers;
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void {
			switch (operation) {
				case "getAllManageables":
					// Ensure that we don't have nested groups in the array
					manageables = Manageable.normalizeManageables(data as Array);
					
					sendNotification(RMNotifications.MANAGEABLES_LOADED, manageables);
					break;
				case "addGroup":
				case "addUser":
				case "deleteManageables":
				case "updateGroups":
				case "updateUsers":
				case "moveManageables":
					// v3.4 If you added an author, promoted a user to be an author, or moved an author into a new group
					// you need to init the group for Edited Content
					// Whilst addUser returns data, the other operations don't. So this might not be the best place to do it.
					// It is done in each place (addUser, moveManageables, updateUsers)
					
					// Refresh the manageables from the database
					getAllManageables();
					break;
				case "importXMLFromUpload":
				case "importManageables":
					sendNotification(RMNotifications.XML_IMPORTED, data);
					getAllManageables();
					break;
				case "getExtraGroups":
					// Get the actual Group objects from the ids before returning them
					sendNotification(RMNotifications.EXTRA_GROUPS_LOADED, getGroupsByIds(data as Array));
					break;
				case "setExtraGroups":
					break;
				case "initEditedContent":
					//MonsterDebugger.trace(this, "back after initialising for edited content");
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, data:Object):void {
			//sendNotification(ApplicationFacade.TRACE_ERROR, operation + ": " + data);
			
			// Don't show function name as this is sometimes an expected error
			sendNotification(CommonNotifications.TRACE_ERROR, data);
			
			switch (operation) {
				case "addGroup":
				case "addUser":
				case "deleteManageables":
				case "updateGroups":
				case "updateUsers":
				case "moveManageables":
					// Refresh the manageables from the database
					getAllManageables();
					break;
				case "importXMLFromUpload":
				case "importManageables":
				case "getExtraGroups":
				case "setExtraGroups":
				case "initEditedContent":
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Fault from unknown operation: " + operation);
			}
		}
		

		
	}
}