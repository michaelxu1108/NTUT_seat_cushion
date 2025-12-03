// Copyright 2024-2025, Zhen-Xiang Chen.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Wei-Zhe decoder.
///
/// This decoder is used to collect values ​​and then send the seat
/// cushion data via stream when the conditions are met.
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';

import '../../seat_cushion.dart';
import 'template.dart';

@visibleForTesting
@pragma('vm:notify-debugger-on-exception')
enum WeiZheDecoderValuesStage { first, second, third }

class WeiZheDecoder implements SeatCushionSensorDecoder {
  final Map<SeatCushionType, Map<WeiZheDecoderValuesStage, List<int>?>>
  _buffer = {
    for (var v in SeatCushionType.values)
      v: {for (var v in WeiZheDecoderValuesStage.values) v: null},
  };

  final _leftController = StreamController<LeftSeatCushion>.broadcast();

  final _rightController = StreamController<RightSeatCushion>.broadcast();

  final _lock = Lock();

  // ============================================
  // 時間戳記輔助函數
  // ============================================
  /// 獲取當前時間戳記字串 (HH:mm:ss.SSS)
  String _getTimestamp() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';
  }

  /// 帶時間戳記的 debugPrint
  void _debugPrintWithTimestamp(String message) {
    debugPrint('[${_getTimestamp()}] $message');
  }

  @override
  Stream<LeftSeatCushion> get leftStream => _leftController.stream;

  @override
  Stream<RightSeatCushion> get rightStream => _rightController.stream;

  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  SeatCushionType? valuesToSeatCushionType(List<int> values) {
    if (values.isEmpty) {
      _debugPrintWithTimestamp('⚠️ valuesToSeatCushionType: 收到空的數據包');
      return null;
    }
    final header = values.first & 0xF0;
    if (header == 0x10) return SeatCushionType.right;
    if (header == 0x20) return SeatCushionType.left;
    _debugPrintWithTimestamp(
      '⚠️ valuesToSeatCushionType: 未知的設備類型 header=0x${header.toRadixString(16)}',
    );
    return null;
  }

  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  WeiZheDecoderValuesStage? valuesToStage(List<int> values) {
    if (values.isEmpty) {
      _debugPrintWithTimestamp('⚠️ valuesToStage: 收到空的數據包');
      return null;
    }
    final stage = values.first & 0x0F;
    if (stage == 0x01) return WeiZheDecoderValuesStage.first;
    if (stage == 0x02) return WeiZheDecoderValuesStage.second;
    if (stage == 0x03) return WeiZheDecoderValuesStage.third;
    _debugPrintWithTimestamp('⚠️ valuesToStage: 未知的階段 stage=0x${stage.toRadixString(16)}');
    return null;
  }

  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  int stageToLength(WeiZheDecoderValuesStage stage) {
    switch (stage) {
      case WeiZheDecoderValuesStage.first:
        return 243;
      case WeiZheDecoderValuesStage.second:
        return 243;
      case WeiZheDecoderValuesStage.third:
        return 13;
    }
  }

  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  List<double> valuesToForces(List<int> values) {
    final byteData = ByteData.sublistView(Uint8List.fromList(values));
    return [
      for (var i = 0; i < byteData.lengthInBytes; i += 2)
        byteData.getInt16(i, Endian.little).toDouble(),
    ];
  }

  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  int indexToRow({required SeatCushionType type, required int index}) {
    switch (type) {
      case SeatCushionType.left:
        return index ~/ SeatCushion.unitsMaxColumn;
      case SeatCushionType.right:
        return (SeatCushion.unitsMaxRow - 1) -
            (index ~/ SeatCushion.unitsMaxColumn);
    }
  }

  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  int indexToColumn({required SeatCushionType type, required int index}) {
    switch (type) {
      case SeatCushionType.left:
        return (SeatCushion.unitsMaxColumn - 1) -
            (index % SeatCushion.unitsMaxColumn);
      case SeatCushionType.right:
        return index % SeatCushion.unitsMaxColumn;
    }
  }

  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  int rowColumnToIndex({
    required SeatCushionType type,
    required int row,
    required int column,
  }) {
    switch (type) {
      case SeatCushionType.left:
        return (row * SeatCushion.unitsMaxColumn) +
            ((SeatCushion.unitsMaxColumn - 1) - column);
      case SeatCushionType.right:
        return (((SeatCushion.unitsMaxRow - 1) - row) *
                SeatCushion.unitsMaxColumn) +
            column;
    }
  }

  /// 將值添加到緩衝區​​然後發送座位
  /// 當條件滿足時通過流緩衝數據。
  @override
  Future<void> addValues(List<int> values) async {
    return await _lock.synchronized(() {
      try {
        /// 診斷日誌：顯示收到的原始數據
        if (values.isNotEmpty) {
          final header = values.first;
          _debugPrintWithTimestamp(
            '📦 收到數據包: 長度=${values.length}, header=0x${header.toRadixString(16).padLeft(2, '0')}',
          );
        }

        /// 檢查類型是否有效。
        final type = valuesToSeatCushionType(values);
        if (type == null) {
          _debugPrintWithTimestamp('⚠️ 無法識別設備類型，忽略此數據包');
          return;
        }

        /// 檢查階段是否有效。
        final stage = valuesToStage(values);
        if (stage == null) {
          _debugPrintWithTimestamp('⚠️ 無法識別階段，忽略此數據包');
          return;
        }

        /// 檢查長度是否有效。
        final length = stageToLength(stage);
        if (length != values.length) {
          _debugPrintWithTimestamp(
            '⚠️ 數據長度不符: 期望=$length, 實際=${values.length}, 類型=$type, 階段=$stage',
          );
          return;
        }

        _debugPrintWithTimestamp('✅ 有效數據包: 類型=$type, 階段=$stage, 長度=${values.length}');

        /// 更新緩衝區。
        _buffer[type]!.update(stage, (_) => values);

        /// 檢查該類型緩衝區的各個階段值是否已準備好。
        final allStageValuesIsNotEmpty = _buffer[type]!.values.every(
          (values) => values != null,
        );

        if (allStageValuesIsNotEmpty) {
          _debugPrintWithTimestamp('🎯 所有階段數據已就緒，開始解碼 $type 座墊數據...');

          /// Get the force list.
          final rawForces = valuesToForces(
            _buffer[type]!.values.expand((e) => e!.skip(1)).toList(),
          );

          _debugPrintWithTimestamp('   解碼後力值數量: ${rawForces.length}');

          /// Map the force list to 2D-list.
          final forces = List.generate(SeatCushion.unitsMaxRow, (row) {
            return List.generate(SeatCushion.unitsMaxColumn, (column) {
              return rawForces[rowColumnToIndex(
                type: type,
                row: row,
                column: column,
              )];
            });
          });

          /// Get current time.
          final time = DateTime.now();

          /// Add the seat cushion data to the corresponding stream.
          switch (type) {
            case SeatCushionType.left:
              _debugPrintWithTimestamp('📤 發送左側座墊數據到 stream');
              _leftController.add(LeftSeatCushion(forces: forces, time: time));
            case SeatCushionType.right:
              _debugPrintWithTimestamp('📤 發送右側座墊數據到 stream');
              _rightController.add(
                RightSeatCushion(forces: forces, time: time),
              );
          }

          /// Clear the buffer of this type.
          for (final stage in WeiZheDecoderValuesStage.values) {
            _buffer[type]!.update(stage, (_) => null);
          }
        }
      } catch (e, stackTrace) {
        _debugPrintWithTimestamp('❌ 解碼數據時發生錯誤:');
        _debugPrintWithTimestamp('   錯誤: $e');
        _debugPrintWithTimestamp('   堆疊追蹤: $stackTrace');
        _debugPrintWithTimestamp('   數據包長度: ${values.length}');
        if (values.isNotEmpty) {
          _debugPrintWithTimestamp(
            '   數據包 header: 0x${values.first.toRadixString(16).padLeft(2, '0')}',
          );
        }
      }
    });
  }

  /// Generate a mock values for testing.
  List<int> generateMokeValues() {
    final random = Random.secure();
    final header = ((random.nextInt(2) + 1) << 4) | (random.nextInt(3) + 1);
    final stage = valuesToStage([header])!;
    final length = stageToLength(stage) - 1;
    return [
      header,
      ...List.generate((length / 2.0).toInt(), (index) {
        /// Force
        final force =
            (random.nextDouble() *
                (SeatCushion.forceMax - SeatCushion.forceMin)) +
            SeatCushion.forceMin;
        final forceBytes = (ByteData(
          2,
        )..setInt16(0, force.toInt(), Endian.little)).buffer.asUint8List();

        return [...forceBytes];
      }).expand((e) => e),
    ];
  }

  /// Close the stream.
  void close() {
    _leftController.close();
    _rightController.close();
  }
}
