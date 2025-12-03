import 'package:flutter/material.dart';
import 'package:utl_amulet/l10n/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:utl_amulet/domain/repository/amulet_repository.dart';

import 'package:utl_amulet/presentation/theme/theme_data.dart';

import '../../../init/resource/infrastructure/bluetooth_resource.dart';
import '../../../service/file/file_handler.dart';
import '../../change_notifier/amulet/amulet_features_change_notifier.dart';
import '../../change_notifier/amulet/amulet_line_chart_change_notifier.dart';

class _ToggleDownloadingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
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
          appLocalizations: appLocalizations,
        );
        await repository.clear();
        await Fluttertoast.showToast(
          msg: appLocalizations.downloadFileFinishedNotification('CSV'),
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

class _BluetoothCommandInput extends StatefulWidget {
  const _BluetoothCommandInput();

  @override
  State<_BluetoothCommandInput> createState() => _BluetoothCommandInputState();
}

class _BluetoothCommandInputState extends State<_BluetoothCommandInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendCommand() async {
    final command = _controller.text.trim();
    if (command.isEmpty) {
      await Fluttertoast.showToast(msg: '請輸入指令');
      return;
    }

    setState(() => _isSending = true);

    try {
      final success = await BluetoothResource.bluetoothModule.sendCommand(command: command);
      if (success) {
        await Fluttertoast.showToast(msg: '指令已發送: 0x$command');
        _controller.clear();
      } else {
        await Fluttertoast.showToast(msg: '發送失敗');
      }
    } catch (e) {
      await Fluttertoast.showToast(msg: '錯誤: $e');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '藍牙指令',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 300,
            child: Row(
              children: [
                const Text('0x', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_isSending,
                    decoration: const InputDecoration(
                      hintText: '61/62/63/70D612D90003C5...',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: _isSending ? null : _sendCommand,
                  icon: _isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '指令範例:\n0x60:BLE模式 0x64:校正 0x65:磁力計\n0x66:低頭模式 0x67:呼吸模式\n0x70:綁定手環 0x71:取消綁定',
            style: TextStyle(fontSize: 8, color: Colors.grey),
          ),
        ],
      ),
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
        const Divider(),
        const _BluetoothCommandInput(),
      ],
    );
  }
}
