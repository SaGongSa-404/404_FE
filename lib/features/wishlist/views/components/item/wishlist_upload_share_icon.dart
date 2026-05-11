import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:path_parsing/path_parsing.dart';

const String _kUploadSvgPathD =
    'M11 16V7.85L8.4 10.45L7 9L12 4L17 9L15.6 10.45L13 7.85V16H11ZM6 20C5.45 20 4.97917 19.8042 4.5875 19.4125C4.19583 19.0208 4 18.55 4 18V15H6V18H18V15H20V18C20 18.55 19.8042 19.0208 19.4125 19.4125C19.0208 19.8042 18.55 20 18 20H6Z';

class _PathSink implements PathProxy {
  _PathSink(this.path);
  final Path path;

  @override
  void close() => path.close();

  @override
  void cubicTo(double x1, double y1, double x2, double y2, double x3, double y3) =>
      path.cubicTo(x1, y1, x2, y2, x3, y3);

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);
}

class WishlistUploadShareIcon extends StatelessWidget {
  const WishlistUploadShareIcon({super.key, this.size = 22});

  final double size;

  static final Path _path24 = _buildPath24();

  static Path _buildPath24() {
    final path = Path();
    writeSvgPathDataToPath(_kUploadSvgPathD, _PathSink(path));
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _WishlistUploadPainter(_path24),
    );
  }
}

class _WishlistUploadPainter extends CustomPainter {
  _WishlistUploadPainter(this.path);

  final Path path;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas.save();
    canvas.scale(scale);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.brown
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WishlistUploadPainter oldDelegate) => oldDelegate.path != path;
}
