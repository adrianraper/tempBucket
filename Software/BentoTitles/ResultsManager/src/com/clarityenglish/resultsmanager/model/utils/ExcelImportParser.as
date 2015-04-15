package com.clarityenglish.resultsmanager.model.utils {
	import com.clarityenglish.resultsmanager.vo.manageable.Group;
	import com.clarityenglish.resultsmanager.vo.manageable.User;
	import com.gskinner.StringUtils;
	import com.clarityenglish.utils.TraceUtils;
	import nl.demonsters.debugger.MonsterDebugger;
	
	public class ExcelImportParser {
		
		/**
		 * Convert a tab-delimited list (copied and pasted from Excel) into an array of groups and an array of users ready for
		 * the remote import function.
		 * 
		 * @param	text
		 * @return
		 */
		public static function excelPasteToManageables(text:String):Object {
			var xml:XML = new XML();
			
			// Split the text into lines
			// TODO: Check on Mac!
			var lines:Array = text.split("\r");
			
			// The first line defines the headers
			var headers:Array = lines[0].split("\t");
			
			// Ensure that there is at least a username or name field in the headers (otherwise we can't import anything)
			// AR also allow ID in this role
			var validHeaders:Boolean = false;
			for each (var header:String in headers) {
				if (headerToUserField(header) == "name" || headerToUserField(header) == "studentID") {
					validHeaders = true;
					break;
				}
			}
			
			if (!validHeaders)
				throw new ExcelImportError(ExcelImportError.NO_USERNAME_HEADER);
			
			var users:Array = new Array();
			var groups:Array = new Array();
			
			// Now go through the lines building users and groups
			for (var n:uint = 1; n < lines.length; n++) {
				var data:Array = lines[n].split("\t");
				
				var user:User = new User();
				var groupName:String = null;
				
				for (var h:uint = 0; h < headers.length; h++) {
					header = headers[h];
					if (header && data[h]) {
						// AR Surely this should also be done through headerToUserField?
						// DK No - group is a heirarchial operator which embeds a new 'Group' object rather than setting a field on the current User object
						// This should not be case sensitive.
						//if (header == "group") {
						//if (StringUtils.trim(header.toLowerCase()) == "group") {
						if (headerToUserField(header) == "group") {
							groupName = data[h];
							// TraceUtils.myTrace("import: group=" + data[h]);
						} else {
							// How about translating userType from a number to string. Less likely to make mistakes?
							// TODO I expect these are constants somewhere
							if (headerToUserField(header)) {
								if (headerToUserField(header) == "userType") {
									switch (StringUtils.trim(data[h].toLowerCase())) {
										case "teacher":
											data[h] = User.USER_TYPE_TEACHER;
											break;
										case "reporter":
											data[h] = User.USER_TYPE_REPORTER;
											break;
										case "author":
											data[h] = User.USER_TYPE_AUTHOR;
											break;
										//case "learner":
										//case "student":
										//case "": // This is pointless as a blank field in Excel doesn't trigger this header row.
										default:
											data[h] = User.USER_TYPE_STUDENT;
									}
								}
								// This is going to call expiryDateAsString in user.as. Since this is coming direct from Excel (or wherever)
								// we need to step in at this point if we are going to use different formats from m/d/Y.
								// I am confident that this is only used for import.
								user[headerToUserField(header)] = data[h];
								//// TraceUtils.myTrace("import: " + headerToUserField(header) + "=" + data[h]);
							}
						}
					}
				}
				
				// If the user doesn't have a name then ignore it (this covers empty and invalid rows)
				if (user.name) {
					// v3.3 If you don't specify userType, we should default it to student (I think it happens anyway)
					if (!user.userType) 
						user.userType = User.USER_TYPE_STUDENT;

					if (groupName) {
						// This user is in a group
						// TraceUtils.myTrace("import user into " + groupName);
						if (!groups[groupName]) {
							// If the group doesn't exist (in this temporary array) create a new one
							// It will only create a real group in the back end if necessary
							var group:Group = new Group();
							group.name = groupName;
							groups[groupName] = group;
						}
						groups[groupName].children.push(user);
					} else {
						// This user is not in a group so add it to the users array
						users.push(user);
					}
				}
				
			}
			//MonsterDebugger.trace(null, users);
			// Convert groups to an indexed array instead of an associative array
			var indexedGroups:Array = new Array();
			for each (group in groups)
				indexedGroups.push(group);
			groups = indexedGroups;
			
			return { groups: groups, users: users };
		}
		
		private static function headerToUserField(header:String):String {
			switch (StringUtils.trim(header.toLowerCase())) {
				case "name":
				case "username":
				case "user name":
				case "user_name":
				case "family_name":
				case "last_name":
				case "student name":
				case "student_name":
					return "name";
				case "password":
					return "password";
				case "studentid":
				case "student id":
				case "student_id":
				case "learnerid":
				case "learner id":
				case "learner_id":
				case "id":
				case "id_no":
				case "id_number":
					return "studentID";
				case "usertype":
				case "type":
					return "userType";
				case "email":
				case "e-mail":
					return "email";
				// AR Added a new data field
				case "region":
				case "city":
					return "city";
				case "country":
					return "country";
				case "company":
				case "job":
					return "company";
				case "custom1":
				case "custom2":
				case "custom3":
				case "custom4":
					return header;
				case "expiry":
				case "expirydate":
				case "expiry_date":
				case "expiry date":
					return "expiryDateAsString";
				// v3.3 Can you bring in other data if you know what you are doing?
				case "full name":
				case "fullname":
					return "fullName";
				// v3.1 Add in variations for group name
				case "groupname":
				case "group":
				case "group name":
				case "group_name":
				case "group-name":
					return "group";
				case "birthday":
					return "birthdayAsString";
				default:
					// We want to allow unrecognised headers so don't throw an exception here (ticket #48)
					//throw new Error("Unknown header '" + header + "'");
					return null;
			}
		}
		
	}
}