part of dock_spawn;


class TabPage {
  TabHost host;
  TabHandle handle;
  IDockContainer container;
  Element containerElement;
  bool selected = false;
  
  TabPage(this.host, this.container) {
    handle = new TabHandle(this);
    containerElement = container.containerElement;
  }
  
  void destroy() {
    handle.destroy();
  }
  
  void onSelected() {
    host.onTabPageSelected(this);
  }
  
  void setSelected(bool flag) {
    selected = flag;
    handle.setSelected(flag);
    
    if (selected) {
      host.contentElement.nodes.add(containerElement);
      // force a resize again
      int width = host.contentElement.clientWidth;
      int height = host.contentElement.clientHeight;
      container.resize(width, height);
    } else {
      containerElement.remove();
    }
  }

  void resize(int width, int height) {
    container.resize(width, height);
  }
}
