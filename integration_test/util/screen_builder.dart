import 'package:flutter_template_name/src/app.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/feature/authentication/model/user.dart';
import 'package:flutter_template_name/src/feature/settings/widget/settings_scope.dart';
import 'package:ui/ui.dart';

import 'fake_dependencies.dart';

/// Build a screen with fake dependencies.
Widget screenBuilder(
  Widget Function() builder, {
  void Function(Dependencies dependencies)? init,
  Locale? locale,
  User? user,
}) {
  final builderKey = GlobalKey();
  final dependencies = $initializeFakeDependencies(user: user);

  init?.call(dependencies);
  final widget = builder();

  return dependencies.inject(
    child: RepaintBoundary(
      child: SettingsScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: true,
          theme: UIThemeData.light(),
          darkTheme: UIThemeData.dark(),
          locale: locale ?? Config.locale,
          supportedLocales: /* Locales.values */ const [Config.locale],
          localizationsDelegates: App.localizationsDelegates,
          onGenerateTitle: (context) => /* AppLocalization.of(context).title */ 'Screenbuilder',
          builder: (context, _) => MediaQuery(
            key: builderKey,
            data: MediaQuery.of(context).copyWith(textScaler: .noScaling),
            child: widget,
          ),
        ),
      ),
    ),
  );
}
