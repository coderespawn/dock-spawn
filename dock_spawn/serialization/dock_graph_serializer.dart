part of dock_spawn;

/**
 * The serializer saves / loads the state of the dock layout hierarchy
 */ 
class DockGraphSerializer {

  String serialize(DockModel model) {
    var graphInfo = _buildGraphInfo(model.rootNode);
    return json.stringify(graphInfo);
  }
  
  Map<String, Object> _buildGraphInfo(DockNode node) {
    var nodeState = new Map<String, Object>();
    node.container.saveState(nodeState);
    
    var childrenInfo = [];
    node.children.forEach((childNode) {
      childrenInfo.add(_buildGraphInfo(childNode));
    });

    var nodeInfo = { };
    nodeInfo['containerType'] = node.container.containerType;
    nodeInfo['state'] = nodeState;
    nodeInfo['children'] = childrenInfo;
    return nodeInfo;
  }
}
