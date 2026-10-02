import 'package:example/src/common/widgets/component_preview_group.dart';
import 'package:example/src/common/widgets/preview_section.dart';
import 'package:ui/ui.dart';

enum _ContentState { loading, content, empty, error }

class FeedbackPreview extends StatefulWidget {
  const FeedbackPreview({super.key});
  @override
  State<FeedbackPreview> createState() => _FeedbackPreviewState();
}

class _FeedbackPreviewState extends State<FeedbackPreview> {
  _ContentState _state = _ContentState.loading;

  @override
  Widget build(BuildContext context) => PreviewSection(
    title: 'Loading and content states',
    child: Padding(
      padding: PreviewSection.contentPaddingOf(context),
      child: ComponentPreviewGroup(
        title: 'Shared shimmer clock',
        description: 'Switch between skeleton, content, empty, and error. Retry returns to loading; content replaces the skeleton without changing its role.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final state in _ContentState.values)
                  ChoiceChip(
                    label: Text(state.name),
                    selected: state == _state,
                    onSelected: (_) => setState(() => _state = state),
                  ),
              ],
            ),
            switch (_state) {
              _ContentState.loading => Semantics(
                label: 'Loading content',
                liveRegion: true,
                child: const ExcludeSemantics(
                  child: UIShimmerGroup(
                    child: Column(
                      spacing: 16,
                      children: [
                        Row(
                          children: [
                            Shimmer(size: Size(48, 48), cornerRadius: 24),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  Shimmer(size: Size(180, 16), alignment: Alignment.centerLeft),
                                  Shimmer(size: Size(120, 12), alignment: Alignment.centerLeft),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Shimmer(size: Size(double.infinity, 72)),
                      ],
                    ),
                  ),
                ),
              ),
              _ContentState.content => const UIListTile(
                leading: Icon(Icons.check_circle_outline),
                title: Text('Content is ready'),
                subtitle: Text('Skeleton replaced by a real row'),
              ),
              _ContentState.empty => const UIListTile(
                leading: Icon(Icons.inbox_outlined),
                title: Text('Nothing here yet'),
                subtitle: Text('Create an item to get started'),
              ),
              _ContentState.error => Column(
                children: [
                  const UIListTile(leading: Icon(Icons.error_outline), title: Text('Could not load content')),
                  TextButton(
                    onPressed: () => setState(() => _state = _ContentState.loading),
                    child: const Text('Retry content'),
                  ),
                ],
              ),
            },
          ],
        ),
      ),
    ),
  );
}
