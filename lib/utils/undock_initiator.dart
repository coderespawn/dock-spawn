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
  
  StreamSubscription<MouseEvent> mouseDownHandler;
  StreamSubscription<MouseEvent> mouseUpHandler;
  StreamSubscription<MouseEvent> mouseMoveHandler;
  
  bool _enabled = false;
  bool get enabled {
    return _enabled;
  }
  
  void set enabled(bool value) {
    _enabled = value;
    if (_enabled) {
      _cancelSubscription(mouseDownHandler);
      mouseDownHandler = element.onMouseDown.listen(onMouseDown);
    } else {
      _cancelSubscription(mouseDownHandler);
      _cancelSubscription(mouseUpHandler);
      _cancelSubscription(mouseMoveHandler);
      mouseDownHandler = null;
      mouseUpHandler = null;
      mouseMoveHandler = null;
    }
  }
  
  UndockInitiator(this.element, this.listener, [this.thresholdPixels = 10]) {
  }
  
  void _cancelSubscription(StreamSubscription sub) {
    if (sub != null) {
      sub.cancel();
    }
  }
  
  void onMouseDown(MouseEvent e) {
    // Make sure we dont do this on floating dialogs
    if (enabled) {
      _cancelSubscription(mouseUpHandler);
      _cancelSubscription(mouseMoveHandler);
      mouseUpHandler = window.onMouseUp.listen(onMouseUp);
      mouseMoveHandler = window.onMouseMove.listen(onMouseMove);
      dragStartPosition = new Point2(e.page.x, e.page.y);
    }
  }
  void onMouseUp(MouseEvent e) {
    _cancelSubscription(mouseUpHandler);
    _cancelSubscription(mouseMoveHandler);
    mouseUpHandler = null;
    mouseMoveHandler = null;
  }
  void onMouseMove(MouseEvent e) {
    Point2 position = new Point2(e.page.x, e.page.y);
    num dx = position.x - dragStartPosition.x;
    num dy = position.y - dragStartPosition.y;
    num distance = sqrt(dx * dx + dy * dy);
    
    if (distance > thresholdPixels) {
      enabled = false;
      _requestUndock(e);
    }
  }
  
  void _requestUndock(MouseEvent e) {
    num dragOffsetX = dragStartPosition.x - element.offset.left;
    num dragOffsetY = dragStartPosition.y - element.offset.top;
    Point2 dragOffset = new Point2(dragOffsetX, dragOffsetY);
    listener(e, dragOffset);
  }
}
