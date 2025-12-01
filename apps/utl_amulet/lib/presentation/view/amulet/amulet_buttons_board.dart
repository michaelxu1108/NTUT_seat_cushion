import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:utl_amulet/domain/repository/amulet_repository.dart';

import 'package:utl_amulet/presentation/theme/theme_data.dart';

import '../../../service/file/file_handler.dart';
import '../../change_notifier/amulet/amulet_features_change_notifier.dart';
import '../../change_notifier/amulet/amulet_line_chart_change_notifier.dart';

class _ToggleDownloadingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isSaving = context.select<AmuletFeaturesChangeNotifier, bool>((f) => f.isSaving);
    final features = context.read<AmuletFeaturesChangeNotifier>();
    final fileHandler = context.read<FileHandler>();
    final repository = context.read<AmuletRepository>();
    final lineChartManager = context.read<AmuletLineChartManagerChangeNotifier>();
    VoidCallback? onPressed = (isSaving)
      ? () async {
        features.toggleIsSaving();
        lineChartManager.clear();
        await fileHandler.downloadAmuletEntitiesFile(
          
          fetchEntitiesStream: repository.fetchEntities(),
        );
        await repository.clear();
        await Fluttertoast.showToast(
          msg: "Download CSV file finished",
        );
      }
      : features.toggleIsSaving;
    final themeData = Theme.of(context);
    final color = (isSaving)
        ? themeData.clearEnabledColor
        : themeData.savingEnabledColor;
    final iconData = (isSaving)
        ? Icons.stop
        : Icons.play_arrow;
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        iconData,
      ),
      color: color,
    );
  }
}

class AmuletButtonsBoard extends StatelessWidget {
  const AmuletButtonsBoard({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ToggleDownloadingButton(),
      ],
    );
  }
}
