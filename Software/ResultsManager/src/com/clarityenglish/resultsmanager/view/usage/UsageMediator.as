/*
 Mediator - PureMVC
 */
package com.clarityenglish.resultsmanager.view.usage {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.resultsmanager.ApplicationFacade;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.resultsmanager.model.ManageableProxy;
	import com.clarityenglish.resultsmanager.model.UsageProxy;
	import com.clarityenglish.resultsmanager.RMNotifications;
	import com.clarityenglish.resultsmanager.view.shared.events.TitleEvent;
	import com.clarityenglish.common.vo.content.Course;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	import org.davekeen.utils.ArrayUtils;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import com.clarityenglish.resultsmanager.view.usage.components.*;
	import com.clarityenglish.resultsmanager.view.usage.*;
	import com.clarityenglish.utils.TraceUtils;
	
	/**
	 * A Mediator
	 */
	public class UsageMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "UsageMediator";
		
		public function UsageMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
		}
		
		/**
		 * Setup event listeners and register sub-mediators
		 */
		override public function onRegister():void {
			super.onRegister();
			
			usageView.addEventListener(TitleEvent.TITLE_CHANGE, onTitleChange);
		}
		
		private function get usageView():UsageView {
			return viewComponent as UsageView;
		}

		/**
		 * Get the Mediator name.
		 * <P>
		 * Called by the framework to get the name of this
		 * mediator. If there is only one instance, we may
		 * define it in a constant and return it here. If
		 * there are multiple instances, this method must
		 * return the unique name of this instance.</P>
		 * 
		 * @return String the Mediator name
		 */
		override public function getMediatorName():String {
			return UsageMediator.NAME;
		}
        
		/**
		 * List all notifications this Mediator is interested in.
		 * <P>
		 * Automatically called by the framework when the mediator
		 * is registered with the view.</P>
		 * 
		 * @return Array the list of Nofitication names
		 */
		override public function listNotificationInterests():Array {
			return [
					RMNotifications.USAGE_LOADED,
					CommonNotifications.COPY_LOADED,
					RMNotifications.CONTENT_LOADED,
					RMNotifications.MANAGEABLES_LOADED,
				];
		}

		/**
		 * Handle all notifications this Mediator is interested in.
		 * <P>
		 * Called by the framework when a notification is sent that
		 * this mediator expressed an interest in when registered
		 * (see <code>listNotificationInterests</code>.</P>
		 * 
		 * @param INotification a notification 
		 */
		TraceUtils.myTrace("UsageMediator");
		override public function handleNotification(note:INotification):void {
			//TraceUtils.myTrace("UsageMediator.Notification." + note.getName());
			switch (note.getName()) {
				case RMNotifications.MANAGEABLES_LOADED:
					// Get the user type counts from the ManageableProxy and set it in the view
					var manageablesProxy:ManageableProxy = facade.retrieveProxy(ManageableProxy.NAME) as ManageableProxy;
					var userTypeCounts:Array = manageablesProxy.getUserTypeCounts();
					//usageView.setUserTypeCounts( [ { type: "Students", count: userTypeCounts[User.USER_TYPE_STUDENT] },
					// AR drop the number of students from this list - unless it is total number in db? 
					// Would be nice, but trouble is that it so completely dominates the bar chart.
					// Also, we may not be using Authors, so drop them if none (keep reporters if none though)
					var holdingArray:Array = [ { type: "Reporters", count: userTypeCounts[User.USER_TYPE_REPORTER] },
												   { type: "Teachers", count: userTypeCounts[User.USER_TYPE_TEACHER] } ];
					if (userTypeCounts[User.USER_TYPE_AUTHOR]>0) {
					   holdingArray.push( { type: "Authors", count: userTypeCounts[User.USER_TYPE_AUTHOR] } );
					}
					usageView.setUserTypeCounts( holdingArray );
					break;
				case RMNotifications.USAGE_LOADED:
					var data:Object = note.getBody();
					//trace("back , id=" + data.firstID);
					var selectedTitle:Title = usageView.titleList.selectedItem as Title;
					// AR Before you do anything with the courseUserCounts, you need to check if there
					// is any data there. The SQL call returns an empty recordset if it finds nothing.
					// This becomes an empty string in the mediator. (Not undefined or null).
					//TraceUtils.myTrace("data.courseUserCounts.undefined=" + (data.courseUserCounts==undefined));
					//TraceUtils.myTrace("data.courseUserCounts.null=" + (data.courseUserCounts==null));
					//TraceUtils.myTrace("data.courseUserCounts.''=" + (data.courseUserCounts==""));
					//TraceUtils.myTrace("data.courseUserCounts.length=" + data.courseUserCounts.length);
					
					// v3.6 based on the data that comes back, we can work out which component views we want to display
					// How to safely work out if the parts of the object that I am expecting exist?
					if (data.sessionCounts) {
						var toDate:Date = new Date(usageView.toDateField.selectedDate.setHours(23, 59, 59, 999));
						var fromDate:Date = new Date(usageView.fromDateField.selectedDate.setHours(0, 0, 0, 0));
						//if (data.sessionCounts['2010']) {
						TraceUtils.myTrace("got sessionsStarted");
						usageView.show_session_count = true;
						usageView.setSessionCounts(data.sessionCounts, fromDate, toDate);
						
						//} else {
						//	TraceUtils.myTrace("not got sessionsStarted");
						//	usageView.show_session_count = false;
						//}
					} else {
						TraceUtils.myTrace("not got sessionsStarted");
						usageView.show_session_count = false;
					}
					TraceUtils.myTrace("for title=" + selectedTitle.name);
						
					// AR Another problem is that if one course has had nothing happen, it will not exist 
					// in data. But we certainly want to see it listed with 0s.
					// AR Now we will only get back one set of counts, including duration and time in one record
					// v3.6 But I would like to add an 'other' record to count courses that are not in the current product.
					// It will come in data.otherCourseCounts
					
					//if (data.courseUserCounts.length>0) {
					// v3.6 If no data, data.courseCounts is null
					//if (data.courseCounts.length>0) {
					if (data.courseCounts && data.courseCounts.length>0) {
						// Add course names into the course user counts, and check the maximum value
						var maxDuration:Number=0;
						var maxCount:Number = 0;
						//for each (var item:Object in data.courseUserCounts) {
						for each (var item:Object in data.courseCounts) {
							//item.courseName = selectedTitle.getCourseById(item.courseID).caption;
							item.courseName = selectedTitle.getCourseById(item.courseID).name;
							//TraceUtils.myTrace("usageMediator:item.courseID=" + item.courseID + " caption=" + item.courseName + " users=" + item.courseCount);
							if (item.courseCount > maxCount) {
								maxCount = item.courseCount;
							}
							if (item.duration > maxDuration) {
								maxDuration = item.duration;
							}
						}
						// AR I can't see that this next bit is used at all!
						/*
						// AR Change the display for the number of courses run (pie chart or gauge)
						//var singleValue:Number = data.courseUserCounts[0].courseCount;
						var singleValue:Number = maxCount;
						var maxValue:Number;
						switch (true) {
							case (singleValue < 10):
								maxValue = 10;
								break;
							case (singleValue < 20):
								maxValue = 20;
								break;
							case (singleValue < 50):
								maxValue = 50;
								break;
							case (singleValue < 100):
								maxValue = 100;
								break;
							case (singleValue < 1000):
								maxValue = Math.ceil(singleValue / 100) * 100;
								break;
							default:
								maxValue = Math.ceil(singleValue / 100)+2 * 100;
								break;
						}
						*/
						//TraceUtils.myTrace("usageMediator.data.length " + data.courseUserCounts.length + " value=" + singleValue + " max=" + maxValue);
						//usageView.multipleCoursesInTitle((data.courseUserCounts.length > 1), singleValue, maxValue, data.courseUserCounts[0].courseName);
						//usageView.multipleCoursesInTitle((data.courseUserCounts.length > 1));
						
						// Sort courseUserCounts on courseID (based on the order in the content xml)
						//data.courseUserCounts = sortOnCourseID(data.courseUserCounts);
						data.courseCounts = sortOnCourseID(data.courseCounts);
						
						// Set the course time counts in the view, also pass the max duration
						//usageView.setCourseTimeCounts(data.courseTimeCounts);
						// Just one panel for course information now
						//usageView.setCourseTimeCounts(data.courseTimeCounts, maxDuration);
						//usageView.setCourseCounts(data.courseUserCounts, data.courseTimeCounts, maxDuration);
						usageView.setCourseCounts(data.courseCounts, maxDuration, maxCount);
					}
					/*
					if (data.courseTimeCounts.length>0) {
						// Add course names into the course time counts
						for each (item in data.courseTimeCounts) {
							item.courseName = selectedTitle.getCourseById(item.courseID).caption;
							//TraceUtils.myTrace("usageMediator:item.courseID=" + item.courseID + " caption=" + item.courseName + " time=" + item.duration);
						}
						
						// Sort courseTimeCounts on courseID (based on the order in the content xml)
						data.courseTimeCounts = sortOnCourseID(data.courseTimeCounts);
					}
					*/
					// Set the usage count in the view
					// Just one panel for course information now
					//usageView.setCourseUserCounts(data.courseUserCounts);
					//usageView.setCourseUserCounts(data.courseUserCounts);
					
					/*
					// AR Figure out the maximum value so you know whether to display hours or minutes
					for each (item in data.courseTimeCounts) {
						if (item && item.duration > maxDuration) {
							maxDuration = item.duration;
						}
					}
					*/
					
					// Set the failed login counts in the view
					//TraceUtils.myTrace("failed login, data.failedLoginCounts=" + data.failedLoginCounts);
					if (data.failedLoginCounts == new Object()) {
						data.failedLoginCounts = new Array();
					}
					usageView.setFailedLoginCounts(data.failedLoginCounts);
					
					// AR We have a new statistics display showing number of users who have started this title
					// against the number of licences
					// We need completely different view for AA licences
					usageView.userTypeCounts.AAlicence = (selectedTitle.licenceType==Title.LICENCE_TYPE_AA);
					//usageView.userTypeCounts.setExpiryDate(selectedTitle.expiryDate);
					usageView.userTypeCounts.setExpiryDate(selectedTitle);
					// v3.6 Or rather, we need a different view for LT
					//if (selectedTitle.licenceType == Title.LICENCE_TYPE_AA) {
					if (selectedTitle.licenceType == Title.LICENCE_TYPE_LT ||
						selectedTitle.licenceType == Title.LICENCE_TYPE_TT) {
						TraceUtils.myTrace("usageMediator: titleUserCounts=" + data.titleUserCounts + " of max=" + selectedTitle.maxStudents);
						//usageView.userTypeCounts.setStudentValues(data.titleUserCounts, selectedTitle.maxStudents);
						usageView.userTypeCounts.setStudentValues(data.titleUserCounts, selectedTitle);
						// and a nice maximum on the other users chart
						//usageView.userTypeCounts.setOtherUsersMax()						
					} else {
						usageView.userTypeCounts.setAALicence(selectedTitle.maxStudents);
					}
					// Send more information about the account
					TraceUtils.myTrace("set other info for " + selectedTitle.name);
					usageView.userTypeCounts.setTitleInformation(selectedTitle);

					
					break;
				case RMNotifications.CONTENT_LOADED:
					usageView.titleList.dataProvider = note.getBody();
					break;
				case CommonNotifications.COPY_LOADED:
					var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
					usageView.setCopyProvider(copyProvider);
					break;
				default:
					break;		
			}
		}
		
		private function onTitleChange(e:TitleEvent):void {
			var usageProxy:UsageProxy = facade.retrieveProxy(UsageProxy.NAME) as UsageProxy;
			usageProxy.getUsage(e.title, e.fromDate, e.toDate);
		}
		
		/**
		 * Sort the data array (returned from the server and containing dynamic object) into the same order of courses as in the XML
		 * Can I also add in an empty data record if it is missing?
		 * @param	data
		 * @return
		 */
		private function sortOnCourseID(data:Array):Array {
			var selectedTitle:Title = usageView.titleList.selectedItem as Title;

			//AR If there are 6 courses, but this data object only contains stuff for 4 of them,
			// then this routine adds in 2 empty slots on the y-axis. No it doesn't!
			var sortedData:Array = new Array();
			var emptyDataItem:Object = new Object();
			for each (var course:Course in selectedTitle.courses) {
				//sortedData.push(ArrayUtils.searchArrayForObject(data, course.id, "courseID"));
				var checkedItem:Object = ArrayUtils.searchArrayForObject(data, course.id, "courseID");
				//TraceUtils.myTrace("sortOnCourseID, title.id=" + course.id);
				if (checkedItem != null) {
					//TraceUtils.myTrace("found so copy id=" + checkedItem.courseID);
					sortedData.push(checkedItem);
				} else {
					emptyDataItem = new Object();
					emptyDataItem.courseID = course.id;
					//emptyDataItem.courseName = course.caption;
					emptyDataItem.courseName = course.name;
					TraceUtils.myTrace("empty data so add title id=" + emptyDataItem.courseID + " name=" + emptyDataItem.courseName);
					sortedData.push(emptyDataItem);
				}
			}
			//TraceUtils.myTrace("finally data.length=" + sortedData.length);
			return sortedData;
		}
		
	}
}
