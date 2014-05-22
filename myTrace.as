_root.sendConn = new LocalConnection();
// v6.3.1 For production sites, don't build up a trace system
if (_root.noTrace == "true") {
	_global.myTrace = undefined;
	_root.sendConn.send("_trace", "myTrace", "No tracing from this site");
} else {
	_global.myTrace = function(message, level) {
		_root.sendConn.send("_trace", "myTrace", message, level);
		trace(message);
	}
}
