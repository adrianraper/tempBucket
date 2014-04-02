package com.clarityenglish.bento.vo.content.transform {
	
	[RemoteClass(alias = "com.clarityenglish.bento.vo.content.transform.DirectStartDisableTransform")]
	public class DirectStartDisableTransform extends XmlTransform {
		
		public static const enabled:int = 3;
		public static const disabled:int = 8;
		public static const autoStart:int = 256;
		
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
					directStart.unitID = exerciseXML.parent().@id.toString();
				}
					

				if (directStart.unitID) {
					// gh#761 
					var unitXML:XML = xml..course.unit.(@id == directStart.unitID)[0];
					directStart.courseID = unitXML.parent().@id.toString();
					// cannot get the parent course ID					
					//directStart.courseID = xml..course.(descendants("unit").@id.contains(directStart.unitID))[0].@id.toString();
				}					
				
				if (directStart.courseID) {
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
									} else if (unit.@id == directStart.unitID && directStart.scorm){
										for each (var exercise:XML in unit.exercise) {
											exercise.@enabledFlag = enabled;
										}
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
		}
	}
}
