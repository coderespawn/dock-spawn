
abstract class SplitterDockContainer implements IDockContainer {
  String name;
  SplitterPanel splitterPanel;
  String containerType;
  abstract bool get stackedVertical();
  
  SplitterDockContainer(this.name, List<IDockContainer> childContainers) {
    splitterPanel = new SplitterPanel(childContainers, stackedVertical);
  }
  
  void resize(int _width, int _height) {
    splitterPanel.resize(_width, _height);
  }

  int get minimumAllowedChildNodes() { return 2; }
  
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
  
  Element get containerElement() {
    return splitterPanel.panelElement;
  }

  int get width() {
    return splitterPanel.panelElement.$dom_clientWidth;
  }
  
  void set width(int value) {
    splitterPanel.resize(value, height);
  }
  
  int get height() {
    return splitterPanel.panelElement.$dom_clientHeight;
  }

  void set height(int value) {
    splitterPanel.resize(width, value);
  }
}
