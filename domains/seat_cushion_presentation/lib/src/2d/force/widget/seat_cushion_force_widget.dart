part of '../../all_seat_cushion_view.dart';

@immutable
@TailorMixin()
class SeatCushionForceWidgetTheme
    extends ThemeExtension<SeatCushionForceWidgetTheme>
    with _$SeatCushionForceWidgetThemeTailorMixin {
  @override
  final Color borderColor;
  @override
  final ForceToColorConverter forceToColor;

  const SeatCushionForceWidgetTheme({
    required this.borderColor,
    required this.forceToColor,
  });
}

/// **Themes:**
/// - [SeatCushionForceWidgetTheme]
class SeatCushionForceWidget extends StatelessWidget {
  final double force;

  final double height;

  final double width;

  const SeatCushionForceWidget({
    super.key,
    required this.force,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final themeExtension = themeData.extension<SeatCushionForceWidgetTheme>()!;

    final borderWidth = min(width, height) * 1.0 / 15.0;
    final borderRadius = borderWidth;

    // Convert force from grams to mmHg (1kg = 760mmHg)
    final forceInMmHg = (force / 1000.0) * 760;

    return Container(
      decoration: BoxDecoration(
        color: themeExtension.forceToColor(force),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: themeExtension.borderColor,
          width: borderWidth,
        ),
      ),
      height: height,
      width: width,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: EdgeInsets.all(borderWidth * 0.5),
            child: Text(
              forceInMmHg.toStringAsFixed(0),
              style: TextStyle(
                color: _getContrastColor(themeExtension.forceToColor(force)),
                fontSize: min(width, height) * 0.25,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to determine text color based on background brightness
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
