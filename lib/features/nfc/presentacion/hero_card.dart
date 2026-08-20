import 'dart:math';
import 'package:flutter/material.dart';

class HeroCard extends StatefulWidget {
  const HeroCard({super.key});

  @override
  State<HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<HeroCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              height: 260,
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: SweepGradient(
                  transform: GradientRotation(_controller.value * 2 * pi),
                  colors: const [
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xFFF97316),
                    Color(0xFFF97316),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.75, 0.85, 0.92, 1.0],
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage("assets/img/fondo_abstracto.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFFF8C00), width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: Color(0xFFFF8C00), size: 8),
                            SizedBox(width: 8),
                            Text(
                              'BULLY APP - BULLYCHIP',
                              style: TextStyle(
                                color: Color(0xFFFF8C00),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Buscar por ",
                              style: TextStyle(
                                fontSize: 22,
                                fontFamily: "Poppins",
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: " BullyChip",
                              style: TextStyle(
                                fontSize: 22,
                                fontFamily: "Poppins",
                                color: Color(0xFFF97316),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: "  \n", style: TextStyle(fontSize: 24)),
                            TextSpan(
                              text: "Escanea el BullyChip del ejemplar o ingresa el código para consultar su registro.",
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "Poppins",
                                color: Color.fromARGB(127, 255, 255, 255),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Puedes dejar el Painter aquí abajo si solo lo usa esta tarjeta, o llevarlo a su propio archivo si se usa en más lugares
class RotatingBorderPainter extends CustomPainter {
  final double progress;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  RotatingBorderPainter({
    required this.progress,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(borderWidth / 2, borderWidth / 2, size.width - borderWidth, size.height - borderWidth);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final basePaint = Paint()
      ..color = borderColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rrect, basePaint);

    final path = Path()..addRRect(rrect);
    final arcPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final pathMetric = path.computeMetrics().first;
    final totalLength = pathMetric.length;
    const visiblePercentage = 0.35;

    final start = progress * totalLength;
    final end = start + (totalLength * visiblePercentage);

    if (end <= totalLength) {
      canvas.drawPath(pathMetric.extractPath(start, end), arcPaint);
    } else {
      canvas.drawPath(pathMetric.extractPath(start, totalLength), arcPaint);
      canvas.drawPath(pathMetric.extractPath(0, end - totalLength), arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RotatingBorderPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.borderColor != borderColor;
  }
}