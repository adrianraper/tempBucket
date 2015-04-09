package com.clarityenglish.bento.vo.content.transform {
	import com.clarityenglish.bento.vo.content.Exercise;
	
	[RemoteClass(alias = "com.clarityenglish.bento.vo.content.transform.DirectStartDisableTransform")]
	public class DirectStartDisableTransform extends XmlTransform {
		
		private var directStart:Object;
		
		public function DirectStartDisableTransform(directStart:Object) {
			this.directStart = directStart;
		}
		
		override public function transform(xml:XML):void {
			namespace xhtml = "http://www.w3.org/1999/xhtml";
			use namespace xhtml;
			// #338 - If courseID is defined, disable the other courses.  If you get back a unit, get it's course too for inverted-hiding as well as the other units.
			// Road to IELTS has a group ID within a unit for an extra level of interface grouping.  Pick that up too.
			if (directStart) {
				if (directStart.exerciseID) {
					//directStart.unitID = xml..unit.(descendants("exercise").@id.contains(directStart.exerciseID))[0].@id.toString();
					var exerciseXML:XML = xml..unit.exercise.(@id == directStart.exerciseID)[0];
					if (exerciseXML)
						directStart.unitID = exerciseXML.parent().@id.toString();
				}
					

				if (directStart.unitID) {
					// gh#761 
					var unitXML:XML = xml..course.unit.(@id == directStart.unitID)[0];
					if (unitXML)
						directStart.courseID = unitXML.parent().@id.toString();
				}					

				// TODO: We should only be setting disabled on or off here, not forcing eF to be enabled (3)
				// in case some other eF flags have been set that we want
				var enabled:Number = Exercise.EF_NAVIGATE_ON | Exercise.EF_MENU_ON;
				var disabled:Number = Exercise.EF_DISABLED;
				if (directStart.courseID) {
					// gh#853 Only disable other courses if the targetted course id exists
					var courseXML:XML = xml..course.(@id == directStart.courseID)[0];
					if (courseXML) {
						for each (var course:XML in xml..course) {
							if (course.@id == directStart.courseID) {
								course.@enabledFlag = enabled;
								if (directStart.unitID) {
									for each (var unit:XML in course.unit) {
										if (unit.@id == directStart.unitID && !directStart.scorm) {
											unit.@enabledFlag = enabled;
											if (directStart.exerciseID) {
												for each (var exercise:XML in unit.exercise) {
													if (exercise.@id == directStart.exerciseID) {
														exercise.@enabledFlag = enabled;
													} else {
														exercise.@enabledFlag = disabled;
													}
												}
											} else if (directStart.groupID) {
												for each (exercise in unit.exercise) {
													if (exercise.@group == directStart.groupID) {
														exercise.@enabledFlag = enabled;
													} else {
														exercise.@enabledFlag = disabled;
													}
												}
											}
										} else if (unit.@id == directStart.unitID && directStart.scorm) {
											for each (exercise in unit.exercise)
												exercise.@enabledFlag = enabled;
										} else {
											unit.@enabledFlag = disabled;
										}
									}
								}
							} else {
								course.@enabledFlag = disabled;
							}
						}
					}
				}
				// gh#584
				directStart = null;
			}
		}
	}
}
