import 'dart:async';
import 'dart:math';

import 'package:stream_utils/stream_util.dart';

import '../../seat_cushion.dart';

/// --------------------------------------------
/// [AutoMockSeatCushionSensor]
/// --------------------------------------------
///
/// A mock implementation of [SeatCushionSensor] that automatically generates
/// simulated seat cushion data at regular intervals.
///
/// This sensor is useful for testing and development when no physical
/// seat cushion device is available. It generates realistic pressure patterns
/// that simulate a person sitting on the cushion.
///
/// ## Features
/// - Automatically generates data every 100ms
/// - Simulates realistic pressure distribution with:
///   - Higher pressure in the center (ischium area)
///   - Lower pressure at the edges
///   - Random variations to simulate natural body movements
/// - Provides separate streams for left, right, and combined cushion data
///
/// ## Usage
/// ```dart
/// final sensor = AutoMockSeatCushionSensor();
/// sensor.leftStream.listen((cushion) {
///   print('Left total force: ${cushion.totalForce()}');
/// });
/// ```
///
/// Don't forget to call [dispose()] when the sensor is no longer needed.
class AutoMockSeatCushionSensor implements SeatCushionSensor {
  final StreamController<LeftSeatCushion> _leftController =
      StreamController.broadcast();

  final StreamController<RightSeatCushion> _rightController =
      StreamController.broadcast();

  final StreamController<SeatCushionSet> _setController =
      StreamController.broadcast();

  late final Timer _timer;
  final Random _random = Random();

  /// Creates an auto-generating mock sensor.
  ///
  /// The sensor will automatically start generating data every 100ms.
  AutoMockSeatCushionSensor() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _generateMockData();
    });
  }

  /// Generates realistic mock seat cushion data.
  ///
  /// Creates a pressure distribution that simulates a person sitting,
  /// with higher pressure in the center and lower at the edges.
  void _generateMockData() {
    final now = DateTime.now();

    // Generate left cushion data
    final leftForces = _generateForceMatrix();
    final left = LeftSeatCushion(
      forces: leftForces,
      time: now,
    );

    // Generate right cushion data
    final rightForces = _generateForceMatrix();
    final right = RightSeatCushion(
      forces: rightForces,
      time: now,
    );

    _leftController.add(left);
    _rightController.add(right);
    _setController.add(
      SeatCushionSet(left: left, right: right),
    );
  }

  /// Generates a realistic force matrix simulating a person sitting.
  ///
  /// The pattern includes:
  /// - Two main pressure points (simulating sit bones/ischium)
  /// - Gradual falloff from pressure centers
  /// - Random variations for realism
  /// - Lower pressure at edges
  List<List<double>> _generateForceMatrix() {
    final forces = <List<double>>[];

    // Define two pressure centers (simulating sit bones)
    final center1Row = 12.0 + _random.nextDouble() * 2;
    final center1Col = 2.5 + _random.nextDouble() * 0.5;
    final center2Row = 18.0 + _random.nextDouble() * 2;
    final center2Col = 5.5 + _random.nextDouble() * 0.5;

    for (int row = 0; row < SeatCushion.unitsMaxRow; row++) {
      final rowForces = <double>[];

      for (int col = 0; col < SeatCushion.unitsMaxColumn; col++) {
        // Calculate distance from both pressure centers
        final dist1 = sqrt(
          pow(row - center1Row, 2) + pow(col - center1Col, 2) * 4,
        );
        final dist2 = sqrt(
          pow(row - center2Row, 2) + pow(col - center2Col, 2) * 4,
        );

        // Base force calculation with Gaussian-like falloff
        double force = 0;

        // First pressure point (upper sit bone)
        if (dist1 < 8) {
          force += 800 * exp(-dist1 / 3.0);
        }

        // Second pressure point (lower sit bone)
        if (dist2 < 8) {
          force += 900 * exp(-dist2 / 3.0);
        }

        // Add some background pressure (thigh area)
        if (row > 5 && row < 25 && col > 1 && col < 7) {
          force += 50 + _random.nextDouble() * 30;
        }

        // Add random variation for realism
        force += _random.nextDouble() * 20 - 10;

        // Clamp to valid range
        force = force.clamp(SeatCushion.forceMin, SeatCushion.forceMax);

        rowForces.add(force);
      }

      forces.add(rowForces);
    }

    return forces;
  }

  @override
  Stream<LeftSeatCushion> get leftStream => _leftController.stream;

  @override
  Stream<RightSeatCushion> get rightStream => _rightController.stream;

  @override
  Stream<SeatCushionSet> get setStream => _setController.stream;

  @override
  Stream<SeatCushion> get stream => mergeStreams([
        leftStream,
        rightStream,
      ]);

  /// Disposes of the sensor and stops data generation.
  ///
  /// Call this method when the sensor is no longer needed to prevent
  /// memory leaks and stop the background timer.
  void dispose() {
    _timer.cancel();
    _leftController.close();
    _rightController.close();
    _setController.close();
  }
}
