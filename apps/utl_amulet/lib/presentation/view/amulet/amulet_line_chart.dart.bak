import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../change_notifier/amulet/amulet_line_chart_change_notifier.dart';
import '../../change_notifier/amulet/amulet_line_chart_filtered_change_notifier.dart';
import '../../change_notifier/amulet/mapper/mapper.dart';

class AmuletLineChart extends StatelessWidget {
  const AmuletLineChart({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final item = context.select<AmuletLineChartFilteredChangeNotifier, AmuletLineChartItem>((l) => l.items.first);
    final series = context.select<AmuletLineChartFilteredChangeNotifier, List<LineSeries>>((l) => l.createLineSeriesList(
      appLocalizations: appLocalizations,
    ));
    final lineChartManager = context.read<AmuletLineChartManagerChangeNotifier>();
    return Column(
      children: [
        Text(lineChartManager.getItemName(
          appLocalizations: appLocalizations,
          item: item,
        )),
        Expanded(
          child: SfCartesianChart(
            series: series,
            onChartTouchInteractionDown: (ChartTouchInteractionArgs tapArgs) {
              lineChartManager.isTouched = true;
            },
            onChartTouchInteractionUp: (ChartTouchInteractionArgs tapArgs) {
              lineChartManager.isTouched = false;
              lineChartManager.x = null;
            },
            onTrackballPositionChanging: (TrackballArgs trackballArgs) {
              int? seriesIndex = trackballArgs.chartPointInfo.seriesIndex;
              if(seriesIndex == null) return;
              int? dataPointIndex = trackballArgs.chartPointInfo.dataPointIndex;
              if(dataPointIndex == null) return;
              double? x = series
                .skip(trackballArgs.chartPointInfo.seriesIndex!)
                .firstOrNull
                ?.dataSource
                ?.skip(trackballArgs.chartPointInfo.dataPointIndex!)
                .firstOrNull
                ?.x
                .toDouble();
              lineChartManager.x = x;
            },
            trackballBehavior: TrackballBehavior(
              enable: true,
              shouldAlwaysShow: true,
              activationMode: ActivationMode.singleTap,
              tooltipAlignment: ChartAlignment.near,
              tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
              // tooltipSettings: InteractiveTooltip(
              //   enable: true,
              // ),
              lineType: TrackballLineType.vertical,
            ),
            zoomPanBehavior: ZoomPanBehavior(
              enablePinching: true,
              // enableDoubleTapZooming: true,
              enablePanning: true,
              // zoomMode: ZoomMode.x,
              enableMouseWheelZooming: true,
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
