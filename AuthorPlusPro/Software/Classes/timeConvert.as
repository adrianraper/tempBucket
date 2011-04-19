class Classes.timeConvert {
	// variables
	var startLocalTime:Date;
	var startServerTime:Date;
	var dateToPad:Date;
	var diffInMilliSec:Number;

	// v6.4.2.5 You need to be able to be sure that the ID is not the same as the last one
	var lastCID:Number;	
	
	// init function
	function timeConvert() {
		startLocalTime = _global.NNW._localTime;
		//_global.myTrace("start local time = "+startLocalTime.toString());
		setStartServerTime(_global.NNW._serverTime);	// change String to Date
		//_global.myTrace("start server time = "+startServerTime.toString());
		dateToPad = startLocalTime;
		diffInMilliSec = 0;
		lastCID=0;
	}
	// function to pad zero
	private function padZeros(s:String, n:Number) : String {
		if (n>s.length) {
			for (var i=1; i<=(n-s.length); i++) {
				s = "0" + s;
			}
		}
		return s;
	}
	// private functions to get part of the padded date/time
	private function getPaddedMonth() : String {
		var m = dateToPad.getMonth() + 1;
		var s = m.toString();
		return padZeros(s, 2);
	}
	private function getPaddedDay() : String {
		var s = dateToPad.getDate().toString();
		return padZeros(s, 2);
	}
	private function getPaddedHour() : String {
		var s = dateToPad.getHours().toString();
		return padZeros(s, 2);
	}
	private function getPaddedMinute() : String {
		var s = dateToPad.getMinutes().toString();
		return padZeros(s, 2);
	}
	private function getPaddedSecond() : String {
		var s = dateToPad.getSeconds().toString();
		return padZeros(s, 2);
	}
	private function getPaddedDate() : String {
		return dateToPad.getFullYear() + getPaddedMonth() + getPaddedDay();
	}
	private function getPaddedTime() : String {
		return getPaddedHour() + getPaddedMinute() + getPaddedSecond();
	}
	// public functions to get the padded date/time
	public function getPaddedDateTime(): String {
		return getPaddedDate() + getPaddedTime();
	}
	public function getClarityUniqueID() : String {
		var r = random(999) + 1;
		return getPaddedDateTime() + padZeros(r.toString(), 3);
	}
	// set start server time variable
	private function setStartServerTime(s:String) : Void {
		if (s!=undefined) {
			startServerTime = new Date(Number(s.substr(0,4)), Number(s.substr(4,2))-1, Number(s.substr(6,2)), Number(s.substr(8,2)), Number(s.substr(10,2)), Number(s.substr(12,2)));
		} else {
			startServerTime = startLocalTime;
		}
	}
	// calculate the difference in server & local times
	public function calDiffInTime() : Void {
		var d = Number(startServerTime) - Number(startLocalTime);
		diffInMilliSec = (d!=undefined && !isNaN(d)) ? d : 0;
	}
	// convert given date to server time
	public function convertToServerTime(d:Date) : String {
		var sTime = diffInMilliSec + Number(d);
		dateToPad = new Date(sTime);
		return getPaddedDateTime();
	}
	// get current server time (String)
	public function getCurrentServerTimeStamp() : String {
		dateToPad = new Date();
		return convertToServerTime(new Date());
	}
	// get current server time (milliseconds since 1 Jan 1970 - getTime() format)
	// see getCurrentClarityUniqueID() for explanation for why getTime() is used
	// v6.4.2.5 Change to returning  a number so you can more easily manipulate it
	//public function getCurrentServerTime() : String {
	public function getCurrentServerTime() : Number {
		var currentTime = new Date().getTime();
		var serverTime = currentTime + diffInMilliSec;
		//return serverTime.toString();
		return serverTime;
	}
	// get clarity unique ID with current server time (String)
	public function getCurrentClarityUniqueID() : String {
		// v0.16.1, DL: ClarityUniqueID is found to be too long to fit in an integer field in databases
		// use getTime (milliseconds since 1 Jan 1970) instead
		/*dateToPad = new Date();
		var r = random(999) + 1;
		return convertToServerTime(new Date()) + padZeros(r.toString(), 3);*/
		
		// AR v6.4.2.5 This is not returning a unique id for the network version as it happens too quickly
		// so remember the last one and up it if it is not the same
		var thisCID:Number = getCurrentServerTime();
		if (thisCID<=lastCID) {
			//_global.myTrace("change CID from " + thisCID + " to " + (lastCID+1));
			thisCID = lastCID+1;
		}
		lastCID = thisCID;
		return thisCID.toString();
		//return getCurrentServerTime();
	}
}