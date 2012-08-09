
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

  void onMouseMoved(MouseEvent e) {
    int dx = e.x - previousMouseEvent.x;
    int dy = e.y - previousMouseEvent.y;
    _performDrag(dx, dy);
    previousMouseEvent = e;
  }
  
  void _performDrag(int dx, int dy) {
    int previousPanelSize = stackedVertical ? previousContainer.containerElement.$dom_clientHeight : previousContainer.containerElement.$dom_clientWidth; 
    int nextPanelSize = stackedVertical ? nextContainer.containerElement.$dom_clientHeight : nextContainer.containerElement.$dom_clientWidth;
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
      previousContainer.height = newPreviousPanelSize;
      nextContainer.height = newNextPanelSize;
    } else {
      previousContainer.width = newPreviousPanelSize;
      nextContainer.width = newNextPanelSize;
    }
  }
  
  void _startDragging(MouseEvent e) {
    disableGlobalTextSelection();
    window.document.body.classes.add("disable-selection");
    window.on.mouseMove.add(mouseMovedHandler);
    window.on.mouseUp.add(mouseUpHandler);
    previousMouseEvent = e;
  }
  
  void _stopDragging(MouseEvent e) {
    enableGlobalTextSelection();
    window.document.body.classes.remove("disable-selection");
    window.on.mouseMove.remove(mouseMovedHandler);
    window.on.mouseUp.remove(mouseUpHandler);
  }
}
