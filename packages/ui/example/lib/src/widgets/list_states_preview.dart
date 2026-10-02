import 'package:example/src/common/widgets/preview_section.dart';
import 'package:ui/ui.dart';

class ListStatesPreview extends StatelessWidget {
  const ListStatesPreview({super.key});
  @override
  Widget build(BuildContext context) => PreviewSection(
    title: 'List states and pagination',
    child: Padding(
      padding: PreviewSection.contentPaddingOf(context),
      child: TextButton(
        onPressed: () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => const _ListScreen())),
        child: const Text('Open interactive list'),
      ),
    ),
  );
}

class _ListScreen extends StatefulWidget {
  const _ListScreen();
  @override
  State<_ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<_ListScreen> {
  List<int> _items = List.generate(16, (index) => index);
  int _nextId = 16;
  int? _removed;
  bool _error = false;
  bool _loading = false;
  int _generation = 0;

  Future<void> _load() async {
    final generation = _generation;
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted || generation != _generation) return;
    setState(() {
      _items = [..._items, ...List.generate(8, (_) => _nextId++)];
      _loading = false;
      _error = false;
    });
  }

  void _remove(int id) => setState(() {
    _removed = id;
    _items = _items.where((item) => item != id).toList();
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Interactive list')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _generation++;
                    _loading = true;
                    _error = false;
                  });
                  _load().ignore();
                },
                child: const Text('Load list'),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _generation++;
                  _items = [];
                  _loading = false;
                  _error = false;
                }),
                child: const Text('Empty list'),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _generation++;
                  _loading = false;
                  _error = true;
                }),
                child: const Text('List error'),
              ),
              TextButton(
                onPressed: _removed == null
                    ? null
                    : () => setState(() {
                        _items = [..._items, _removed!]..sort();
                        _removed = null;
                      }),
                child: const Text('Restore removed row'),
              ),
            ],
          ),
        ),
        if (_loading)
          const Expanded(child: Center(child: UILoaderIndicator()))
        else if (_error)
          Expanded(
            child: Center(
              child: TextButton(
                onPressed: () {
                  setState(() => _loading = true);
                  _load().ignore();
                },
                child: const Text('Retry list'),
              ),
            ),
          )
        else if (_items.isEmpty)
          const Expanded(child: Center(child: Text('No items')))
        else
          Expanded(
            child: UILazyLoadScrollView(
              onLazyLoad: _load,
              canLazyLoad: _items.length < 48,
              child: ListView.builder(
                itemCount: _items.length + 1,
                itemBuilder: (context, index) {
                  if (index == _items.length) return const UILazyLoadingIndicator();
                  final id = _items[index];
                  return UISlidable(
                    key: ValueKey(id),
                    extentRatio: UISlidableExtentRatio.xl,
                    onDismissed: () => _remove(id),
                    confirmDismiss: () async => true,
                    actions: [UISlidableAction.delete(label: 'Delete', onPressed: () => _remove(id))],
                    child: UIListTile(
                      title: Text('Row $id'),
                      subtitle: const Text('Swipe or use the delete button'),
                      trailing: IconButton(
                        tooltip: 'Delete row $id',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _remove(id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    ),
  );
}
