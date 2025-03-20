// First, at the top of vision_input.dart, ensure you have:
import 'dart:ui' as ui;

// Then, modify your Rect class to avoid conflict:
/// Represents a rectangle in 2D space.
class Rect {
  /// The left coordinate.
  final double left;

  /// The top coordinate.
  final double top;

  /// The right coordinate.
  final double right;

  /// The bottom coordinate.
  final double bottom;

  /// Creates a [Rect] with the given coordinates.
  const Rect(this.left, this.top, this.right, this.bottom);

  /// Creates a [Rect] from a map.
  factory Rect.fromJson(Map<String, dynamic> json) {
    return Rect(
      json['left']?.toDouble() ?? 0.0,
      json['top']?.toDouble() ?? 0.0,
      json['right']?.toDouble() ?? 0.0,
      json['bottom']?.toDouble() ?? 0.0,
    );
  }

  /// Creates a [Rect] from a Flutter [ui.Rect].
  factory Rect.fromLTRB(double left, double top, double right, double bottom) {
    return Rect(left, top, right, bottom);
  }

  /// Creates a [Rect] from a Flutter [ui.Rect].
  factory Rect.fromLTWH(double left, double top, double width, double height) {
    return Rect(left, top, left + width, top + height);
  }

  /// Converts rectangle to a map.
  Map<String, dynamic> toJson() => {
        'left': left,
        'top': top,
        'right': right,
        'bottom': bottom,
      };

  /// The width of the rectangle.
  double get width => right - left;

  /// The height of the rectangle.
  double get height => bottom - top;

  /// Converts to a Flutter [ui.Rect].
  ui.Rect get boundingBox => ui.Rect.fromLTRB(left, top, right, bottom);
}