/**
 * A splitter panel manages the child containers inside it with splitter bars.
 * It can be stacked horizontally or vertically
 */
dockspawn.SplitterPanel = function(childContainers, stackedVertical)
{
    this.childContainers = childContainers;
    this.stackedVertical = stackedVertical;
    this.panelElement = document.createElement('div');
    this.spiltterBars = [];
    this._buildSplitterDOM();
};

dockspawn.SplitterPanel.prototype._buildSplitterDOM = function()
{
    if (this.childContainers.length <= 1)
        throw new dockspawn.Exception("Splitter panel should contain atleast 2 panels");

    this.spiltterBars = [];
    for (var i = 0; i < this.childContainers.length - 1; i++)
    {
        var previousContainer = this.childContainers[i];
        var nextContainer = this.childContainers[i + 1];
        var splitterBar = new dockspawn.SplitterBar(previousContainer, nextContainer, this.stackedVertical);
        this.spiltterBars.push(splitterBar);

        // Add the container and split bar to the panel's base div element
        this._insertContainerIntoPanel(previousContainer);
        this.panelElement.appendChild(splitterBar.barElement);
    }
    this._insertContainerIntoPanel(this.childContainers.slice(-1)[0]);
};

dockspawn.SplitterPanel.prototype.performLayout = function(children)
{
    this.removeFromDOM();

    // rebuild
    this.childContainers = children;
    this._buildSplitterDOM();
};

dockspawn.SplitterPanel.prototype.removeFromDOM = function()
{
    this.childContainers.forEach(function(container)
    {
        if (container.containerElement)
        {
            container.containerElement.classList.remove("splitter-container-vertical");
            container.containerElement.classList.remove("splitter-container-horizontal");
            removeNode(container.containerElement);
        }
    });
    this.spiltterBars.forEach(function(bar) { removeNode(bar.barElement); });
};

dockspawn.SplitterPanel.prototype.destroy = function()
{
    this.removeFromDOM();
    this.panelElement.parentNode.removeChild(this.panelElement);
};

dockspawn.SplitterPanel.prototype._insertContainerIntoPanel = function(container)
{
    if (!container)
    {
        console.log('undefined');
    }

    removeNode(container.containerElement);
    this.panelElement.appendChild(container.containerElement);
    container.containerElement.classList.add(this.stackedVertical ? "splitter-container-vertical" : "splitter-container-horizontal");
};

/**
 * Sets the percentage of space the specified [container] takes in the split panel
 * The percentage is specified in [ratio] and is between 0..1
 */
dockspawn.SplitterPanel.prototype.setContainerRatio = function(container, ratio)
{
    var splitPanelSize = this.stackedVertical ? this.panelElement.clientHeight : this.panelElement.clientWidth;
    var newContainerSize = splitPanelSize * ratio;
    var barSize = this.stackedVertical ? this.spiltterBars[0].barElement.clientHeight : this.spiltterBars[0].barElement.clientWidth;

    var otherPanelSizeQuota = splitPanelSize - newContainerSize - barSize * this.spiltterBars.length;
    var otherPanelScaleMultipler = otherPanelSizeQuota / splitPanelSize;

    for (var i = 0; i < this.childContainers.length; i++)
    {
        var child = this.childContainers[i];
        var size;
        if (child !== container)
        {
            size = this.stackedVertical ? child.containerElement.clientHeight : child.containerElement.clientWidth;
            size *= otherPanelScaleMultipler;
        }
        else
            size = newContainerSize;

        if (this.stackedVertical)
            child.resize(child.width, Math.floor(size));
        else
            child.resize(Math.floor(size), child.height);
    }
};

dockspawn.SplitterPanel.prototype.resize = function(width, height)
{
    if (this.childContainers.length <= 1)
        return;

    // Adjust the fixed dimension that is common to all (i.e. width, if stacked vertical; height, if stacked horizontally)
    for (var i = 0; i < this.childContainers.length; i++)
    {
        var childContainer = this.childContainers[i];
        if (this.stackedVertical)
            childContainer.resize(width, childContainer.height);
        else
            childContainer.resize(childContainer.width, height);

        if (i < this.spiltterBars.length) {
            var splitBar = this.spiltterBars[i];
            if (this.stackedVertical)
                splitBar.barElement.style.width = width + "px";
            else
                splitBar.barElement.style.height = height + "px";
        }
    }

    // Adjust the varying dimension
    var totalChildPanelSize = 0;
    // Find out how much space existing child containers take up (excluding the splitter bars)
    var self = this;
    this.childContainers.forEach(function(container)
    {
        var size = self.stackedVertical ?
            container.height :
            container.width;
        totalChildPanelSize += size;
    });

    // Get the thickness of the bar
    var barSize = this.stackedVertical ? this.spiltterBars[0].barElement.clientHeight : this.spiltterBars[0].barElement.clientWidth;

    // Find out how much space existing child containers will take after being resized (excluding the splitter bars)
    var targetTotalChildPanelSize = this.stackedVertical ? height : width;
    targetTotalChildPanelSize -= barSize * this.spiltterBars.length;

    // Get the scale multiplier
    totalChildPanelSize = Math.max(totalChildPanelSize, 1);
    var scaleMultiplier = targetTotalChildPanelSize / totalChildPanelSize;

    // Update the size with this multiplier
    var updatedTotalChildPanelSize = 0;
    for (var i = 0; i < this.childContainers.length; i++)
    {
        var child = this.childContainers[i];
        var original = this.stackedVertical ?
            child.containerElement.clientHeight :
            child.containerElement.clientWidth;

        var newSize = Math.floor(original * scaleMultiplier);
        updatedTotalChildPanelSize += newSize;

        // If this is the last node, add any extra pixels to fix the rounding off errors and match the requested size
        if (i == this.childContainers.length - 1)
            newSize += targetTotalChildPanelSize - updatedTotalChildPanelSize;

        // Set the size of the panel
        if (this.stackedVertical)
            child.resize(child.width, newSize);
        else
            child.resize(newSize, child.height);
    }

    this.panelElement.style.width = width + "px";
    this.panelElement.style.height = height + "px";
};
