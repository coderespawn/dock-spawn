/**
 * Deserializes the dock layout hierarchy from JSON and creates a dock hierarhcy graph
 */
dockspawn.DockGraphDeserializer = function(dockManager)
{
    this.dockManager = dockManager;
};

dockspawn.DockGraphDeserializer.prototype.deserialize = function(json)
{
    var graphInfo = JSON.parse(_json);
    var model = new dockspawn.DockModel();
    model.rootNode = this._buildGraph(graphInfo);
    return model;
};

dockspawn.DockGraphDeserializer.prototype._buildGraph = function(nodeInfo)
{
    var childrenInfo = nodeInfo.children;
    var children = [];
    var self = this;
    childrenInfo.forEach(function(childInfo)
    {
        var childNode = self._buildGraph(childInfo);
        children.push(childNode);
    });

    // Build the container owned by this node
    var container = this._createContainer(nodeInfo, children);

    // Build the node for this container and attach it's children
    var node = new dockspawn.DockNode(container);
    node.children = children;
    node.children.forEach(function(childNode) { childNode.parent = node; });

    return node;
};

dockspawn.DockGraphDeserializer.prototype._createContainer = function(nodeInfo, children)
{
    var containerType = nodeInfo.containerType;
    var containerState = nodeInfo.state;
    var container;

    var childContainers = [];
    children.forEach(function(childNode) { childContainers.push(childNode.container); });
    childContainers = [];

    if (containerType == "panel")
        container = new dockspawn.PanelContainer.loadFromState(containerState, this.dockManager);
    else if (containerType == "horizontal")
        container = new dockspawn.HorizontalDockContainer(this.dockManager, childContainers);
    else if (containerType == "vertical")
        container = new dockspawn.VerticalDockContainer(this.dockManager, childContainers);
    else if (containerType == "fill")
    {
        // Check if this is a document manager

        // TODO: Layout engine compares the string "fill", so cannot create another subclass type
        // called document_manager and have to resort to this hack. use RTTI in layout engine
        var typeDocumentManager = containerState.documentManager;
        if (typeDocumentManager)
            container = new DocumentManagerContainer(this.dockManager);
        else
            container = new dockspawn.FillDockContainer(this.dockManager);
    }
    else
        throw new dockspawn.Exception("Cannot create dock container of unknown type: " + containerType);

    // Restore the state of the container
    container.loadState(containerState);
    container.performLayout(childContainers);
    return container;
};
