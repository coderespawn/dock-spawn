part of dock_spawn;

class Color {
  num r = 0;
  num g = 0; 
  num b = 0;
  num a = 1;
  
  int get r255 => (r * 255).toInt();
  int get g255 => (g * 255).toInt();
  int get b255 => (b * 255).toInt();
  
  Color();
  Color.fromRGBA(this.r, this.g, this.b, this.a);
  
  String toString() => "$r, $g, $b";
  String toString255() => "$r255, $g255, $b255";
  void parse(String data) {
    var tokens = data.split(",");
    if (tokens.length >= 3) {
      r = double.parse(tokens[0]);
      g = double.parse(tokens[1]);
      b = double.parse(tokens[2]);
    }
  }
  void parse255(String data) {
    var tokens = data.split(",");
    if (tokens.length < 3) {
      throw new Exception("Invalid color input format $data");
    }
    r = double.parse(tokens[0]) / 255;
    g = double.parse(tokens[1]) / 255;
    b = double.parse(tokens[2]) / 255;
  }
  
  String toRgba() => "rgba($r255, $g255, $b255, $a)";
}

class Point2 {
  num x;
  num y;
  
  Point2(this.x, this.y);
  Point2.copy(Point2 other) : x = other.x, y = other.y;
  Point2.empty() : x = 0, y = 0;  
  
  Point2 operator-(Point2 other) {
    return new Point2(x - other.x, y - other.y);
  }

  Point2 operator+(Point2 other) {
    return new Point2(x + other.x, y + other.y);
  }
  
  Point2 operator*(num value) {
    return new Point2(x * value, y * value);
  }
  
  bool operator==(Point2 other) {
    return x == other.x && y == other.y;
  }
  
  bool inside(Point2 startLocation, Size size) {
    final sx = startLocation.x;
    final sy = startLocation.y;
    final width = size.width;
    final height = size.height;
    return x >= sx && y >= sy &&
        x <= sx + width && y <= sy + height;
  }
  
  String toString() => "[$x, $y]";
}

class Size {
  num width = 0;
  num height = 0;
  Size.empty();
  Size.copy(Size other) {
    this.width = other.width;
    this.height = other.height;
  }
  Size(this.width, this.height);

  Size operator-(Size other) {
    return new Size(width - other.width, height - other.height);
  }

  Size operator+(Size other) {
    return new Size(width + other.width, height + other.height);
  }
  
  Size operator*(num value) {
    return new Size(width * value, height * value);
  }
}
