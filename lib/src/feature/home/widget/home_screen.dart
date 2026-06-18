import 'package:flutter_template_name/src/common/localization/localization.dart';
import 'package:ui/ui.dart';

/// {@template home_screen}
/// HomeScreen widget.
/// {@endtemplate}
class HomeScreen extends StatelessWidget {
  /// {@macro home_screen}
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(pinned: true, title: UIText.titleMedium(l10n.homeTitle), leading: const SizedBox.shrink()),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(mainAxisAlignment: .center, children: <Widget>[Text(l10n.homeTitle)]),
            ),
          ),
        ],
      ),
    );
  }
}
