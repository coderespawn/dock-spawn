part of dock_spawn;

abstract class SplitterDockContainer implements IDockContainer {
  String name;
  DockManager dockManager;
  SplitterPanel splitterPanel;
  String containerType;
  bool get stackedVertical;

  int _cachedWidth;
  int _cachedHeight;
  SplitterDockContainer(this.name, this.dockManager, List<IDockContainer> childContainers) {
    splitterPanel = new SplitterPanel(childContainers, stackedVertical);
  }
  
  
  void resize(int _width, int _height) {
//    if (_cachedWidth == _cachedWidth && _cachedHeight == _height) {
//      // No need to resize
//      return;
//    }
    splitterPanel.resize(_width, _height);
    _cachedWidth = _width;
    _cachedHeight = _height;
  }

  int get minimumAllowedChildNodes { return 2; }
  
  void performLayout(List<IDockContainer> childContainers) {
    splitterPanel.performLayout(childContainers);
  }
  
  void setActiveChild(IDockContainer child) {
  }
  
  void destroy() {
    splitterPanel.destroy();
  }

  /**
   * Sets the percentage of space the specified [container] takes in the split panel
   * The percentage is specified in [ratio] and is between 0..1
   */ 
  void setContainerRatio(IDockContainer container, num ratio) {
    splitterPanel.setContainerRatio(container, ratio);
    resize(width, height);
  }
  
  void saveState(Map<String, Object> state) {
    state['width'] = width;
    state['height'] = height;
  }
  
  void loadState(Map<String, Object> state) {
    num _width = state['width'];
    num _height = state['height'];
    resize(_width, _height);
  }
  
  Element get containerElement {
    return splitterPanel.panelElement;
  }

  int get width {
    if (_cachedWidth == null) {
      _cachedWidth = splitterPanel.panelElement.$dom_clientWidth;
    }
    return _cachedWidth;
//    return splitterPanel.panelElement.clientWidth;
  }
  
  int get height {
    if (_cachedHeight == null) {
      _cachedHeight = splitterPanel.panelElement.$dom_clientHeight;
    }
    return _cachedHeight; //splitterPanel.panelElement.clientHeight;
//    return splitterPanel.panelElement.clientHeight;
  }

}
