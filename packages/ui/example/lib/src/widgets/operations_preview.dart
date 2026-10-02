import 'dart:async';

import 'package:example/src/common/widgets/preview_section.dart';
import 'package:ui/ui.dart';

/// Exercises overlapping regular and lazy presentation loading.
class OperationsPreview extends StatefulWidget {
  const OperationsPreview({super.key});

  @override
  State<OperationsPreview> createState() => _OperationsPreviewState();
}

class _OperationsPreviewState extends State<OperationsPreview> {
  final _loading = UILoadingController();

  @override
  void dispose() {
    _loading.dispose();
    super.dispose();
  }

  void _run({required bool lazy}) => unawaited(
    _loading.run<void>(
      () => Future<void>.delayed(Duration(seconds: lazy ? 5 : 3)),
      lazy: lazy,
      message: lazy ? 'Loading more' : 'Saving demo',
    ),
  );

  @override
  Widget build(BuildContext context) => PreviewSection(
    title: 'Scoped loading',
    child: Padding(
      padding: EdgeInsets.all(Theme.of(context).uiTheme.size.offset.regular),
      child: UILoadingScope(
        controller: _loading,
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const UILoadingTitle('All operations'),
            const UILoadingTitle('Regular operations only', showLazyLoading: false),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                UIButton(onPressed: () => _run(lazy: false), child: const Text('Regular operation')),
                UIButton.secondary(onPressed: () => _run(lazy: true), child: const Text('Lazy operation')),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
