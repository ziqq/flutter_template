import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_template_name/src/common/localization/localization.dart' show Localization;

/// Extension for [Localization] on [BuildContext]
extension LocalizationExtension on BuildContext {
  /// Localization strings from context.
  Localization stringOf() => Localization.stringOf<Localization>(this);
}
