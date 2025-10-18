part of '../all_seat_cushion_view.dart';

@immutable
@TailorMixin()
class SeatCushionIschiumPointWidgetTheme
    extends ThemeExtension<SeatCushionIschiumPointWidgetTheme>
    with _$SeatCushionIschiumPointWidgetThemeTailorMixin {
  @override
  final Color borderColor;
  @override
  final Color ischiumColor;

  const SeatCushionIschiumPointWidgetTheme({
    required this.borderColor,
    required this.ischiumColor,
  });
}

class _IschiumPoint extends CustomPainter {
  final double x;
  final double y;
  final double? radiusMm;  // 半徑（毫米單位）
  final BuildContext context;
  _IschiumPoint(this.context, this.x, this.y, this.radiusMm);
  @override
  void paint(Canvas canvas, Size size) {
    // 防止 NaN 或 Infinity 值導致渲染錯誤
    if (!x.isFinite || !y.isFinite) {
      return;
    }

    final themeData = Theme.of(context);
    final themeExtension = themeData
        .extension<SeatCushionIschiumPointWidgetTheme>()!;
    final center = Offset(x, y);

    // 計算圓環的半徑
    final double radius;
    if (radiusMm != null && radiusMm! > 0) {
      // 使用動態半徑（從毫米轉換為像素）
      radius = size.width * (radiusMm! / SeatCushion.deviceWidth);
    } else {
      // 使用默認半徑
      radius = size.width *
          ((SeatCushionUnit.sensorWidth * 0.4) / SeatCushion.deviceWidth);
    }

    // 繪製空心圓環（外圈）
    final outerRingPaint = Paint()
      ..color = themeExtension.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 繪製空心圓環（內圈，粉紅色）
    final innerRingPaint = Paint()
      ..color = themeExtension.ischiumColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 繪製兩層圓環
    canvas.drawCircle(center, radius + 1.5, outerRingPaint);
    canvas.drawCircle(center, radius, innerRingPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// **Themes:**
/// - [SeatCushionIschiumPointWidgetTheme]
class SeatCushionIschiumPointWidget<T extends SeatCushion>
    extends StatelessWidget {
  const SeatCushionIschiumPointWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final seatCushion = context.watch<T?>();
        final ischiumPosition = seatCushion?.ischiumPosition();
        final ischiumRadius = seatCushion?.ischiumRadius();

        final width = constraints.maxWidth;
        final height = width / SeatCushion.deviceAspectRatio;
        return SizedBox(
          width: width,
          height: height,
          child: (ischiumPosition != null)
              ? CustomPaint(
                  painter: _IschiumPoint(
                    context,
                    ((ischiumPosition.x / SeatCushion.deviceWidth) + 0.5) *
                        width,
                    ((ischiumPosition.y / SeatCushion.deviceHeight) + 0.5) *
                        height,
                    ischiumRadius,
                  ),
                  child: Container(),
                )
              : null,
        );
      },
    );
  }
}
