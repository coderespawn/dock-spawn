dockspawn.DraggableContainer = function(dialog, delegate, topLevelElement, dragHandle)
{
    this.dialog = dialog;
    this.delegate = delegate;
    this.containerElement = delegate.containerElement;
    this.dockManager = delegate.dockManager;
    this.topLevelElement = topLevelElement;
    this.containerType = delegate.containerType;
    this.mouseDownHandler = new dockspawn.EventHandler(dragHandle, 'mousedown', this.onMouseDown.bind(this));
    this.topLevelElement.style.marginLeft = topLevelElement.offsetLeft + "px";
    this.topLevelElement.style.marginTop = topLevelElement.offsetTop + "px";
    this.minimumAllowedChildNodes = delegate.minimumAllowedChildNodes;
};

dockspawn.DraggableContainer.prototype.destroy = function()
{
    this.removeDecorator();
    this.delegate.destroy();
};

dockspawn.DraggableContainer.prototype.saveState = function(state)
{
    this.delegate.saveState(state);
};

dockspawn.DraggableContainer.prototype.loadState = function(state)
{
    this.delegate.loadState(state);
};

dockspawn.DraggableContainer.prototype.setActiveChild = function(child)
{
};

Object.defineProperty(dockspawn.DraggableContainer.prototype, "width", {
    get: function() { return this.delegate.width; }
});

Object.defineProperty(dockspawn.DraggableContainer.prototype, "height", {
    get: function() { return this.delegate.height; }
});

dockspawn.DraggableContainer.prototype.name = function(value)
{
    if (value)
        this.delegate.name = value;
    return this.delegate.name;
};

dockspawn.DraggableContainer.prototype.resize = function(width, height)
{
    this.delegate.resize(width, height);
};

dockspawn.DraggableContainer.prototype.performLayout = function(children)
{
    this.delegate.performLayout(children);
};

dockspawn.DraggableContainer.prototype.removeDecorator = function()
{
    if (this.mouseDownHandler)
    {
        this.mouseDownHandler.cancel();
        delete this.mouseDownHandler;
    }
};

dockspawn.DraggableContainer.prototype.onMouseDown = function(event)
{
    this._startDragging(event);
    this.previousMousePosition = { x: event.pageX, y: event.pageY };
    if (this.mouseMoveHandler)
    {
        this.mouseMoveHandler.cancel();
        delete this.mouseMoveHandler;
    }
    if (this.mouseUpHandler)
    {
        this.mouseUpHandler.cancel();
        delete this.mouseUpHandler;
    }

    this.mouseMoveHandler = new dockspawn.EventHandler(window, 'mousemove', this.onMouseMove.bind(this));
    this.mouseUpHandler = new dockspawn.EventHandler(window, 'mouseup', this.onMouseUp.bind(this));
};

dockspawn.DraggableContainer.prototype.onMouseUp = function(event)
{
    this._stopDragging(event);
    this.mouseMoveHandler.cancel();
    delete this.mouseMoveHandler;
    this.mouseUpHandler.cancel();
    delete this.mouseUpHandler;
};

dockspawn.DraggableContainer.prototype._startDragging = function(event)
{
    if (this.dialog.eventListener)
        this.dialog.eventListener.onDialogDragStarted(this.dialog, event);
    document.body.classList.add("disable-selection");
};

dockspawn.DraggableContainer.prototype._stopDragging = function(event)
{
    if (this.dialog.eventListener)
        this.dialog.eventListener.onDialogDragEnded(this.dialog, event);
    document.body.classList.remove("disable-selection");
};

dockspawn.DraggableContainer.prototype.onMouseMove = function(event)
{
    var currentMousePosition = new Point(event.pageX, event.pageY);
    var dx = Math.floor(currentMousePosition.x - this.previousMousePosition.x);
    var dy = Math.floor(currentMousePosition.y - this.previousMousePosition.y);
    this._performDrag(dx, dy);
    this.previousMousePosition = currentMousePosition;
};

dockspawn.DraggableContainer.prototype._performDrag = function(dx, dy)
{
    var left = dx + getPixels(this.topLevelElement.style.marginLeft);
    var top = dy + getPixels(this.topLevelElement.style.marginTop);
    this.topLevelElement.style.marginLeft = left + "px";
    this.topLevelElement.style.marginTop = top + "px";
};
