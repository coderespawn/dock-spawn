import "SplitterDockContainer";

dockspawn.VerticalDockContainer = function(dockManager, childContainers)
{
    this.stackedVertical = true;
    dockspawn.SplitterDockContainer.call(this, getNextId("vertical_splitter_"), dockManager, childContainers);
    this.containerType = "vertical";
};
dockspawn.VerticalDockContainer.prototype = new dockspawn.SplitterDockContainer();
dockspawn.VerticalDockContainer.prototype.constructor = dockspawn.VerticalDockContainer;
