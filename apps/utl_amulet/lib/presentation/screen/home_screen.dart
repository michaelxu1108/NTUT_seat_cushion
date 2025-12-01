import 'dart:math';

import 'package:bluetooth_presentation/bluetooth_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:utl_amulet/presentation/view/amulet/amulet_buttons_board.dart';
import 'package:utl_amulet/presentation/view/amulet/amulet_dashboard.dart';
import 'package:utl_amulet/presentation/view/amulet/amulet_line_chart_list.dart';
import 'package:utl_amulet/presentation/view/bluetooth/bluetooth_scanner_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return StreamBuilder<fbp.BluetoothAdapterState>(
      stream: fbp.FlutterBluePlus.adapterState,
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
            const bluetoothScannerView = BluetoothScannerView();
            const amuletDashboard = AmuletDashboard();
            const amuletButtonsBoard = AmuletButtonsBoard();
            const amuletLineChartList = AmuletLineChartList();
            final tabViewMap = {
              const Icon(Icons.bluetooth_searching_rounded): bluetoothScannerView,
              const Icon(Icons.list_alt): amuletDashboard,
            };
            final tabBar = TabBar(
              isScrollable: false,
              tabs: tabViewMap.keys.map((icon) {
                return Tab(
                  icon: icon,
                );
              }).toList(),
            );
            final tabView = TabBarView(
              children: tabViewMap.values.toList(),
            );
            final tabController = DefaultTabController(
              length: tabViewMap.length,
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
                  amuletButtonsBoard,
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