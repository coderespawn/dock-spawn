part of dock_spawn;

int getPixels(String pixels) {
  if (pixels == null) return 0;
  return int.parse(pixels.replaceAll("px", ""));
}


Point2 getMousePosition(MouseEvent e, Element element) {
  int parentOffsetX = element.offset.left;
  int parentOffsetY = element.offset.top;
  int parentWidth = element.client.width;
  int parentHeight = element.client.height;
  int x = e.offset.x - parentOffsetX;
  int y = e.offset.x - parentOffsetY;
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
  int x = element.offset.left;
  int y = element.offset.top;
  int width = element.client.width;
  int height = element.client.height;
  
  return (px >= x && px <= x + width && py >= y && py <= y + height);
}


class Rectangle {
  num x;
  num y;
  num width;
  num height;
}