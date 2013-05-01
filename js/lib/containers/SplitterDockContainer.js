import "../splitter/SplitterPanel";

dockspawn.SplitterDockContainer = function(name, dockManager, childContainers)
{
    // for prototype inheritance purposes only
    if (arguments.length == 0)
        return;

    this.name = name;
    this.dockManager = dockManager;
    this.splitterPanel = new dockspawn.SplitterPanel(childContainers, this.stackedVertical);
    this.containerElement = this.splitterPanel.panelElement;
    this.minimumAllowedChildNodes = 2;
}

dockspawn.SplitterDockContainer.prototype.resize = function(width, height)
{
//    if (_cachedWidth == _cachedWidth && _cachedHeight == _height) {
//      // No need to resize
//      return;
//    }
    this.splitterPanel.resize(width, height);
    this._cachedWidth = width;
    this._cachedHeight = height;
};

dockspawn.SplitterDockContainer.prototype.performLayout = function(childContainers)
{
    this.splitterPanel.performLayout(childContainers);
};

dockspawn.SplitterDockContainer.prototype.setActiveChild = function(child)
{
};

dockspawn.SplitterDockContainer.prototype.destroy = function()
{
    this.splitterPanel.destroy();
};

/**
 * Sets the percentage of space the specified [container] takes in the split panel
 * The percentage is specified in [ratio] and is between 0..1
 */
dockspawn.SplitterDockContainer.prototype.setContainerRatio = function(container, ratio)
{
    this.splitterPanel.setContainerRatio(container, ratio);
    this.resize(this.width, this.height);
};

dockspawn.SplitterDockContainer.prototype.saveState = function(state)
{
    state.width = this.width;
    state.height = this.height;
};

dockspawn.SplitterDockContainer.prototype.loadState = function(state)
{
    this.resize(state.width, state.height);
};

Object.defineProperty(dockspawn.SplitterDockContainer.prototype, "width", {
    get: function()
    {
        if (this._cachedWidth === undefined)
            this._cachedWidth = this.splitterPanel.panelElement.clientWidth;
        return this._cachedWidth;
    }
});

Object.defineProperty(dockspawn.SplitterDockContainer.prototype, "height", {
    get: function()
    {
        if (this._cachedHeight === undefined)
            this._cachedHeight = this.splitterPanel.panelElement.clientHeight;
        return this._cachedHeight;
    }
});
