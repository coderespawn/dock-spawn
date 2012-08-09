
class FillDockContainer implements IDockContainer {
  String containerType = "fill";
  DivElement element;
  DockManager dockManager;
  TabHost tabHost;
  int tabOrientation = TabHost.DIRECTION_BOTTOM;
  int get minimumAllowedChildNodes() { return 2; }
  String name;
  
  FillDockContainer([int tabStripDirection = TabHost.DIRECTION_BOTTOM]) {
    this.tabOrientation = tabStripDirection;
    name = getNextId("fill_");
    element = new DivElement();
    element.classes.add("dock-container");
    element.classes.add("dock-container-fill");
    
    tabHost = new TabHost(tabStripDirection: tabOrientation);
    element.nodes.add(tabHost.hostElement);
  }

  
  void setActiveChild(IDockContainer child) {
    tabHost.setActiveTab(child);
  }
  
  void resize(int _width, int _height) {
    element.style.width = "${_width}px";
    element.style.height = "${_height}px";
    tabHost.resize(_width, _height);
  }
  
  void performLayout(List<IDockContainer> children) {
    tabHost.performLayout(children);
  }
  
  void destroy() {
    element.remove();
    element = null;
  }

  void saveState(Map<String, Object> state) {
    state['width'] = width;
    state['height'] = height;
  }
  
  void loadState(Map<String, Object> state) {
    width = state['width'];
    height = state['height'];
  }
  
  Element get containerElement() {
    return element;
  }
  
  int get width() {
    return element.$dom_clientWidth;
  }
  void set width(int value) {
    element.style.width = "${value}px";
    tabHost.resize(value, height);
  }

  int get height() {
    return element.$dom_clientHeight;
  }
  void set height(int value) {
    element.style.height = "${value}px";
    tabHost.resize(width, value);
  }
  

}
