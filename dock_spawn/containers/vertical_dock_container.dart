part of dock_spawn;

class VerticalDockContainer extends SplitterDockContainer {

  VerticalDockContainer(List<IDockContainer> childContainers) : super(getNextId("vertical_splitter_"), childContainers) {
    containerType = "vertical";
    
  }
  
  bool get stackedVertical {
    return true;
  }
}
