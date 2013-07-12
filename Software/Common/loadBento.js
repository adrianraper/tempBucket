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
			thisMovie("bento").focus();
		}
		// *********
		// *********
		var argList="?configFile=" + jsLocation;
		argList+="&prefix=" + jsPrefix + "&productCode=" + jsProductCode;
		argList+="&version=" + jsVersion;
		
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
			startTime: jsStartTime,
			referrer: jsReferrer,
			server: jsServer,
			ip: jsIP,
			courseFile: jsCourseFile,
			licence: "",
			sessionid: jsSessionID
		};
			
		var params = {
			id: "bento",
			name: "bento",
			quality: "high",
			allowfullscreen: "true",
			scale: "showall",
			allowscriptaccess: "always"
		};
		var attr = {
			id: "bento",
			name: "bento"
		};
		var expressInstall = jsWebShare + "/Software/Common/expressInstall.swf";
