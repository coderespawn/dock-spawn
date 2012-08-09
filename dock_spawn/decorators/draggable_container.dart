
class DraggableContainer implements IDockContainer {
  String containerType;
  IDockContainer delegate;
  Element topLevelElement;
  Element dragHandle;
  Dialog dialog;
  DialogEventListener eventListener;
  
  var mouseDownHandler;
  var mouseUpHandler;
  var mouseMoveHandler;
  
  Point dragOffset;
  Point previousMousePosition;
  
  DraggableContainer(this.dialog, this.delegate, this.topLevelElement, this.dragHandle) {
    containerType = delegate.containerType;
    
    mouseDownHandler = onMouseDown;
    mouseUpHandler = onMouseUp;
    mouseMoveHandler = onMouseMove;
    
    dragHandle.on.mouseDown.add(mouseDownHandler);
    topLevelElement.style.marginLeft = "${topLevelElement.$dom_offsetLeft}";
    topLevelElement.style.marginTop = "${topLevelElement.$dom_offsetTop}";
  }

  void destroy() {
    removeDecorator();
    delegate.destroy();
  }

  void saveState(Map<String, Object> state) {
    delegate.saveState(state);
  }
  
  void loadState(Map<String, Object> state) {
    delegate.loadState(state);
  }
  
  void setActiveChild(IDockContainer child) {
  }

  int get minimumAllowedChildNodes() { return delegate.minimumAllowedChildNodes; }
  
  int get width() {
    return delegate.width;
  }
  void set width(int value) {
    delegate.width = value;
  }

  int get height() {
    return delegate.height;
  }
  void set height(int value) {
    delegate.height = value;
  }

  String get name() {
    return delegate.name;
  }
  void set name(String value) {
    delegate.name = value;
  }
  
  void resize(int _width, int _height) {
    delegate.resize(_width, _height);
  }
  
  void performLayout(List<IDockContainer> children) {
    delegate.performLayout(children);
  }
  
  void removeDecorator() {
    dragHandle.on.mouseDown.remove(mouseDownHandler);
  }
  
  Element get containerElement() {
    return delegate.containerElement;
  }
  
  void onMouseDown(MouseEvent event) {
    _startDragging(event);
    previousMousePosition = new Point(event.pageX, event.pageY);
    window.on.mouseMove.add(mouseMoveHandler);
    window.on.mouseUp.add(mouseUpHandler);
  }
  
  void onMouseUp(MouseEvent event) {
    _stopDragging(event);
    window.on.mouseMove.remove(mouseMoveHandler);
    window.on.mouseUp.remove(mouseUpHandler);
  }
  
  void _startDragging(MouseEvent event) {
    if (dialog.eventListener != null) {
      dialog.eventListener.onDialogDragStarted(dialog, event);
    }
    window.document.body.classes.add("disable-selection");
  }
  
  void _stopDragging(MouseEvent event) {
    if (dialog.eventListener != null) {
      dialog.eventListener.onDialogDragEnded(dialog, event);
    }
    window.document.body.classes.remove("disable-selection");
  }

  void onMouseMove(MouseEvent event) {
    Point currentMousePosition = new Point(event.pageX, event.pageY);
    int dx = (currentMousePosition.x - previousMousePosition.x).toInt();
    int dy = (currentMousePosition.y - previousMousePosition.y).toInt();
    _performDrag(dx, dy);
    previousMousePosition = currentMousePosition; 
  }
  
  void _performDrag(int dx, int dy) {
    int left = dx + getPixels(topLevelElement.style.marginLeft);
    int top = dy + getPixels(topLevelElement.style.marginTop);
    topLevelElement.style.marginLeft = "${left}px";
    topLevelElement.style.marginTop = "${top}px";
  }
}
