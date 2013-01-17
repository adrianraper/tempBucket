package com.clarityenglish.bento.vo.content.transform {
	import com.clarityenglish.common.vo.content.Course;
	
	[RemoteClass(alias="com.clarityenglish.bento.vo.content.transform.ProgressCourseSummaryTransform")]
	public class ProgressCourseSummaryTransform extends XmlTransform {
		
		override public function transform(xml:XML):void {
			namespace xhtml = "http://www.w3.org/1999/xhtml";
			use namespace xhtml;
			
			for each (var course:XML in xml..script.(@id == "model")..course) {
				var stats:Object = { of: 0, count: 0, totalDone: 0, totalScore: 0, scoredCount: 0, durationCount: 0, duration: 0, averageScore: 0, averageDuration: 0, coverage: 0 };
				
				for each (var exercise:XML in course..exercise) {
					stats.of += 1;
					if (exercise.hasOwnProperty("@done") && Number(exercise.@done) > 0) {
						stats.count += 1;
						stats.totalDone += Number(exercise.@done);
					}
					
					for each (var score:XML in exercise.score) {
						// #232. #161. Don't let non-marked exercise scores impact the average
						if (score.hasOwnProperty("@score") && Number(score.@score) >= 0) {
							stats.totalScore += Number(score.@score);
							stats.scoredCount += 1;
						}
						
						// #318. 0 duration is for offline exercises (downloading a pdf for instance) so ignore it.
						if (score.hasOwnProperty("@duration") && Number(score.@duration) > 0) {
							stats.durationCount += 1;
							stats.duration += Number(score.@duration);
						}
					}
					
					if (stats.scoredCount > 0) stats.averageScore = Math.floor(stats.totalScore / stats.scoredCount);
					if (stats.durationCount > 0) stats.averageDuration = Math.floor(stats.duration / stats.durationCount);
					if (stats.of > 0) stats.coverage = Math.floor(stats.count / stats.of * 100);
				}
				
				// Now that everything has been calculated set the attributes on the course node
				for (var key:String in stats)
					course.@[key] = stats[key];
			}
		}
		
	}
}
