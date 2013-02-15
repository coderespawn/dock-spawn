part of dock_spawn;

/** 
 * A tab handle represents the tab button on the tab strip
 */
class TabHandle {
  static int zIndexCounter = 1000;
  DivElement elementBase;
  DivElement elementText;
  DivElement elementCloseButton;
  UndockInitiator undockInitiator;
  TabPage parent;
  var undockHandler;

  var mouseClickHandler;  // Button click handler for the tab handle
  var closeButtonHandler; // Button click handler for the close button
  
  TabHandle(this.parent) {
    undockHandler = _performUndock;
    elementBase = new DivElement();
    elementText = new DivElement();
    elementCloseButton = new DivElement();
    elementBase.classes.add("tab-handle");
    elementBase.classes.add("disable-selection"); // Disable text selection
    elementText.classes.add("tab-handle-text");
    elementCloseButton.classes.add("tab-handle-close-button");
    elementBase.nodes.add(elementText);
    if (parent.host.displayCloseButton) {
      elementBase.nodes.add(elementCloseButton);
    }
    
    parent.host.tabListElement.nodes.add(elementBase);
    
    PanelContainer panel = parent.container;
    String title = panel.getRawTitle();
    elementText.innerHtml = title;
    
    // Set the close button text (font awesome)
    String closeIcon = "icon-remove-sign";
    elementCloseButton.innerHtml = '<i class="$closeIcon"></i>';
    
    _bringToFront(elementBase);
    
    undockInitiator = new UndockInitiator(elementBase, undockHandler);
    undockInitiator.enabled = true;

    mouseClickHandler = onMouseClicked;
    elementBase.on.click.add(mouseClickHandler);
    
    closeButtonHandler = onCloseButtonClicked;
    elementCloseButton.on.mouseDown.add(closeButtonHandler);
    
  }
  
  void destroy() {
    elementBase.on.click.remove(mouseClickHandler);
    elementCloseButton.on.mouseDown.remove(closeButtonHandler);
    elementBase.remove();
    elementCloseButton.remove();
    elementBase = null;
    elementCloseButton = null;
  }

  Dialog _performUndock(MouseEvent e, Point2 dragOffset) {
    if (parent.container.containerType == "panel") {
      undockInitiator.enabled = false;
      PanelContainer panel = parent.container;
      return panel.performUndockToDialog(e, dragOffset);
    }
    else {
      return null;
    }
  }
  
  void onMouseClicked(MouseEvent e) {
    parent.onSelected();
  }
  
  void onCloseButtonClicked(MouseEvent e) {
    // If the page contains a panel element, undock it and destroy it
    if (parent.container.containerType == "panel") {
      undockInitiator.enabled = false;
      PanelContainer panel = parent.container;
      panel.performUndock();
    }
  }
  
  void setSelected(bool selected) {
    String selectedClassName = "tab-handle-selected";
    if (selected) {
      elementBase.classes.add(selectedClassName);
    } else {
      elementBase.classes.remove(selectedClassName);
    }
  }
  
  void setZIndex(int zIndex) {
    elementBase.style.zIndex = "$zIndex";
  }
  
  void _bringToFront(Element element) {
    element.style.zIndex = "$zIndexCounter";
    zIndexCounter++;
  }
}
