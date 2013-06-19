		// ****
		// Change this variable along with the above fixed paths
		var webShare = "";
		// 
		// ****
		function thisMovie(movieName) {
			if (window.document[movieName]) {
				return window.document[movieName];
			}
			if (navigator.appName.indexOf("Microsoft Internet") == -1) {
				if (document.embeds && document.embeds[movieName])
					return document.embeds[movieName];
			} else { // if (navigator.appName.indexOf("Microsoft Internet")!=-1)
				return document.getElementById(movieName);
			}
		}
		
		function onLoad() {
			thisMovie("orchid").focus();
		}
		// *********
		// *********
		var startControl = webShare + "/Software/Common/";
		var sections = location.pathname.split("/");
		var userdatapath = sections.slice(0,sections.length-1).join("/");
		var argList="?browser=true&userDataPath=" + userdatapath + "&location=" + jsLocation;
		argList+="&prefix="+jsPrefix+"&productCode="+jsProductCode;
		argList+="&accountName="+jsAccountName;
		
		// see whether variables have come from command line or, preferentially, session variables
		// the rest can come from other kinds of integration
		var flashvars = {
			username: jsUserName,
			password: jsPassword,
			studentID: jsStudentID,
			userID: jsUserID,
			email: jsEmail,
			instanceID: jsInstanceID,
			course: queryStringCourseID,
			startingPoint: queryStringStartingPoint,
			action: swfobject.getQueryParamValue("action"),
			referrer: jsReferrer,
			server: jsServer,
			ip: jsIP,
			courseFile: jsCourseFile,
			licence: ""
		};
		// v6.5.6 For preview from RM - overwrite any other conflicting parameters
		if (swfobject.getQueryParamValue("preview")) {
			flashvars.preview = "true";
		}
			
		var params = {
			id: "orchid",
			name: "orchid",
			scale: "showall",
			menu: "false",
			allowfullscreen: "true"
		};
		// v6.5.5.6 Allow resize screen mode
		if (swfobject.getQueryParamValue("resize")=="true") {
			params.scale="showall";
		} else {
			params.scale="noScale";
		}
		var attr = {
			id: "orchid",
			name: "orchid"
		};
		var expressInstall = startControl + "expressInstall.swf";
