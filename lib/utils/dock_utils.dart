part of dock_spawn;

int getPixels(String pixels) {
  if (pixels == null) return 0;
  return int.parse(pixels.replaceAll("px", ""));
}


Point2 getMousePosition(MouseEvent e, Element element) {
  int parentOffsetX = element.offsetLeft;
  int parentOffsetY = element.offsetTop;
  int parentWidth = element.clientWidth;
  int parentHeight = element.clientHeight;
  int x = e.offsetX - parentOffsetX;
  int y = e.offsetX - parentOffsetY;
  return new Point2(x, y);
}

void disableGlobalTextSelection() {
  document.body.classes.add("disable-selection");
}

void enableGlobalTextSelection() {
  document.body.classes.remove("disable-selection");
}

bool isPointInsideNode(int px, int py, DockNode node) {
  Element element = node.container.containerElement;
  int x = element.offsetLeft;
  int y = element.offsetTop;
  int width = element.clientWidth;
  int height = element.clientHeight;
  
  return (px >= x && px <= x + width && py >= y && py <= y + height);
}


class Rectangle {
  num x;
  num y;
  num width;
  num height;
}