/**
 * The serializer saves / loads the state of the dock layout hierarchy
 */
dockspawn.DockGraphSerializer = function()
{
};

dockspawn.DockGraphSerializer.prototype.serialize = function(model)
{
    var graphInfo = this._buildGraphInfo(model.rootNode);
    return JSON.stringify(graphInfo);
};

dockspawn.DockGraphSerializer.prototype._buildGraphInfo = function(node)
{
    var nodeState = {};
    node.container.saveState(nodeState);

    var childrenInfo = [];
    var self = this;
    node.childNodes.forEach(function(childNode) {
        childrenInfo.push(self._buildGraphInfo(childNode));
    });

    var nodeInfo = {};
    nodeInfo.containerType = node.container.containerType;
    nodeInfo.state = nodeState;
    nodeInfo.children = childrenInfo;
    return nodeInfo;
};
