/**
 * Manages the dock overlay buttons that are displayed over the dock manager
 */
dockspawn.DockWheel = function(dockManager)
{
    this.dockManager = dockManager;
    this.elementMainWheel = document.createElement("div");    // Contains the main wheel's 5 dock buttons
    this.elementSideWheel = document.createElement("div");    // Contains the 4 buttons on the side
    this.wheelItems = {};
    var wheelTypes = [
        "left", "right", "top", "down", "fill",     // Main dock wheel buttons
        "left-s", "right-s", "top-s", "down-s"      // Buttons on the extreme 4 sides
    ];
    var self = this;
    wheelTypes.forEach(function(wheelType)
    {
        self.wheelItems[wheelType] = new DockWheelItem(self, wheelType);
        if (wheelType.substr(-2, 2) == "-s")
            // Side button
            self.elementSideWheel.appendChild(self.wheelItems[wheelType].element);
        else
            // Main dock wheel button
            self.elementMainWheel.appendChild(self.wheelItems[wheelType].element);
    });

    var zIndex = 100000;
    this.elementMainWheel.classList.add("dock-wheel-base");
    this.elementSideWheel.classList.add("dock-wheel-base");
    this.elementMainWheel.style.zIndex = zIndex + 1;
    this.elementSideWheel.style.zIndex = zIndex;
    this.elementPanelPreview = document.createElement("div");  // Used for showing the preview of where the panel would be docked
    this.elementPanelPreview.classList.add("dock-wheel-panel-preview");
    this.elementPanelPreview.style.zIndex = zIndex - 1;
    this.activeDialog = undefined;  // The dialog being dragged, when the wheel is visible
    this._activeNode = undefined;
    this._visible = false;
};

/** The node over which the dock wheel is being displayed on */
Object.defineProperty(dockspawn.DockWheel.prototype, "activeNode", {
    get: function() { return this._activeNode; },
    set: function(value)
    {
        var previousValue = this._activeNode;
        this._activeNode = value;

        if (previousValue !== this._activeNode)
        {
            // The active node has been changed.
            // Reattach the wheel to the new node's element and show it again
            if (this._visible)
                this.showWheel();
        }
    }
});

dockspawn.DockWheel.prototype.showWheel = function()
{
    this._visible = true;
    if (!this.activeNode)
    {
        // No active node selected. make sure the wheel is invisible
        removeNode(this.elementMainWheel);
        removeNode(this.elementSideWheel);
        return;
    }
    var element = this.activeNode.container.containerElement;
    var containerWidth = element.clientWidth;
    var containerHeight = element.clientHeight;
    var baseX = Math.floor(containerWidth / 2) + element.offsetLeft;
    var baseY = Math.floor(containerHeight / 2) + element.offsetTop;
    this.elementMainWheel.style.left = baseX + "px";
    this.elementMainWheel.style.top = baseY + "px";

    // The positioning of the main dock wheel buttons is done automatically through CSS
    // Dynamically calculate the positions of the buttons on the extreme sides of the dock manager
    var sideMargin = 20;
    var dockManagerWidth = this.dockManager.element.clientWidth;
    var dockManagerHeight = this.dockManager.element.clientHeight;
    var dockManagerOffsetX = this.dockManager.element.offsetLeft;
    var dockManagerOffsetY = this.dockManager.element.offsetTop;

    removeNode(this.elementMainWheel);
    removeNode(this.elementSideWheel);
    element.appendChild(this.elementMainWheel);
    this.dockManager.element.appendChild(this.elementSideWheel);

    this._setWheelButtonPosition("left-s",   sideMargin, -dockManagerHeight / 2);
    this._setWheelButtonPosition("right-s",  dockManagerWidth - sideMargin * 2, -dockManagerHeight / 2);
    this._setWheelButtonPosition("top-s",    dockManagerWidth / 2, -dockManagerHeight + sideMargin);
    this._setWheelButtonPosition("down-s",   dockManagerWidth / 2, -sideMargin);
};

dockspawn.DockWheel.prototype._setWheelButtonPosition = function(wheelId, left, top)
{
    var item = this.wheelItems[wheelId];
    var itemHalfWidth = item.element.clientWidth / 2;
    var itemHalfHeight = item.element.clientHeight / 2;

    var x = Math.floor(left - itemHalfWidth);
    var y = Math.floor(top - itemHalfHeight);
//    item.element.style.left = "${x}px";
//    item.element.style.top = "${y}px";
    item.element.style.marginLeft = x + "px";
    item.element.style.marginTop = y + "px";
};

dockspawn.DockWheel.prototype.hideWheel = function()
{
    this._visible = false;
    this.activeNode = undefined;
    removeNode(this.elementMainWheel);
    removeNode(this.elementSideWheel);
    removeNode(this.elementPanelPreview);

    // deactivate all wheels
    for (var wheelType in this.wheelItems)
        this.wheelItems[wheelType].active = false;
};

dockspawn.DockWheel.prototype.onMouseOver = function(wheelItem, e)
{
    if (!this.activeDialog)
        return;

    // Display the preview panel to show where the panel would be docked
    var rootNode = this.dockManager.context.model.rootNode;
    var bounds;
    if (wheelItem.id == "top") {
        bounds = this.dockManager.layoutEngine.getDockBounds(this.activeNode, this.activeDialog.panel, "vertical", true);
    } else if (wheelItem.id == "down") {
        bounds = this.dockManager.layoutEngine.getDockBounds(this.activeNode, this.activeDialog.panel, "vertical", false);
    } else if (wheelItem.id == "left") {
        bounds = this.dockManager.layoutEngine.getDockBounds(this.activeNode, this.activeDialog.panel, "horizontal", true);
    } else if (wheelItem.id == "right") {
        bounds = this.dockManager.layoutEngine.getDockBounds(this.activeNode, this.activeDialog.panel, "horizontal", false);
    } else if (wheelItem.id == "fill") {
        bounds = this.dockManager.layoutEngine.getDockBounds(this.activeNode, this.activeDialog.panel, "fill", false);
    } else if (wheelItem.id == "top-s") {
        bounds = this.dockManager.layoutEngine.getDockBounds(rootNode, this.activeDialog.panel, "vertical", true);
    } else if (wheelItem.id == "down-s") {
        bounds = this.dockManager.layoutEngine.getDockBounds(rootNode, this.activeDialog.panel, "vertical", false);
    } else if (wheelItem.id == "left-s") {
        bounds = this.dockManager.layoutEngine.getDockBounds(rootNode, this.activeDialog.panel, "horizontal", true);
    } else if (wheelItem.id == "right-s") {
        bounds = this.dockManager.layoutEngine.getDockBounds(rootNode, this.activeDialog.panel, "horizontal", false);
    }

    if (bounds)
    {
        this.dockManager.element.appendChild(this.elementPanelPreview);
        this.elementPanelPreview.style.left = Math.round(bounds.x) + "px";
        this.elementPanelPreview.style.top = Math.round(bounds.y) + "px";
        this.elementPanelPreview.style.width = Math.round(bounds.width) + "px";
        this.elementPanelPreview.style.height = Math.round(bounds.height) + "px";
    }
};

dockspawn.DockWheel.prototype.onMouseOut = function(wheelItem, e)
{
    removeNode(this.elementPanelPreview);
};

/**
 * Called if the dialog is dropped in a dock panel.
 * The dialog might not necessarily be dropped in one of the dock wheel buttons,
 * in which case the request will be ignored
 */
dockspawn.DockWheel.prototype.onDialogDropped = function(dialog)
{
    // Check if the dialog was dropped in one of the wheel items
    var wheelItem = this._getActiveWheelItem();
    if (wheelItem)
        this._handleDockRequest(wheelItem, dialog);
};

/**
 * Returns the wheel item which has the mouse cursor on top of it
 */
dockspawn.DockWheel.prototype._getActiveWheelItem = function()
{
    for (var wheelType in this.wheelItems)
    {
        var wheelItem = this.wheelItems[wheelType];
        if (wheelItem.active)
            return wheelItem;
    }
    return undefined;
};

dockspawn.DockWheel.prototype._handleDockRequest = function(wheelItem, dialog)
{
    if (!this.activeNode)
        return;
    if (wheelItem.id == "left") {
        this.dockManager.dockDialogLeft(this.activeNode, dialog);
    } else if (wheelItem.id == "right") {
        this.dockManager.dockDialogRight(this.activeNode, dialog);
    } else if (wheelItem.id == "top") {
        this.dockManager.dockDialogUp(this.activeNode, dialog);
    } else if (wheelItem.id == "down") {
        this.dockManager.dockDialogDown(this.activeNode, dialog);
    } else if (wheelItem.id == "fill") {
        this.dockManager.dockDialogFill(this.activeNode, dialog);
    } else if (wheelItem.id == "left-s") {
        this.dockManager.dockDialogLeft(this.dockManager.context.model.rootNode, dialog);
    } else if (wheelItem.id == "right-s") {
        this.dockManager.dockDialogRight(this.dockManager.context.model.rootNode, dialog);
    } else if (wheelItem.id == "top-s") {
        this.dockManager.dockDialogUp(this.dockManager.context.model.rootNode, dialog);
    } else if (wheelItem.id == "down-s") {
        this.dockManager.dockDialogDown(this.dockManager.context.model.rootNode, dialog);
    }
};

function DockWheelItem(wheel, id)
{
    this.wheel = wheel;
    this.id = id;
    var wheelType = id.replace("-s", "");
    this.element = document.createElement("div");
    this.element.classList.add("dock-wheel-item");
    this.element.classList.add("disable-selection");
    this.element.classList.add("dock-wheel-" + wheelType);
    this.element.classList.add("dock-wheel-" + wheelType + "-icon");
    this.hoverIconClass = "dock-wheel-" + wheelType + "-icon-hover";
    this.mouseOverHandler = new dockspawn.EventHandler(this.element, 'mouseover', this.onMouseMoved.bind(this));
    this.mouseOutHandler = new dockspawn.EventHandler(this.element, 'mouseout', this.onMouseOut.bind(this));
    this.active = false;    // Becomes active when the mouse is hovered over it
};

DockWheelItem.prototype.onMouseMoved = function(e)
{
    this.active = true;
    this.element.classList.add(this.hoverIconClass);
    this.wheel.onMouseOver(this, e);
};

DockWheelItem.prototype.onMouseOut = function(e)
{
    this.active = false;
    this.element.classList.remove(this.hoverIconClass);
    this.wheel.onMouseOut(this, e);
};
