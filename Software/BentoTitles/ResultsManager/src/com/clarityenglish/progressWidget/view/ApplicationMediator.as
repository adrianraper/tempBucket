/*
 Mediator - PureMVC
 */
package com.clarityenglish.progressWidget.view {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.progressWidget.PWNotifications;
	import com.clarityenglish.common.view.AbstractApplicationMediator;
	import com.clarityenglish.progressWidget.ApplicationFacade;
	import com.clarityenglish.progressWidget.PWApplication;
	import com.clarityenglish.progressWidget.Constants;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.progressWidget.model.ProgressProxy;
	//import com.flexiblexperiments.ListItemGroupedDragProxy;
	import com.clarityenglish.common.vo.content.Content;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.content.Course;
	import com.clarityenglish.common.vo.content.Unit;
	import com.clarityenglish.common.vo.content.Exercise;
	import com.clarityenglish.progressWidget.vo.progress.Coverage;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import flash.events.Event;
	import com.clarityenglish.progressWidget.events.RefreshEvent;
	import mx.core.Application;
	import com.clarityenglish.utils.TraceUtils;	
	import nl.demonsters.debugger.MonsterDebugger;
	
	/**
	 * A Mediator
	 */
	public class ApplicationMediator extends AbstractApplicationMediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "ApplicationMediator";
		
		// Content structure
		private var titles:Array;
		private var progress:Array;
		private var everyonesProgress:Array;
		private var userDetails:Object;
		
		public function ApplicationMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
		}
		
		private function get application():PWApplication {
			return viewComponent as PWApplication;
		}
		
		/**
		 * Setup event listeners and register sub-mediators
		 */
		override public function onRegister():void {
			super.onRegister();
			
			//facade.registerMediator(new ProgressMediator(application.progressView));
			//facade.registerMediator(new ComparisonMediator(application.comparisonView));
			
			// Events from the views
			application.comparisonView.addEventListener(Event.CHANGE, onChange);
			application.progressView.addEventListener(RefreshEvent.DATA, onRefresh);
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
			return ApplicationMediator.NAME;
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
			// Concatenate any extra notifications to the array returned by this function in the superclass
			// Q: Why do I have to add content_loaded to this list, but I don't have to add the other notifications like LOGGED_IN?
			// Answer: Because the others are registered as commands in applicationFacade.
			return super.listNotificationInterests().concat([
				PWNotifications.CONTENT_LOADED,
				PWNotifications.SCORES_LOADED,
				PWNotifications.EVERYONES_SCORES_LOADED,
				PWNotifications.RELOAD_EVERYONES_SCORES,
				PWNotifications.REFRESH,
			]);
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
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			// TraceUtils.myTrace("AppMediator.handleNotification." + note.getName());
			//MonsterDebugger.trace(this, note);
			
			switch (note.getName()) {
				case CommonNotifications.LOGGED_IN:
					application.topStack.selectedIndex = 0; // the progressView
					
					break;
				case CommonNotifications.LOGGED_OUT:
					application.topStack.selectedIndex = 0; // the loginView
					break;
					
				case CommonNotifications.COPY_LOADED:
					var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
					
					// Set the copy in any static classes (e.g. Renderers or things that are recycled)
					//ListItemGroupedDragProxy.copyProvider = copyProvider;
					
					application.setCopyProvider(copyProvider);
					break;
					
				case PWNotifications.CONTENT_LOADED:
					// v3.1 This is where we make sure that we have all the data that the view needs in an appropriate format
					// In this case this means getting the content objects that will be displayed (trackable)
					// Save in our content structure
					this.titles = note.getBody() as Array;
					
					// Default view to prove that content was read correctly
					application.detailView.tree.dataProvider = note.getBody();
					//application.switchView("detailView");
					
					// TraceUtils.myTrace("PW.userID=" + Application.application.parameters.userID);
					// Then requesting the progress data for each of these.
					// Once this comes back (see below) - we will then merge and pass to the view
					this.userDetails = new Object();
					this.userDetails.userID = Application.application.parameters.userID;
					this.userDetails.rootID = Application.application.parameters.rootID;
					this.userDetails.productCode = Application.application.parameters.productCode;
					if (Application.application.parameters.country) this.userDetails.country = Application.application.parameters.country;
					
					var progressProxy:ProgressProxy = facade.retrieveProxy(ProgressProxy.NAME) as ProgressProxy;
					progressProxy.getCoverage(titles, new Date(2000, 0, 1), new Date(), this.userDetails);
					
					break; 
					
				// Detail view is just for debugging, doesn't need it's own mediator, so handle events for it here
				case PWNotifications.SCORES_LOADED:
					//// TraceUtils.myTrace("beginning of scores loaded");
					// Save in our content structure
					this.progress = note.getBody() as Array;
					//// TraceUtils.myTrace("1=" + this.progress.length);
					
					// Now the scores for this title have come back, list them out for debug
					application.detailView.listMyScores.dataProvider = this.progress;
					
					// Merge the scores into the titles and create an XML object with the results
					// This is driven by productCode to differentiate the thing we are reporting on from the supporting titles.
					var coverageOutput:Array = mergeCoverageAndContent(Application.application.parameters.productCode);
					//var coverageOutput:XML = mergeCoverageAndContent(Application.application.parameters.productCode);
					//// TraceUtils.myTrace("2=" + coverageOutput.length);
					
					// Give it to the detail view (debug)
					application.detailView.simpleList.dataProvider = coverageOutput.map(formatCoverage);
										
					// make a more sophisticated data set, now that titles contains the stats objects
					var progressData:XML = convertTitlesToXML(Application.application.parameters.productCode);
					application.detailView.everyonesOutput.text = progressData.toXMLString();
					//// TraceUtils.myTrace("merged output=" + progressData.toXMLString());
					
					// We can send this to the progress view now
					application.progressView.setDataProvider(progressData);
					application.switchView("progressView");
					
					// Now go and get everyone's data, at least in a default "worldwide" view
					progressProxy = facade.retrieveProxy(ProgressProxy.NAME) as ProgressProxy;
					progressProxy.getEveryonesCoverage(this.titles, new Date(2000, 0, 1), new Date(), this.userDetails);
					break;
					
				case PWNotifications.EVERYONES_SCORES_LOADED:
					// Now the scores for everyone have come back, we need to summarise them and do some more averaging
					// The number of users is needed per course, so this will be the first x records of the array.
					
					var numberOfUsers:Array = new Array();
					if ((note.getBody() as Array).length>0) {
						//// TraceUtils.myTrace("got everyones progress for " + (note.getBody() as Array)[0].users + " other users.");
						// The first records are a header - contains number of users. Then the rest are progress records.
						while ((note.getBody() as Array)[0].users) {
							// TraceUtils.myTrace("number of users=" + (note.getBody() as Array)[0].users + " id=" + (note.getBody() as Array)[0].id);
							var temp:Object = (note.getBody() as Array).shift();
							numberOfUsers[temp.id] = temp.users;
						}
						//var numberOfUsers:uint = (note.getBody() as Array).shift().users;
						this.everyonesProgress = note.getBody() as Array;
					} else {
						this.everyonesProgress = new Array();
					}
					application.detailView.listEveryonesScores.dataProvider = this.everyonesProgress;

					// We already have the merged coverage and content for this user.
					// Can we just piggy back on that structure?
					addEveryonesCoverage(Application.application.parameters.productCode, numberOfUsers);
					
					// make a more sophisticated data set, now that titles contains the stats objects
					progressData = convertTitlesToXML(Application.application.parameters.productCode);
					application.detailView.everyonesOutput.text = progressData.toXMLString();
					
					// update the chart
					application.comparisonView.setChartDataProvider(progressData);
					application.comparisonView.updateChart();
					break;
					
				case PWNotifications.RELOAD_EVERYONES_SCORES:
					// We want to get everyone's score again for replotting.
					var appData:Array = note.getBody() as Array;
					this.userDetails.country = appData[0];
					
					// TraceUtils.myTrace("country=" + appData[0]);
					//// TraceUtils.myTrace("duration=" + appData[1]);
					switch (appData[1]) {
						case 0: // always
							var startDate:Date = new Date(2000, 0, 1);
							var endDate:Date = new Date();
							break;
						case 1: // since I started
							if (Application.application.parameters.userStartDate &&
								Date.parse(Application.application.parameters.userStartDate)>0) {
								startDate = new Date(Application.application.parameters.userStartDate);
							} else {
								startDate = new Date(new Date().getTime() - (1000 * 60 * 60 * 24 * 30));
							}
							endDate = new Date();
							break;
						case 2: // in the last month
							startDate = new Date(new Date().getTime() - (1000 * 60 * 60 * 24 * 30));
							endDate = new Date();
							break;
						case 3: // in the last year
							startDate = new Date(new Date().getTime() - (1000 * 60 * 60 * 24 * 365));
							endDate = new Date();
							break;
					}
					//// TraceUtils.myTrace("appMediator.startDate=" + startDate.toDateString());
					progressProxy = facade.retrieveProxy(ProgressProxy.NAME) as ProgressProxy;
					progressProxy.getEveryonesCoverage(this.titles, startDate, endDate, this.userDetails);
					break;
					
				case PWNotifications.REFRESH:
					MonsterDebugger.trace(this, "PWNotifications.REFRESH");
					// v3.3 Get all scores again.
					
					// Default view to prove that content was read correctly
					application.detailView.tree.dataProvider = note.getBody();
					//application.switchView("detailView");
					
					progressProxy = facade.retrieveProxy(ProgressProxy.NAME) as ProgressProxy;
					progressProxy.getCoverage(titles, new Date(2000, 0, 1), new Date(), this.userDetails);
					
					break; 
					
				default:
					break;		
			}
		}
		
		/*
		 * This reacts to changes in the view that require new data for everyone.
		 * I don't think I can sendNotification from a view, so I trigger an event in the view and the notification from here
		 * even though my code above is (for now) the only thing to react to this notification.
		 */
		private function onChange(e:Event):void {
			// TraceUtils.myTrace("appMediator.onChange");
			sendNotification(PWNotifications.RELOAD_EVERYONES_SCORES, [application.comparisonView.countrySelection.selectedItem.label, 
																		application.comparisonView.durationSelection.selectedItem.data]);
			// Now go and get everyone's data, with new filtering
			//// TraceUtils.myTrace("event target=" + e.currentTarget);
			//// TraceUtils.myTrace("country=" + application.comparisonView.countrySelection.selectedItem.label);
			//// TraceUtils.myTrace("duration=" + application.comparisonView.durationSelection.selectedItem.data);
			//var progressProxy:ProgressProxy = facade.retrieveProxy(ProgressProxy.NAME) as ProgressProxy;
			//progressProxy.getEveryonesCoverage(this.titles, new Date(2000, 0, 1), new Date(), this.userDetails);
		}
		private function onRefresh(e:Event):void {
			//// TraceUtils.myTrace("appMediator.onRefresh");
			MonsterDebugger.trace(this, "onRefresh");
			sendNotification(PWNotifications.REFRESH);
		}
		/*
		 * This function takes a tree of content, and an array of coverage values, merges based on id
		 * and formats the output.
		 */
		private function mergeCoverageAndContent(productCode:int):Array {
			
			// TODO: Since I don't really want to flatten the structure, can I use array_walk_recursive instead of the following?
			// Well, maybe you could if you were in PHP!
			// Maybe I could add a coverage item to each object?
			
			// First make an array of all items from the titles content object. Used to find IDs quickly and for debugging.
			var reportableIDs:Array = new Array();
			
			// temp objects for bubbling up progress scores into summaries
			var thisItemCoverage:Coverage;
			var thisUnitCoverage:Coverage;
			var thisCourseCoverage:Coverage;
			var thisTitleCoverage:Coverage;
			
			// This loops through all the content read from emu.xml and course.xml (if any).
			// For each trackable item it attempts to get a coverage record, if the item has been done.
			for each (var title:Title in titles) {
				// TraceUtils.myTrace("reportable.id=" + title.id);
				// Is this the EMU title?
				if (title.id == String(productCode)) {
					//thisTitleCoverage = new Coverage(title);
					for each (var course:Course in title.courses) {
						//// TraceUtils.myTrace("reportable.id=" + course.id);
						thisCourseCoverage = new Coverage(course);
						for each (var unit:Unit in course.units) {
							//// TraceUtils.myTrace("reportable.id=" + unit.id);
							// For EMU coverage, more than one trackable item means we report at item level
							// Otherwise we move the item coverage up to the unit level.
							if (unit.exercises.length>1) {
								for each (var item:Exercise in unit.exercises) {
									thisItemCoverage = new Coverage(item);
									//// TraceUtils.myTrace("item.reportable.id=" + item.id + " maxScore=" + item.maxScore);
									thisItemCoverage.setCoverage(getCoverageForID(item.id, item.maxScore));
									// attach the coverage object to the .stats property?
									item.stats = thisItemCoverage;
									reportableIDs.push(thisItemCoverage);
								}
							} else {
								thisUnitCoverage = new Coverage(unit);
								item = unit.exercises[0];
								//// TraceUtils.myTrace("unit.reportable.id=" + item.id + " maxScore=" + item.maxScore);
								thisUnitCoverage.setCoverage(getCoverageForID(item.id, item.maxScore));
								unit.stats = thisUnitCoverage;
								reportableIDs.push(thisUnitCoverage);
							}
						}
						// This is just empty, but will be filled later
						course.stats = thisCourseCoverage;
					}
					
				} else {
					// So this is a title from a licenced product (assume AP) in the EMU	
					// Summarise by bubbling up the exercise progress.
					thisTitleCoverage = new Coverage(title);
					for each (course in title.courses) {
						//// TraceUtils.myTrace("second loop reportable.id=" + course.id);
						thisCourseCoverage = new Coverage(course);
						for each (unit in course.units) {
							//// TraceUtils.myTrace("reportable.id=" + unit.id);
							thisUnitCoverage = new Coverage(unit);
							for each (item in unit.exercises) {
								thisItemCoverage = new Coverage(item);
								// AP exercises send back .completed=1 and .total=1 for each exercise that has been done at least once
								// And for exercises that I haven't done, the maxScore is 1
								thisItemCoverage.setCoverage(getCoverageForID(thisItemCoverage.id, 1));
								thisUnitCoverage.completed += thisItemCoverage.completed;
								thisUnitCoverage.total += thisItemCoverage.total;
								// attach the coverage object to the .stats property
								item.stats = thisItemCoverage;
								reportableIDs.push(thisItemCoverage);
							}
							thisCourseCoverage.completed += thisUnitCoverage.completed;
							thisCourseCoverage.total += thisUnitCoverage.total;
							// attach the coverage object to the .stats property
							unit.stats = thisUnitCoverage;
							//reportableIDs.push(thisUnitCoverage);
						}
						thisTitleCoverage.completed += thisCourseCoverage.completed;
						thisTitleCoverage.total += thisCourseCoverage.total;
						// attach the coverage object to the .stats property
						course.stats = thisCourseCoverage;
						//reportableIDs.push(thisCourseCoverage);
					}
					// attach the coverage object to the .stats property
					//// TraceUtils.myTrace("adding stats to title" + title.id);
					title.stats = thisTitleCoverage;
					//reportableIDs.push(thisTitleCoverage);
				}
			}
			// Finally (because you don't really know what order the above all went in) we need to see if there are any
			// items in the EMU that are tracking items in the other titles. Typically this is a unit in AP summarised to the EMU.
			// Also use this loop to count up the completed and total to get a course level summary
			for each (title in titles) {
				if (title.id == String(productCode)) {
					for each (course in title.courses) {
						var summaryTotal:Number = 0;
						var summaryCompleted:Number = 0;
						for each (unit in course.units) {
							for each (item in unit.exercises) {
								if (item.trackableID) {
									//// TraceUtils.myTrace("linked coverage test" + item.trackableID);
									// We have found an item in the EMU that needs to pick up coverage from the 
									// tracked ID in the rest of the titles.
									// However, you don't want to simply replace the emu coverage with the linked one
									// otherwise it all goes horribly wrong when you start adding in everyone's scores.
									// So just copy the information.
									//var sourceCoverage:Coverage = getLinkedCoverage(reportableIDs, item.trackableID);
									var sourceCoverage:Coverage = getLinkedCoverage(titles, item.trackableID);
									//// TraceUtils.myTrace("got linked coverage=" + sourceCoverage.toString());
									if (unit.exercises.length > 1) {
										// It replaces the item coverage because there are many exercises
										//item.stats = sourceCoverage;
										item.stats.setCoverage(sourceCoverage);
									} else {
										// Here it replaces the unit coverage because there is just one exercise
										//unit.stats = sourceCoverage;
										unit.stats.setCoverage(sourceCoverage);
									}
								}
								// Either the item OR the unit has stats, never both
								if (item.stats is Coverage) {
									//// TraceUtils.myTrace("item.stats.completed=" + Number(item.stats.completed));
									summaryTotal += Number(item.stats.total);
									summaryCompleted += Number(item.stats.completed);
								}
							}
							if (unit.stats is Coverage) {
								//// TraceUtils.myTrace("unit.stats.completed=" + Number(unit.stats.completed));
								summaryTotal += Number(unit.stats.total);
								summaryCompleted += Number(unit.stats.completed);
							}
						}
						//// TraceUtils.myTrace("course.stats.completed=" + summaryCompleted);
						course.stats.total = summaryTotal;
						course.stats.completed = summaryCompleted;
					}
				}
			}
			
			// Quick easy list for debugging
			return reportableIDs;
		}
		// Scan through the progress records you got back from db to see if there is data for this id
		private function getCoverageForID(id:String, defaultMaxScore:Number=0):Object {
			for each (var score:Object in this.progress) {
				if (score.id == id) {
					return { completed:score.completed, total:score.total };
					break;
				}
			}
			//// TraceUtils.myTrace("no coverage for " + id + " so return completed=" + defaultMaxScore);
			return { completed:0, total:defaultMaxScore };
		}
		// Try it on the structure itself
		private function getLinkedCoverage(titles:Array, id:String):Coverage {
			for each (var title:Title in titles) {
				// v3.6 I am getting errors because title might not have added the stats object
				// In fact, all content objects might not have it. I wonder why this used to work?
				if (title.stats && title.stats.id == id) {
					//// TraceUtils.myTrace("got it, stats=" + (title.stats as Coverage).completed);
					return title.stats as Coverage;
					break;
				}
				for each (var course:Course in title.courses) {
					//// TraceUtils.myTrace("getLinked for course=" + course.id);
					//if (course.stats.id == id) {
					if (course.stats && course.stats.id == id) {
						return course.stats as Coverage;
						break;
					}
					for each (var unit:Unit in course.units) {
						//// TraceUtils.myTrace("getLinked for unit=" + unit.id);
						//if (unit.stats.id == id) {
						if (unit.stats && unit.stats.id == id) {
							return unit.stats as Coverage;
							break;
						}
						for each (var item:Exercise in unit.exercises) {
							//// TraceUtils.myTrace("getLinked for item=" + item.id);
							//if (item.stats.id == id) {
							if (item.stats && item.stats.id == id) {
								return item.stats as Coverage;
								break;
							}
						}
					}
				}
			}
			return null;
		}
		// This builds an XML object showing the stats we want
		private function convertTitlesToXML(productCode:int):XML {
			
			for each (var title:Title in titles) {
				if (title.id == String(productCode)) {
					var thisTitle:XML = <progress></progress>;
					thisTitle.@name = title.name;
					
					for each (var course:Course in title.courses) {
						var thisCourse:XML = <course></course>;
						thisCourse.@name = course.name;
						thisCourse.@completed = course.stats.completed;
						thisCourse.@total = course.stats.total;
						thisCourse.@ecompleted = course.stats.everyonesCompleted;
						thisCourse.@etotal = course.stats.everyonesTotal;
						
						for each (var unit:Unit in course.units) {
							var thisUnit:XML = <unit></unit>;
							thisUnit.@name = unit.name;
							if (unit.stats) {
								thisUnit.@completed = unit.stats.completed;
								thisUnit.@total = unit.stats.total;
								thisUnit.@ecompleted = unit.stats.everyonesCompleted;
								thisUnit.@etotal = unit.stats.everyonesTotal;
							} // else {
								for each (var item:Exercise in unit.exercises) {
									if (item.stats) {
										var thisItem:XML = <item></item>;
										thisItem.@name = item.name;
										thisItem.@completed = item.stats.completed;
										thisItem.@total = item.stats.total;
										thisItem.@ecompleted = item.stats.everyonesCompleted;
										thisItem.@etotal = item.stats.everyonesTotal;
										thisUnit.appendChild(thisItem);
									}
								}
							//}
							thisCourse.appendChild(thisUnit);
						}
						thisTitle.appendChild(thisCourse);
					}
				}
			}
			return thisTitle;
			
		}

		/*
		 * This function takes a tree of content that has already had an individual's coverage added to it.
		 * We then need to add in an array of coverage that comes from everyone else.
		 */ 
		private function addEveryonesCoverage(productCode:int, numberOfUsers:Array):void {

			// As of now, all I want to do is summarise to the course level, but lets see about it all
			
			// temp objects for bubbling up progress scores into summaries
			var thisItemCoverage:Coverage;
			var thisUnitCoverage:Coverage;
			var thisCourseCoverage:Coverage;
			var thisTitleCoverage:Coverage;
			
			// This loops through all the content read from emu.xml and course.xml (if any).
			// For each trackable item it attempts to get a coverage record, if the item has been done.
			for each (var title:Title in titles) {
				//// TraceUtils.myTrace("reportable.id=" + title.id);
				// Is this the EMU title?
				if (title.id == String(productCode)) {
					//thisTitleCoverage = new Coverage(title);
					for each (var course:Course in title.courses) {
						//// TraceUtils.myTrace("reportable.id=" + course.id);
						//thisCourseCoverage = course.stats;
						for each (var unit:Unit in course.units) {
							//// TraceUtils.myTrace("reportable.id=" + unit.id);
							// For EMU coverage, more than one trackable item means we report at item level
							// Otherwise we move the item coverage up to the unit level.
							if (unit.exercises.length>1) {
								for each (var item:Exercise in unit.exercises) {
									thisItemCoverage = item.stats as Coverage;
									//// TraceUtils.myTrace("emu item work on =" + thisItemCoverage.toString());
									// To work out the averages, you need to know how many people have started this course
									// TODO This figure is not accurate. If someone has only done AP in a course, we can't count them 
									// (unless we make the AP have one unit in one course!), then we could map the AP course ID to the EMU course ID
									//// TraceUtils.myTrace("number of users for course " + course.id + "=" + numberOfUsers[course.id]);
									// NOTE. The total for everyone comes from item.total * number of users
									thisItemCoverage.setEveryonesCoverage(getEveryonesCoverageForID(item.id, item.maxScore), numberOfUsers[course.id]);
									// attach the coverage object to the .stats property?
									//item.stats = thisItemCoverage;
									//reportableIDs.push(thisItemCoverage);
								}
							} else {
								thisUnitCoverage = unit.stats as Coverage;
								item = unit.exercises[0];
								//// TraceUtils.myTrace("emu unit work on =" + thisUnitCoverage.toString());
								//// TraceUtils.myTrace("number of users for course " + course.id + "=" + numberOfUsers[course.id]);
								thisUnitCoverage.setEveryonesCoverage(getEveryonesCoverageForID(item.id, item.maxScore), numberOfUsers[course.id]);
								//unit.stats = thisUnitCoverage;
								//reportableIDs.push(thisUnitCoverage);
							}
						}
						// This is just empty, but will be filled later
						//course.stats = thisCourseCoverage;
					//for each (pushedCoverage in reportableIDs) {
					//	// TraceUtils.myTrace("w:reportableIDs=" + pushedCoverage.toString());
					//}
					}
					//// TraceUtils.myTrace("end loop, raptile=" + titles[0].courses[0].units[0].stats.toString());
					
				} else {
					// So this is a title from a licenced product (assume AP) in the EMU	
					// Summarise by bubbling up the exercise progress.
					thisTitleCoverage = new Coverage(title);
					for each (course in title.courses) {
						//// TraceUtils.myTrace("reportable.id=" + course.id);
						thisCourseCoverage = course.stats as Coverage;
						for each (unit in course.units) {
							//// TraceUtils.myTrace("reportable.id=" + unit.id);
							thisUnitCoverage = unit.stats as Coverage;
							for each (item in unit.exercises) {
								thisItemCoverage = item.stats as Coverage;
								// AP exercises send back .completed=1 and .total=1 for each exercise that has been done at least once
								// And for exercises that I haven't done, the maxScore is 1
								//// TraceUtils.myTrace("number of users for course " + course.id + "=" + numberOfUsers[course.id]);
								thisItemCoverage.setEveryonesCoverage(getEveryonesCoverageForID(thisItemCoverage.id, 1), numberOfUsers[course.id]);
								//thisItemCoverage.total++;
								thisUnitCoverage.everyonesCompleted += thisItemCoverage.everyonesCompleted;
								thisUnitCoverage.everyonesTotal += thisItemCoverage.everyonesTotal;
								//// TraceUtils.myTrace("everyone AP item:" + item.name + " everyonesCompleted=" + thisItemCoverage.everyonesCompleted);
								// attach the coverage object to the .stats property
								//item.stats = thisItemCoverage;
								//reportableIDs.push(thisItemCoverage);
							}
							//// TraceUtils.myTrace("everyone AP unit:" + unit.name + " everyonesCompleted=" + thisUnitCoverage.everyonesCompleted);
							//reportableIDs.push(thisUnitCoverage);
							//// TraceUtils.myTrace("everyone AP unit:" + thisUnitCoverage.toString());
							thisCourseCoverage.everyonesCompleted += thisUnitCoverage.everyonesCompleted;
							thisCourseCoverage.everyonesTotal += thisUnitCoverage.everyonesTotal;
							// attach the coverage object to the .stats property
							//unit.stats = thisUnitCoverage;
						}
						thisTitleCoverage.everyonesCompleted += thisCourseCoverage.everyonesCompleted;
						thisTitleCoverage.everyonesTotal += thisCourseCoverage.everyonesTotal;
						// attach the coverage object to the .stats property
						//course.stats = thisCourseCoverage;
						//reportableIDs.push(thisCourseCoverage);
					}
					// attach the coverage object to the .stats property
					title.stats = thisTitleCoverage;
					//reportableIDs.push(thisTitleCoverage);
					//// TraceUtils.myTrace("end loop, reptile=" + titles[0].courses[0].units[0].stats.toString());
				}
			}
			//// TraceUtils.myTrace("end loop, roptile=" + titles[0].courses[0].units[0].stats.toString());
			//for each (var pushedCoverage:Coverage in reportableIDs) {
			//	// TraceUtils.myTrace("z:reportableIDs=" + pushedCoverage.toString());
			//}
			// Finally (because you don't really know what order the above all went in) we need to see if there are any
			// items in the EMU that are tracking items in the other titles. Typically this is a unit in AP summarised to the EMU.
			// Also use this loop to count up the completed and total to get a course level summary
			for each (title in titles) {
				if (title.id == String(productCode)) {
					for each (course in title.courses) {
						var summaryTotal:Number = 0;
						var summaryCompleted:Number = 0;
						for each (unit in course.units) {
							for each (item in unit.exercises) {
								if (item.trackableID) {
									// We have found an item in the EMU that needs to pick up coverage from the 
									// tracked ID in the rest of the titles.
									//var sourceCoverage:Coverage = getLinkedCoverage(reportableIDs, item.trackableID);
									var sourceCoverage:Coverage = getLinkedCoverage(titles, item.trackableID);
									//// TraceUtils.myTrace("got everyone linked coverage=" + sourceCoverage.toString());
									if (unit.exercises.length > 1) {
										// It replaces the item coverage because there are many exercises
										// Just copy the numbers, don't actually put the AP coverage object into the emu
										// Total will be wrong because it is based on number of users starting the AP course, not starting the EMU course
										item.stats.setEveryonesCoverage(sourceCoverage, numberOfUsers[course.id]);
										//item.stats.everyonesCompleted = sourceCoverage.everyonesCompleted;
										//item.stats.everyonesTotal = sourceCoverage.everyonesTotal;
									} else {
										// Here it replaces the unit coverage because there is just one exercise
										unit.stats.setEveryonesCoverage(sourceCoverage, numberOfUsers[course.id]);
										//unit.stats.everyonesCompleted =  sourceCoverage.everyonesCompleted;
										//unit.stats.everyonesTotal =  sourceCoverage.everyonesTotal;
									}
									//// TraceUtils.myTrace("buss");
								}
								// Either the item OR the unit has stats, never both
								if (item.stats is Coverage) {
									//// TraceUtils.myTrace("item.stats.completed=" + Number(item.stats.completed));
									summaryTotal += Number(item.stats.everyonesTotal);
									summaryCompleted += Number(item.stats.everyonesCompleted);
								}
							}
							if (unit.stats is Coverage) {
								//// TraceUtils.myTrace("unit.stats.completed=" + Number(unit.stats.completed));
								summaryTotal += Number(unit.stats.everyonesTotal);
								summaryCompleted += Number(unit.stats.everyonesCompleted);
							}
						}
						//// TraceUtils.myTrace("course.stats.completed=" + summaryCompleted);
						course.stats.everyonesTotal = summaryTotal;
						course.stats.everyonesCompleted = summaryCompleted;
					}
				}
			}
			
		}

		
		// Scan through the everyones progress records you got back from db to see if there is data for this id
		private function getEveryonesCoverageForID(id:String, defaultMaxScore:Number=0):Object {
			for each (var score:Object in this.everyonesProgress) {
				if (score.id == id) {
					return { completed:score.completed, total:score.total };
					break;
				}
			}
			//// TraceUtils.myTrace("no coverage for " + id + " so return completed=" + defaultMaxScore);
			return { completed:0, total:defaultMaxScore };
		}
		
		private function formatCoverage(element:Coverage, index:int, arr:Array):String {
			return element.toString();
		}
		//private function getLinkedCoverage(arrayList:Array, id:String):Coverage {
		//	for each (var coverage:Coverage in arrayList) {
		//		if (coverage.id == id) {
		//			return coverage;
		//			break;
		//		}
		//	}
		//	return null;
		//}
	}
}
