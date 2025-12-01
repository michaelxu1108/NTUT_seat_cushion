import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../service/data_stream/amulet_sensor_data_stream.dart';
import '../../change_notifier/amulet/amulet_line_chart_change_notifier.dart';
import '../../change_notifier/amulet/mapper/mapper.dart';

class _Item extends StatelessWidget {
  final String label;
  final String data;
  const _Item({
    super.key,
    required this.label,
    required this.data,
  });
  @override
  Widget build(BuildContext context) {
    return Text(
      "$label: $data",
    );
  }
}

class AmuletDashboard extends StatelessWidget {
  const AmuletDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    final sensorData = context.select<AmuletLineChartManagerChangeNotifier, AmuletSensorData?>((m) {
      return (m.isTouched)
        ? m.getSensorDataByX()
        : m.getLastSensorData();
    });
    final x = context.select<AmuletLineChartManagerChangeNotifier, double?>((m) => m.getSensorX());
    final lineChartManager = context.read<AmuletLineChartManagerChangeNotifier>();
    final appLocalizations = AppLocalizations.of(context)!;
    final xLabel = lineChartManager.getXName(appLocalizations: appLocalizations);
    final xData = x?.toStringAsFixed(2) ?? "";
    return Column(
      children: [
        _Item(
          label: xLabel,
          data: xData,
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: AmuletLineChartItem.values.length,
            itemBuilder: (context, index) {
              final appLocalizations = AppLocalizations.of(context)!;
              final item = AmuletLineChartItem.values[index];
              final yLabel = lineChartManager.getItemName(appLocalizations: appLocalizations, item: item);
              final yData = (sensorData != null)
                ? lineChartManager.getData(data: sensorData, item: item).toStringAsFixed(2)
                : "";
              return _Item(
                label: yLabel,
                data: yData,
              );
            },
          ),
        ),
      ],
    );
  }
}
