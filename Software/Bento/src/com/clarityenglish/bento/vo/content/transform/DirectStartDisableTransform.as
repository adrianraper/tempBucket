package com.clarityenglish.bento.vo.content.transform {
	import com.clarityenglish.common.vo.content.Course;
	
	[RemoteClass(alias="com.clarityenglish.bento.vo.content.transform.DirectStartDisableTransform")]
	public class DirectStartDisableTransform extends XmlTransform {
		
		override public function transform(xml:XML):void {
			namespace xhtml = "http://www.w3.org/1999/xhtml";
			use namespace xhtml;
		}
		
		/*if (!bentoProxy.menuXHTML) {
			// Whilst I get back a full <head><script> xml structure, I never want more than the <menu> node.
			// Use the XHTML class to strip the namespace from the XML
			//var data:XHTML = new XHTML(new XML(dataProvider));
			//var menuXHTML:XHTML = new XHTML(data.head.script.menu[0], this.href);
			//var menuXHTML:XHTML = new XHTML(data.head.script.(@id == "model" && @type == "application/xml").menu[0], this.href);
			var menuXHTML:XHTML = new XHTML(new XML(dataProvider), this.href);
			
			// #338
			// If courseID is defined, disable the other courses.
			// TODO. Need to update the circular animation to also respect enabledFlag.
			// TODO. Also need to do similar thing for hiddenContent, so perhaps take it out somewhere
			// This is also handled in state machine. Either I can do the menu enabling bits here
			// and the direct start there, or...
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var directStart:Object = configProxy.getDirectStart();
			
			// #338 If you get back a course, hide the others.
			// If you get back a unit, get it's course too for inverted-hiding as well as the other units.
			// Road to IELTS has a group ID within a unit for an extra level of interface grouping. Pick that up too.
			
			if (directStart) {
				if (directStart.exerciseID)
					directStart.unitID = menuXHTML..unit.(descendants("exercise").@id.contains(directStart.exerciseID))[0].@id.toString();
				
				if (directStart.unitID)
					directStart.courseID = menuXHTML..course.(descendants("unit").@id.contains(directStart.unitID))[0].@id.toString();
				
				if (directStart.courseID) {
					for each (var course:XML in menuXHTML..course) {
						if (course.@id == directStart.courseID) {
							course.@enabledFlag = 3;
							if (directStart.unitID) {
								for each (var unit:XML in course.unit) {
									if (unit.@id == directStart.unitID) {
										unit.@enabledFlag = 3;
										if (directStart.exerciseID) {
											for each (var exercise:XML in unit.exercise) {
												if (exercise.@id == directStart.exerciseID) {
													exercise.@enabledFlag = 3;
												} else {
													exercise.@enabledFlag = 8;
												}
											}
										} else if (directStart.groupID) {
											for each (exercise in unit.exercise) {
												if (exercise.@group == directStart.groupID) {
													exercise.@enabledFlag = 3;
												} else {
													exercise.@enabledFlag = 8;
												}
											}
										}
									} else {
										unit.@enabledFlag = 8;
									}
								}
							}
						} else {
							course.@enabledFlag = 8;
						}
					}
				}
			}
			
			//loadedResources[href] = menuXHTML; // GH #95
			bentoProxy.menuXHTML = menuXHTML;
			
			sendNotification(BBNotifications.MENU_XHTML_LOADED, menuXHTML);
		}*/
		
	}
}
