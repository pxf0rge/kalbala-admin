import 'package:flutter/material.dart';
import 'package:kalbala_admin/core/theme/app_colors.dart';

/// KalBala mark — shopping cart decorated with a bold **K**.
class KalBalaLogoMark extends StatelessWidget {
  const KalBalaLogoMark({
    this.size = 36,
    this.color,
    this.showAccent = true,
    this.useBrandAsset = false,
    super.key,
  });

  final double size;
  final Color? color;
  final bool showAccent;
  final bool useBrandAsset;

  @override
  Widget build(BuildContext context) {
    if (useBrandAsset) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset(
          'assets/branding/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      );
    }

    final paintColor = color ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : AppColors.primary);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _KalBalaMarkPainter(
          color: paintColor,
          accent: showAccent ? AppColors.accent : paintColor,
        ),
      ),
    );
  }
}

class _KalBalaMarkPainter extends CustomPainter {
  _KalBalaMarkPainter({required this.color, required this.accent});

  final Color color;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sw = w * 0.075;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final accentFill = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;

    final basket = Path()
      ..moveTo(w * 0.18, h * 0.34)
      ..lineTo(w * 0.82, h * 0.34)
      ..lineTo(w * 0.74, h * 0.68)
      ..lineTo(w * 0.26, h * 0.68)
      ..close();
    canvas.drawPath(basket, stroke);

    canvas.drawLine(Offset(w * 0.34, h * 0.34), Offset(w * 0.38, h * 0.68), stroke);
    canvas.drawLine(Offset(w * 0.50, h * 0.34), Offset(w * 0.50, h * 0.68), stroke);
    canvas.drawLine(Offset(w * 0.66, h * 0.34), Offset(w * 0.62, h * 0.68), stroke);
    canvas.drawLine(Offset(w * 0.22, h * 0.50), Offset(w * 0.78, h * 0.50), stroke);

    final handle = Path()
      ..moveTo(w * 0.28, h * 0.34)
      ..quadraticBezierTo(w * 0.28, h * 0.16, w * 0.50, h * 0.16)
      ..quadraticBezierTo(w * 0.72, h * 0.16, w * 0.72, h * 0.34);
    canvas.drawPath(handle, stroke);

    canvas.drawCircle(Offset(w * 0.34, h * 0.80), w * 0.07, fill);
    canvas.drawCircle(Offset(w * 0.66, h * 0.80), w * 0.07, fill);

    final badgeR = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.50),
      width: w * 0.36,
      height: w * 0.36,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeR, Radius.circular(w * 0.08)),
      accentFill,
    );

    final kPainter = TextPainter(
      text: TextSpan(
        text: 'K',
        style: TextStyle(
          color: Colors.white,
          fontSize: w * 0.26,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    kPainter.paint(
      canvas,
      Offset(
        badgeR.center.dx - kPainter.width / 2,
        badgeR.center.dy - kPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _KalBalaMarkPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.accent != accent;
}
