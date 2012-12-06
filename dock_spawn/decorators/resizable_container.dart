part of dock_spawn;

/**
 * Decorates a dock container with resizer handles around its base element
 * This enables the container to be resized from all directions
 */
class ResizableContainer implements IDockContainer {
  String containerType;
  IDockContainer delegate;
  Element topLevelElement;
  Dialog dialog;
  List<ResizeHandle> resizeHandles;
  
  Point2 dragOffset;
  Point2 previousMousePosition;
  
  ResizableContainer(this.dialog, this.delegate, this.topLevelElement) {
    containerType = delegate.containerType;
    topLevelElement.style.marginLeft = "${topLevelElement.offsetLeft}";
    topLevelElement.style.marginTop = "${topLevelElement.offsetTop}";
    _buildResizeHandles();
  }
  
  void setActiveChild(IDockContainer child) {
  }

  int get minimumAllowedChildNodes { return delegate.minimumAllowedChildNodes; }
  
  void _buildResizeHandles() {
    resizeHandles = new List<ResizeHandle>();
//    _buildResizeHandle(true, false, true, false); // Dont need the corner resizer near the close button
    _buildResizeHandle(false, true, true, false);
    _buildResizeHandle(true, false, false, true);
    _buildResizeHandle(false, true, false, true);

    _buildResizeHandle(true, false, false, false);
    _buildResizeHandle(false, true, false, false);
    _buildResizeHandle(false, false, true, false);
    _buildResizeHandle(false, false, false, true);

}
  
  void _buildResizeHandle(bool east, bool west, bool north, bool south) {
    var handle = new ResizeHandle();
    handle.east = east;
    handle.west = west;
    handle.north = north;
    handle.south = south;
    
    // Create an invisible div for the handle
    handle.element = new DivElement();
    topLevelElement.nodes.add(handle.element);
    
    // Build the class name for the handle
    String verticalClass = "";
    String horizontalClass = "";
    if (north) verticalClass = "n";
    if (south) verticalClass = "s";
    if (east) horizontalClass = "e";
    if (west) horizontalClass = "w";
    String cssClass = "resize-handle-$verticalClass$horizontalClass";
    if (verticalClass.length > 0 && horizontalClass.length > 0) {
      handle.corner = true;
    }

    handle.element.classes.add(handle.corner ? "resize-handle-corner" : "resize-handle");
    handle.element.classes.add(cssClass);
    resizeHandles.add(handle);
    
    // Create the mouse event handlers
    handle.mouseMoveHandler = (MouseEvent e) {
      onMouseMoved(handle, e);
    };
    handle.mouseDownHandler = (MouseEvent e) {
      onMouseDown(handle, e);
    };
    handle.mouseUpHandler = (MouseEvent e) {
      onMouseUp(handle, e);
    };

    handle.element.on.mouseDown.add(handle.mouseDownHandler);
  }

  void saveState(Map<String, Object> state) {
    delegate.saveState(state);
  }
  
  void loadState(Map<String, Object> state) {
    delegate.loadState(state);
  }
  
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
    _adjustResizeHandles(_width, _height);
  }
  
  void _adjustResizeHandles(int _width, int _height) {
    resizeHandles.forEach((handle) {
      handle.adjustSize(topLevelElement, _width, _height);
    });
  }
  
  void performLayout(List<IDockContainer> children) {
    delegate.performLayout(children);
  }
  
  void destroy() {
    removeDecorator();
    delegate.destroy();
  }
  
  void removeDecorator() {
    
  }
    
  Element get containerElement {
    return delegate.containerElement;
  }

  bool readyToProcessNextResize = true;
  void onMouseMoved(ResizeHandle handle, MouseEvent e) {
    if (!readyToProcessNextResize) {
      return;
    }
    readyToProcessNextResize = false;
    
    window.requestLayoutFrame(() {
      Point2 currentMousePosition = new Point2(e.pageX, e.pageY);
      int dx = (currentMousePosition.x - previousMousePosition.x).toInt();
      int dy = (currentMousePosition.y - previousMousePosition.y).toInt();
      _performDrag(handle, dx, dy);
      previousMousePosition = currentMousePosition;
      readyToProcessNextResize = true;
    });
  }
  
  void onMouseDown(ResizeHandle handle, MouseEvent event) {
    previousMousePosition = new Point2(event.pageX, event.pageY);
    window.on.mouseMove.add(handle.mouseMoveHandler);
    window.on.mouseUp.add(handle.mouseUpHandler);

    document.body.classes.add("disable-selection");
  }
  
  void onMouseUp(ResizeHandle handle, MouseEvent event) {
    window.on.mouseMove.remove(handle.mouseMoveHandler);
    window.on.mouseUp.remove(handle.mouseUpHandler);

    document.body.classes.remove("disable-selection");
  }
  
  
  void _performDrag(ResizeHandle handle, int dx, int dy) {
    var bounds = new BoundingBox();
    bounds.left = getPixels(topLevelElement.style.marginLeft);
    bounds.top = getPixels(topLevelElement.style.marginTop);
    bounds.width = topLevelElement.clientWidth;
    bounds.height = topLevelElement.clientHeight;
    
    if (handle.east) _resizeEast(dx, bounds);
    if (handle.west) _resizeWest(dx, bounds);
    if (handle.north) _resizeNorth(dy, bounds);
    if (handle.south) _resizeSouth(dy, bounds);
  }
  
  void _resizeWest(int dx, BoundingBox bounds) {
    _resizeContainer(dx, 0, -dx, 0, bounds);
  }
  
  void _resizeEast(int dx, BoundingBox bounds) {
    _resizeContainer(0, 0, dx, 0, bounds);
  }

  void _resizeNorth(int dy, BoundingBox bounds) {
    _resizeContainer(0, dy, 0, -dy, bounds);
  }

  void _resizeSouth(int dy, BoundingBox bounds) {
    _resizeContainer(0, 0, 0, dy, bounds);
  }
  
  void _resizeContainer(int leftDelta, int topDelta, int widthDelta, int heightDelta, BoundingBox bounds) {
    bounds.left += leftDelta;
    bounds.top += topDelta;
    bounds.width += widthDelta;
    bounds.height += heightDelta;
    
    int minWidth = 50;  // TODO: Move to external configuration
    int minHeight = 50;  // TODO: Move to external configuration
    bounds.width = max(bounds.width, minWidth);
    bounds.height = max(bounds.height, minHeight);
    
    topLevelElement.style.marginLeft = "${bounds.left}px";
    topLevelElement.style.marginTop = "${bounds.top}px";

    resize(bounds.width, bounds.height);
  }
}

class ResizeHandle {
  final int handleSize = 6;   // TODO: Get this from DOM
  final int cornerSize = 12;  // TODO: Get this from DOM
  
  DivElement element;
  var mouseMoveHandler;
  var mouseDownHandler;
  var mouseUpHandler;
  bool east = false;
  bool west = false;
  bool north = false;
  bool south = false;
  bool corner = false;
  
  void adjustSize(Element container, int clientWidth, int clientHeight) {
    if (corner) {
      if (west) element.style.left = "0px";
      if (east) element.style.left = "${clientWidth - cornerSize}px";
      if (north) element.style.top = "0px";
      if (south) element.style.top = "${clientHeight - cornerSize}px";
    }
    else {
      if (west) {
        element.style.left = "0px";
        element.style.top = "${cornerSize}px";
      }
      if (east) {
        element.style.left = "${clientWidth - handleSize}px";
        element.style.top = "${cornerSize}px";
      }
      if (north) {
        element.style.left = "${cornerSize}px";
        element.style.top = "0px";
      }
      if (south) {
        element.style.left = "${cornerSize}px";
        element.style.top = "${clientHeight - handleSize}px";
      }
      
      if (west || east) {
        element.style.height = "${clientHeight - cornerSize * 2}px";
      } else {
        element.style.width = "${clientWidth - cornerSize * 2}px";
      }
    }
  }
}
