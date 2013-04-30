dockspawn.SplitterBar = function(previousContainer, nextContainer, stackedVertical)
{
    this.previousContainer = previousContainer; // The panel to the left/top side of the bar, depending on the bar orientation
    this.nextContainer = nextContainer;         // The panel to the right/bottom side of the bar, depending on the bar orientation
    this.stackedVertical = stackedVertical;
    this.barElement = document.createElement('div');
    this.barElement.classList.add(stackedVertical ? "splitbar-horizontal" : "splitbar-vertical");
    this.mouseDownHandler = new dockspawn.EventHandler(this.barElement, 'mousedown', this.onMouseDown.bind(this));
    this.minPanelSize = 50; // TODO: Get from container configuration
    this.readyToProcessNextDrag = true;
};

dockspawn.SplitterBar.prototype.onMouseDown = function(e)
{
    this._startDragging(e);
};

dockspawn.SplitterBar.prototype.onMouseUp = function(e)
{
    this._stopDragging(e);
};

dockspawn.SplitterBar.prototype.onMouseMoved = function(e)
{
    if (!this.readyToProcessNextDrag)
        return;
    this.readyToProcessNextDrag = false;

    var dockManager = this.previousContainer.dockManager;
    dockManager.suspendLayout();
    var dx = e.pageX - this.previousMouseEvent.pageX;
    var dy = e.pageY - this.previousMouseEvent.pageY;
    this._performDrag(dx, dy);
    this.previousMouseEvent = e;
    this.readyToProcessNextDrag = true;
    dockManager.resumeLayout();
};

dockspawn.SplitterBar.prototype._performDrag = function(dx, dy)
{
    var previousWidth = this.previousContainer.containerElement.clientWidth;
    var previousHeight = this.previousContainer.containerElement.clientHeight;
    var nextWidth = this.nextContainer.containerElement.clientWidth;
    var nextHeight = this.nextContainer.containerElement.clientHeight;

    var previousPanelSize = this.stackedVertical ? previousHeight : previousWidth;
    var nextPanelSize = this.stackedVertical ? nextHeight : nextWidth;
    var deltaMovement = this.stackedVertical ? dy : dx;
    var newPreviousPanelSize = previousPanelSize + deltaMovement;
    var newNextPanelSize = nextPanelSize - deltaMovement;

    if (newPreviousPanelSize < this.minPanelSize || newNextPanelSize < this.minPanelSize)
    {
        // One of the panels is smaller than it should be.
        // In that case, check if the small panel's size is being increased
        var continueProcessing = (newPreviousPanelSize < this.minPanelSize && newPreviousPanelSize > previousPanelSize) ||
            (newNextPanelSize < this.minPanelSize && newNextPanelSize > nextPanelSize);

        if (!continueProcessing)
            return;
    }

    if (this.stackedVertical)
    {
        this.previousContainer.resize(previousWidth, newPreviousPanelSize);
        this.nextContainer.resize(nextWidth, newNextPanelSize);
    }
    else
    {
        this.previousContainer.resize(newPreviousPanelSize, previousHeight);
        this.nextContainer.resize(newNextPanelSize, nextHeight);
    }
};

dockspawn.SplitterBar.prototype._startDragging = function(e)
{
    disableGlobalTextSelection();
    if (this.mouseMovedHandler)
    {
        this.mouseMovedHandler.cancel();
        delete this.mouseMovedHandler;
    }
    if (this.mouseUpHandler)
    {
        this.mouseUpHandler.cancel();
        delete this.mouseUpHandler;
    }
    this.mouseMovedHandler = new dockspawn.EventHandler(window, 'mousemove', this.onMouseMoved.bind(this));
    this.mouseUpHandler = new dockspawn.EventHandler(window, 'mouseup', this.onMouseUp.bind(this));
    this.previousMouseEvent = e;
};

dockspawn.SplitterBar.prototype._stopDragging = function(e)
{
    enableGlobalTextSelection();
    document.body.classList.remove("disable-selection");
    if (this.mouseMovedHandler)
    {
        this.mouseMovedHandler.cancel();
        delete this.mouseMovedHandler;
    }
    if (this.mouseUpHandler)
    {
        this.mouseUpHandler.cancel();
        delete this.mouseUpHandler;
    }
};
