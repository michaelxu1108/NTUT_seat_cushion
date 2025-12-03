import 'dart:math';

import 'package:bluetooth_presentation/bluetooth_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:utl_amulet/l10n/gen_l10n/app_localizations.dart';
import 'package:utl_amulet/presentation/view/amulet/amulet_control_panel.dart';
import 'package:utl_amulet/presentation/view/amulet/amulet_dashboard.dart';
import 'package:utl_amulet/presentation/view/amulet/amulet_line_chart_list.dart';
import 'package:utl_amulet/presentation/view/bluetooth/bluetooth_scanner_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Stream<fbp.BluetoothAdapterState>? _adapterStateStream;

  @override
  void initState() {
    super.initState();
    // 延遲訂閱，確保 FlutterBluePlus 已完全初始化
    Future.microtask(() {
      if (mounted) {
        setState(() {
          _adapterStateStream = fbp.FlutterBluePlus.adapterState;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (_adapterStateStream == null) {
      // 在 stream 準備好之前顯示載入畫面
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return StreamBuilder<fbp.BluetoothAdapterState>(
      stream: _adapterStateStream,
      initialData: fbp.BluetoothAdapterState.unknown,
      builder: (context, snapshot) {
        final state = snapshot.data;

        if (state != fbp.BluetoothAdapterState.on) {
          // Bluetooth is off or unavailable, show status view
          return const BluetoothStatusView();
        }

        // Bluetooth is on, show the main interface
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final mediaQueryData = MediaQuery.of(context);
            final controllerWidth = min(constraints.maxWidth / 3, (constraints.maxWidth - mediaQueryData.viewInsets.horizontal));
            final appLocalizations = AppLocalizations.of(context)!;
            const bluetoothScannerView = BluetoothScannerView();
            const amuletDashboard = AmuletDashboard();
            const amuletControlPanel = AmuletControlPanel();
            const amuletLineChartList = AmuletLineChartList();

            // 定義 Tab 標題和對應的頁面
            final tabItems = [
              {'icon': Icons.bluetooth_searching_rounded, 'label': appLocalizations.tabBluetoothScanner, 'view': bluetoothScannerView},
              {'icon': Icons.list_alt, 'label': appLocalizations.tabDataList, 'view': amuletDashboard},
              {'icon': Icons.settings_input_antenna, 'label': appLocalizations.tabControlPanel, 'view': amuletControlPanel},
            ];

            final tabBar = TabBar(
              isScrollable: false,
              labelStyle: const TextStyle(fontSize: 9, height: 1.0),
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              indicatorPadding: EdgeInsets.zero,
              tabs: tabItems.map((item) {
                return Tab(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'] as IconData, size: 18),
                      const SizedBox(height: 2),
                      Text(
                        item['label'] as String,
                        style: const TextStyle(fontSize: 9),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
            final tabView = TabBarView(
              children: tabItems.map((item) => item['view'] as Widget).toList(),
            );
            final tabController = DefaultTabController(
              length: tabItems.length,
              child: Scaffold(
                appBar: tabBar,
                body: tabView,
              ),
            );
            return Scaffold(
              body: SafeArea(
                child: Row(children: <Widget>[
                  const Expanded(
                    child: amuletLineChartList,
                  ),
                  const VerticalDivider(),
                  SizedBox(
                    width: controllerWidth,
                    child: tabController,
                  )
                ]),
              ),
            );
          },
        );
      },
    );
  }
}