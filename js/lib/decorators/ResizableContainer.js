/**
 * Decorates a dock container with resizer handles around its base element
 * This enables the container to be resized from all directions
 */
dockspawn.ResizableContainer = function(dialog, delegate, topLevelElement)
{
    this.dialog = dialog;
    this.delegate = delegate;
    this.containerElement = delegate.containerElement;
    this.dockManager = delegate.dockManager;
    this.topLevelElement = topLevelElement;
    this.containerType = delegate.containerType;
    this.topLevelElement.style.marginLeft = this.topLevelElement.offsetLeft + "px";
    this.topLevelElement.style.marginTop = this.topLevelElement.offsetTop + "px";
    this.minimumAllowedChildNodes = delegate.minimumAllowedChildNodes;
    this._buildResizeHandles();
    this.readyToProcessNextResize = true;
};

dockspawn.ResizableContainer.prototype.setActiveChild = function(child)
{
};

dockspawn.ResizableContainer.prototype._buildResizeHandles = function()
{
    this.resizeHandles = [];
//    this._buildResizeHandle(true, false, true, false); // Dont need the corner resizer near the close button
    this._buildResizeHandle(false, true, true, false);
    this._buildResizeHandle(true, false, false, true);
    this._buildResizeHandle(false, true, false, true);

    this._buildResizeHandle(true, false, false, false);
    this._buildResizeHandle(false, true, false, false);
    this._buildResizeHandle(false, false, true, false);
    this._buildResizeHandle(false, false, false, true);
};

dockspawn.ResizableContainer.prototype._buildResizeHandle = function(east, west, north, south)
{
    var handle = new ResizeHandle();
    handle.east = east;
    handle.west = west;
    handle.north = north;
    handle.south = south;

    // Create an invisible div for the handle
    handle.element = document.createElement('div');
    this.topLevelElement.appendChild(handle.element);

    // Build the class name for the handle
    var verticalClass = "";
    var horizontalClass = "";
    if (north) verticalClass = "n";
    if (south) verticalClass = "s";
    if (east) horizontalClass = "e";
    if (west) horizontalClass = "w";
    var cssClass = "resize-handle-" + verticalClass + horizontalClass;
    if (verticalClass.length > 0 && horizontalClass.length > 0)
        handle.corner = true;

    handle.element.classList.add(handle.corner ? "resize-handle-corner" : "resize-handle");
    handle.element.classList.add(cssClass);
    this.resizeHandles.push(handle);

    var self = this;
    handle.mouseDownHandler = new dockspawn.EventHandler(handle.element, 'mousedown', function(e) { self.onMouseDown(handle, e); });
};

dockspawn.ResizableContainer.prototype.saveState = function(state)
{
    this.delegate.saveState(state);
};

dockspawn.ResizableContainer.prototype.loadState = function(state)
{
    this.delegate.loadState(state);
};

Object.defineProperty(dockspawn.ResizableContainer.prototype, "width", {
    get: function() { return this.delegate.width; }
});

Object.defineProperty(dockspawn.ResizableContainer.prototype, "height", {
    get: function() { return this.delegate.height; }
});

dockspawn.ResizableContainer.prototype.name = function(value)
{
    if (value)
        this.delegate.name = value;
    return this.delegate.name;
};

dockspawn.ResizableContainer.prototype.resize = function(width, height)
{
    this.delegate.resize(width, height);
    this._adjustResizeHandles(width, height);
};

dockspawn.ResizableContainer.prototype._adjustResizeHandles = function(width, height)
{
    var self = this;
    this.resizeHandles.forEach(function(handle) {
        handle.adjustSize(self.topLevelElement, width, height);
    });
};

dockspawn.ResizableContainer.prototype.performLayout = function(children)
{
    this.delegate.performLayout(children);
};

dockspawn.ResizableContainer.prototype.destroy = function()
{
    this.removeDecorator();
    this.delegate.destroy();
};

dockspawn.ResizableContainer.prototype.removeDecorator = function()
{
};

dockspawn.ResizableContainer.prototype.onMouseMoved = function(handle, e)
{
    if (!this.readyToProcessNextResize)
        return;
    this.readyToProcessNextResize = false;

//    window.requestLayoutFrame(() {
    this.dockManager.suspendLayout();
    var currentMousePosition = new Point(e.pageX, e.pageY);
    var dx = Math.floor(currentMousePosition.x - this.previousMousePosition.x);
    var dy = Math.floor(currentMousePosition.y - this.previousMousePosition.y);
    this._performDrag(handle, dx, dy);
    this.previousMousePosition = currentMousePosition;
    this.readyToProcessNextResize = true;
    this.dockManager.resumeLayout();
//    });
};

dockspawn.ResizableContainer.prototype.onMouseDown = function(handle, event)
{
    this.previousMousePosition = new Point(event.pageX, event.pageY);
    if (handle.mouseMoveHandler)
    {
        handle.mouseMoveHandler.cancel();
        delete handle.mouseMoveHandler
    }
    if (handle.mouseUpHandler)
    {
        handle.mouseUpHandler.cancel();
        delete handle.mouseUpHandler
    }

    // Create the mouse event handlers
    var self = this;
    handle.mouseMoveHandler = new dockspawn.EventHandler(window, 'mousemove', function(e) { self.onMouseMoved(handle, e); });
    handle.mouseUpHandler = new dockspawn.EventHandler(window, 'mouseup', function(e) { self.onMouseUp(handle, e); });

    document.body.classList.add("disable-selection");
};

dockspawn.ResizableContainer.prototype.onMouseUp = function(handle, event)
{
    handle.mouseMoveHandler.cancel();
    handle.mouseUpHandler.cancel();
    delete handle.mouseMoveHandler;
    delete handle.mouseUpHandler;

    document.body.classList.remove("disable-selection");
};

dockspawn.ResizableContainer.prototype._performDrag = function(handle, dx, dy)
{
    var bounds = {};
    bounds.left = getPixels(this.topLevelElement.style.marginLeft);
    bounds.top = getPixels(this.topLevelElement.style.marginTop);
    bounds.width = this.topLevelElement.clientWidth;
    bounds.height = this.topLevelElement.clientHeight;

    if (handle.east) this._resizeEast(dx, bounds);
    if (handle.west) this._resizeWest(dx, bounds);
    if (handle.north) this._resizeNorth(dy, bounds);
    if (handle.south) this._resizeSouth(dy, bounds);
};

dockspawn.ResizableContainer.prototype._resizeWest = function(dx, bounds)
{
    this._resizeContainer(dx, 0, -dx, 0, bounds);
};

dockspawn.ResizableContainer.prototype._resizeEast = function(dx, bounds)
{
    this._resizeContainer(0, 0, dx, 0, bounds);
};

dockspawn.ResizableContainer.prototype._resizeNorth = function(dy, bounds)
{
    this._resizeContainer(0, dy, 0, -dy, bounds);
};

dockspawn.ResizableContainer.prototype._resizeSouth = function(dy, bounds)
{
    this._resizeContainer(0, 0, 0, dy, bounds);
};

dockspawn.ResizableContainer.prototype._resizeContainer = function(leftDelta, topDelta, widthDelta, heightDelta, bounds)
{
    bounds.left += leftDelta;
    bounds.top += topDelta;
    bounds.width += widthDelta;
    bounds.height += heightDelta;

    var minWidth = 50;  // TODO: Move to external configuration
    var minHeight = 50;  // TODO: Move to external configuration
    bounds.width = Math.max(bounds.width, minWidth);
    bounds.height = Math.max(bounds.height, minHeight);

    this.topLevelElement.style.marginLeft = bounds.left + "px";
    this.topLevelElement.style.marginTop = bounds.top + "px";

    this.resize(bounds.width, bounds.height);
};


function ResizeHandle()
{
    this.element = undefined;
    this.handleSize = 6;   // TODO: Get this from DOM
    this.cornerSize = 12;  // TODO: Get this from DOM
    this.east = false;
    this.west = false;
    this.north = false;
    this.south = false;
    this.corner = false;
}

ResizeHandle.prototype.adjustSize = function(container, clientWidth, clientHeight)
{
    if (this.corner)
    {
        if (this.west) this.element.style.left = "0px";
        if (this.east) this.element.style.left = (clientWidth - this.cornerSize) + "px";
        if (this.north) this.element.style.top = "0px";
        if (this.south) this.element.style.top = (clientHeight - this.cornerSize) + "px";
    }
    else
    {
        if (this.west)
        {
            this.element.style.left = "0px";
            this.element.style.top = this.cornerSize + "px";
        }
        if (this.east) {
            this.element.style.left = (clientWidth - this.handleSize) + "px";
            this.element.style.top = this.cornerSize + "px";
        }
        if (this.north) {
            this.element.style.left = this.cornerSize + "px";
            this.element.style.top = "0px";
        }
        if (this.south) {
            this.element.style.left = this.cornerSize + "px";
            this.element.style.top = (clientHeight - this.handleSize) + "px";
        }

        if (this.west || this.east) {
            this.element.style.height = (clientHeight - this.cornerSize * 2) + "px";
        } else {
            this.element.style.width = (clientWidth - this.cornerSize * 2) + "px";
        }
    }
};
