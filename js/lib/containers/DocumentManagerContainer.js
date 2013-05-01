import "FillDockContainer";

/**
 * The document manager is then central area of the dock layout hierarchy.
 * This is where more important panels are placed (e.g. the text editor in an IDE,
 * 3D view in a modelling package etc
 */
dockspawn.DocumentManagerContainer = function(dockManager)
{
    dockspawn.FillDockContainer.call(this, dockManager, dockspawn.TabHost.DIRECTION_TOP);
    this.minimumAllowedChildNodes = 0;
    this.element.classList.add("document-manager");
    this.tabHost.createTabPage = this._createDocumentTabPage;
    this.tabHost.displayCloseButton = true;
};
dockspawn.DocumentManagerContainer.prototype = new dockspawn.FillDockContainer();
dockspawn.DocumentManagerContainer.prototype.constructor = dockspawn.DocumentManagerContainer;

dockspawn.DocumentManagerContainer.prototype._createDocumentTabPage = function(tabHost, container)
{
    return new dockspawn.DocumentTabPage(tabHost, container);
};

dockspawn.DocumentManagerContainer.prototype.saveState = function(state)
{
    dockspawn.FillDockContainer.prototype.saveState.call(this, state);
    state.documentManager = true;
};

/** Returns the selected document tab */
dockspawn.DocumentManagerContainer.prototype.selectedTab = function()
{
    return this.tabHost.activeTab;
};

/**
 * Specialized tab page that doesn't display the panel's frame when docked in a tab page
 */
dockspawn.DocumentTabPage = function(host, container)
{
    dockspawn.TabPage.call(this, host, container);

    // If the container is a panel, extract the content element and set it as the tab's content
    if (this.container.containerType == "panel")
    {
        this.panel = container;
        this.containerElement = this.panel.elementContent;

        // detach the container element from the panel's frame.
        // It will be reattached when this tab page is destroyed
        // This enables the panel's frame (title bar etc) to be hidden
        // inside the tab page
        removeNode(this.containerElement);
    }
};
dockspawn.DocumentTabPage.prototype = new dockspawn.TabPage();
dockspawn.DocumentTabPage.prototype.constructor = dockspawn.DocumentTabPage;

dockspawn.DocumentTabPage.prototype.destroy = function()
{
    dockspawn.TabPage.prototype.destroy.call(this);

    // Restore the panel content element back into the panel frame
    removeNode(this.containerElement);
    this.panel.elementContentHost.appendChild(this.containerElement);
};
