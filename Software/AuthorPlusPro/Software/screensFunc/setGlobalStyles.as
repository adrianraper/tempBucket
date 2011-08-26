/* import CSS style decoration */
import mx.styles.CSSStyleDeclaration;

/* function for copying CSS style decoration */
function copyCSSStyleDecoration(source, target) : Void {
	for (var style in source) {
	   target.setStyle(style, source.getStyle(style));
	}
}

/* set global styles
	this should eventually go 'coz all components will have their own styles
*/
_global.style.setStyle("themeColor", "haloOrange");

/* embed fonts
	Verdana is now embedded in the library
	set it as the default font of all UI components
	but it doesn't seem to be working with non-Latin alphabets
*/
_global.style.setStyle("fontFamily", "Verdana");
_global.style.setStyle("fontSize", 12);
_global.style.setStyle("fontWeight", "bold");
//_global.style.setStyle("embedFonts", true);

/* styles for Label */
_global.styles.Label = new CSSStyleDeclaration();
_global.styles.Label.setStyle("color", 0x000000);
_global.styles.Label.setStyle("fontSize", 12);
_global.styles.Label.setStyle("fontWeight", "bold");
_global.styles.Label.setStyle("fontFamily", "Verdana");

/* styles for TextInput & TextArea */
_global.styles.TextInput = new CSSStyleDeclaration();
_global.styles.TextInput.setStyle("color", 0x000000);
_global.styles.TextInput.setStyle("fontSize", 13);
_global.styles.TextInput.setStyle("fontWeight", "none");
_global.styles.TextInput.setStyle("backgroundColor", 0xFFFFFF);
_global.styles.TextInput.setStyle("fontFamily", "Verdana");

_global.styles.TextArea = new CSSStyleDeclaration();
_global.styles.TextArea.setStyle("color", 0x000000);
_global.styles.TextArea.setStyle("fontSize", 13);
_global.styles.TextArea.setStyle("fontWeight", "none");
_global.styles.TextArea.setStyle("backgroundColor", 0xFFFFFF);
_global.styles.TextArea.setStyle("fontFamily", "Verdana");

/* styles for ComboBox & List (DataGrid used in NNW) */
_global.styles.ComboBox = new CSSStyleDeclaration();
_global.styles.ComboBox.setStyle("color", 0x000000);
_global.styles.ComboBox.setStyle("fontSize", 13);
_global.styles.ComboBox.setStyle("fontWeight", "none");
_global.styles.ComboBox.setStyle("backgroundColor", 0xFFFFFF);
_global.styles.ComboBox.setStyle("fontFamily", "Verdana");

_global.styles.ScrollSelectList = new CSSStyleDeclaration();
_global.styles.ScrollSelectList.setStyle("color", 0x000000);
_global.styles.ScrollSelectList.setStyle("fontSize", 13);
_global.styles.ScrollSelectList.setStyle("fontWeight", "none");
_global.styles.ScrollSelectList.setStyle("backgroundColor", 0xFFFFFF);
_global.styles.ScrollSelectList.setStyle("fontFamily", "Verdana");

_global.styles.List = new CSSStyleDeclaration();
copyCSSStyleDecoration(_global.styles.ScrollSelectList, _global.styles.List);

_global.styles.DataGrid = new CSSStyleDeclaration();
copyCSSStyleDecoration(_global.styles.ScrollSelectList, _global.styles.DataGrid);

/* globally set tabEnabled = false */
Button.prototype.tabEnabled = false;
ComboBox.prototype.tabEnabled = false;
