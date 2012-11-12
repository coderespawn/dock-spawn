
/**
 * Manages the dock overlay buttons that are displayed over the dock manager
 */
class DockWheel {
  DockManager dockManager;
  DivElement elementMainWheel;  // Contains the main wheel's 5 dock buttons
  DivElement elementSideWheel;  // Contains the 4 buttons on the side
  DivElement elementPanelPreview; // Used for showing the preview of where the panel would be docked 
  Map<String, DockWheelItem> wheelItems;
  Dialog activeDialog;  // The dialog being dragged, when the wheel is visible
  bool _visible = false;
  
  /** The node over which the dock wheel is being displayed on */
  DockNode _activeNode;
  DockNode get activeNode() {
    return _activeNode;
  }
  void set activeNode(DockNode value) {
    var previousValue = _activeNode;
    _activeNode = value;

    if (previousValue != _activeNode) {
      // The active node has been changed. 
      // Reattach the wheel to the new node's element and show it again
      if (_visible) {
        showWheel();
      }
    }
  }
  
  DockWheel(this.dockManager) {
    elementMainWheel = new DivElement();
    elementSideWheel = new DivElement();
    wheelItems = new Map<String, DockWheelItem>();
    var wheelTypes = [
        "left", "right", "top", "down", "fill",     // Main dock wheel buttons
        "left-s", "right-s", "top-s", "down-s",     // Buttons on the extreme 4 sides
    ];
    wheelTypes.forEach((String wheelType) {
      wheelItems[wheelType] = new DockWheelItem(this, wheelType);
      if (wheelType.endsWith("-s")) {
        // Side button
        elementSideWheel.nodes.add(wheelItems[wheelType].element);
      } else {
        // Main dock wheel button
        elementMainWheel.nodes.add(wheelItems[wheelType].element);
      }
    });

    int zIndex = 100000;
    elementMainWheel.classes.add("dock-wheel-base");
    elementSideWheel.classes.add("dock-wheel-base");
    elementMainWheel.style.zIndex = "${zIndex + 1}";
    elementSideWheel.style.zIndex = "$zIndex";
    
    elementPanelPreview = new DivElement();
    elementPanelPreview.classes.add("dock-wheel-panel-preview");
    elementPanelPreview.style.zIndex = "${zIndex - 1}";
  }
  
  void showWheel() {
    _visible = true;
    if (activeNode == null) {
      // No active node selected. make sure the wheel is invisible
      elementMainWheel.remove();
      elementSideWheel.remove();
      return;
    }
    Element element = activeNode.container.containerElement;
    int containerWidth = element.clientWidth;
    int containerHeight = element.clientHeight;
    int baseX = (containerWidth / 2).toInt() + element.offsetLeft;
    int baseY = (containerHeight / 2).toInt() + element.offsetTop;
    elementMainWheel.style.left = "${baseX}px";
    elementMainWheel.style.top = "${baseY}px";
    
    // The positioning of the main dock wheel buttons is done automatically through CSS
    // Dynamically calculate the positions of the buttons on the extreme sides of the dock manager
    num sideMargin = 20;
    num dockManagerWidth = dockManager.element.clientWidth;
    num dockManagerHeight = dockManager.element.clientHeight;
    num dockManagerOffsetX = dockManager.element.offsetLeft;
    num dockManagerOffsetY = dockManager.element.offsetTop;

    elementMainWheel.remove();
    elementSideWheel.remove();
    element.nodes.add(elementMainWheel);
    dockManager.element.nodes.add(elementSideWheel);

    _setWheelButtonPosition("left-s",   sideMargin, -dockManagerHeight / 2);
    _setWheelButtonPosition("right-s",  dockManagerWidth - sideMargin * 2, -dockManagerHeight / 2);
    _setWheelButtonPosition("top-s",    dockManagerWidth / 2, -dockManagerHeight + sideMargin);
    _setWheelButtonPosition("down-s",   dockManagerWidth / 2, -sideMargin);
    
  }
  
  void _setWheelButtonPosition(String wheelId, num left, num top) {
    DockWheelItem item = wheelItems[wheelId];
    num itemHalfWidth = item.element.clientWidth / 2;
    num itemHalfHeight = item.element.clientHeight / 2;
    
    int x = (left - itemHalfWidth).toInt();
    int y = (top - itemHalfHeight).toInt();
//    item.element.style.left = "${x}px";
//    item.element.style.top = "${y}px";
    item.element.style.marginLeft = "${x}px";
    item.element.style.marginTop = "${y}px";
  }
  
  void hideWheel() {
    _visible = false;
    activeNode = null;
    elementMainWheel.remove();
    elementSideWheel.remove();
    elementPanelPreview.remove();
    
    // deactivate all wheels
    wheelItems.values.forEach((item) => item.active = false);
  }
  
  void onMouseOver(DockWheelItem wheelItem, MouseEvent e) {
    if (activeDialog == null) return;
    
    // Display the preview panel to show where the panel would be docked
    DockNode rootNode = dockManager.context.model.rootNode;
    Rectangle bounds;
    if (wheelItem.id == "top") {
      bounds = dockManager.layoutEngine.getDockBounds(_activeNode, activeDialog.panel, "vertical", true);
    } else if (wheelItem.id == "down") {
      bounds = dockManager.layoutEngine.getDockBounds(_activeNode, activeDialog.panel, "vertical", false);
    } else if (wheelItem.id == "left") {
      bounds = dockManager.layoutEngine.getDockBounds(_activeNode, activeDialog.panel, "horizontal", true);
    } else if (wheelItem.id == "right") {
      bounds = dockManager.layoutEngine.getDockBounds(_activeNode, activeDialog.panel, "horizontal", false);
    } else if (wheelItem.id == "fill") {
      bounds = dockManager.layoutEngine.getDockBounds(_activeNode, activeDialog.panel, "fill", false);
    } else if (wheelItem.id == "top-s") {
      bounds = dockManager.layoutEngine.getDockBounds(rootNode, activeDialog.panel, "vertical", true);
    } else if (wheelItem.id == "down-s") {
      bounds = dockManager.layoutEngine.getDockBounds(rootNode, activeDialog.panel, "vertical", false);
    } else if (wheelItem.id == "left-s") {
      bounds = dockManager.layoutEngine.getDockBounds(rootNode, activeDialog.panel, "horizontal", true);
    } else if (wheelItem.id == "right-s") {
      bounds = dockManager.layoutEngine.getDockBounds(rootNode, activeDialog.panel, "horizontal", false);
    }
    
    if (bounds != null) {
      dockManager.element.nodes.add(elementPanelPreview);
      elementPanelPreview.style.left = "${bounds.x.toInt()}px";
      elementPanelPreview.style.top = "${bounds.y.toInt()}px";
      elementPanelPreview.style.width = "${bounds.width.toInt()}px";
      elementPanelPreview.style.height = "${bounds.height.toInt()}px";
    }
  }
  void onMouseOut(DockWheelItem wheelItem, MouseEvent e) {
    elementPanelPreview.remove();
  }
  
  /**
   * Called if the dialog is dropped in a dock panel.  
   * The dialog might not necessarily be dropped in one of the dock wheel buttons,
   * in which case the request will be ignored
   */
  void onDialogDropped(Dialog dialog) {
    // Check if the dialog was dropped in one of the wheel items
    DockWheelItem wheelItem = _getActiveWheelItem();
    if (wheelItem != null) {
      _handleDockRequest(wheelItem, dialog);
    }
  }
  
  /**
   * Returns the wheel item which has the mouse cursor on top of it
   */
  DockWheelItem _getActiveWheelItem() {
    for (var wheelItem in wheelItems.values) {
      if (wheelItem.active) {
        return wheelItem;
      }
    }
    return null;
  }
  
  void _handleDockRequest(DockWheelItem wheelItem, Dialog dialog) {
    if (_activeNode == null) return;
    if (wheelItem.id == "left") {
      dockManager.dockDialogLeft(_activeNode, dialog);
    } else if (wheelItem.id == "right") {
      dockManager.dockDialogRight(_activeNode, dialog);
    } else if (wheelItem.id == "top") {
      dockManager.dockDialogUp(_activeNode, dialog);
    } else if (wheelItem.id == "down") {
      dockManager.dockDialogDown(_activeNode, dialog);
    } else if (wheelItem.id == "fill") {
      dockManager.dockDialogFill(_activeNode, dialog);
    } else if (wheelItem.id == "left-s") {
      dockManager.dockDialogLeft(dockManager.context.model.rootNode, dialog);
    } else if (wheelItem.id == "right-s") {
      dockManager.dockDialogRight(dockManager.context.model.rootNode, dialog);
    } else if (wheelItem.id == "top-s") {
      dockManager.dockDialogUp(dockManager.context.model.rootNode, dialog);
    } else if (wheelItem.id == "down-s") {
      dockManager.dockDialogDown(dockManager.context.model.rootNode, dialog);
    }
  }
}


class DockWheelItem {
  String id;
  DivElement element;
  DockWheel wheel;
  String hoverIconClass;
  var mouseOverHandler;
  var mouseOutHandler;
  var mouseUpHandler;
  bool active = false;    // Becomes active when the mouse is hovered over it
  
  DockWheelItem(this.wheel, this.id) {
    var wheelType = id.replaceAll("-s", "");
    element = new DivElement();
    element.classes.add("dock-wheel-item");
    element.classes.add("disable-selection");
    element.classes.add("dock-wheel-$wheelType");
    element.classes.add("dock-wheel-$wheelType-icon");
    hoverIconClass = "dock-wheel-$wheelType-icon-hover";
    mouseOverHandler = onMouseMoved;
    mouseOutHandler = onMouseOut;
    element.on.mouseOver.add(mouseOverHandler);
    element.on.mouseOut.add(mouseOutHandler);
  }

  void onMouseMoved(MouseEvent e) {
    active = true;
    element.classes.add(hoverIconClass);
    wheel.onMouseOver(this, e);
  }
  
  void onMouseOut(MouseEvent e) {
    active = false;
    element.classes.remove(hoverIconClass);
    wheel.onMouseOut(this, e);
  }
}