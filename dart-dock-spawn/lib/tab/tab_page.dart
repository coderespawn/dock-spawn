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
    
    if (container is PanelContainer) {
      PanelContainer panel = container;
      panel.onTitleChanged = onTitleChanged;
    }
  }
  
  void onTitleChanged(IDockContainer sender, String title) {
    handle.updateTitle();
  }
  
  void destroy() {
    handle.destroy();

    if (container is PanelContainer) {
      PanelContainer panel = container;
      panel.onTitleChanged = null;
    }
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
      int width = host.contentElement.client.width;
      int height = host.contentElement.client.height;
      container.resize(width, height);
    } else {
      containerElement.remove();
    }
  }

  void resize(int width, int height) {
    container.resize(width, height);
  }
}
