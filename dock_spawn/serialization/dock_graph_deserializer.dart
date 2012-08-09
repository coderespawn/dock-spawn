
/**
 * Deserializes the dock layout hierarchy from JSON and creates a dock hierarhcy graph
 */
class DockGraphDeserializer {
  DockManager dockManager;
  DockGraphDeserializer(this.dockManager);
  
  DockModel deserialize(String json) {
    Map<String, Object> graphInfo = JSON.parse(json);
    DockModel model = new DockModel();
    model.rootNode = _buildGraph(graphInfo);
    return model;
  }
  
  DockNode _buildGraph(Map<String, Object> nodeInfo) {
    List childrenInfo = nodeInfo['children'];
    var children = new List<DockNode>();
    childrenInfo.forEach((childInfo) {
      DockNode childNode = _buildGraph(childInfo);
      children.add(childNode);
    });

    // Build the container owned by this node
    IDockContainer container = _createContainer(nodeInfo, children);
    
    // Build the node for this container and attach it's children
    DockNode node = new DockNode(container);
    node.children = children;
    node.children.forEach((childNode) => childNode.parent = node);
    
    return node;
  }
  
  IDockContainer _createContainer(Map<String, Object> nodeInfo, List<DockNode> children) {
    String containerType = nodeInfo['containerType'];
    Map<String, Object> containerState = nodeInfo['state'];
    IDockContainer container = null;
    
    var childContainers = new List<IDockContainer>();
    children.forEach((childNode) => childContainers.add(childNode.container));
    childContainers = [];
    
    if (containerType == "panel") {
      container = new PanelContainer.loadFromState(containerState, dockManager);
    } 
    else if (containerType == "horizontal") {
      container = new HorizontalDockContainer(childContainers);
    }
    else if (containerType == "vertical") {
      container = new VerticalDockContainer(childContainers);
    }
    else if (containerType == "fill") {
      // Check if this is a document manager
      
      // TODO: Layout engine compares the string "fill", so cannot create another subclass type
      // called document_manager and have to resort to this hack. use RTTI in layout engine
      var typeDocumentManager = containerState['documentManager'];
      if (typeDocumentManager != null && typeDocumentManager) {
        container = new DocumentManagerContainer(dockManager);
      } else {
        container = new FillDockContainer();
      }
    }
    else {
      throw new DockException("Cannot create dock container of unknown type: $containerType");
    }

    // Restore the state of the container
    container.loadState(containerState);
    container.performLayout(childContainers);
    return container;
  }
}
