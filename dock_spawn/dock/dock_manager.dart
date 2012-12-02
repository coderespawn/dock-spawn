part of dock_spawn;

/**
 * Dock manager manages all the dock panels in a hierarchy, similar to visual studio.
 * It owns a Html Div element inside which all panels are docked
 * Initially the document manager takes up the central space and acts as the root node
 */
class DockManager implements DialogEventListener {
  DockManagerContext context;
  DockWheel dockWheel;
  DockLayoutEngine layoutEngine;
  DivElement element;
  var mouseMoveHandler;
  
  DockManager(this.element) {
    if (this.element == null) {
      throw new DockException("Invalid Dock Manager element provided");
    }
    mouseMoveHandler = onMouseMoved;
  }

  void initialize() {
    context = new DockManagerContext(this);
    DockNode documentNode = new DockNode(context.documentManagerView);
    context.model.rootNode = documentNode;
    context.model.documentManagerNode = documentNode;
    setRootNode(context.model.rootNode);
    // Resize the layout
    resize(element.clientWidth, element.clientHeight);
    dockWheel = new DockWheel(this);
    layoutEngine = new DockLayoutEngine(this);
    
    rebuildLayout(context.model.rootNode);
  }
  
  void rebuildLayout(DockNode node) {
    node.children.forEach((child) => rebuildLayout(child));
    node.performLayout();
  }
  
  void invalidate() {
    resize(element.clientWidth, element.clientHeight);
  }
    
  void resize(int width, int height) {
    element.style.width = "${width}px";
    element.style.height = "${height}px";
    context.model.rootNode.container.resize(width, height);
  }
  
  /**
   * Reset the dock model . This happens when the state is loaded from json
   */
  void setModel(DockModel model) {
    context.documentManagerView.containerElement.remove();
    context.model = model;
    setRootNode(model.rootNode);
    
    rebuildLayout(model.rootNode);
    invalidate();
  }
  
  void setRootNode(DockNode node) {
    if (context.model.rootNode != null) {
      // detach it from the dock manager's base element
//      context.model.rootNode.detachFromParent();
    }

    // Attach the new node to the dock manager's base element and set as root node
    node.detachFromParent();
    context.model.rootNode = node;
    element.nodes.add(node.container.containerElement);
  }
  

  void onDialogDragStarted(Dialog sender, MouseEvent e) {
    dockWheel.activeNode = _findNodeOnPoint(e.pageX, e.pageY);
    dockWheel.activeDialog = sender;
    dockWheel.showWheel();
    window.on.mouseMove.add(mouseMoveHandler);
  }
  
  void onDialogDragEnded(Dialog sender, MouseEvent e) {
    window.on.mouseMove.remove(mouseMoveHandler);
    dockWheel.onDialogDropped(sender);
    dockWheel.hideWheel();
    dockWheel.activeDialog = null;
  }
  
  void onMouseMoved(MouseEvent e) {
    dockWheel.activeNode = _findNodeOnPoint(e.pageX, e.pageY);
  }
  
  /**
   * Perform a DFS on the dock model's tree to find the 
   * deepest level panel (i.e. the top-most non-overlapping panel) 
   * that is under the mouse cursor
   * Retuns null if no node is found under this point
   */
  DockNode _findNodeOnPoint(x, y) {
    var stack = new List<DockNode>();
    stack.add(context.model.rootNode);
    DockNode bestMatch = null;
    
    while (stack.length > 0) {
      var topNode = stack.last; // peek
      stack.removeLast();         // pop
      
      if (isPointInsideNode(x, y, topNode)) {
        // This node contains the point. 
        bestMatch = topNode;
        
        // Keep looking future down
        stack.addAll(topNode.children);
      }
    }
    return bestMatch;
  }
  
  /** Dock the [dialog] to the left of the [referenceNode] node */
  DockNode dockDialogLeft(DockNode referenceNode, Dialog dialog) {
    return _requestDockDialog(referenceNode, dialog, layoutEngine.dockLeft);
  }

  /** Dock the [dialog] to the right of the [referenceNode] node */
  DockNode dockDialogRight(DockNode referenceNode, Dialog dialog) {
    return _requestDockDialog(referenceNode, dialog, layoutEngine.dockRight);
  }

  /** Dock the [dialog] above the [referenceNode] node */
  DockNode dockDialogUp(DockNode referenceNode, Dialog dialog) {
    return _requestDockDialog(referenceNode, dialog, layoutEngine.dockUp);
  }

  /** Dock the [dialog] below the [referenceNode] node */
  DockNode dockDialogDown(DockNode referenceNode, Dialog dialog) {
    return _requestDockDialog(referenceNode, dialog, layoutEngine.dockDown);
  }

  /** Dock the [dialog] as a tab inside the [referenceNode] node */
  DockNode dockDialogFill(DockNode referenceNode, Dialog dialog) {
    return _requestDockDialog(referenceNode, dialog, layoutEngine.dockFill);
  }

  /** Dock the [container] to the left of the [referenceNode] node */
  DockNode dockLeft(DockNode referenceNode, IDockContainer container, [num ratio]) {
    return _requestDockContainer(referenceNode, container, layoutEngine.dockLeft, ratio);
  }

  /** Dock the [container] to the right of the [referenceNode] node */
  DockNode dockRight(DockNode referenceNode, IDockContainer container, [num ratio]) {
    return _requestDockContainer(referenceNode, container, layoutEngine.dockRight, ratio);
  }

  /** Dock the [container] above the [referenceNode] node */
  DockNode dockUp(DockNode referenceNode, IDockContainer container, [num ratio]) {
    return _requestDockContainer(referenceNode, container, layoutEngine.dockUp, ratio);
  }

  /** Dock the [container] below the [referenceNode] node */
  DockNode dockDown(DockNode referenceNode, IDockContainer container, [num ratio]) {
    return _requestDockContainer(referenceNode, container, layoutEngine.dockDown, ratio);
  }

  /** Dock the [container] as a tab inside the [referenceNode] node */
  DockNode dockFill(DockNode referenceNode, IDockContainer container) {
    return _requestDockContainer(referenceNode, container, layoutEngine.dockFill, null);
  }

  DockNode _requestDockDialog(DockNode referenceNode, Dialog dialog, LayoutEngineDockFunction layoutDockFunction) {
    // Get the active dialog that was dragged on to the dock wheel
    var panel = dialog.panel;
    var newNode = new DockNode(panel);
    panel.prepareForDocking();
    dialog.destroy();
    layoutDockFunction(referenceNode, newNode);
    invalidate();
    return newNode;
  }

  DockNode _requestDockContainer(DockNode referenceNode, IDockContainer container, LayoutEngineDockFunction layoutDockFunction, num ratio) {
    // Get the active dialog that was dragged on to the dock wheel
    var newNode = new DockNode(container);
    if (container.containerType == "panel") {
      PanelContainer panel = container;
      panel.prepareForDocking();
      panel.elementPanel.remove();
    }
    layoutDockFunction(referenceNode, newNode);
    
    if (ratio != null && newNode.parent != null &&
        (newNode.parent.container.containerType == "vertical" || newNode.parent.container.containerType == "horizontal")) {
      SplitterDockContainer splitter = newNode.parent.container;
      splitter.setContainerRatio(container, ratio);
    }
    
    rebuildLayout(context.model.rootNode);
    invalidate();
    return newNode;
  }
  
  /** 
   * Undocks a panel and converts it into a floating dialog window
   * It is assumed that only leaf nodes (panels) can be undocked
   */ 
  Dialog requestUndockToDialog(IDockContainer container, MouseEvent event, Point2 dragOffset) {
    DockNode node = _findNodeFromContainer(container);
    layoutEngine.undock(node);

    // Create a new dialog window for the undocked panel
    var dialog = new Dialog(node.container, this);

    // Adjust the relative position
    num dialogWidth = dialog.elementDialog.clientWidth;
    if (dragOffset.x > dialogWidth) {
      dragOffset.x = 0.75 * dialogWidth;
    }
    dialog.setPosition(
        event.pageX - dragOffset.x, 
        event.pageY - dragOffset.y);
    dialog.draggable.onMouseDown(event);

    return dialog;
  }

  /** Undocks a panel and converts it into a floating dialog window
   * It is assumed that only leaf nodes (panels) can be undocked
   */ 
  void requestUndock(IDockContainer container) {
    DockNode node = _findNodeFromContainer(container);
    layoutEngine.undock(node);
  }
  
  
  /** 
   * Removes a dock container from the dock layout hierarcy
   * Returns the node that was removed from the dock tree 
   */ 
  DockNode requestRemove(IDockContainer container) {
    DockNode node = _findNodeFromContainer(container);
    DockNode parent = node.parent;
    node.detachFromParent();
    if (parent != null) {
      rebuildLayout(parent);
    }
    return node;
  }
  
  
  /** Finds the node that owns the specified [container] */
  DockNode _findNodeFromContainer(IDockContainer container) {
    var stack = new List<DockNode>();
    stack.add(context.model.rootNode);

    while (stack.length > 0) {
      var topNode = stack.last; // peek
      stack.removeLast();         // pop
      
      if (topNode.container == container) {
        return topNode;
      }
      stack.addAll(topNode.children);
    }
    
    throw new DockException("Cannot find dock node beloging to the element");
  }
  
  String saveState() {
    var serializer = new DockGraphSerializer();
    return serializer.serialize(context.model);
  }
  
  void loadState(String json) {
    var deserializer = new DockGraphDeserializer(this);
    context.model = deserializer.deserialize(json);
    setModel(context.model);
  }
  
}

typedef void LayoutEngineDockFunction(DockNode referenceNode, DockNode newNode); 
