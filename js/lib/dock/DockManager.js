/**
 * Dock manager manages all the dock panels in a hierarchy, similar to visual studio.
 * It owns a Html Div element inside which all panels are docked
 * Initially the document manager takes up the central space and acts as the root node
 */

 dockspawn.DockManager = function(element)
{
    if (element === undefined)
        throw new dockspawn.Exception("Invalid Dock Manager element provided");

    this.element = element;
    this.context = this.dockWheel = this.layoutEngine = this.mouseMoveHandler = undefined;
    this.layoutEventListeners = [];
};

dockspawn.DockManager.prototype.initialize = function()
{
    this.context = new dockspawn.DockManagerContext(this);
    var documentNode = new dockspawn.DockNode(this.context.documentManagerView);
    this.context.model.rootNode = documentNode;
    this.context.model.documentManagerNode = documentNode;
    this.setRootNode(this.context.model.rootNode);
    // Resize the layout
    this.resize(this.element.clientWidth, this.element.clientHeight);
    this.dockWheel = new dockspawn.DockWheel(this);
    this.layoutEngine = new dockspawn.DockLayoutEngine(this);

    this.rebuildLayout(this.context.model.rootNode);
};

dockspawn.DockManager.prototype.rebuildLayout = function(node)
{
    var self = this;
    node.children.forEach(function(child) { self.rebuildLayout(child); });
    node.performLayout();
};

dockspawn.DockManager.prototype.invalidate = function()
{
    this.resize(this.element.clientWidth, this.element.clientHeight);
};

dockspawn.DockManager.prototype.resize = function(width, height)
{
    this.element.style.width = width + "px";
    this.element.style.height = height + "px";
    this.context.model.rootNode.container.resize(width, height);
};

/**
 * Reset the dock model . This happens when the state is loaded from json
 */
dockspawn.DockManager.prototype.setModel = function(model)
{
    removeNode(this.context.documentManagerView.containerElement);
    this.context.model = model;
    this.setRootNode(model.rootNode);

    this.rebuildLayout(model.rootNode);
    this.invalidate();
};

dockspawn.DockManager.prototype.setRootNode = function(node)
{
    if (this.context.model.rootNode)
    {
        // detach it from the dock manager's base element
//      context.model.rootNode.detachFromParent();
    }

    // Attach the new node to the dock manager's base element and set as root node
    node.detachFromParent();
    this.context.model.rootNode = node;
    this.element.appendChild(node.container.containerElement);
};


dockspawn.DockManager.prototype.onDialogDragStarted = function(sender, e)
{
    this.dockWheel.activeNode = this._findNodeOnPoint(e.pageX, e.pageY);
    this.dockWheel.activeDialog = sender;
    this.dockWheel.showWheel();
    if (this.mouseMoveHandler)
    {
        this.mouseMoveHandler.cancel();
        delete this.mouseMoveHandler;
    }
    this.mouseMoveHandler = new dockspawn.EventHandler(window, 'mousemove', this.onMouseMoved.bind(this));
};

dockspawn.DockManager.prototype.onDialogDragEnded = function(sender, e)
{
    if (this.mouseMoveHandler)
    {
        this.mouseMoveHandler.cancel();
        delete this.mouseMoveHandler;
    }
    this.dockWheel.onDialogDropped(sender);
    this.dockWheel.hideWheel();
    delete this.dockWheel.activeDialog;
};

dockspawn.DockManager.prototype.onMouseMoved = function(e)
{
    this.dockWheel.activeNode = this._findNodeOnPoint(e.clientX, e.clientY);
};

/**
 * Perform a DFS on the dock model's tree to find the
 * deepest level panel (i.e. the top-most non-overlapping panel)
 * that is under the mouse cursor
 * Retuns null if no node is found under this point
 */
dockspawn.DockManager.prototype._findNodeOnPoint = function(x, y)
{
    var stack = [];
    stack.push(this.context.model.rootNode);
    var bestMatch;

    while (stack.length > 0)
    {
        var topNode = stack.pop();

        if (isPointInsideNode(x, y, topNode))
        {
            // This node contains the point.
            bestMatch = topNode;

            // Keep looking future down
            [].push.apply(stack, topNode.children);
        }
    }
    return bestMatch;
};

/** Dock the [dialog] to the left of the [referenceNode] node */
dockspawn.DockManager.prototype.dockDialogLeft = function(referenceNode, dialog)
{
    return this._requestDockDialog(referenceNode, dialog, this.layoutEngine.dockLeft.bind(this.layoutEngine));
};

/** Dock the [dialog] to the right of the [referenceNode] node */
dockspawn.DockManager.prototype.dockDialogRight = function(referenceNode, dialog)
{
    return this._requestDockDialog(referenceNode, dialog, this.layoutEngine.dockRight.bind(this.layoutEngine));
};

/** Dock the [dialog] above the [referenceNode] node */
dockspawn.DockManager.prototype.dockDialogUp = function(referenceNode, dialog)
{
    return this._requestDockDialog(referenceNode, dialog, this.layoutEngine.dockUp.bind(this.layoutEngine));
};

/** Dock the [dialog] below the [referenceNode] node */
dockspawn.DockManager.prototype.dockDialogDown = function(referenceNode, dialog)
{
    return this._requestDockDialog(referenceNode, dialog, this.layoutEngine.dockDown.bind(this.layoutEngine));
};

/** Dock the [dialog] as a tab inside the [referenceNode] node */
dockspawn.DockManager.prototype.dockDialogFill = function(referenceNode, dialog)
{
    return this._requestDockDialog(referenceNode, dialog, this.layoutEngine.dockFill.bind(this.layoutEngine));
};

/** Dock the [container] to the left of the [referenceNode] node */
dockspawn.DockManager.prototype.dockLeft = function(referenceNode, container, ratio)
{
    return this._requestDockContainer(referenceNode, container, this.layoutEngine.dockLeft.bind(this.layoutEngine), ratio);
};

/** Dock the [container] to the right of the [referenceNode] node */
dockspawn.DockManager.prototype.dockRight = function(referenceNode,  container, ratio)
{
    return this._requestDockContainer(referenceNode, container, this.layoutEngine.dockRight.bind(this.layoutEngine), ratio);
};

/** Dock the [container] above the [referenceNode] node */
dockspawn.DockManager.prototype.dockUp = function(referenceNode,  container, ratio)
{
    return this._requestDockContainer(referenceNode, container, this.layoutEngine.dockUp.bind(this.layoutEngine), ratio);
};

/** Dock the [container] below the [referenceNode] node */
dockspawn.DockManager.prototype.dockDown = function(referenceNode,  container, ratio)
{
    return this._requestDockContainer(referenceNode, container, this.layoutEngine.dockDown.bind(this.layoutEngine), ratio);
};

/** Dock the [container] as a tab inside the [referenceNode] node */
dockspawn.DockManager.prototype.dockFill = function(referenceNode, container)
{
    return this._requestDockContainer(referenceNode, container, this.layoutEngine.dockFill.bind(this.layoutEngine));
};

dockspawn.DockManager.prototype._requestDockDialog = function(referenceNode, dialog, layoutDockFunction)
{
    // Get the active dialog that was dragged on to the dock wheel
    var panel = dialog.panel;
    var newNode = new dockspawn.DockNode(panel);
    panel.prepareForDocking();
    dialog.destroy();
    layoutDockFunction(referenceNode, newNode);
    this.invalidate();
    return newNode;
};

dockspawn.DockManager.prototype._requestDockContainer = function(referenceNode, container, layoutDockFunction, ratio)
{
    // Get the active dialog that was dragged on to the dock wheel
    var newNode = new dockspawn.DockNode(container);
    if (container.containerType == "panel")
    {
        var panel = container;
        panel.prepareForDocking();
        removeNode(panel.elementPanel);
    }
    layoutDockFunction(referenceNode, newNode);

    if (ratio && newNode.parent &&
        (newNode.parent.container.containerType == "vertical" || newNode.parent.container.containerType == "horizontal"))
    {
        var splitter = newNode.parent.container;
        splitter.setContainerRatio(container, ratio);
    }

    this.rebuildLayout(this.context.model.rootNode);
    this.invalidate();
    return newNode;
};

/**
 * Undocks a panel and converts it into a floating dialog window
 * It is assumed that only leaf nodes (panels) can be undocked
 */
dockspawn.DockManager.prototype.requestUndockToDialog = function(container, event, dragOffset)
{
    var node = this._findNodeFromContainer(container);
    this.layoutEngine.undock(node);

    // Create a new dialog window for the undocked panel
    var dialog = new dockspawn.Dialog(node.container, this);

    // Adjust the relative position
    var dialogWidth = dialog.elementDialog.clientWidth;
    if (dragOffset.x > dialogWidth)
        dragOffset.x = 0.75 * dialogWidth;
    dialog.setPosition(
        event.clientX - dragOffset.x,
        event.clientY - dragOffset.y);
    dialog.draggable.onMouseDown(event);

    return dialog;
};

/** Undocks a panel and converts it into a floating dialog window
 * It is assumed that only leaf nodes (panels) can be undocked
 */
dockspawn.DockManager.prototype.requestUndock = function(container)
{
    var node = this._findNodeFromContainer(container);
    this.layoutEngine.undock(node);
};

/**
 * Removes a dock container from the dock layout hierarcy
 * Returns the node that was removed from the dock tree
 */
dockspawn.DockManager.prototype.requestRemove = function(container)
{
    var node = this._findNodeFromContainer(container);
    var parent = node.parent;
    node.detachFromParent();
    if (parent)
        this.rebuildLayout(parent);
    return node;
};

/** Finds the node that owns the specified [container] */
dockspawn.DockManager.prototype._findNodeFromContainer = function(container)
{
    //this.context.model.rootNode.debug_DumpTree();

    var stack = [];
    stack.push(this.context.model.rootNode);

    while (stack.length > 0)
    {
        var topNode = stack.pop();

        if (topNode.container === container)
            return topNode;
        [].push.apply(stack, topNode.children);
    }

    throw new dockspawn.Exception("Cannot find dock node belonging to the element");
};

dockspawn.DockManager.prototype.addLayoutListener = function(listener)
{
    this.layoutEventListeners.push(listener);
};

dockspawn.DockManager.prototype.removeLayoutListener = function(listener)
{
    this.layoutEventListeners.splice(this.layoutEventListeners.indexOf(listener), 1);
};

dockspawn.DockManager.prototype.suspendLayout = function()
{
    var self = this;
    this.layoutEventListeners.forEach(function(listener) { 
		if (listener.onSuspendLayout) listener.onSuspendLayout(self); 
	});
};

dockspawn.DockManager.prototype.resumeLayout = function()
{
    var self = this;
    this.layoutEventListeners.forEach(function(listener) { 
		if (listener.onResumeLayout) listener.onResumeLayout(self); 
	});
};

dockspawn.DockManager.prototype.notifyOnDock = function(dockNode)
{
    var self = this;
    this.layoutEventListeners.forEach(function(listener) { 
		if (listener.onDock) {
			listener.onDock(self, dockNode); 
		}
	});
};

dockspawn.DockManager.prototype.notifyOnUnDock = function(dockNode)
{
    var self = this;
    this.layoutEventListeners.forEach(function(listener) { 
		if (listener.onUndock) {
			listener.onUndock(self, dockNode); 
		}
	});
};

dockspawn.DockManager.prototype.saveState = function()
{
    var serializer = new dockspawn.DockGraphSerializer();
    return serializer.serialize(this.context.model);
};

dockspawn.DockManager.prototype.loadState = function(json)
{
    var deserializer = new dockspawn.DockGraphDeserializer(this);
    this.context.model = deserializer.deserialize(json);
    this.setModel(this.context.model);
};

//typedef void LayoutEngineDockFunction(dockspawn.DockNode referenceNode, dockspawn.DockNode newNode);

/**
* The Dock Manager notifies the listeners of layout changes so client containers that have
* costly layout structures can detach and reattach themself to avoid reflow
*/
//abstract class LayoutEventListener {
//void onSuspendLayout(dockspawn.DockManager dockManager);
//void onResumeLayout(dockspawn.DockManager dockManager);
//}
