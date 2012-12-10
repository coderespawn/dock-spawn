part of dock_spawn;

class VerticalDockContainer extends SplitterDockContainer {

  VerticalDockContainer(DockManager dockManager, List<IDockContainer> childContainers) 
      : super(getNextId("vertical_splitter_"), dockManager, childContainers) {
    containerType = "vertical";
    
  }
  
  bool get stackedVertical {
    return true;
  }
}
