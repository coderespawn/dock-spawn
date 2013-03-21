part of dock_spawn;

/**
 * A splitter panel manages the child containers inside it with splitter bars.  
 * It can be stacked horizontally or vertically
 */  
class SplitterPanel {
  DivElement panelElement;
  List<IDockContainer> childContainers;
  List<SplitterBar> spiltterBars;
  bool stackedVertical;
  
  SplitterPanel(this.childContainers, this.stackedVertical) {
    panelElement = new DivElement();
    spiltterBars = new List<SplitterBar>();
    _buildSplitterDOM();
  }
  
  void _buildSplitterDOM() {
    if (childContainers.length <= 1) {
      return;
      //throw new SplitterException("Splitter panel should contain atleast 2 panels");
    }
    
    spiltterBars = new List<SplitterBar>();
    for (int i = 0; i < childContainers.length - 1; i++) {
      var previousContainer = childContainers[i];
      var nextContainer = childContainers[i + 1];
      var splitterBar = new SplitterBar(previousContainer, nextContainer, stackedVertical);
      spiltterBars.add(splitterBar);
      
      // Add the container and split bar to the panel's base div element
      _insertContainerIntoPanel(previousContainer);
      panelElement.nodes.add(splitterBar.barElement);
    }
    _insertContainerIntoPanel(childContainers.last);
  }

  void performLayout(List<IDockContainer> children)  {
    removeFromDOM();
    
    // rebuild
    this.childContainers = children;
    _buildSplitterDOM();
  }
  
  void removeFromDOM() {
    childContainers.forEach((container) {
      if (container.containerElement != null) {
        container.containerElement.classes.remove("splitter-container-vertical");
        container.containerElement.classes.remove("splitter-container-horizontal");
        container.containerElement.remove();
      }
    });
    spiltterBars.forEach((bar) => bar.barElement.remove());
  }
  
  void destroy() {
    removeFromDOM();
    panelElement.remove();
  }
  
  void _insertContainerIntoPanel(IDockContainer container) {
    container.containerElement.remove();
    panelElement.nodes.add(container.containerElement);
    container.containerElement.classes.add(stackedVertical ? "splitter-container-vertical" : "splitter-container-horizontal");
  }

  /**
   * Sets the percentage of space the specified [container] takes in the split panel
   * The percentage is specified in [ratio] and is between 0..1
   */ 
  void setContainerRatio(IDockContainer container, num ratio) {
    num splitPanelSize = stackedVertical ? panelElement.client.height : panelElement.client.width;
    num newContainerSize = splitPanelSize * ratio;
    int barSize = stackedVertical ? spiltterBars[0].barElement.client.height : spiltterBars[0].barElement.client.width;

    num otherPanelSizeQuota = splitPanelSize - newContainerSize - barSize * spiltterBars.length;
    num otherPanelScaleMultipler = otherPanelSizeQuota / splitPanelSize;
    
    childContainers.forEach((child) {
      num size;
      if (child != container) {
        size = stackedVertical ? child.containerElement.client.height : child.containerElement.client.width;
        size *=  otherPanelScaleMultipler;
      } else {
        size = newContainerSize;
      }
      
      if (stackedVertical) {
        child.resize(child.width, size.toInt());
      } else {

        child.resize(size.toInt(), child.height);
      }
    });
  }
  
  void resize(int width, int height) {
    if (childContainers.length <= 1) return;
    
    // Adjust the fixed dimension that is common to all (i.e. width, if stacked vertical; height, if stacked horizontally)
    for (int i = 0; i < childContainers.length; i++) {
      var childContainer = childContainers[i];
      if (stackedVertical) {
        childContainer.resize(width, childContainer.height);
      } else {
        childContainer.resize(childContainer.width, height);
      }
      
      if (i < spiltterBars.length) {
        var splitBar = spiltterBars[i];
        if (stackedVertical) {
          splitBar.barElement.style.width = "${width}px";
        } else {
          splitBar.barElement.style.height = "${height}px";
        }
      }
    }
    
    // Adjust the varying dimension
    int totalChildPanelSize = 0;
    // Find out how much space existing child containers take up (excluding the splitter bars)
    childContainers.forEach((container) {
      int size = stackedVertical ? 
          container.height : 
          container.width;
      totalChildPanelSize += size;
    });
    
    // Get the thickness of the bar
    int barSize = stackedVertical ? spiltterBars[0].barElement.client.height : spiltterBars[0].barElement.client.width;
    
    // Find out how much space existing child containers will take after being resized (excluding the splitter bars)  
    int targetTotalChildPanelSize = stackedVertical ? height : width;
    targetTotalChildPanelSize -= barSize * spiltterBars.length;
    
    // Get the scale multiplier 
    totalChildPanelSize = max(totalChildPanelSize, 1);
    num scaleMultiplier = targetTotalChildPanelSize / totalChildPanelSize;
    
    // Update the size with this multiplier
    int updatedTotalChildPanelSize = 0;
    for (int i = 0; i < childContainers.length; i++) {
      var child = childContainers[i];
      int original = stackedVertical ? 
          child.containerElement.client.height : 
          child.containerElement.client.width;

      int newSize = (original * scaleMultiplier).toInt();
      updatedTotalChildPanelSize += newSize;
      
      // If this is the last node, add any extra pixels to fix the rounding off errors and match the requested size
      if (i == childContainers.length - 1) {
        newSize += targetTotalChildPanelSize - updatedTotalChildPanelSize;
      }
      
      // Set the size of the panel
      if (stackedVertical) {
        child.resize(child.width, newSize);
      } else {
        child.resize(newSize, child.height);
      }
    }
    
    panelElement.style.width = "${width}px";
    panelElement.style.height = "${height}px";
  }
}
