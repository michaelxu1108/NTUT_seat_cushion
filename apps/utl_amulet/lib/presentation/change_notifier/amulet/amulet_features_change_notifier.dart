import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:utl_amulet/application/amulet_entity_creator.dart';

class AmuletFeaturesChangeNotifier extends ChangeNotifier {
  final AmuletEntityCreator amuletEntityCreator;
  late final StreamSubscription _subscription;
  AmuletFeaturesChangeNotifier({
    required this.amuletEntityCreator,
  }) {
    _subscription = amuletEntityCreator.isCreatingStream.listen((_) => notifyListeners());
  }
  bool get isSaving => amuletEntityCreator.isCreating;
  toggleIsSaving() {
    return amuletEntityCreator.toggleCreating();
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
