import 'package:utl_amulet/l10n/gen_l10n/app_localizations.dart';
import 'package:utl_amulet/domain/entity/amulet_entity.dart';

abstract class FileHandler {
  Future<bool> downloadAmuletEntitiesFile({
    required Stream<AmuletEntity> fetchEntitiesStream,
    required AppLocalizations appLocalizations,
  });
}
