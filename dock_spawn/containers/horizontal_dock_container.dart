part of dock_spawn;

class HorizontalDockContainer extends SplitterDockContainer  {

  HorizontalDockContainer(List<IDockContainer> childContainers) : super(getNextId("horizontal_splitter_"), childContainers) {
    containerType = "horizontal";
  }
  
  bool get stackedVertical {
    return false;
  }
}
