import 'package:flutter/material.dart';

class PreviewStyles {
  // Gradient presets
  static const Map<String, LinearGradient> gradients = {
    'sunset': LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
    ),
    'ocean': LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    ),
    'forest': LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF134E5E), Color(0xFF71B280)],
    ),
    'purple_dream': LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF9D50BB), Color(0xFF6E48AA)],
    ),
    'fire': LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
    ),
    'monochrome': LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2C3E50), Color(0xFF95A5A6)],
    ),
    'lavender': LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFDA22FF), Color(0xFF9733EE)],
    ),
    'mint': LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
    ),
  };

  // Pattern builders with color support
  static Widget buildPattern(String patternId, {double size = 90, Color? color}) {
    final patternColor = color ?? const Color(0xFF9C27B0);
    
    switch (patternId) {
      case 'stripes':
        return _buildStripes(size, patternColor);
      case 'dots':
        return _buildDots(size, patternColor);
      case 'geometric':
        return _buildGeometric(size, patternColor);
      case 'waves':
        return _buildWaves(size, patternColor);
      case 'chevron':
        return _buildChevron(size, patternColor);
      default:
        return Container(
          width: size,
          height: size,
          color: Colors.grey[300],
        );
    }
  }

  static Widget _buildStripes(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: _StripesPainter(color),
      ),
    );
  }

  static Widget _buildDots(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
      ),
      child: CustomPaint(
        painter: _DotsPainter(color),
      ),
    );
  }

  static Widget _buildGeometric(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.05),
      ),
      child: CustomPaint(
        painter: _GeometricPainter(color),
      ),
    );
  }

  static Widget _buildWaves(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.05),
      ),
      child: CustomPaint(
        painter: _WavesPainter(color),
      ),
    );
  }

  static Widget _buildChevron(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.05),
      ),
      child: CustomPaint(
        painter: _ChevronPainter(color),
      ),
    );
  }

  // Get gradient by ID
  static LinearGradient? getGradient(String id) {
    return gradients[id];
  }

  // Get all gradient IDs
  static List<String> get gradientIds => gradients.keys.toList();
}

// Custom painters for patterns
class _StripesPainter extends CustomPainter {
  final Color color;
  _StripesPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const stripeWidth = 12.0;
    for (double x = -size.height; x < size.width + size.height; x += stripeWidth * 2) {
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + size.height, size.height)
        ..lineTo(x + size.height + stripeWidth, size.height)
        ..lineTo(x + stripeWidth, 0)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DotsPainter extends CustomPainter {
  final Color color;
  _DotsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 12.0;
    const radius = 2.5;
    // Ensure dots stay within bounds
    for (double x = spacing / 2; x < size.width - radius; x += spacing) {
      for (double y = spacing / 2; y < size.height - radius; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GeometricPainter extends CustomPainter {
  final Color color;
  _GeometricPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const spacing = 18.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Draw diamond shape
        final path = Path()
          ..moveTo(x + spacing / 2, y)
          ..lineTo(x + spacing, y + spacing / 2)
          ..lineTo(x + spacing / 2, y + spacing)
          ..lineTo(x, y + spacing / 2)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WavesPainter extends CustomPainter {
  final Color color;
  _WavesPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const waveHeight = 8.0;
    const waveWidth = 20.0;
    const spacing = 15.0;

    for (double y = 0; y < size.height + waveHeight; y += spacing) {
      final path = Path()..moveTo(0, y);
      
      for (double x = 0; x < size.width; x += waveWidth) {
        path.quadraticBezierTo(
          x + waveWidth / 4, y - waveHeight,
          x + waveWidth / 2, y,
        );
        path.quadraticBezierTo(
          x + 3 * waveWidth / 4, y + waveHeight,
          x + waveWidth, y,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChevronPainter extends CustomPainter {
  final Color color;
  _ChevronPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const spacing = 15.0;
    const chevronWidth = 12.0;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += chevronWidth * 2) {
        final path = Path()
          ..moveTo(x, y + spacing / 2)
          ..lineTo(x + chevronWidth / 2, y)
          ..lineTo(x + chevronWidth, y + spacing / 2);
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
