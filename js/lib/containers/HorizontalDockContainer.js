import "SplitterDockContainer";

dockspawn.HorizontalDockContainer = function(dockManager, childContainers)
{
    this.stackedVertical = false;
    dockspawn.SplitterDockContainer.call(this, getNextId("horizontal_splitter_"), dockManager, childContainers);
    this.containerType = "horizontal";
};
dockspawn.HorizontalDockContainer.prototype = new dockspawn.SplitterDockContainer();
dockspawn.HorizontalDockContainer.prototype.constructor = dockspawn.HorizontalDockContainer;
