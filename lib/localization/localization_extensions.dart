import 'package:flutter/widgets.dart';
import 'package:mathstep/l10n/app_localizations.dart';

extension LocalizationExt on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
