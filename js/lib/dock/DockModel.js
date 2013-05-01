/**
 * The Dock Model contains the tree hierarchy that represents the state of the
 * panel placement within the dock manager.
 */
dockspawn.DockModel = function()
{
    this.rootNode = this.documentManagerNode = undefined;
};

dockspawn.DockNode = function(container)
{
    /** The dock container represented by this node */
    this.container = container;
    this.children = [];
}

dockspawn.DockNode.prototype.detachFromParent = function()
{
    if (this.parent)
    {
        this.parent.removeChild(this);
        delete this.parent;
    }
};

dockspawn.DockNode.prototype.removeChild = function(childNode)
{
    var index = this.children.indexOf(childNode);
    if (index >= 0)
        this.children.splice(index, 1);
};

dockspawn.DockNode.prototype.addChild = function(childNode)
{
    childNode.detachFromParent();
    childNode.parent = this;
    this.children.push(childNode);
};

dockspawn.DockNode.prototype.addChildBefore = function(referenceNode, childNode)
{
    this._addChildWithDirection(referenceNode, childNode, true);
};

dockspawn.DockNode.prototype.addChildAfter = function(referenceNode, childNode)
{
    this._addChildWithDirection(referenceNode, childNode, false);
};

dockspawn.DockNode.prototype._addChildWithDirection = function(referenceNode, childNode, before)
{
    // Detach this node from it's parent first
    childNode.detachFromParent();
    childNode.parent = this;

    var referenceIndex = this.children.indexOf(referenceNode);
    var preList = this.children.slice(0, referenceIndex);
    var postList = this.children.slice(referenceIndex + 1, this.children.length);

    this.children = preList.slice(0);
    if (before)
    {
        this.children.push(childNode);
        this.children.push(referenceNode);
    }
    else
    {
        this.children.push(referenceNode);
        this.children.push(childNode);
    }
    Array.prototype.push.apply(this.children, postList);
};

dockspawn.DockNode.prototype.performLayout = function()
{
    var childContainers = this.children.map(function(childNode) { return childNode.container; });
    this.container.performLayout(childContainers);
};

dockspawn.DockNode.prototype.debug_DumpTree = function(indent)
{
    if (indent === undefined)
        indent = 0;

    var message = this.container.name;
    for (var i = 0; i < indent; i++)
        message = "\t" + message;

    var parentType = this.parent === undefined ? "null" : this.parent.container.containerType;
    console.log(">>" + message + " [" + parentType + "]");

    this.children.forEach(function(childNode) { childNode.debug_DumpTree(indent + 1) });
};
