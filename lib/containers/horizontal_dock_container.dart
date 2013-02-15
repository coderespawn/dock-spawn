part of dock_spawn;

class HorizontalDockContainer extends SplitterDockContainer  {

  HorizontalDockContainer(DockManager dockManager, List<IDockContainer> childContainers) 
      : super(getNextId("horizontal_splitter_"), dockManager, childContainers) {
    containerType = "horizontal";
  }
  
  bool get stackedVertical {
    return false;
  }
}
