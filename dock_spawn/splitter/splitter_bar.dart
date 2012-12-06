part of dock_spawn;

class SplitterBar {
  IDockContainer previousContainer; // The panel to the left/top side of the bar, depending on the bar orientation
  IDockContainer nextContainer;     // The panel to the right/bottom side of the bar, depending on the bar orientation
  DivElement barElement;
  bool stackedVertical;
  var mouseMovedHandler;
  var mouseDownHandler;
  var mouseUpHandler;
  MouseEvent previousMouseEvent;
  int minPanelSize = 50; // TODO: Get from container configuration
  Size previousContainerSize;
  Size nextContainerSize;
  
  SplitterBar(this.previousContainer, this.nextContainer, this.stackedVertical) {
    barElement = new DivElement();
    barElement.classes.add(stackedVertical ? "splitbar-horizontal" : "splitbar-vertical");

    mouseMovedHandler = onMouseMoved;
    mouseDownHandler = onMouseDown;
    mouseUpHandler = onMouseUp;
    
    barElement.on.mouseDown.add(mouseDownHandler);
  }

  void onMouseDown(MouseEvent e) {
    _startDragging(e);
  }
  
  void onMouseUp(MouseEvent e) {
    _stopDragging(e);
  }
 
  bool readyToProcessNextDrag = true;
  void onMouseMoved(MouseEvent e) {
    if (!readyToProcessNextDrag) {
      print ("Skip");
      return;
    }
    readyToProcessNextDrag = false;
    window.requestLayoutFrame(() {
      int dx = e.pageX - previousMouseEvent.pageX;
      int dy = e.pageY - previousMouseEvent.pageY;
      _performDrag(dx, dy);
      previousMouseEvent = e;
      readyToProcessNextDrag = true;
    });
  }
  
  void _performDrag(int dx, int dy) {
    int previousWidth = previousContainer.containerElement.clientWidth;
    int previousHeight = previousContainer.containerElement.clientHeight;
    int nextWidth = nextContainer.containerElement.clientWidth;
    int nextHeight = nextContainer.containerElement.clientHeight;
    
    int previousPanelSize = stackedVertical ? previousHeight : previousWidth; 
    int nextPanelSize = stackedVertical ? nextHeight : nextWidth;
    int deltaMovement = stackedVertical ? dy : dx;
    int newPreviousPanelSize = previousPanelSize + deltaMovement; 
    int newNextPanelSize = nextPanelSize - deltaMovement;
    
    if (newPreviousPanelSize < minPanelSize || newNextPanelSize < minPanelSize) {
      // One of the panels is smaller than it should be.
      // In that case, check if the small panel's size is being increased
      bool continueProcessing = (newPreviousPanelSize < minPanelSize && newPreviousPanelSize > previousPanelSize) || 
          (newNextPanelSize < minPanelSize && newNextPanelSize > nextPanelSize);
      
      if (!continueProcessing) return;
    }

    if (stackedVertical) {
      previousContainer.resize(previousWidth, newPreviousPanelSize);
      nextContainer.resize(nextWidth, newNextPanelSize);
    } else {
      previousContainer.resize(newPreviousPanelSize, previousHeight);
      nextContainer.resize(newNextPanelSize, nextHeight);
    }
  }
  
  void _startDragging(MouseEvent e) {
    disableGlobalTextSelection();
    document.body.classes.add("disable-selection");
    window.on.mouseMove.add(mouseMovedHandler);
    window.on.mouseUp.add(mouseUpHandler);
    previousMouseEvent = e;
  }
  
  void _stopDragging(MouseEvent e) {
    enableGlobalTextSelection();
    document.body.classes.remove("disable-selection");
    window.on.mouseMove.remove(mouseMovedHandler);
    window.on.mouseUp.remove(mouseUpHandler);
  }
}
