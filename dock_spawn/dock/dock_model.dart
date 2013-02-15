part of dock_spawn;

/**
 * The Dock Model contains the tree hierarchy that represents the state of the 
 * panel placement within the dock manager.
 */ 
class DockModel {
  DockNode rootNode;
  DockNode documentManagerNode;
  
  DockModel() {
  }
}


class DockNode {
  /** The dock container represented by this node */
  IDockContainer container;
  
  
  DockNode parent;
  List<DockNode> children;
  
  DockNode(this.container) {
    children = new List<DockNode>();
  }
  
  void detachFromParent() {
    if (parent != null) {
      parent.removeChild(this);
    }
    parent = null;
  }
  
  void removeChild(DockNode childNode) {
    int index = children.indexOf(childNode);
    if (index >= 0) {
      children.removeRange(index, 1);
    }
  }
  
  void addChild(DockNode childNode) {
    childNode.detachFromParent();
    childNode.parent = this;
    children.add(childNode);
  }

  void addChildBefore(DockNode referenceNode, DockNode childNode) {
    _addChildWithDirection(referenceNode, childNode, true);
  }
  
  void addChildAfter(DockNode referenceNode, DockNode childNode) {
    _addChildWithDirection(referenceNode, childNode, false);
  }
  
  void _addChildWithDirection(DockNode referenceNode, DockNode childNode, bool before) {
    // Detach this node from it's parent first
    childNode.detachFromParent();
    childNode.parent = this;
    
    int referenceIndex = children.indexOf(referenceNode);
    List<DockNode> preList = children.getRange(0, referenceIndex);
    List<DockNode> postList = children.getRange(referenceIndex + 1, children.length - (referenceIndex + 1));
    
    children = new List<DockNode>();
    children.addAll(preList);
    if (before) {
      children.add(childNode);
      children.add(referenceNode);
    } else {
      children.add(referenceNode);
      children.add(childNode);
    }
    children.addAll(postList);
  }
  
  void performLayout() {
    var childContainers = new List<IDockContainer>();
    children.forEach((childNode) => childContainers.add(childNode.container));
    container.performLayout(childContainers);
  }

}