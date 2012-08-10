/**
 * A custom panel that manages the Code Mirror editor control
 */
class EditorPanel extends PanelContainer {
  /**
   * Code Mirror source code control's wrapped elements. Save a reference for resizing later on
   * http://codemirror.net/doc/manual.html
   */ 
  Element codeMirrorBase;
  Element codeMirrorScroller; 
  Element codeMirrorScrollBar; 
  
  EditorPanel(Element elementContent, DockManager dockManager, [String title = "Panel"])
      : super(elementContent, dockManager, title)
  {
    _initialize();
  }
  
  void resize(int _width, int _height) {
    super.resize(_width, _height);
    int clientWidth = elementContent.$dom_clientWidth;
    int clientHeight = elementContent.$dom_clientHeight;
    
    codeMirrorBase.style.width = "${clientWidth}px";
    codeMirrorBase.style.height = "${clientHeight}px";
    codeMirrorScroller.style.height = "${clientHeight}px";
    codeMirrorScrollBar.style.height = "${clientHeight}px";
  }
  
  void _initialize() {
    // Find the wrapper divs created by the code mirror control so we can resize them later on
    for (var element in elementContent.nodes) {
      if (element is DivElement) {
        Element div = element;
        if (div.classes.contains("CodeMirror")) {
          codeMirrorBase = div;
          break;
        }  
      }
    }
    if (codeMirrorBase == null) {
      throw new IdeException("Not a valid editor control. Make sure code mirror is initailized with this panel");
    }
    
    // Search for the scoll element for setting the height on resize
    for (var element in codeMirrorBase.nodes) {
      if (element is DivElement) {
        DivElement div = element;
        if (div.classes.contains("CodeMirror-scroll")) {
          codeMirrorScroller = div;
        }
        if (div.classes.contains("CodeMirror-scrollbar")) {
          codeMirrorScrollBar = div;
        }
      }
    }
    if (codeMirrorScroller == null || codeMirrorScrollBar == null) {
      throw new IdeException("Not a valid editor control. Cannot find scroller. Make sure code mirror is initailized with this panel");
    }
  }
}
