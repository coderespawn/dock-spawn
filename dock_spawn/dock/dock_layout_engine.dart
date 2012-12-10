part of dock_spawn;

class DockLayoutEngine {
  DockManager dockManager;

  DockLayoutEngine(this.dockManager);
  
  /** docks the [newNode] to the left of [referenceNode] */
  void dockLeft(DockNode referenceNode, DockNode newNode) {
    _performDock(referenceNode, newNode, "horizontal", true);
  }
  
  /** docks the [newNode] to the right of [referenceNode] */
  void dockRight(DockNode referenceNode, DockNode newNode) {
    _performDock(referenceNode, newNode, "horizontal", false);
  }
  
  /** docks the [newNode] to the top of [referenceNode] */
  void dockUp(DockNode referenceNode, DockNode newNode) {
    _performDock(referenceNode, newNode, "vertical", true);
  }
  
  /** docks the [newNode] to the bottom of [referenceNode] */
  void dockDown(DockNode referenceNode, DockNode newNode) {
    _performDock(referenceNode, newNode, "vertical", false);
  }
  
  /** docks the [newNode] by creating a new tab inside [referenceNode] */
  void dockFill(DockNode referenceNode, DockNode newNode) {
    _performDock(referenceNode, newNode, "fill", false);
  }
  
  void undock(DockNode node) {
    DockNode parentNode = node.parent;
    if (parentNode == null) {
      throw new DockException("Cannot undock.  panel is not a leaf node");
    }
    
    // Get the position of the node relative to it's siblings
    int siblingIndex = parentNode.children.indexOf(node);
    
    // Detach the node from the dock manager's tree hierarchy
    node.detachFromParent();
    
    // Fix the node's parent hierarchy
    if (parentNode.children.length < parentNode.container.minimumAllowedChildNodes) {
      // If the child count falls below the minimum threshold, destroy the parent and merge 
      // the children with their grandparents
      DockNode grandParent = parentNode.parent;
      parentNode.children.forEach((otherChild) {
        if (grandParent != null) {
          // parent node is not a root node
          grandParent.addChildAfter(parentNode, otherChild);
          parentNode.detachFromParent();
          parentNode.container.destroy();
          grandParent.performLayout();
        }
        else {
          // Parent is a root node.  
          // Make the other child the root node
          parentNode.detachFromParent();
          parentNode.container.destroy();
          dockManager.setRootNode(otherChild);
        }
      });
    }
    else {
      // the node to be removed has 2 or more other siblings. So it is safe to continue 
      // using the parent composite container. 
      parentNode.performLayout();
      
      // Set the next sibling as the active child (e.g. for a Tab host, it would select it as the active tab)
      if (parentNode.children.length > 0) {
        DockNode nextActiveSibling = parentNode.children[max(0, siblingIndex - 1)];
        parentNode.container.setActiveChild(nextActiveSibling.container);
      }
    }
    dockManager.invalidate();
  }
  
  void _performDock(DockNode referenceNode, DockNode newNode, String direction, bool insertBeforeReference) {
    if (referenceNode.parent != null && referenceNode.parent.container.containerType == "fill") {
      referenceNode = referenceNode.parent;
    }
    
    if (direction == "fill" && referenceNode.container.containerType == "fill") {
      referenceNode.addChild(newNode);
      referenceNode.performLayout();
      referenceNode.container.setActiveChild(newNode.container);
      return;
    }
    
    // Check if reference node is root node
    DockModel model = dockManager.context.model;
    if (referenceNode == model.rootNode) {
      IDockContainer compositeContainer = _createDockContainer(direction, newNode, referenceNode);
      DockNode compositeNode = new DockNode(compositeContainer);
      
      if (insertBeforeReference) {
        compositeNode.addChild(newNode);
        compositeNode.addChild(referenceNode);
      } else {
        compositeNode.addChild(referenceNode);
        compositeNode.addChild(newNode);
      }
      
      // Attach the root node to the dock manager's DOM
      dockManager.setRootNode(compositeNode);
      dockManager.rebuildLayout(dockManager.context.model.rootNode);
      compositeNode.container.setActiveChild(newNode.container);
      return;
    }
    
    if (referenceNode.parent.container.containerType != direction) {
      DockNode referenceParent = referenceNode.parent;

      // Get the dimensions of the reference node, for resizing later on
      int referenceNodeWidth = referenceNode.container.containerElement.clientWidth;
      int referenceNodeHeight = referenceNode.container.containerElement.clientHeight;
      
      // Get the dimensions of the reference node, for resizing later on
      int referenceNodeParentWidth = referenceParent.container.containerElement.clientWidth;
      int referenceNodeParentHeight = referenceParent.container.containerElement.clientHeight;
      
      // Replace the reference node with a new composite node with the reference and new node as it's children
      IDockContainer compositeContainer = _createDockContainer(direction, newNode, referenceNode);
      DockNode compositeNode = new DockNode(compositeContainer);

      referenceParent.addChildAfter(referenceNode, compositeNode);
      referenceNode.detachFromParent();
      referenceNode.container.containerElement.remove();

      if (insertBeforeReference) {
        compositeNode.addChild(newNode);
        compositeNode.addChild(referenceNode);
      } else {
        compositeNode.addChild(referenceNode);
        compositeNode.addChild(newNode);
      }
      
      referenceParent.performLayout();
      compositeNode.performLayout();
      
      compositeNode.container.setActiveChild(newNode.container);
      compositeNode.container.resize(referenceNodeWidth, referenceNodeHeight);
      referenceParent.container.resize(referenceNodeParentWidth, referenceNodeParentHeight); 
    }
    else {
      // Add as a sibling, since the parent of the reference node is of the right composite type
      DockNode referenceParent = referenceNode.parent;
      if (insertBeforeReference) {
        referenceParent.addChildBefore(referenceNode, newNode);
      } else {
        referenceParent.addChildAfter(referenceNode, newNode);
      }
      referenceParent.performLayout();
      referenceParent.container.setActiveChild(newNode.container);
    }
    
    // force resize the panel
    int containerWidth = newNode.container.containerElement.clientWidth;
    int containerHeight = newNode.container.containerElement.clientHeight;
    newNode.container.resize(containerWidth, containerHeight);
  }
  
  void _forceResizeCompositeContainer(IDockContainer container) {
    int width = container.containerElement.clientWidth;
    int height = container.containerElement.clientHeight;
    container.resize(width, height);
  }
  
  IDockContainer _createDockContainer(String containerType, DockNode newNode, DockNode referenceNode) {
    if (containerType == "horizontal") {
      return new HorizontalDockContainer(dockManager, [newNode.container, referenceNode.container]);
    }
    else if (containerType == "vertical") {
      return new VerticalDockContainer(dockManager, [newNode.container, referenceNode.container]);
    }
    else if (containerType == "fill") {
      return new FillDockContainer(dockManager);
    } 
    else {
      throw new DockException("Failed to create dock container of type: $containerType");
    }
  }
  

  /** 
   * Gets the bounds of the new node if it were to dock with the specified configuration
   * The state is not modified in this function.  It is used for showing a preview of where
   * the panel would be docked when hovered over a dock wheel button
   */
  Rectangle getDockBounds(DockNode referenceNode, IDockContainer containerToDock, String direction, bool insertBeforeReference) {
    DockNode compositeNode; // The node that contains the splitter / fill node
    int childCount;
    int childPosition;
    if (direction == "fill") {
      // Since this is a fill operation, the highlight bounds is the same as the reference node
      // TODO: Create a tab handle highlight to show that it's going to be docked in a tab
      Element targetElement = referenceNode.container.containerElement;
      Rectangle bounds = new Rectangle();
      bounds.x = targetElement.offsetLeft;
      bounds.y = targetElement.offsetTop;
      bounds.width = targetElement.clientWidth;
      bounds.height= targetElement.clientHeight;
      return bounds;
    }
    
    if (referenceNode.parent != null && referenceNode.parent.container.containerType == "fill") {
      // Ignore the fill container's child and move one level up
      referenceNode = referenceNode.parent;
    }
    
    // Flag to indicate of the renference node was replaced with a new composite node with 2 children 
    bool hierarchyModified = false;
    if (referenceNode.parent != null && referenceNode.parent.container.containerType == direction) {
      // The parent already is of the desired composite type.  Will be inserted as sibling to the reference node
      compositeNode = referenceNode.parent;
      childCount = compositeNode.children.length;
      childPosition = compositeNode.children.indexOf(referenceNode) + (insertBeforeReference ? 0 : 1);
    } else {
      // The reference node will be replaced with a new composite node of the desired type with 2 children
      compositeNode = referenceNode;
      childCount = 1;   // The newly inserted composite node will contain the reference node
      childPosition = (insertBeforeReference ? 0 : 1);
      hierarchyModified = true;
    }
    
    int splitBarSize = 5;  // TODO: Get from DOM
    num targetPanelSize = 0;
    num targetPanelStart = 0;
    if (direction == "vertical" || direction == "horizontal") {
      // Existing size of the composite container (without the splitter bars).
      // This will also be the final size of the composite (splitter / fill) 
      // container after the new panel has been docked
      int compositeSize = _getVaringDimension(compositeNode.container, direction) - (childCount - 1) * splitBarSize;
      
      // size of the newly added panel
      int newPanelOriginalSize = _getVaringDimension(containerToDock, direction);  
      num scaleMultiplier = compositeSize / (compositeSize + newPanelOriginalSize);
      
      // Size of the panel after it has been docked and scaled
      targetPanelSize = newPanelOriginalSize * scaleMultiplier;
      if (hierarchyModified) {
        targetPanelStart = insertBeforeReference ? 0 : compositeSize * scaleMultiplier;
      }
      else {
        for (int i = 0; i < childPosition; i++) {
          targetPanelStart += _getVaringDimension(compositeNode.children[i].container, direction);
        }
        targetPanelStart *= scaleMultiplier;
      }
    }
    
    Rectangle bounds = new Rectangle();
    if (direction == "vertical") {
      bounds.x = compositeNode.container.containerElement.offsetLeft;
      bounds.y = compositeNode.container.containerElement.offsetTop + targetPanelStart;
      bounds.width = compositeNode.container.width; 
      bounds.height = targetPanelSize;
    } else if (direction == "horizontal") {
      bounds.x = compositeNode.container.containerElement.offsetLeft + targetPanelStart;
      bounds.y = compositeNode.container.containerElement.offsetTop;
      bounds.width = targetPanelSize; 
      bounds.height = compositeNode.container.height;
    }
    
    return bounds;
  }
  
  num _getVaringDimension(IDockContainer container, String direction) {
    if (direction == "vertical") {
      return container.height;
    } else if (direction == "horizontal") {
      return container.width;
    } else {
      return 0;
    }
  }
}
