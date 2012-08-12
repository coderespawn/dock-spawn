
int getPixels(String pixels) {
  if (pixels == null) return 0;
  return Math.parseInt(pixels.replaceAll("px", ""));
}


Point2 getMousePosition(MouseEvent e, Element element) {
  int parentOffsetX = element.$dom_offsetLeft;
  int parentOffsetY = element.$dom_offsetTop;
  int parentWidth = element.$dom_clientWidth;
  int parentHeight = element.$dom_clientHeight;
  int x = e.x - parentOffsetX;
  int y = e.y - parentOffsetY;
  return new Point2(x, y);
}

void disableGlobalTextSelection() {
  window.document.body.classes.add("disable-selection");
}

void enableGlobalTextSelection() {
  window.document.body.classes.remove("disable-selection");
}

bool isPointInsideNode(int px, int py, DockNode node) {
  Element element = node.container.containerElement;
  int x = element.$dom_offsetLeft;
  int y = element.$dom_offsetTop;
  int width = element.$dom_clientWidth;
  int height = element.$dom_clientHeight;
  
  return (px >= x && px <= x + width && py >= y && py <= y + height);
}


class Rectangle {
  num x;
  num y;
  num width;
  num height;
}