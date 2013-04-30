/**
 * Listens for events on the [element] and notifies the [listener]
 * if an undock event has been invoked.  An undock event is invoked
 * when the user clicks on the event and drags is beyond the
 * specified [thresholdPixels]
 */
dockspawn.UndockInitiator = function(element, listener, thresholdPixels)
{
    if (!thresholdPixels)
        thresholdPixels = 10;

    this.element = element;
    this.listener = listener;
    this.thresholdPixels = thresholdPixels;
    this._enabled = false;
};

Object.defineProperty(dockspawn.UndockInitiator.prototype, "enabled", {
    get: function() { return this._enabled; },
    set: function(value)
    {
        this._enabled = value;
        if (this._enabled)
        {
            if (this.mouseDownHandler)
            {
                this.mouseDownHandler.cancel();
                delete this.mouseDownHandler;
            }
            this.mouseDownHandler = new dockspawn.EventHandler(this.element, 'mousedown', this.onMouseDown.bind(this));
        }
        else
        {
            if (this.mouseDownHandler)
            {
                this.mouseDownHandler.cancel();
                delete this.mouseDownHandler;
            }
            if (this.mouseUpHandler)
            {
                this.mouseUpHandler.cancel();
                delete this.mouseUpHandler;
            }
            if (this.mouseMoveHandler)
            {
                this.mouseMoveHandler.cancel();
                delete this.mouseMoveHandler;
            }
        }
    }
});

dockspawn.UndockInitiator.prototype.onMouseDown = function(e)
{
    // Make sure we dont do this on floating dialogs
    if (this.enabled)
    {
        if (this.mouseUpHandler)
        {
            this.mouseUpHandler.cancel();
            delete this.mouseUpHandler;
        }
        if (this.mouseMoveHandler)
        {
            this.mouseMoveHandler.cancel();
            delete this.mouseMoveHandler;
        }
        this.mouseUpHandler = new dockspawn.EventHandler(window, 'mouseup', this.onMouseUp.bind(this));
        this.mouseMoveHandler = new dockspawn.EventHandler(window, 'mousemove', this.onMouseMove.bind(this));
        this.dragStartPosition = new Point(e.pageX, e.pageY);
    }
};

dockspawn.UndockInitiator.prototype.onMouseUp = function(e)
{
    if (this.mouseUpHandler)
    {
        this.mouseUpHandler.cancel();
        delete this.mouseUpHandler;
    }
    if (this.mouseMoveHandler)
    {
        this.mouseMoveHandler.cancel();
        delete this.mouseMoveHandler;
    }
};

dockspawn.UndockInitiator.prototype.onMouseMove = function(e)
{
    var position = new Point(e.pageX, e.pageY);
    var dx = position.x - this.dragStartPosition.x;
    var dy = position.y - this.dragStartPosition.y;
    var distance = Math.sqrt(dx * dx + dy * dy);

    if (distance > this.thresholdPixels)
    {
        this.enabled = false;
        this._requestUndock(e);
    }
};

dockspawn.UndockInitiator.prototype._requestUndock = function(e)
{
    var dragOffsetX = this.dragStartPosition.x - this.element.offsetLeft;
    var dragOffsetY = this.dragStartPosition.y - this.element.offsetTop;
    var dragOffset = new Point(dragOffsetX, dragOffsetY);
    this.listener(e, dragOffset);
};
