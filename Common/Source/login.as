//List of methods that the module will react to when called by the controller
loginNS.getProgressObject = function() {
	// the progress object will hold a record for each exercise that the user has done
	// it will just take the last score if 1 exercise has been done more than once.
	// Note: realistically, how many duplicate records will there be, in which case I should
	// either save memory and not store the records at all, or should save time and hold them
	// all in memory all the time!
	// For now, I will read all records.
	// Once you have read the score records, you then loop through the scaffold and
	// mark down each one that has been completed.
	// Then you go through the scaffold again and calculate a % complete for each higher level
	var thisProgress = new progressObject();
	thisProgress.load();
	thisProgress.onLoad = function(success) {
		if (success) {
			myTrace("progress has been found");
			var returnCode = true;
			// 6.0.2.0 remove connections
			//sender = new LocalConnection();
			//sender.send("controlConnection", "setProgressObject", this);
			//delete sender;
			_global.ORCHID.root.controlNS.setProgressObject(this);
		}
	}
}
loginNS.startSession = function() {
	addSession();
}
// 6.0.5.0 Key function for regularly telling the licence control database
// that this user is still running strong and hearty
loginNS.holdLicence = function() {
	_global.ORCHID.session.holdLicence();
}
// keep the interval ID so that it can be killed when refreshing or exiting
// v6.5.5.1 Why not hold this much more often, then you can be more responsive to old licences
//loginNS.licenceHoldTime = 600000; // measured in milli-seconds (600,000 = 10 minutes)
loginNS.licenceHoldTime = 60000; // measured in milli-seconds (60,000 = 1 minute)
// the interval is actually triggered once the user is properly logged in
