part of dock_spawn;

class BoundingBox {
  Size size;
  Point2 location;
  
  BoundingBox() {
    size = new Size(0, 0);
    location = new Point2(0, 0);
  }
  

  BoundingBox.copy(BoundingBox other) {
    size = new Size.copy(other.size);
    location = new Point2.copy(other.location);
  }
  
  
  num get x => location.x;
  set x(num value) => location.x = value;
      
  num get y => location.y;
  set y(num value) => location.y = value;

  num get width => size.width;
  set width(num value) => size.width = value;
      
  num get height => size.height;
  set height(num value) => size.height = value;

  num get left => location.x;
  set left(num value) => location.x = value;
      
  num get top => location.y;
  set top(num value) => location.y = value;
  
  num get right => location.x + size.width;
  set right(num value) => size.width = value - left;
      
  num get bottom => location.y + size.height;
  set bottom(num value) => size.height = value - top;

}
