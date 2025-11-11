import 'package:flutter/material.dart';

class CustomPagePainter extends CustomPainter {
  final Color backgroundColor;
  final Color decorationColor;

  CustomPagePainter({
    required this.backgroundColor,
    required this.decorationColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // VẼ BACKGROUND
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // VẼ DECORATION Ở GÓC
    final decorPaint = Paint()
      ..color = decorationColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Góc trên trái
    final path1 = Path()
      ..moveTo(0, 0)
      ..lineTo(80, 0)
      ..lineTo(0, 80)
      ..close();
    canvas.drawPath(path1, decorPaint);

    // Góc dưới phải
    final path2 = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width - 80, size.height)
      ..lineTo(size.width, size.height - 80)
      ..close();
    canvas.drawPath(path2, decorPaint);

    // VẼ ĐƯỜNG VIỀN TRANG SÁ CH
    final borderPaint = Paint()
      ..color = decorationColor.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(
      Rect.fromLTWH(20, 20, size.width - 40, size.height - 40),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPagePainter oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor ||
        decorationColor != oldDelegate.decorationColor;
  }
}