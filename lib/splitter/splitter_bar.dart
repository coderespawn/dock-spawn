part of dock_spawn;

class SplitterBar {
  IDockContainer previousContainer; // The panel to the left/top side of the bar, depending on the bar orientation
  IDockContainer nextContainer;     // The panel to the right/bottom side of the bar, depending on the bar orientation
  DivElement barElement;
  bool stackedVertical;
  StreamSubscription<MouseEvent> mouseMovedHandler;
  StreamSubscription<MouseEvent> mouseDownHandler;
  StreamSubscription<MouseEvent> mouseUpHandler;
  MouseEvent previousMouseEvent;
  int minPanelSize = 50; // TODO: Get from container configuration
  Size previousContainerSize;
  Size nextContainerSize;
  
  SplitterBar(this.previousContainer, this.nextContainer, this.stackedVertical) {
    barElement = new DivElement();
    barElement.classes.add(stackedVertical ? "splitbar-horizontal" : "splitbar-vertical");
    
    mouseDownHandler = barElement.onMouseDown.listen(onMouseDown);
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
    var dockManager = previousContainer.dockManager;
    dockManager.suspendLayout();
    int dx = e.$dom_pageX - previousMouseEvent.$dom_pageX;
    int dy = e.$dom_pageY - previousMouseEvent.$dom_pageY;
    _performDrag(dx, dy);
    previousMouseEvent = e;
    readyToProcessNextDrag = true;
    dockManager.resumeLayout();
  }
  
  void _performDrag(int dx, int dy) {
    int previousWidth = previousContainer.containerElement.$dom_clientWidth;
    int previousHeight = previousContainer.containerElement.$dom_clientHeight;
    int nextWidth = nextContainer.containerElement.$dom_clientWidth;
    int nextHeight = nextContainer.containerElement.$dom_clientHeight;
    
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
    if (mouseMovedHandler != null) {
      mouseMovedHandler.cancel();
      mouseMovedHandler = null;
    }
    if (mouseUpHandler != null) {
      mouseUpHandler.cancel();
      mouseUpHandler = null;
    }
    mouseMovedHandler = window.onMouseMove.listen(onMouseMoved);
    mouseUpHandler = window.onMouseUp.listen(onMouseUp);
    previousMouseEvent = e;
  }
  
  void _stopDragging(MouseEvent e) {
    enableGlobalTextSelection();
    document.body.classes.remove("disable-selection");
    if (mouseMovedHandler != null) {
      mouseMovedHandler.cancel();
      mouseMovedHandler = null;
    }
    if (mouseUpHandler != null) {
      mouseUpHandler.cancel();
      mouseUpHandler = null;
    }
  }
}
