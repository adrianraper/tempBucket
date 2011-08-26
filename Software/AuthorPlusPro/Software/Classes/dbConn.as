/*
this class fires queries in XML:
<query>
	<node>value</node>
</query>
*/

import Classes.dbResponse;
import Classes.mdmDbConnClass;

class Classes.dbConn extends XML {
	
	var dbHost:String;
	var dbPath:String;	// v6.4.1.2, DL: dbPath for Access database
	var dbScore:String;	// v6.4.1.2, DL: dbScore for score database used with FSP
	var scripting:String;	// v6.5.4.7
	var queryPurpose:String;
	
	var _dbServerPath:String;
	var queryPath:String;
	
	// 6.4.1.2, DL: local or use server
	var __server:Boolean;
	
	// v6.4.1.2, DL: create an mdmActionRunClass object
	var mdmDbConn:mdmDbConnClass;
	
	function dbConn() {
		dbHost = _global.NNW.paths.dbHost;
		dbPath = _global.NNW.paths.dbPath;
		dbScore = _global.NNW.paths.dbScore;
		scripting = _global.NNW.paths.scripting;
		queryPurpose = "";
		
		_dbServerPath = _global.NNW.paths.sqlServerPath;
		
		__server = _global.NNW.__server;
		mdmDbConn = new mdmDbConnClass();
	}

	function myTrace(s:String) : Void {
		_global.myTrace(s);
	}
	
	function formQuery(obj:Object) : Void {
		if (__server) {
			removeAllNodes();
			var queryNode:XMLNode = this.createElement("query");
			this.appendChild(queryNode);
			for (var i in obj) {
				var objNode:XMLNode = this.createElement(i);
				var objValue:XMLNode = this.createTextNode(obj[i]);
				objNode.appendChild(objValue);
				queryNode.appendChild(objNode);
			}
			myTrace("(dbConn) - Query XML = "+this.firstChild.toString());
		} else {
			//myTrace("(dbConn) - inside formQuery else branch");
			delete mdmDbConn;
			mdmDbConn = new mdmDbConnClass();
			mdmDbConn.dbScore = dbScore;
			mdmDbConn.queryPurpose = queryPurpose;
			for (var attr in obj) {
				mdmDbConn[attr] = obj[attr];
			}
		}
	}
	
	function sendQuery() : Void {
		//myTrace("(dbConn) - inside sendQuery");
		// v6.4.1.2, DL: use FSP for network connection
		if (__server) {
			//myTrace("(dbConn) - inside sendQuery if__server");
			var dbResponse = new dbResponse();
			dbResponse.queryPurpose = queryPurpose;
			
			// v6.4.1.2, DL: handle both scripting language (ASP/PHP)
			// refresh the _dbServerPath to ensure it has been updated after reading the licence
			_dbServerPath = _global.NNW.paths.sqlServerPath;
			// default as ASP as the moment
			// v6.5.4.7 Scripting is independent of database now
			//var scripting = _parent.licence.scripting.toLowerCase();
			myTrace("sendQuery to scripting=" + scripting); 
			//if (_dbServerPath.substr(-5, 5).toUpperCase()=="MYSQL") {
			//	var queryPath:String = _dbServerPath+"/APLQuery.php";
			//} else {
			//	var queryPath:String = _dbServerPath+"/APLQuery.asp";
			//}
			var queryPath:String = _dbServerPath+"/APLQuery." + scripting;
			
			// v6.4.1.2, DL: for Access database, use dbPath instead of dbHost
			if (_dbServerPath.substr(-6, 6).toUpperCase()=="ACCESS") {
				this.sendAndLoad(queryPath+"?prog=NNW&dbPath="+dbPath, dbResponse);
				myTrace("(dbConn) - "+queryPath+"?prog=NNW&dbPath="+dbPath);
			} else {
				this.sendAndLoad(queryPath+"?prog=NNW&dbHost="+dbHost, dbResponse);
				myTrace("(dbConn) - "+queryPath+"?prog=NNW&dbHost="+dbHost);
			}
		} else {
			//myTrace("(dbConn) - inside sendQuery else branch");
			mdmDbConn.sendQuery();
		}
	}
	
	/* remove all nodes in this */
	function removeAllNodes() : Void {
		if (this.hasChildNodes()) {
			for (var i in this.childNodes) {
				this.childNodes[i].removeNode();
			}
		}
	}
	
	//v6.4.3 Also need to pass rootID
	// v6.5.4.6 and licence ID
	//function checkLogin(u:String, p:String, r:Number) : Void {
	function checkLogin(u:String, p:String, r:Number, l:Number) : Void {
		queryPurpose = "checkLogin";
		//debug mode
		//u = "Teacher";
		//p = "ClarityRM";
		_global.myTrace("(dbConn) - checkLogin:rootID=" + r + " username=" + u);
		formQuery({purpose:queryPurpose, username:u, password:p, rootID:String(r), licenceID:String(l)});
		sendQuery();
	}
	
	/* v0.7.2, DL: get encryption decrypt key */
	function getDecryptKey() : Void {
		queryPurpose = "getDecryptKey";
		formQuery({purpose:queryPurpose, eKey:_global.NNW._encryptKey});
		sendQuery();
	}
	
	// v6.5.5.3 get licence details from the database
	function getLicenceDetails(p:String) : Void {
		_global.myTrace("(dbConn) - getLicenceDetails:prefix=" + p);
		queryPurpose = "getLicenceDetails";
		formQuery({purpose:queryPurpose, prefix:p});
		sendQuery();
	}
	

	//v6.4.4, RL: check MGS is enable or not.
	// AR v6.4.2.6 Check with userID rather than name
	//function checkMGS(u:String) :Void {
	function checkMGS(userID:Number) :Void {
		//myTrace("(dbConn) - inside checkEnableMGS, username ="+u);
		queryPurpose = "checkMGS";
		//_global.myTrace("(dbConn) - checkMGS:username=" + u);
		//formQuery({purpose:queryPurpose, username:u});
		_global.myTrace("(dbConn) - checkMGS:userID=" + userID);
		formQuery({purpose:queryPurpose, userID:userID});
		sendQuery();
	}

	//v6.4.4, RL: check MGS and get MGS now in 1 go, so this is not use anymore
	/*
	function getMGS(u:String) :Void {
		//myTrace("(dbConn) - inside getEnableMGS");
		queryPurpose = "getMGS";
		formQuery({purpose:queryPurpose, username:u});
		sendQuery();
	}
	*/

	function updateEditedContent(UID:String, eF:Number) : Void {
		queryPurpose = "updateEditedContent";
		_global.myTrace("(dbConn) - updateEditedContent:UID=" + UID + " enabledFlag=" + eF);
		formQuery({purpose:queryPurpose, UID:UID, eF:eF});
		sendQuery();
	}
}