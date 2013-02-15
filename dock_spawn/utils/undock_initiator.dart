part of dock_spawn;

/** Listen for undock events */
typedef Dialog OnUndock(MouseEvent e, Point2 dragOffset);

/**
 * Listens for events on the [element] and notifies the [listener]
 * if an undock event has been invoked.  An undock event is invoked
 * when the user clicks on the event and drags is beyond the 
 * specified [thresholdPixels]
 */ 
class UndockInitiator {
  Element element;
  OnUndock listener;
  num thresholdPixels;
  Point2 dragStartPosition;
  
  var mouseDownHandler;
  var mouseUpHandler;
  var mouseMoveHandler;
  
  bool _enabled = false;
  bool get enabled {
    return _enabled;
  }
  
  void set enabled(bool value) {
    _enabled = value;
    if (_enabled) {
      element.on.mouseDown.add(mouseDownHandler);
    } else {
      element.on.mouseDown.remove(mouseDownHandler);
      window.on.mouseUp.remove(mouseUpHandler);
      window.on.mouseMove.remove(mouseMoveHandler);
    }
  }
  
  UndockInitiator(this.element, this.listener, [this.thresholdPixels = 10]) {
    mouseDownHandler = onMouseDown;
    mouseUpHandler = onMouseUp;
    mouseMoveHandler = onMouseMove;
  }
  
  void onMouseDown(MouseEvent e) {
    // Make sure we dont do this on floating dialogs
    if (enabled) {
      window.on.mouseUp.add(mouseUpHandler);
      window.on.mouseMove.add(mouseMoveHandler);
      dragStartPosition = new Point2(e.pageX, e.pageY);
    }
  }
  void onMouseUp(MouseEvent e) {
    window.on.mouseUp.remove(mouseUpHandler);
    window.on.mouseMove.remove(mouseMoveHandler);
  }
  void onMouseMove(MouseEvent e) {
    Point2 position = new Point2(e.pageX, e.pageY);
    num dx = position.x - dragStartPosition.x;
    num dy = position.y - dragStartPosition.y;
    num distance = sqrt(dx * dx + dy * dy);
    
    if (distance > thresholdPixels) {
      enabled = false;
      _requestUndock(e);
    }
  }
  
  void _requestUndock(MouseEvent e) {
    num dragOffsetX = dragStartPosition.x - element.offsetLeft;
    num dragOffsetY = dragStartPosition.y - element.offsetTop;
    Point2 dragOffset = new Point2(dragOffsetX, dragOffsetY);
    listener(e, dragOffset);
  }
}
