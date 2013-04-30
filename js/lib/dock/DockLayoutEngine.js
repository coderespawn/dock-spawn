import "DockManager";

dockspawn.DockLayoutEngine = function(dockManager)
{
    this.dockManager = dockManager;
}

/** docks the [newNode] to the left of [referenceNode] */
dockspawn.DockLayoutEngine.prototype.dockLeft = function(referenceNode, newNode)
{
    this._performDock(referenceNode, newNode, "horizontal", true);
};

/** docks the [newNode] to the right of [referenceNode] */
dockspawn.DockLayoutEngine.prototype.dockRight = function(referenceNode, newNode) {
    this._performDock(referenceNode, newNode, "horizontal", false);
};

/** docks the [newNode] to the top of [referenceNode] */
dockspawn.DockLayoutEngine.prototype.dockUp = function(referenceNode, newNode) {
    this._performDock(referenceNode, newNode, "vertical", true);
};

/** docks the [newNode] to the bottom of [referenceNode] */
dockspawn.DockLayoutEngine.prototype.dockDown = function(referenceNode, newNode) {
    this._performDock(referenceNode, newNode, "vertical", false);
};

/** docks the [newNode] by creating a new tab inside [referenceNode] */
dockspawn.DockLayoutEngine.prototype.dockFill = function(referenceNode, newNode) {
    this._performDock(referenceNode, newNode, "fill", false);
};

dockspawn.DockLayoutEngine.prototype.undock = function(node)
{
    var parentNode = node.parent;
    if (!parentNode)
        throw new dockspawn.Exception("Cannot undock.  panel is not a leaf node");

    // Get the position of the node relative to it's siblings
    var siblingIndex = parentNode.children.indexOf(node);

    // Detach the node from the dock manager's tree hierarchy
    node.detachFromParent();

    // Fix the node's parent hierarchy
    if (parentNode.children.length < parentNode.container.minimumAllowedChildNodes) {
        // If the child count falls below the minimum threshold, destroy the parent and merge
        // the children with their grandparents
        var grandParent = parentNode.parent;
        for (var i = 0; i < parentNode.children.length; i++)
        {
            var otherChild = parentNode.children[i];
            if (grandParent)
            {
                // parent node is not a root node
                grandParent.addChildAfter(parentNode, otherChild);
                parentNode.detachFromParent();
                parentNode.container.destroy();
                grandParent.performLayout();
            }
            else
            {
                // Parent is a root node.
                // Make the other child the root node
                parentNode.detachFromParent();
                parentNode.container.destroy();
                this.dockManager.setRootNode(otherChild);
            }
        }
    }
    else
    {
        // the node to be removed has 2 or more other siblings. So it is safe to continue
        // using the parent composite container.
        parentNode.performLayout();

        // Set the next sibling as the active child (e.g. for a Tab host, it would select it as the active tab)
        if (parentNode.children.length > 0)
        {
            var nextActiveSibling = parentNode.children[Math.max(0, siblingIndex - 1)];
            parentNode.container.setActiveChild(nextActiveSibling.container);
        }
    }
    this.dockManager.invalidate();
};

dockspawn.DockLayoutEngine.prototype._performDock = function(referenceNode, newNode, direction, insertBeforeReference)
{
    if (referenceNode.parent && referenceNode.parent.container.containerType == "fill")
        referenceNode = referenceNode.parent;

    if (direction == "fill" && referenceNode.container.containerType == "fill")
    {
        referenceNode.addChild(newNode);
        referenceNode.performLayout();
        referenceNode.container.setActiveChild(newNode.container);
        return;
    }

    // Check if reference node is root node
    var model = this.dockManager.context.model;
    if (referenceNode === model.rootNode)
    {
        var compositeContainer = this._createDockContainer(direction, newNode, referenceNode);
        var compositeNode = new dockspawn.DockNode(compositeContainer);

        if (insertBeforeReference)
        {
            compositeNode.addChild(newNode);
            compositeNode.addChild(referenceNode);
        }
        else
        {
            compositeNode.addChild(referenceNode);
            compositeNode.addChild(newNode);
        }

        // Attach the root node to the dock manager's DOM
        this.dockManager.setRootNode(compositeNode);
        this.dockManager.rebuildLayout(this.dockManager.context.model.rootNode);
        compositeNode.container.setActiveChild(newNode.container);
        return;
    }

    if (referenceNode.parent.container.containerType != direction) {
        var referenceParent = referenceNode.parent;

        // Get the dimensions of the reference node, for resizing later on
        var referenceNodeWidth = referenceNode.container.containerElement.clientWidth;
        var referenceNodeHeight = referenceNode.container.containerElement.clientHeight;

        // Get the dimensions of the reference node, for resizing later on
        var referenceNodeParentWidth = referenceParent.container.containerElement.clientWidth;
        var referenceNodeParentHeight = referenceParent.container.containerElement.clientHeight;

        // Replace the reference node with a new composite node with the reference and new node as it's children
        var compositeContainer = this._createDockContainer(direction, newNode, referenceNode);
        var compositeNode = new dockspawn.DockNode(compositeContainer);

        referenceParent.addChildAfter(referenceNode, compositeNode);
        referenceNode.detachFromParent();
        removeNode(referenceNode.container.containerElement);

        if (insertBeforeReference)
        {
            compositeNode.addChild(newNode);
            compositeNode.addChild(referenceNode);
        }
        else
        {
            compositeNode.addChild(referenceNode);
            compositeNode.addChild(newNode);
        }

        referenceParent.performLayout();
        compositeNode.performLayout();

        compositeNode.container.setActiveChild(newNode.container);
        compositeNode.container.resize(referenceNodeWidth, referenceNodeHeight);
        referenceParent.container.resize(referenceNodeParentWidth, referenceNodeParentHeight);
    }
    else
    {
        // Add as a sibling, since the parent of the reference node is of the right composite type
        var referenceParent = referenceNode.parent;
        if (insertBeforeReference)
            referenceParent.addChildBefore(referenceNode, newNode);
        else
            referenceParent.addChildAfter(referenceNode, newNode);
        referenceParent.performLayout();
        referenceParent.container.setActiveChild(newNode.container);
    }

    // force resize the panel
    var containerWidth = newNode.container.containerElement.clientWidth;
    var containerHeight = newNode.container.containerElement.clientHeight;
    newNode.container.resize(containerWidth, containerHeight);
};

dockspawn.DockLayoutEngine.prototype._forceResizeCompositeContainer = function(container)
{
    var width = container.containerElement.clientWidth;
    var height = container.containerElement.clientHeight;
    container.resize(width, height);
};

dockspawn.DockLayoutEngine.prototype._createDockContainer = function(containerType, newNode, referenceNode)
{
    if (containerType == "horizontal")
        return new dockspawn.HorizontalDockContainer(this.dockManager, [newNode.container, referenceNode.container]);
    if (containerType == "vertical")
        return new dockspawn.VerticalDockContainer(this.dockManager, [newNode.container, referenceNode.container]);
    if (containerType == "fill")
        return new dockspawn.FillDockContainer(this.dockManager);
    throw new dockspawn.Exception("Failed to create dock container of type: " + containerType);
};


/**
 * Gets the bounds of the new node if it were to dock with the specified configuration
 * The state is not modified in this function.  It is used for showing a preview of where
 * the panel would be docked when hovered over a dock wheel button
 */
dockspawn.DockLayoutEngine.prototype.getDockBounds = function(referenceNode, containerToDock, direction, insertBeforeReference)
{
    var compositeNode; // The node that contains the splitter / fill node
    var childCount;
    var childPosition;
    if (direction == "fill")
    {
        // Since this is a fill operation, the highlight bounds is the same as the reference node
        // TODO: Create a tab handle highlight to show that it's going to be docked in a tab
        var targetElement = referenceNode.container.containerElement;
        var bounds = new Rectangle();
        bounds.x = targetElement.offsetLeft;
        bounds.y = targetElement.offsetTop;
        bounds.width = targetElement.clientWidth;
        bounds.height= targetElement.clientHeight;
        return bounds;
    }

    if (referenceNode.parent && referenceNode.parent.container.containerType == "fill")
        // Ignore the fill container's child and move one level up
        referenceNode = referenceNode.parent;

    // Flag to indicate of the renference node was replaced with a new composite node with 2 children
    var hierarchyModified = false;
    if (referenceNode.parent && referenceNode.parent.container.containerType == direction) {
        // The parent already is of the desired composite type.  Will be inserted as sibling to the reference node
        compositeNode = referenceNode.parent;
        childCount = compositeNode.children.length;
        childPosition = compositeNode.children.indexOf(referenceNode) + (insertBeforeReference ? 0 : 1);
    } else {
        // The reference node will be replaced with a new composite node of the desired type with 2 children
        compositeNode = referenceNode;
        childCount = 1;   // The newly inserted composite node will contain the reference node
        childPosition = (insertBeforeReference ? 0 : 1);
        hierarchyModified = true;
    }

    var splitBarSize = 5;  // TODO: Get from DOM
    var targetPanelSize = 0;
    var targetPanelStart = 0;
    if (direction == "vertical" || direction == "horizontal")
    {
        // Existing size of the composite container (without the splitter bars).
        // This will also be the final size of the composite (splitter / fill)
        // container after the new panel has been docked
        var compositeSize = this._getVaringDimension(compositeNode.container, direction) - (childCount - 1) * splitBarSize;

        // size of the newly added panel
        var newPanelOriginalSize = this._getVaringDimension(containerToDock, direction);
        var scaleMultiplier = compositeSize / (compositeSize + newPanelOriginalSize);

        // Size of the panel after it has been docked and scaled
        targetPanelSize = newPanelOriginalSize * scaleMultiplier;
        if (hierarchyModified)
            targetPanelStart = insertBeforeReference ? 0 : compositeSize * scaleMultiplier;
        else
        {
            for (var i = 0; i < childPosition; i++)
                targetPanelStart += this._getVaringDimension(compositeNode.children[i].container, direction);
            targetPanelStart *= scaleMultiplier;
        }
    }

    var bounds = new Rectangle();
    if (direction == "vertical")
    {
        bounds.x = compositeNode.container.containerElement.offsetLeft;
        bounds.y = compositeNode.container.containerElement.offsetTop + targetPanelStart;
        bounds.width = compositeNode.container.width;
        bounds.height = targetPanelSize;
    } else if (direction == "horizontal") {
        bounds.x = compositeNode.container.containerElement.offsetLeft + targetPanelStart;
        bounds.y = compositeNode.container.containerElement.offsetTop;
        bounds.width = targetPanelSize;
        bounds.height = compositeNode.container.height;
    }

    return bounds;
};

dockspawn.DockLayoutEngine.prototype._getVaringDimension = function(container, direction)
{
    if (direction == "vertical")
        return container.height;
    if (direction == "horizontal")
        return container.width;
    return 0;
};
