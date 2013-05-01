import "../tab/TabHost";

dockspawn.FillDockContainer = function(dockManager, tabStripDirection)
{
    if (arguments.length == 0)
        return;

    if (tabStripDirection === undefined)
        tabStripDirection = dockspawn.TabHost.DIRECTION_BOTTOM;

    this.dockManager = dockManager;
    this.tabOrientation = tabStripDirection;
    this.name = getNextId("fill_");
    this.element = document.createElement("div");
    this.containerElement = this.element;
    this.containerType = "fill";
    this.minimumAllowedChildNodes = 2;
    this.element.classList.add("dock-container");
    this.element.classList.add("dock-container-fill");
    this.tabHost = new dockspawn.TabHost(this.tabOrientation);
    this.element.appendChild(this.tabHost.hostElement);
}

dockspawn.FillDockContainer.prototype.setActiveChild = function(child)
{
    this.tabHost.setActiveTab(child);
};

dockspawn.FillDockContainer.prototype.resize = function(width, height)
{
    this.element.style.width = width + "px";
    this.element.style.height = height + "px";
    this.tabHost.resize(width, height);
};

dockspawn.FillDockContainer.prototype.performLayout = function(children)
{
    this.tabHost.performLayout(children);
};

dockspawn.FillDockContainer.prototype.destroy = function()
{
    if (removeNode(this.element))
        delete this.element;
};

dockspawn.FillDockContainer.prototype.saveState = function(state)
{
    state.width = this.width;
    state.height = this.height;
};

dockspawn.FillDockContainer.prototype.loadState = function(state)
{
    this.width = state.width;
    this.height = state.height;
};

Object.defineProperty(dockspawn.FillDockContainer.prototype, "width", {
    get: function() { return this.element.clientWidth; },
    set: function(value) { this.element.style.width = value + "px" }
});

Object.defineProperty(dockspawn.FillDockContainer.prototype, "height", {
    get: function() { return this.element.clientHeight; },
    set: function(value) { this.element.style.height = value + "px" }
});
