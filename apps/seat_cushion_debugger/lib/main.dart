import 'package:bluetooth_presentation/bluetooth_presentation.dart';
import 'package:bluetooth_utils/bluetooth_utils.dart';
import 'package:data_utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:seat_cushion/infrastructure/repository/in_memory.dart';
import 'package:seat_cushion/infrastructure/sensor/auto_mock_sensor.dart';
import 'package:seat_cushion/infrastructure/sensor/bluetooth_sensor.dart';
import 'package:seat_cushion/infrastructure/sensor_decoder/wei_zhe_decoder.dart';
import 'package:seat_cushion/seat_cushion.dart';
import 'package:seat_cushion_presentation/seat_cushion_presentation.dart';

import 'init/initializer.dart';
import 'l10n/gen_l10n/app_localizations.dart';
import 'presentation/screen/home_page/home_page.dart' as home;
import 'presentation/view/bluetooth_devices_scanner/bluetooth_devices_scanner.dart';
import 'presentation/widget/bluetooth_command_line/bluetooth_command_line.dart';
import 'presentation/widget/seat_cushion_features_line/seat_cushion_features_line.dart';
import 'presentation/widget/seat_cushion_force_color_bar/seat_cushion_force_color_bar.dart';
import 'utils/seat_cushion_file.dart';

late final Initializer initializer;

/// ============================================
/// iOS 模擬器藍牙模擬配置
/// MOCK MODE CONFIGURATION FOR iOS SIMULATOR
/// ============================================
///
/// iOS 模擬器不支援真實藍牙功能，因此需要使用模擬模式
/// iOS Simulator does not support real Bluetooth, so mock mode is required
///
/// 設定說明 / Configuration:
/// - true:  使用模擬資料（適用於 iOS 模擬器，無需藍牙裝置）
///          Use mock data (for iOS Simulator, no Bluetooth device needed)
/// - false: 使用真實藍牙裝置（僅適用於實體裝置）
///          Use real Bluetooth device (only for physical devices)
///
/// 建議 / Recommendation:
/// - iOS 模擬器開發時設為 true
///   Set to true when developing on iOS Simulator
/// - 使用實體 iPhone/iPad 測試時設為 false
///   Set to false when testing on physical iPhone/iPad
///
const bool useMockData = false;

/// ============================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================
  // 傳感器初始化
  // Sensor Initialization
  // ============================================

  // 根據模擬模式設置創建相應的傳感器
  // Create appropriate sensor based on mock mode configuration
  final SeatCushionSensor sensor;

  // 藍牙支援狀態旗標
  // Bluetooth support status flag
  bool fbpIsSupported = true;

  if (useMockData) {
    // ----------------------------------------
    // 模擬模式（適用於 iOS 模擬器）
    // Mock Mode (for iOS Simulator)
    // ----------------------------------------

    // 使用自動生成的模擬傳感器（無需實體藍牙裝置）
    // Use auto-generated mock sensor (no physical Bluetooth device needed)
    sensor = AutoMockSeatCushionSensor();

    // 在模擬模式下，設定藍牙為「不支援」狀態，完全略過藍牙檢查
    // In mock mode, set Bluetooth as "not supported" to completely bypass Bluetooth checks
    // 這樣可以避免在 iOS 模擬器上出現藍牙錯誤訊息
    // This prevents Bluetooth error messages on iOS Simulator
    fbpIsSupported = true;

    // 輸出除錯訊息到控制台
    // Output debug message to console
    debugPrint('🔧 執行模擬模式 - 使用模擬坐墊資料（適用於 iOS 模擬器）');
    debugPrint(
      '🔧 Running in MOCK MODE - Using simulated seat cushion data (for iOS Simulator)',
    );
  } else {
    // ----------------------------------------
    // 真實藍牙模式（僅適用於實體裝置）
    // Real Bluetooth Mode (for physical devices only)
    // ----------------------------------------

    // 檢查藍牙是否被裝置支援
    // Check if Bluetooth is supported by the device
    try {
      fbpIsSupported = await fbp.FlutterBluePlus.isSupported;
    } catch (e) {
      // 如果檢查失敗，設定為不支援
      // If check fails, set as not supported
      fbpIsSupported = false;
      debugPrint('⚠️ 藍牙檢查失敗: $e');
      debugPrint('⚠️ Bluetooth check failed: $e');
    }

    // 使用真實的藍牙傳感器
    // Use real Bluetooth sensor
    sensor = BluetoothSeatCushionSensor(
      decoder: WeiZheDecoder(), // 使用 WeiZhe 解碼器解析藍牙資料
      fbpIsSupported: fbpIsSupported,
    );

    // 輸出除錯訊息到控制台
    // Output debug message to console
    debugPrint('📱 執行藍牙模式 - 連接到真實坐墊裝置');
    debugPrint(
      '📱 Running in BLUETOOTH MODE - Connecting to real seat cushion device',
    );
  }

  // ============================================
  // 初始化應用程式
  // Initialize Application
  // ============================================

  // 創建初始化器，包含傳感器、資料儲存庫和藍牙支援狀態
  // Create initializer with sensor, repository and Bluetooth support status
  initializer = Initializer(
    fbpIsSupported: fbpIsSupported, // 藍牙支援狀態
    repository: InMemorySeatCushionRepository(), // 使用記憶體內資料儲存庫
    sensor: sensor, // 傳入剛才創建的傳感器（模擬或真實）
  );

  // 執行初始化流程
  // Execute initialization process
  await initializer();

  // 啟動 Flutter 應用程式
  // Start Flutter application
  runApp(MyApp());
}

/// ============================================
/// 主應用程式類別
/// Main Application Class
/// ============================================
///
/// 這個類別負責設定整個應用程式的主題、路由和狀態管理
/// This class is responsible for setting up the app's theme, routing and state management
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 定義主頁面
    // Define home page
    final homePage = home.HomePage();

    // 定義藍牙關閉時顯示的頁面
    // Define page shown when Bluetooth is off
    final bluetoothOffPage = BluetoothStatusView();

    return MaterialApp(
      title: "Main",
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        extensions: [
          // Bluetooth
          BluetoothDeviceTileTheme(
            connectedColor: Colors.blue,
            connectedIcon: Icons.bluetooth_connected,
            disconnectedColor: Colors.red,
            disconnectedIcon: Icons.bluetooth_disabled,
            highlightColor: Colors.black,
            nullRssiIcon: Icons.device_unknown,
            selectedColor: Colors.green,
          ),
          BluetoothStatusTheme(backGroundColor: Colors.blue),
          BluetoothCommandLineTheme(
            clearColor: Colors.red,
            clearIcon: Icons.delete,
            initColor: Colors.blue,
            initIcon: Icons.start,
            sendColor: Colors.orange,
            sendIcon: Icons.send,
          ),

          // Domain
          SeatCushionForceWidgetTheme(
            borderColor: Colors.black,
            forceToColor: weiZheForceToColorConverter,
          ),
          SeatCushionIschiumPointWidgetTheme(
            borderColor: Colors.black,
            ischiumColor: Colors.pinkAccent,
          ),
          home.AllSeatCushionForces3DMeshWidgetTheme(
            baseColor: Colors.black,
            forceScale: 0.05,
            forceToColor: weiZheForceToColorConverter,
            strokeColor: Colors.black,
          ),
          SeatCushionFeaturesLineTheme(
            clearColor: Colors.red,
            clearIcon: Icons.delete,
            downloadColor: Colors.green,
            downloadIcon: Icons.file_download,
            recordColor: Colors.orange,
            recordIcon: Icons.save,
          ),
          SeatCushionForceColorBarTheme(
            forceToColor: weiZheForceToColorConverter,
          ),
          home.HomePageTheme(
            bluetoothScannerIcon: Icons.bluetooth_searching_rounded,
            seatCushion3DMeshIcon: Icons.curtains_sharp,
            seatCushionDashboardIcon: Icons.map,
          ),
        ],
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent),
        extensions: [
          // Bluetooth
          BluetoothDeviceTileTheme(
            connectedColor: Colors.indigoAccent,
            connectedIcon: Icons.bluetooth_connected,
            disconnectedColor: Colors.red[700]!,
            disconnectedIcon: Icons.bluetooth_disabled,
            highlightColor: Colors.white,
            nullRssiIcon: Icons.device_unknown,
            selectedColor: Colors.green[700]!,
          ),
          BluetoothStatusTheme(backGroundColor: Colors.indigoAccent),
          BluetoothCommandLineTheme(
            clearColor: Colors.red[700]!,
            clearIcon: Icons.delete,
            initColor: Colors.indigoAccent,
            initIcon: Icons.start,
            sendColor: Colors.orange[700]!,
            sendIcon: Icons.send,
          ),

          // Domain
          SeatCushionForceWidgetTheme(
            borderColor: Colors.white,
            forceToColor: weiZheForceToColorConverter,
          ),
          SeatCushionIschiumPointWidgetTheme(
            borderColor: Colors.white,
            ischiumColor: Colors.pinkAccent[700]!,
          ),
          home.AllSeatCushionForces3DMeshWidgetTheme(
            baseColor: Colors.white,
            forceScale: 0.05,
            forceToColor: weiZheForceToColorConverter,
            strokeColor: Colors.white,
          ),
          SeatCushionFeaturesLineTheme(
            clearColor: Colors.red[700]!,
            clearIcon: Icons.delete,
            downloadColor: Colors.green[700]!,
            downloadIcon: Icons.file_download,
            recordColor: Colors.orange[700]!,
            recordIcon: Icons.save,
          ),
          SeatCushionForceColorBarTheme(
            forceToColor: weiZheForceToColorConverter,
          ),
          home.HomePageTheme(
            bluetoothScannerIcon: Icons.bluetooth_searching_rounded,
            seatCushion3DMeshIcon: Icons.curtains_sharp,
            seatCushionDashboardIcon: Icons.map,
          ),
        ],
      ),
      // 主題模式：跟隨系統設定（淺色/深色）
      // Theme mode: Follow system settings (light/dark)
      themeMode: ThemeMode.system,

      // ============================================
      // 主頁面與狀態管理提供者
      // Home Page and State Management Providers
      // ============================================
      home: MultiProvider(
        providers: [
          // ----------------------------------------
          // 藍牙相關提供者
          // Bluetooth Related Providers
          // ----------------------------------------

          // 藍牙適配器狀態串流提供者
          // Bluetooth adapter state stream provider
          StreamProvider(
            create: (_) => (initializer.fbpIsSupported)
                ? fbp
                      .FlutterBluePlus
                      .adapterState // 真實藍牙狀態
                : null, // 模擬模式下不需要真實狀態
            initialData: (initializer.fbpIsSupported)
                ? fbp
                      .FlutterBluePlus
                      .adapterStateNow // 當前藍牙狀態
                : fbp.BluetoothAdapterState.on, // 模擬模式下設為開啟
          ),
          // 藍牙狀態控制器提供者
          // Bluetooth status controller provider
          Provider<BluetoothStatusController>(
            create: (_) => BluetoothStatusController(
              // 按鈕點擊時開啟藍牙
              // Turn on Bluetooth when button is pressed
              onPressedButton: () => fbp.FlutterBluePlus.turnOn(),
            ),
          ),

          // 藍牙裝置掃描器控制器提供者
          // Bluetooth device scanner controller provider
          ChangeNotifierProvider<BluetoothDevicesScannerController>(
            create: (_) => BluetoothDevicesScannerController(
              fbpIsSupported: initializer.fbpIsSupported, // 藍牙支援狀態
              fbpSystemDevices: initializer.fbpSystemDevices, // 系統藍牙裝置列表
            ),
          ),

          // 藍牙命令列控制器提供者
          // Bluetooth command line controller provider
          ChangeNotifierProvider(
            create: (_) => BluetoothCommandLineController(
              // 發送封包到所有已連接的藍牙裝置
              // Send packet to all connected Bluetooth devices
              sendPacket: (controller) async {
                // 遍歷所有已連接的藍牙裝置
                // Iterate through all connected Bluetooth devices
                for (final device in fbp.FlutterBluePlus.connectedDevices) {
                  // 遍歷裝置的所有服務
                  // Iterate through all services of the device
                  for (final s in device.servicesList) {
                    // 遍歷所有可寫入的特徵值
                    // Iterate through all writable characteristics
                    for (final c in s.characteristics.where((c) {
                      final p = c.properties;
                      return p.write || p.writeWithoutResponse;
                    })) {
                      try {
                        // 將十六進制文字轉換為位元組並寫入
                        // Convert hex text to bytes and write
                        await c.write(controller.text.hexToBytes());
                      } catch (e) {
                        // 忽略寫入錯誤
                        // Ignore write errors
                      }
                    }
                  }
                }
              },
              // 初始化觸發器（目前為空實作）
              // Initialization trigger (currently empty implementation)
              triggerInit: () {},
            ),
          ),

          // ----------------------------------------
          // 坐墊感測器相關提供者
          // Seat Cushion Sensor Related Providers
          // ----------------------------------------

          // 左側坐墊感測器資料串流提供者
          // Left seat cushion sensor data stream provider
          StreamProvider(
            create: (_) => initializer.sensor.leftStream,
            initialData: null,
          ),

          // 右側坐墊感測器資料串流提供者
          // Right seat cushion sensor data stream provider
          StreamProvider(
            create: (_) => initializer.sensor.rightStream,
            initialData: null,
          ),

          // 整體坐墊感測器資料串流提供者
          // Complete seat cushion sensor data stream provider
          StreamProvider(
            create: (_) => initializer.sensor.setStream,
            initialData: null,
          ),
          // 坐墊功能列控制器提供者（記錄、清除、下載功能）
          // Seat cushion features line controller provider (record, clear, download)
          ChangeNotifierProvider(
            create: (_) => SeatCushionFeaturesLineController(
              // 下載檔案功能：將記錄的資料匯出為 JSON 檔案
              // Download file function: Export recorded data as JSON file
              downloadFile: (appLocalizations) async {
                // 創建坐墊資料檔案
                // Create seat cushion data file
                final file = await SeatCushionFile.createSeatCushionFile();

                // 寫入檔案標頭
                // Write file header
                await file.writeHead();

                // 從儲存庫中讀取所有實體並寫入檔案
                // Fetch all entities from repository and write to file
                await for (var entity
                    in initializer.repository.fetchEntities()) {
                  await file.writeSeatCushionEntity(entity);
                }

                // 寫入檔案結尾
                // Write file tail
                await file.writeTail();

                // 顯示下載完成提示訊息
                // Show download completion toast message
                await Fluttertoast.showToast(
                  msg: appLocalizations.downloadFileFinishedNotification(
                    "json",
                  ),
                );
              },

              // 清除資料狀態旗標
              // Data clearing status flags
              isClearing: initializer.repository.isClearingAllEntities,
              isClearingStream:
                  initializer.repository.isClearingAllEntitiesStream,

              // 記錄資料狀態旗標
              // Data recording status flags
              isRecording: initializer.sensorRecoderController.isRecording,
              isRecordingStream:
                  initializer.sensorRecoderController.isRecordingStream,

              // 觸發清除所有資料功能
              // Trigger clear all data function
              triggerClear: (appLocalizations) async {
                // 清除儲存庫中的所有資料
                // Clear all data in repository
                await initializer.repository.clearAllEntities();

                // 根據語系顯示對應的提示訊息
                // Show corresponding message based on locale
                String message;
                switch (appLocalizations.localeName) {
                  case "zh":
                    message = "清除旧数据。";
                  case "zh_TW":
                    message = "清除舊數據。";
                  default:
                    message = "Clear old data.";
                }
                await Fluttertoast.showToast(msg: message);
              },

              // 觸發記錄功能（切換記錄狀態）
              // Trigger record function (toggle recording state)
              triggerRecord: () =>
                  initializer.sensorRecoderController.isRecording =
                      !initializer.sensorRecoderController.isRecording,
            ),
          ),
        ],

        // ============================================
        // 頁面路由邏輯
        // Page Routing Logic
        // ============================================
        builder: (context, _) {
          // 根據藍牙狀態決定顯示哪個頁面
          // Determine which page to show based on Bluetooth state

          // 在模擬模式下（fbpIsSupported = false），直接顯示主頁面
          // In mock mode (fbpIsSupported = false), directly show home page
          if (!initializer.fbpIsSupported) {
            return homePage; // 模擬模式：直接進入主頁面，略過藍牙檢查
          }

          // 在真實藍牙模式下，檢查藍牙狀態
          // In real Bluetooth mode, check Bluetooth state
          return (context.watch<fbp.BluetoothAdapterState>() ==
                  fbp.BluetoothAdapterState.on)
              ? homePage // 藍牙開啟時顯示主頁面
              : bluetoothOffPage; // 藍牙關閉時顯示提示頁面
        },
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorObservers: [BluetoothAdapterStateObserver()],
    );
  }
}
