
/**
 * Prints out the dock layout hierarchy structure
 * WARNING: Assumes that the graph is acyclic
 */
debug_DumpTree(DockNode node, [int indent = 0]) {
  String message = node.container.name;
  
  for (int i = 0; i < indent; i++) {
     message = "\t$message";
  }
  String parentType = node.parent == null ? "null" : node.parent.container.containerType;
  print (">>$message [$parentType]");
  
  node.children.forEach((childNode) => debug_DumpTree(childNode, indent + 1));
}

int dockIdCounter = 0;
String getNextId(String prefix) {
  return "${prefix}${dockIdCounter++}";
}