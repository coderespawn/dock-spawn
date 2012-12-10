part of dock_spawn;

/** 
 * The document manager is then central area of the dock layout hierarchy.  
 * This is where more important panels are placed (e.g. the text editor in an IDE,
 * 3D view in a modelling package etc 
 */
class DocumentManagerContainer extends FillDockContainer {

  int get minimumAllowedChildNodes { return 0; }
  
  DocumentManagerContainer(DockManager dockManager)
      : super(dockManager, TabHost.DIRECTION_TOP)
  {
    element.classes.add("document-manager");
    tabHost.createTabPage = _createDocumentTabPage;
    tabHost.displayCloseButton = true;
  }

  TabPage _createDocumentTabPage(TabHost _tabHost, IDockContainer container) {
    return new DocumentTabPage(_tabHost, container);
  }

  void saveState(Map<String, Object> state) {
    super.saveState(state);
    state['documentManager'] = true;
  }
  
  /** Returns the selected document tab */
  TabPage get selectedTab => tabHost.activeTab;
}

/**
 * Specialized tab page that doesn't display the panel's frame when docked in a tab page 
 */
class DocumentTabPage extends TabPage {
  PanelContainer panel = null;
  
  DocumentTabPage(TabHost _host, IDockContainer _container) : super(_host, _container)
  {
    // If the container is a panel, extract the content element and set it as the tab's content
    if (container.containerType == "panel") {
      panel = container;
      containerElement = panel.elementContent;
      
      // detach the container element from the panel's frame.  
      // It will be reattached when this tab page is destroyed
      // This enables the panel's frame (title bar etc) to be hidden
      // inside the tab page
      containerElement.remove();
    }
  }

  void destroy() {
    super.destroy();

    // Restore the panel content element back into the panel frame
    panel.elementContentHost.nodes.add(containerElement);
  }
}
