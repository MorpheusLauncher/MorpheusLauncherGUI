import 'package:flutter/material.dart';

class CirclePainter extends CustomPainter {
  final Color color;
  final double radius;
  final Color outlineColor;
  final double outlineWidth;
  final double distance;

  CirclePainter({
    required this.color,
    required this.radius,
    this.outlineColor = Colors.transparent,
    this.outlineWidth = 0,
    this.distance = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    size = Size(radius, radius);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Disegna il cerchio interno
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    if (outlineWidth > 0) {
      final outlinePaint = Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = outlineWidth;

      // Calcola il raggio del cerchio esterno tenendo conto della distanza
      double outerRadius = size.width / 2 + distance + outlineWidth / 2;

      // Disegna il cerchio esterno
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        outerRadius,
        outlinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ColoredCircle extends StatelessWidget {
  final double size;
  final Color color;
  final Color outlineColor;
  final double outlineWidth;
  final double distance;

  ColoredCircle({
    required this.size,
    required this.color,
    this.outlineColor = Colors.transparent,
    this.outlineWidth = 0,
    this.distance = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(
        size + 2 * (distance + outlineWidth),
        size + 2 * (distance + outlineWidth),
      ),
      painter: CirclePainter(
        color: color,
        radius: size,
        outlineColor: outlineColor,
        outlineWidth: outlineWidth,
        distance: distance,
      ),
    );
  }
}
