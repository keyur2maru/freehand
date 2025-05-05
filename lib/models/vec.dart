import 'dart:math';

class Vec {
  double x;
  double y;
  double z;

  Vec(this.x, this.y, [this.z = 0]);

  Vec clone() => Vec(x, y, z);

  bool equals(Vec other) => x == other.x && y == other.y;

  Vec add(Vec other) => Vec(x + other.x, y + other.y, z);
  Vec sub(Vec other) => Vec(x - other.x, y - other.y);
  Vec mul(double scalar) => Vec(x * scalar, y * scalar);
  Vec neg() => Vec(-x, -y);
  Vec per() => Vec(y, -x);

  Vec uni() {
    final len = length;
    return len == 0 ? clone() : Vec(x / len, y / len);
  }

  Vec lrp(Vec other, double t) =>
      Vec(x + (other.x - x) * t, y + (other.y - y) * t, z + (other.z - z) * t);

  double dpr(Vec other) => x * other.x + y * other.y;
  double cpr(Vec other) => x * other.y - y * other.x;

  static Vec addVec(Vec a, Vec b) => Vec(a.x + b.x, a.y + b.y);
  static Vec addXY(Vec a, double x, double y) => Vec(a.x + x, a.y + y);
  static Vec subVec(Vec a, Vec b) => Vec(a.x - b.x, a.y - b.y);
  static Vec mulVec(Vec v, double scalar) => Vec(v.x * scalar, v.y * scalar);
  static Vec lerpVec(Vec a, Vec b, double t) =>
      Vec(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t);
  static double dotProduct(Vec a, Vec b) => a.x * b.x + a.y * b.y;
  static double crossProduct(Vec a, Vec b) => a.x * b.y - a.y * b.x;

  Vec rotWith(Vec center, double angle) {
    final s = sin(angle);
    final c = cos(angle);
    final px = x - center.x;
    final py = y - center.y;
    final nx = px * c - py * s;
    final ny = px * s + py * c;
    return Vec(nx + center.x, ny + center.y);
  }

  static Vec rotWithVec(Vec point, Vec center, double angle) {
    final s = sin(angle);
    final c = cos(angle);
    final px = point.x - center.x;
    final py = point.y - center.y;
    final nx = px * c - py * s;
    final ny = px * s + py * c;
    return Vec(nx + center.x, ny + center.y);
  }

  double get length => sqrt(x * x + y * y);
  double get dist2 => x * x + y * y;

  static double dist(Vec a, Vec b) =>
      sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));

  static double dist2Between(Vec a, Vec b) =>
      (pow(a.x - b.x, 2) + pow(a.y - b.y, 2)).toDouble();

  static Vec from(dynamic point) {
    if (point is Vec) return point;
    if (point is List) {
      return Vec(
        point[0].toDouble(),
        point[1].toDouble(),
        point.length > 2 ? point[2].toDouble() : 0,
      );
    }
    if (point is Map) {
      return Vec(
        point["x"].toDouble(),
        point["y"].toDouble(),
        point.containsKey("z") ? point["z"].toDouble() : 0,
      );
    }
    throw ArgumentError("Cannot convert to Vec: $point");
  }
}
