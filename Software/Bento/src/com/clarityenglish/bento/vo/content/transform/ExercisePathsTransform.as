package com.clarityenglish.bento.vo.content.transform {

/**
 * This transform looks for symbolic paths in an exercise and substitutes based on paths from config
 * gh#1356
 */

	[RemoteClass(alias = "com.clarityenglish.bento.vo.content.transform.ExercisePathsTransform")]
	public class ExercisePathsTransform extends XmlTransform {
        private var paths:Object;

        public function ExercisePathsTransform(paths:Object) {
            // gh#1408
            this.transformName = "ExercisePathsTransform";
            this.paths = paths;
        }

        override public function transform(xml:XML):void {
            namespace xhtml = "http://www.w3.org/1999/xhtml";

            use namespace xhtml;

            var replaceObj:Object = {contentPath: this.paths.content, sharedMedia: this.paths.sharedMedia};

            // Find any hrefs with a symbol in the path and substitute it
            for each (var node:XML in xml..a) {
                if (node.hasOwnProperty("@href"))
                    node.@href = substTags(node.@href, replaceObj);
            }
        }

        protected function substTags(target:String, replaceObj:Object):String {
            if (replaceObj) {
                for (var searchString:String in replaceObj) {
                    var regExp:RegExp = new RegExp("\{" + searchString + "\}", "g");
                    target = target.replace(regExp, replaceObj[searchString]);
                }
            }
            return target;
        }
    }
}
