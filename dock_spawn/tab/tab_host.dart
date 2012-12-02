part of dock_spawn;


/**
 * Tab Host control contains tabs known as TabPages. 
 * The tab strip can be aligned in different orientations
 */
class TabHost {
  DivElement hostElement;       // The main tab host DOM element
  DivElement contentElement;    // Hosts the active tab content
  DivElement tabListElement;    // Hosts the tab handles
  DivElement separatorElement;  // A seperator line between the tabs and content
  TabPage activeTab = null;
  List<TabPage> pages;
  CreateTabPage createTabPage;  // Factory for creating tab pages
  OnTabChanged onTabChanged;  // Callback to notify if the active tab page has changed

  static const int DIRECTION_TOP = 0;
  static const int DIRECTION_BOTTOM = 1;
  static const int DIRECTION_LEFT = 2;
  static const int DIRECTION_RIGHT = 3;
  
  // Indicates if the close button next to the tab handle should be displayed
  bool displayCloseButton;
  
  /**
   * Create a tab host with the tab strip aligned in the [tabStripDirection] direciton
   * Only TabHost.DIRECTION_BOTTOM and TabHost.DIRECTION_TOP are supported
   */
  TabHost([int tabStripDirection = TabHost.DIRECTION_BOTTOM, this.displayCloseButton = false]) {
    pages = new List<TabPage>();
    hostElement = new DivElement();
    tabListElement = new DivElement();
    separatorElement = new DivElement();
    contentElement = new DivElement();
    createTabPage = _createDefaultTabPage;

    if (tabStripDirection == TabHost.DIRECTION_BOTTOM) {
      hostElement.nodes.add(contentElement);
      hostElement.nodes.add(separatorElement);
      hostElement.nodes.add(tabListElement);
    }
    else if (tabStripDirection == TabHost.DIRECTION_TOP) {
      hostElement.nodes.add(tabListElement);
      hostElement.nodes.add(separatorElement);
      hostElement.nodes.add(contentElement);
    }
    else {
      throw new DockException("Only top and bottom tab strip orientations are supported");
    }
    
    hostElement.classes.add("tab-host");
    tabListElement.classes.add("tab-handle-list-container");
    separatorElement.classes.add("tab-handle-content-seperator");
    contentElement.classes.add("tab-content");
  }
  
  TabPage _createDefaultTabPage(TabHost tabHost, IDockContainer container) {
    return new TabPage(tabHost, container);
  }

  void setActiveTab(IDockContainer container) {
    pages.forEach((page) {
      if (page.container == container) {
        onTabPageSelected(page);
        return;
      }
    });
  }
  
  void resize(int width, int height) {
    hostElement.style.width = "${width}px";
    hostElement.style.height = "${height}px";
    
    int tabHeight = tabListElement.clientHeight;
    int separatorHeight = separatorElement.clientHeight;
    int contentHeight = height - tabHeight - separatorHeight;
    contentElement.style.height = "${contentHeight}px";
    
    if (activeTab != null) {
      activeTab.resize(width, contentHeight);
    }
  }
  
  void performLayout(List<IDockContainer> children) {
    // Destroy all existing tab pages
    pages.forEach((tab) {
      tab.destroy();
    });
    pages.clear();
    
    TabPage oldActiveTab = activeTab;
    activeTab = null;
    
    List<IDockContainer> childPanels = children.filter((child) {
      return child.containerType == "panel";
    });
    
    if (childPanels.length > 0) {
      // Rebuild new tab pages
      childPanels.forEach((child) {
        var page = createTabPage(this, child);
        pages.add(page);
        
        // Restore the active selected tab
        if (oldActiveTab != null && page.container == oldActiveTab.container) {
          activeTab = page;
        }
      });
      _setTabHandlesVisible(true);
    }
    else {
      // Do not show an empty tab handle host with zero tabs
      _setTabHandlesVisible(false);
    }
    
    if (activeTab != null) {
      onTabPageSelected(activeTab);
    }
  }
  
  void _setTabHandlesVisible(bool visible) {
    tabListElement.style.display = visible ? "block" : "none";
    separatorElement.style.display = visible ? "block" : "none";
  }
  
  void onTabPageSelected(TabPage page) {
    activeTab = page;
    pages.forEach((tabPage) {
      bool selected = (tabPage == activeTab); 
      tabPage.setSelected(selected);
    });
    
    // adjust the zIndex of the tabs to have proper shadow/depth effect
    int zIndexDelta = 1;
    int zIndex = 1000;
    pages.forEach((tabPage) {
      tabPage.handle.setZIndex(zIndex);
      bool selected = (tabPage == activeTab); 
      if (selected) zIndexDelta = -1;
      zIndex += zIndexDelta;
    });
    
    // If a callback is defined, then notify it of this event
    if (onTabChanged != null) {
      onTabChanged(this, page);
    }
  }
}


typedef TabPage CreateTabPage(TabHost tabHost, IDockContainer container);
typedef void OnTabChanged(TabHost tabHost, TabPage tabPage);
