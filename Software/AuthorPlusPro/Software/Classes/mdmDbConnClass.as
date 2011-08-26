import Classes.actionResponse;
//import Classes.xmlCourseClass;

// v6.4.3 I can't see this would be needed?
//class Classes.mdmDbConnClass extends XML {
class Classes.mdmDbConnClass {

	var control:Object;
	var dbScore:String;
	var queryPurpose:String;
	
	// query parameters
	var username:String;
	var userID:Number;
	var rootID:Number;
	var password:String;
	
	// interval id
	//var intID:Number;
	// loop counter (don't let it try more than 5 times)
	//var cnt:Number;
	//var maxTrial:Number;
	
	//v6.4.3 Running with mdmScript 2.0
	var mdm:Object;
	
	function mdmDbConnClass() {
		
		mdm = _global.mdm; // mdm script 2
		
		control = _global.NNW.control;
		dbScore = "";
		queryPurpose = "";
		
		//maxTrial = 5;
	}

	function myTrace(s:String) : Void {
		_global.myTrace(s);
	}
	
	function sendQuery() : Void {
		_global.myTrace("mdm.sendQuery=" + this.queryPurpose);
		// for debugging
		//mdm.Exception.disableHandler();

		// connect to db
		
		// v6.4.2.3 Add password protection for the database.
		// Can it be set somewhere else and (if set) used here? In order to avoid changing as little
		// other code as possible (and hiding it), we could assume that you are running network version
		// and it is passed as a parameter from ZINC. I don't think is seeable by anyone.
		// No point at all - might as well force it until you can read from licence or whereever.
		var usePassword = _root.dbPassword;
		if (usePassword != undefined) {
			myTrace("use dbPassword " + usePassword);
			// v6.4.3 mdm script 2
			//_root.mdm.connecttodb_abs(control.paths.dbScore, usePassword);
		} else {
			usePassword = "ClarityDB";
			//_root.mdm.connecttodb_abs(control.paths.dbScore);
		}
		// v6.4.3 Allow MySQL
		if (control.login.licence.database.toLowerCase() == "mysql") {
			myTrace("connect to MySQL");
			var MySQLhost = "localhost"; 
			var MySQLport = ""; // If left empty, this will default to 3306 
			var MySQLcompression = "true"; // Set to false to disable transfer compression 
			var MySQLusername = "network";
			var MySQLpassword = "clarity"; // Note that this user has to have an old style password if MySQL 5 is used.
			// MySQL> SET PASSWORD FOR 'network'@'localhost' = OLD_PASSWORD('newpwd');
			var MySQLdbname = "score"; 
			var success = mdm.Database.MySQL.connect(MySQLhost,MySQLport,MySQLcompression,MySQLusername,MySQLpassword,MySQLdbname); 
			var isConnected = mdm.Database.MySQL.isConnected();
		} else {
			control.paths.dbScore = _global.addSlash(control.paths.dbPath)+"score.mdb";
			myTrace("connect to Access, " + control.paths.dbScore);
			// It seems that connecting as read only fails if anyone else already has the database open at all - wheras regular doesn't!
			//mdm.Database.MSAccess.connectReadOnlyAbs(control.paths.dbScore, usePassword);
			mdm.Database.MSAccess.connectAbs(control.paths.dbScore, usePassword);
			var isConnected = mdm.Database.MSAccess.success();
		}
		if (isConnected) {
			myTrace("connected to " + control.login.licence.database.toLowerCase());
		} else {
			myTrace("not connected to " + control.login.licence.database.toLowerCase());
		}
		
		switch (queryPurpose) {
		case "checkLogin" :
			//myTrace("check login by FSP database connection");
			//myTrace("dbScore: "+dbScore);
			//var sql = "SELECT * FROM T_User WHERE F_Username='"+username+"' AND (F_UserType=1 OR F_UserType=2)";
			// v6.4.2.5 The query passes back more now
			//var sql = "SELECT F_Password FROM T_User WHERE F_Username='"+username+"' AND F_UserType>0";
			// v6.4.2.6 Add userID
			//var sql = "SELECT F_Password, F_UserName, F_Email, F_UserSettings FROM T_User WHERE F_UserName='"+username+"' AND (F_UserType=1 OR F_UserType=2)";
			var sql = "SELECT F_Password, F_UserName, F_UserID, F_Email, F_UserSettings FROM T_User WHERE F_UserName='"+username+"' AND (F_UserType=1 OR F_UserType=2);";
			//var sql = "SELECT F_Password, F_UserName, F_UserID, F_Email, F_UserSettings FROM T_User WHERE F_UserName='"+username+"';";
			myTrace(sql);
			// v6.4.3 mdm script 2
			//_root.mdm.selectfromdb(sql);
			// v6.4.3 Allow MySQL
			if (control.login.licence.database.toLowerCase() == "mysql") {
				var querySuccess = mdm.Database.MySQL.runQuery(sql.split(",").join("@c@"));
				if (querySuccess == "false") {
					var errorDetails = mdm.Database.MySQL.getLastError();
					myTrace("db error details: "+errorDetails);
				}
			} else {
				mdm.Database.MSAccess.select(sql.split(",").join("@c@"));
				// v6.4.2.5 .error returns false if NO ERROR
				//if (mdm.Database.MSAccess.error()){
				if (!mdm.Database.MSAccess.error()){
					var errorDetails = mdm.Database.MSAccess.errorDetails();
					myTrace("db error details: "+errorDetails);
				}
			}
			// set field name & field row to be retreived
			//_root.db_fieldName = "F_Password";
			//_root.db_fieldRow = "0";
			break;
		// v6.4.2.5 Check MGS
		case "checkMGS" :
			//myTrace("check MGS by FSP database connection");
			// Does this user's group have MGS set?
			//v6.4.2.6 Use UserID rather than name
			//var sql = "SELECT F_EnableMGS, F_MGSName, T_Groupstructure.F_GroupParent from T_Groupstructure, T_Membership, T_User " +
			//		" WHERE T_User.F_Username='"+username+"'"+
			//		" AND T_User.F_UserID=T_Membership.F_UserID AND T_Membership.F_GroupID=T_Groupstructure.F_GroupID;";
			var sql = "SELECT F_EnableMGS, F_MGSName, F_GroupParent from T_Groupstructure, T_Membership " +
					" WHERE T_Membership.F_UserID="+userID+
					" AND T_Membership.F_GroupID=T_Groupstructure.F_GroupID;";
			myTrace(sql);
			// v6.4.3 Allow MySQL
			if (control.login.licence.database.toLowerCase() == "mysql") {
				var querySuccess = mdm.Database.MySQL.runQuery(sql.split(",").join("@c@"));
				if (querySuccess == "false") {
					var errorDetails = mdm.Database.MySQL.getLastError();
					myTrace("db error details: "+errorDetails);
				}
			} else {
				mdm.Database.MSAccess.select(sql.split(",").join("@c@"));
				// v6.4.2.5 .error returns false if NO ERROR
				//if (mdm.Database.MSAccess.error()){
				if (!mdm.Database.MSAccess.error()){
					var errorDetails = mdm.Database.MSAccess.errorDetails();
					myTrace("db error details: "+errorDetails);
				}
			}
			break;
		}
		
		
		// initialize counter
		//cnt = 0;
		// start waiting for results
		//clearInterval(intID);
		//_root.db_recordCount = undefined;
		//_root.db_result = undefined;
		
		// v6.4.3 You don't need to do it like this anymore, just read the results
		//intID = setInterval(this, "getResults", 100);
		this.getResults();
	}
	// v6.4.2.5 Used to find the MGS
	function getMGSOfParent(groupID) : Void {
		var sql = "SELECT F_EnableMGS,F_MGSName,F_GroupParent,F_GroupID " +
			"FROM T_Groupstructure " +
			" WHERE F_GroupID="+groupID+";";
		myTrace(sql);
		// v6.4.3 Allow MySQL
		if (control.login.licence.database.toLowerCase() == "mysql") {
			var querySuccess = mdm.Database.MySQL.runQuery(sql.split(",").join("@c@"));
			if (querySuccess == "false") {
				var errorDetails = mdm.Database.MySQL.getLastError();
				myTrace("db error details: "+errorDetails);
			}
		} else {
			mdm.Database.MSAccess.select(sql.split(",").join("@c@"));
			// v6.4.2.5 .error returns false if NO ERROR
			//if (mdm.Database.MSAccess.error()){
			if (!mdm.Database.MSAccess.error()){
				var errorDetails = mdm.Database.MSAccess.errorDetails();
				myTrace("db error details: "+errorDetails);
			}
		}
		this.getResults();
	}
	
	function getResults() : Void {
		myTrace("check for results from db call to " + control.login.licence.database.toLowerCase());
		// v6.4.3 mdm script 2
		//_root.mdm.getrecordcount("db_recordCount");
		//_root.mdm.getfieldfromdb(_root.db_fieldName,_root.db_fieldRow,"db_result"); 
		// v6.4.3 Allow MySQL
		var dataSet:Array;
		var numberOfRows:Number;
		
		if (control.login.licence.database.toLowerCase() == "mysql") {
			_global.myTrace("mysql.getRecordCount");
			//numberOfRows = mdm.Database.MySQL.getRecordCount();
			dataSet = mdm.Database.MySQL.getData();
		} else {
			_global.myTrace("access.getRecordCount");
			//var numberOfRows = mdm.Database.MSAccess.getRecordCount();
			dataSet = mdm.Database.MSAccess.getData();
			//dataSet = new Array();
		}
		// v6.4.2.5 This looks very specific to checkLogin data return, probably need to return dataset[0]
		// or use Orchid like function to split it up.
		var numberOfRows = dataSet.length;
		myTrace("num of rows=" + numberOfRows);
		if (numberOfRows>0) {
			//if (dataSet[0].length>0) {
			//	var thisRecord = dataSet[0][0];
			//}
			var thisRecord = dataSet[0];
		} else {
			//numberOfRows = 0;
			var thisRecord = undefined;
		}
		// v6.4.2.5 This is going to get ugly, but we might need to recurse for MGS
		if (queryPurpose == "checkMGS") {
			_global.myTrace("enable=" + thisRecord[0] + " name=" + thisRecord[1] + " parent=" + thisRecord[2] + " group=" + thisRecord[3]);
			// Did we find an MGS first shot?
			if (thisRecord[0] == "1") {
				// yes - so just fall through to the formatting section
			} else {
				// no, but are we at the top of the group hierarchy? Or is there no more hierarchy (shouldn't be)
				if ((thisRecord[2] == thisRecord[3]) || thisRecord[2]==0 || thisRecord[2]==undefined || thisRecord[2]=="") {
					// yes - so just fall through to the formatting section with what we have
					myTrace("end of heirarchy search");
				} else {
					// so try the parent group and leave this function (getMGSOfParent will bring us back in)
					getMGSOfParent(thisRecord[2]);
					return;
				}
			}
		}
		// v6.4.3 No rows means that the user is not found!
		// v6.4.2.5 Pass the whole record in any case
		//if (numberOfRows<=0) {
		//	switch (queryPurpose) {
		//	case "checkLogin" :
		//		checkLogin("");
		//		break;
		//	//v6.4.2.5 checkEnableMGS case
		//	case "checkMGS":
		//		checkMGS("");
		//		break;
		//	}
		//} else {
		//	myTrace("results retrieved");
			switch (queryPurpose) {
			case "checkLogin" :
				checkLogin(thisRecord);
				break;
			//v6.4.2.5 checkEnableMGS case
			case "checkMGS":
				checkMGS(thisRecord);
				break;
			}		
		//}
		//_root.mdm.closedb();
		// v6.4.3 Allow MySQL
		if (control.login.licence.database.toLowerCase() == "mysql") {
			_global.myTrace("mysql close")
			mdm.Database.MySQL.close();
		} else {
			_global.myTrace("access close")
			mdm.Database.MSAccess.close();
		}
		/*
		//cnt++;
		//if (_root.db_recordCount==undefined && cnt>=maxTrial) {
		//if (numberOfRows==undefined && cnt>=maxTrial) {
		if (numberOfRows<=0 && cnt>=maxTrial) {
			myTrace("db connection timeout");
			switch (queryPurpose) {
			case "checkLogin" :
				checkLogin("");
				break;
			}
			clearInterval(intID);
			//_root.mdm.closedb();
			// v6.4.3 Allow MySQL
			if (control.login.licence.db.toLowerCase() == "mysql") {
				mdm.Database.MySQL.close();
			} else {
				mdm.Database.MSAccess.close();
			}
		//} else if (_root.db_result!=undefined) {
		} else if (thisRecord!=undefined) {
			myTrace("results retrieved");
			switch (queryPurpose) {
			case "checkLogin" :
				//myTrace("result = "+_root.db_result);
				//checkLogin(_root.db_result);
				checkLogin(thisRecord);
				break;
			}
			clearInterval(intID);
			//_root.mdm.closedb();
			// v6.4.3 Allow MySQL
			if (control.login.licence.db.toLowerCase() == "mysql") {
				mdm.Database.MySQL.close();
			} else {
				mdm.Database.MSAccess.close();
			}
		}
		*/
	}
	
	// query specific functions
	// It would be nice to say whether password is wrong, user doesn't exist or user is not authorised
	// v6.4.2.5 pass the whole dataset, not just one field
	//function checkLogin(pwd:String) : Void {
	function checkLogin(thisRecord:Object) : Void {
		// v6.4.2.5 You now have everything in the dataset. You have to match array positions against the SQL stmt.
		// It would be better to use getXML from mdm and then break by attribute. Do this later.
		// v6.4.2.6 Add userID as well
		if (thisRecord == undefined) {
			var v = false;
			var pwd = "";
			var name="";
			var userID=0;
			var email="";
			var settings = "0";
		} else {
			var v = true;
			var pwd = thisRecord[0];
			var name = thisRecord[1];
			// v6.4.2.6 Add userID as well
			var userID = thisRecord[2];
			//var email = thisRecord[2];
			//var settings = thisRecord[3];
			var email = thisRecord[3];
			var settings = thisRecord[4];
			// do the passwords match?
			if (pwd <> password) v=false;
			// These should not be set here, but I am copying it from dbResponse right now
			if (name!=undefined) {
				control._fullname = name;
			}
			if (email!=undefined) {
				control._emailaddress = email;
			}
		}
		myTrace("from db:name=" + name + " userID=" + userID + " settings=" + settings + "pwd=" + pwd);
		// v6.4.2.6 Use UserID rather than name
		//control.login.onCheckLogin(v, name, settings);
		control.login.onCheckLogin(v, userID, settings);
		//if (v && pwd==password) {
			//control.login.onCheckLogin(true);
		//} else {
		//	control.login.onCheckLogin(v, pwd);
		//}
		//_root.db_recordCount = undefined;
		//_root.db_result = undefined;
	}

	function checkMGS(thisRecord:Object) : Void {
		// v6.4.2.5 You now have everything in the dataset. You have to match array positions against the SQL stmt.
		// It would be better to use getXML from mdm and then break by attribute. Do this later.
		if (thisRecord == undefined) {
			var v = false;
			var enabled = "";
			var MGSName="";
		} else {
			var v = true;
			var enabled = thisRecord[0];
			var MGSName = thisRecord[1];
		}
		myTrace("from db:enabled=" + enabled + " MGSName=" + MGSName);
		control.login.onGetMGS(v, enabled, MGSName);
	}

}