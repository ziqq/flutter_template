import 'package:example/src/common/widgets/preview_section.dart';
import 'package:ui/ui.dart';

/// Opens a lazy grouped list with headers that hand off while scrolling.
class GroupedListsPreview extends StatelessWidget {
  const GroupedListsPreview({super.key});

  @override
  Widget build(BuildContext context) => PreviewSection(
    title: 'Grouped sliver lists',
    child: TextButton(
      onPressed: () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => const _GroupedListScreen())),
      child: const Text('Open sticky groups'),
    ),
  );
}

class _GroupedListScreen extends StatefulWidget {
  const _GroupedListScreen();

  @override
  State<_GroupedListScreen> createState() => _GroupedListScreenState();
}

class _GroupedListScreenState extends State<_GroupedListScreen> {
  List<int> _items = List<int>.generate(32, (index) => index);

  static String _groupOf(int value) => 'Group ${value ~/ 8 + 1}';
  static int _idOf(int value) => value;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Sticky groups'),
      actions: [
        TextButton(onPressed: () => setState(() => _items = [..._items, _items.length]), child: const Text('Append')),
      ],
    ),
    body: CustomScrollView(
      slivers: [
        UIGroupedSliverList<String, int>.sticky(
          items: _items,
          groupKeyOf: _groupOf,
          stableIdOf: _idOf,
          headerBackgroundColor: Theme.of(context).uiTheme.color.secondaryBackground,
          headerKeyPrefix: 'demo-header',
          listKeyPrefix: 'demo-list',
          groupHeaderBuilder: (_, group) => Padding(padding: const EdgeInsets.all(16), child: Text(group)),
          itemBuilder: (_, item, _) => UIListTile(title: Text('Item $item')),
          itemSeparatorBuilder: (_) => const Divider(height: 1),
        ),
      ],
    ),
  );
}
