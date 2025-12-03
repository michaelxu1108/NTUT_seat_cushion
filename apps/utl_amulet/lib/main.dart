import 'package:bluetooth_presentation/bluetooth_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:utl_amulet/l10n/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:utl_amulet/init/initializer.dart';
import 'package:utl_amulet/presentation/change_notifier/amulet/amulet_features_change_notifier.dart';
import 'package:utl_amulet/presentation/change_notifier/amulet/amulet_line_chart_change_notifier.dart';
import 'package:utl_amulet/presentation/screen/home_screen.dart';
import 'package:utl_amulet/presentation/theme/theme_data.dart';

import 'init/application_persist.dart';
import 'init/resource/data/data_resource.dart';
import 'init/resource/infrastructure/bluetooth_resource.dart';
import 'init/resource/service/service_resource.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 執行初始化並等待完成
  final initializer = Initializer();
  await initializer();

  // 初始化完成後再啟動應用程式
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
        Locale('zh', 'TW'),
      ],
      theme: ThemeData.light(
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      color: themeData.screenBackgroundColor,
      home: MultiProvider(
        providers: [
          Provider(create: (_) => BluetoothResource.bluetoothModule),
          Provider(create: (_) => DataResource.amuletRepository),
          Provider(create: (_) => ServiceResource.fileHandler),
          Provider(create: (_) => ServiceResource.amuletSensorDataStream),
          Provider(create: (_) => ApplicationPersist.amuletEntityCreator),
          ChangeNotifierProvider(
            create: (_) => AmuletFeaturesChangeNotifier(
              amuletEntityCreator: ApplicationPersist.amuletEntityCreator,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => AmuletLineChartManagerChangeNotifier(
              x: null,
              amuletSensorDataStream: ServiceResource.amuletSensorDataStream,
            ),
          ),
          Provider(
            create: (_) => BluetoothStatusController(
              onPressedButton: () async {
                try {
                  if (await fbp.FlutterBluePlus.isSupported == false) {
                    debugPrint("Bluetooth not supported by this device");
                    return;
                }
                  await fbp.FlutterBluePlus.turnOn();
                } catch (e) {
                  debugPrint("Error turning on Bluetooth: $e");
                }
              },
            ),
          ),
        ],
        child: const HomeScreen(),
      ),
    );
  }
}
