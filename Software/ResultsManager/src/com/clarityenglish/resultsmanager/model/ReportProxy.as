/*
Proxy - PureMVC
*/
package com.clarityenglish.resultsmanager.model {
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONEncoder;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.Reportable;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.Manageable;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.resultsmanager.ApplicationFacade;
	import com.clarityenglish.resultsmanager.Constants;
	import com.clarityenglish.resultsmanager.RMNotifications;
	import com.clarityenglish.utils.TraceUtils;
	
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.utils.ArrayUtils;
	import org.davekeen.utils.ClassUtils;
	import org.davekeen.utils.DateUtils;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * A proxy
	 */
	public class ReportProxy extends Proxy implements IProxy, IDelegateResponder {
		
		public static const NAME:String = "ReportProxy";

		private static var dummyReportable:Reportable;
		
		public function ReportProxy(data:Object = null) {
			super(NAME, data);
			
		}
		
		public function getReport(forReportables:Array, forClass:String, onReportables:Array, opts:Object, template:String="standard"):void {
			var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
			//TraceUtils.myTrace("reportProxy.getReport opts.detailedReport=" + opts.detailedReport);
			
			// Derive the on reportable class
			var onClass:String = ClassUtils.getClassAsString(onReportables[0]) as String;
			
			// Create the report header. You can pretty much put what you want in here.
			var headers:Object = new Object();
			
			// Make a string of all onReportable names. ie selected groups or users or content
			// This pretty much works the same for both types of report.
			//TraceUtils.myTrace("onReportables=" + onReportables.toString());
			headers.onReport = onReportables.map(
					function(reportable:Reportable, index:int, array:Array):String { 
						//TraceUtils.myTrace(reportable.reportableLabel);
						// It would be nice to add in the studentID here (although it makes this function less neat)
						// IF the onClass = User
						// AND opts.includeStudentID is true
						if (onClass == "User" && opts.includeStudentID) {
							return reportable.reportableLabel + " - " + (reportable as User).studentID; 
						} else {
							return reportable.reportableLabel; 
						}
					} ).join(", ");
			headers.onReportLabel = (template == "DPTSummary") ? "Report" : onClass + "(s)";
			
			// Build up header for the forReports. This is reportClass based.
			// If onClass is manageable, then I will want to list the title, course, unit from forClass
			// If onClass is reportable, then I will want to list the group from forClass
			// If you select courses, I want to list the title(s) as part of the string.
			// I suppose if I select units I should add the title and the course.
			if (onReportables[0] is Manageable) {
				// Build as many headings as you need
				var titleArray:Array = new Array();
				var courseArray:Array = new Array();
				var detailArray:Array = new Array();
				// go through the list of reportables and pick up the titles and courses involved (need units?)
				// the map feature doesn't work well as some items will NOT have a detail, we end up with empty commas
				// so switch to regular loop
				/*
				headers.forReportDetail = forReportables.map(
					function(reportable:Reportable, index:int, array:Array):String { 
						// AR Both these methods work to find the title id, the second involves less processing
						//var titleID:Number = reportable.toIDObject()["Title"];
						//var titleID:Number = reportable.uid.split(".")[0];
						titleArray.push(reportable.toCaptionObject()["Title"]);
						if (forClass != "Title") {
							courseArray.push(reportable.toCaptionObject()["Course"]);
						}
						// I only want details for manageables lower than course.
						if (forClass == "Unit" || forClass == "Exercise") {
							return reportable.reportableLabel; 
						} else {
							return undefined;
						}
					} ).join(", ");
				*/
				for each (reportable in forReportables) {
					// AR Both these methods work to find the title id, the second involves less processing
					//var titleID:Number = reportable.toIDObject()["Title"];
					//var titleID:Number = reportable.uid.split(".")[0];
					titleArray.push(reportable.toCaptionObject()["Title"]);
					// gh#1424 Add licence use report
					if (forClass != "Title" || forClass != "Licence")
						courseArray.push(reportable.toCaptionObject()["Course"]);
					
					// I only want details for manageables lower than course.
					if (forClass == "Unit" || forClass == "Exercise")
						detailArray.push(reportable.reportableLabel); 
				}
				headers.forReportDetail = detailArray.join(", ");
				
				headers.forReportLabel = forClass + " details"; // Note that this is the name of the literal, it will be looked up later. No it won't!
				headers.titles = ArrayUtils.removeDuplicates(titleArray).join(", ");
				if (courseArray.length>0) {
					headers.courses = ArrayUtils.removeDuplicates(courseArray).join(", ");
				} else {
					delete headers.courses;
				}
				
			} else {
				// ctp#198
				if (template == "DPTSummary") {
					var tempTests:Array = new Array();
					for each (reportable in forReportables) {
						if (ClassUtils.getClassAsString(reportable) as String == "ScheduledTest")
							tempTests.push(reportable.reportableLabel);
					}
					headers.forReportDetail = tempTests.join(", ");
					headers.forReportLabel = copyProvider.getCopyForId("reportForReportLabel");
				} else {
					headers.forReportDetail = forReportables.map(function(reportable:Reportable, index:int, array:Array):String { 
						return reportable.reportableLabel; } ).join(", ");
					headers.forReportLabel = forClass + "(s)"; // Note that this is the name of the literal, it will be looked up later. No it won't!
				}
			}
			
			// Format the date range nicely
			var dateRange:String = (opts.fromDate) ? "From " + DateUtils.formatDate(opts.fromDate, "D MMM YYYY") + " " : "";
			dateRange += (opts.toDate) ? ((opts.fromDate) ? " to " : "To ") + DateUtils.formatDate(opts.toDate, "D MMM YYYY") : "";
			// Ticket #95 - don't respect local timezones so change the dates into an ANSI string (the server expects to be passed these)
			if (opts.fromDate) opts.fromDate = DateUtils.dateToAnsiString(opts.fromDate);
			if (opts.toDate) opts.toDate = DateUtils.dateToAnsiString(opts.toDate);
			headers.dateRange = dateRange;
			
			// Say what type of attempt filtering we are using. Where do we actually put this in?
			if (opts.attempts)
			    headers.attempts = copyProvider.getCopyForId(opts.attempts + "Attempts");
			
			opts.headers = headers;
			
			// ctp#388
			opts.timezoneOffset = new Date().getTimezoneOffset();
			
			// If the forReportables are Title then replace them with their sub courses as titles don't really exist
			// gh#1424 TODO But we DO want a title summary report - for TB, AR, R2I etc it will be useful
			if (forClass == "Title") {
				var courseReportables:Array = new Array();
				for each (var title:Title in forReportables)
					courseReportables = courseReportables.concat(title.children);
					
				forReportables = courseReportables;
				// Also remove the headers.titles as it will be the same as headers.content
				// I don't think it matters to remove it after it is assigned to opts as still the same object.
				//headers.titles = undefined;
			}
			
			// If the onReportables are Title then replace them with their sub courses as titles don't really exist
			if (onClass == "Title") {
				courseReportables = new Array();
				for each (title in onReportables)
					courseReportables = courseReportables.concat(title.children);
					
				onReportables = courseReportables;
			}
			
			// Get the for reportable JSON ID trees
			var forReportablesIDObjects:Array = new Array();
			for each (var reportable:Reportable in forReportables) {
				forReportablesIDObjects.push(reportable.toIDObject());				
			}
			//trace("forReportablesIDObjects[0] "+ forReportablesIDObjects[0].Unit);	
			
			// Get the on reportable JSON ID trees
			var onReportablesIDObjects:Array = new Array();
			for each (reportable in onReportables)
				onReportablesIDObjects.push(reportable.toIDObject());
			
			var urlRequest:URLRequest = new URLRequest(Constants.AMFPHP_BASE + "services/GenerateReport.php");
			urlRequest.method = Constants.URL_REQUEST_METHOD;
			
			var postVariables:URLVariables = new URLVariables();
			postVariables.nocache = Math.floor(Math.random() * 999999);
			postVariables.forReportablesIDObjects = JSON.encode(forReportablesIDObjects);
			postVariables.forClass = forClass;
			postVariables.onReportablesIDObjects = JSON.encode(onReportablesIDObjects);
			postVariables.onClass = onClass;
			postVariables.opts = JSON.encode(opts);
			// I could include the template that I want here
			postVariables.template = template;
			
			urlRequest.data = postVariables;
								
			navigateToURL(urlRequest, "_blank");
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void {
			switch (operation) {
				case "getReport":
					trace(data);
					sendNotification(RMNotifications.REPORT_GENERATED, data);
					break;
				default:
					trace(data);
					//trace("Return from unknown operation " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, data:Object):void{
			if (data as String == 'errorLostAuthentication') {
				sendNotification(CommonNotifications.AUTHENTICATION_ERROR, "You have been timed out. Please sign in again to keep working.");	
			} else {
				sendNotification(CommonNotifications.TRACE_ERROR, operation + ": " + data);
			}
		}
		
	}
}