
///////////////////// JS Tree Views ////////////////////////////
$(function () {
	$("#solution_window").jstree({ "plugins" : ["themes","html_data","ui"], "core" : { "initially_open" : [ "solution_window_1" ] }})
	$("#toolbox_window").jstree({ "plugins" : ["themes","html_data","ui","crrm","hotkeys"], "core" : {	 }})
});

///////////////////// Code Mirror Editor ////////////////////////////
// Editor 1
var editor1 = CodeMirror(document.getElementById("editor1_window"), {
  lineNumbers: true,
  matchBrackets: true,
  mode: "text/x-csrc",
  value: source_steering_h,
  onCursorActivity: function() {
    editor1.setLineClass(editorLine1, null, null);
    editorLine1 = editor1.setLineClass(editor1.getCursor().line, null, "activeline");
  }
});
var editorLine1 = editor1.setLineClass(0, "activeline");

// Editor 2
var editor2 = CodeMirror(document.getElementById("editor2_window"), {
  lineNumbers: true,
  matchBrackets: true,
  mode: "text/x-csrc",
  value: source_steering_cpp,
  onCursorActivity: function() {
    editor2.setLineClass(editorLine2, null, null);
    editorLine2 = editor2.setLineClass(editor2.getCursor().line, null, "activeline");
  }
});
var editorLine2 = editor2.setLineClass(0, "activeline");

// Output Window
var editorOutput = CodeMirror(document.getElementById("output_window"), {
  value: "[info] program exited with code 0"
});

////////////////////////////////////////////////////////////////

