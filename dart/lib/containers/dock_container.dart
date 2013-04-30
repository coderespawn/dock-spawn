part of dock_spawn;

/**
 * Any dockable entity needs to implement this inteface
 */
abstract class IDockContainer {
  DockManager get dockManager;
  void resize(int _width, int _height);
  void performLayout(List<IDockContainer> children);
  void destroy();
  void setActiveChild(IDockContainer child);
  void saveState(Map<String, Object> state);
  void loadState(Map<String, Object> state);
  Element get containerElement;
  String containerType;
  int get width;
  int get height;
  String name;
  
  /** 
   * Indicates the minimum allowed child nodes a composite dock panel can have
   * If it's children fall below this value, the composite panel is destroyed
   * and it's children are moved one level up 
   */
  int get minimumAllowedChildNodes;
}

