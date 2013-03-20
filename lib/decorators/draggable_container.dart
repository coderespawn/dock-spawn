part of dock_spawn;

class DraggableContainer implements IDockContainer {
  String containerType;
  IDockContainer delegate;
  Element topLevelElement;
  Element dragHandle;
  Dialog dialog;
  DialogEventListener eventListener;

  DockManager get dockManager => delegate.dockManager;
  
  StreamSubscription<MouseEvent> mouseDownHandler;
  StreamSubscription<MouseEvent> mouseUpHandler;
  StreamSubscription<MouseEvent> mouseMoveHandler;
  
  Point2 dragOffset;
  Point2 previousMousePosition;
  
  DraggableContainer(this.dialog, this.delegate, this.topLevelElement, this.dragHandle) {
    containerType = delegate.containerType;
        
    mouseDownHandler = dragHandle.onMouseDown.listen(onMouseDown);
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

  int get minimumAllowedChildNodes { return delegate.minimumAllowedChildNodes; }
  
  int get width {
    return delegate.width;
  }

  int get height {
    return delegate.height;
  }

  String get name {
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
    mouseDownHandler.cancel();
  }
  
  Element get containerElement {
    return delegate.containerElement;
  }
  
  void onMouseDown(MouseEvent event) {
    _startDragging(event);
    previousMousePosition = new Point2(event.$dom_pageX, event.$dom_pageY);
    if (mouseMoveHandler != null) {
      mouseMoveHandler.cancel();
      mouseMoveHandler = null;
    }
    if (mouseUpHandler != null) {
      mouseUpHandler.cancel();
      mouseUpHandler = null;
    }
    
    mouseMoveHandler = window.onMouseMove.listen(onMouseMove);
    mouseUpHandler = window.onMouseUp.listen(onMouseUp);
  }
  
  void onMouseUp(MouseEvent event) {
    _stopDragging(event);
    mouseMoveHandler.cancel();
    mouseMoveHandler = null;
    mouseUpHandler.cancel();
    mouseUpHandler = null;
  }
  
  void _startDragging(MouseEvent event) {
    if (dialog.eventListener != null) {
      dialog.eventListener.onDialogDragStarted(dialog, event);
    }
    
    document.body.classes.add("disable-selection");
  }
  
  void _stopDragging(MouseEvent event) {
    if (dialog.eventListener != null) {
      dialog.eventListener.onDialogDragEnded(dialog, event);
    }
    document.body.classes.remove("disable-selection");
  }

  void onMouseMove(MouseEvent event) {
    Point2 currentMousePosition = new Point2(event.$dom_pageX, event.$dom_pageY);
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
