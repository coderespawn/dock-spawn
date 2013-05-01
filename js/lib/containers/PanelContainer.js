/**
 * This dock container wraps the specified element on a panel frame with a title bar and close button
 */
dockspawn.PanelContainer = function(elementContent, dockManager, title)
{
    if (!title)
        title = "Panel";
    this.elementContent = elementContent;
    this.dockManager = dockManager;
    this.title = title;
    this.containerType = "panel";
    this.iconName = "icon-circle-arrow-right";
    this.minimumAllowedChildNodes = 0;
    this._floatingDialog = undefined;
    this._initialize();
};

Object.defineProperty(dockspawn.PanelContainer.prototype, "floatingDialog", {
    get: function() { return this._floatingDialog; },
    set: function(value)
    {
        this._floatingDialog = value;
        var canUndock = (this._floatingDialog === undefined);
        this.undockInitiator.enabled = canUndock;
    }
});

dockspawn.PanelContainer.loadFromState = function(state, dockManager)
{
    var elementName = state.element;
    var elementContent = document.getElementById(elementName);
    var ret = new dockspawn.PanelContainer(elementContent, dockManager);
    ret.elementContent = elementContent;
    ret._initialize();
    ret.loadState(state);
    return ret;
};

dockspawn.PanelContainer.prototype.saveState = function(state)
{
    state.element = this.elementContent.id;
    state.width = this.width;
    state.height = this.height;
};

dockspawn.PanelContainer.prototype.loadState = function(state)
{
    this.width = state.width;
    this.height = state.height;
    this.resize(this.width, this.height);
};

dockspawn.PanelContainer.prototype.setActiveChild = function(child)
{
};

Object.defineProperty(dockspawn.PanelContainer.prototype, "containerElement", {
    get: function() { return this.elementPanel; }
});

dockspawn.PanelContainer.prototype._initialize = function()
{
    this.name = getNextId("panel_");
    this.elementPanel = document.createElement('div');
    this.elementTitle = document.createElement('div');
    this.elementTitleText = document.createElement('div');
    this.elementContentHost = document.createElement('div');
    this.elementButtonClose = document.createElement('div');

    this.elementPanel.appendChild(this.elementTitle);
    this.elementTitle.appendChild(this.elementTitleText);
    this.elementTitle.appendChild(this.elementButtonClose);
    this.elementButtonClose.innerHTML = '<i class="icon-remove"></i>';
    this.elementButtonClose.classList.add("panel-titlebar-button-close");
    this.elementPanel.appendChild(this.elementContentHost);

    this.elementPanel.classList.add("panel-base");
    this.elementTitle.classList.add("panel-titlebar");
    this.elementTitle.classList.add("disable-selection");
    this.elementTitleText.classList.add("panel-titlebar-text");
    this.elementContentHost.classList.add("panel-content");

    // set the size of the dialog elements based on the panel's size
    var panelWidth = this.elementContent.clientWidth;
    var panelHeight = this.elementContent.clientHeight;
    var titleHeight = this.elementTitle.clientHeight;
    this._setPanelDimensions(panelWidth, panelHeight + titleHeight);

    // Add the panel to the body
    document.body.appendChild(this.elementPanel);

    this.closeButtonClickedHandler = new dockspawn.EventHandler(this.elementButtonClose, 'click', this.onCloseButtonClicked.bind(this));

    removeNode(this.elementContent);
    this.elementContentHost.appendChild(this.elementContent);

    // Extract the title from the content element's attribute
    var contentTitle = this.elementContent.getAttribute('caption');
    var contentIcon = this.elementContent.getAttribute('icon');
    if (contentTitle != null) this.title = contentTitle;
    if (contentIcon != null) this.iconName = contentIcon;
    this._updateTitle();

    this.undockInitiator = new dockspawn.UndockInitiator(this.elementTitle, this.performUndockToDialog.bind(this));
    delete this.floatingDialog;
};

dockspawn.PanelContainer.prototype.destroy = function()
{
    removeNode(this.elementPanel);
    if (this.closeButtonClickedHandler)
    {
        this.closeButtonClickedHandler.cancel();
        delete this.closeButtonClickedHandler;
    }
};

/**
 * Undocks the panel and and converts it to a dialog box
 */
dockspawn.PanelContainer.prototype.performUndockToDialog = function(e, dragOffset)
{
    this.undockInitiator.enabled = false;
    return this.dockManager.requestUndockToDialog(this, e, dragOffset);
};

/**
 * Undocks the container and from the layout hierarchy
 * The container would be removed from the DOM
 */
dockspawn.PanelContainer.prototype.performUndock = function()
{
    this.undockInitiator.enabled = false;
    this.dockManager.requestUndock(this);
};

dockspawn.PanelContainer.prototype.prepareForDocking = function()
{
    this.undockInitiator.enabled = true;
};

Object.defineProperty(dockspawn.PanelContainer.prototype, "width", {
    get: function() { return this._cachedWidth; },
    set: function(value)
    {
        if (value !== this._cachedWidth)
        {
            this._cachedWidth = value;
            this.elementPanel.style.width = value + "px";
        }
    }
});

Object.defineProperty(dockspawn.PanelContainer.prototype, "height", {
    get: function() { return this._cachedHeight; },
    set: function(value)
    {
        if (value !== this._cachedHeight)
        {
            this._cachedHeight = value;
            this.elementPanel.style.height = value + "px";
        }
    }
});

dockspawn.PanelContainer.prototype.resize = function(width,  height)
{
    if (this._cachedWidth == width && this._cachedHeight == height)
    {
        // Already in the desired size
        return;
    }
    this._setPanelDimensions(width, height);
    this._cachedWidth = width;
    this._cachedHeight = height;
};

dockspawn.PanelContainer.prototype._setPanelDimensions = function(width, height)
{
    this.elementTitle.style.width = width + "px";
    this.elementContentHost.style.width = width + "px";
    this.elementContent.style.width = width + "px";
    this.elementPanel.style.width = width + "px";

    var titleBarHeight = this.elementTitle.clientHeight;
    var contentHeight = height - titleBarHeight;
    this.elementContentHost.style.height = contentHeight + "px";
    this.elementContent.style.height = contentHeight + "px";
    this.elementPanel.style.height = height + "px";
};

dockspawn.PanelContainer.prototype.setTitle = function(title)
{
    this.title = title;
    this._updateTitle();
    if (this.onTitleChanged)
        this.onTitleChanged(this, title);
};

dockspawn.PanelContainer.prototype.setTitleIcon = function(iconName)
{
    this.iconName = iconName;
    this._updateTitle();
};

dockspawn.PanelContainer.prototype._updateTitle = function()
{
    this.elementTitleText.innerHTML = '<i class="' + this.iconName + '"></i> ' + this.title;
};

dockspawn.PanelContainer.prototype.getRawTitle = function()
{
    return this.elementTitleText.innerHTML;
};

dockspawn.PanelContainer.prototype.performLayout = function(children)
{
};

dockspawn.PanelContainer.prototype.onCloseButtonClicked = function(e)
{
    if (this.floatingDialog)
        this.floatingDialog.destroy();
    else
    {
        this.performUndock();
        this.destroy();
    }
};
