/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 10 February 2026
 */

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Used to define the order of a [UIGroupedSliverList].
enum GroupedListOrder {
  /// Ascending order (oldest first).
  asc,

  /// Descending order (newest first).
  desc,
}

/// Generic group tuple: (groupKey, items)
typedef _UIGroupedSliverList$Data<K, T> = (K key, List<T> items);

/// {@template ui_grouped_sliver_list}
/// A sliver that renders a flat [items] list as date/section groups with
/// sticky (pinned) group headers.
///
/// Grouping:
/// - Items are grouped by [groupKeyOf]. Equal keys are merged into a single
///   group even when the matching items are not adjacent in [items], so a
///   month or day header is never duplicated.
/// - Items whose [groupKeyOf] returns `null` are skipped and not rendered.
/// - When [sortKeyOf] is provided, items are globally sorted by that key in
///   descending order before grouping. When it is `null`, the original [items]
///   order is preserved and groups appear in first-seen order.
///
/// Headers:
/// - Group headers are [SliverPersistentHeader]s controlled by [headerPinned]
///   (sticky) and [headerFloating] (reappear on scroll up), both `true` by
///   default.
/// - Place this widget in a CustomScrollView's slivers. Header geometry is
///   calculated in that viewport; use sliver refresh controls when combining
///   refresh with sticky headers.
///
/// Paging / append optimization:
/// - Treat items and their payloads as immutable; pass a new list after changes.
/// - Unsorted pages can append to the end without regrouping the existing items.
/// - Sorted updates regroup globally so newer incoming items cannot violate ordering.
/// - [stableIdOf] must return a stable identity per item; it is used to detect
///   pure appends and skip a full regroup. Prefer top-level or instance methods
///   (tear-offs) so the identity stays stable across rebuilds.
///
/// Example (paged day groups, sticky pill headers, sliver pull-to-refresh):
/// ```dart
/// // Keep key/id/sort extractors as stable instance or top-level methods.
/// DateTime? _groupKey(Foo f) {
///   final date = f.date;
///   if (date == null) return null;
///   return DateTime(date.year, date.month, date.day); // day granularity
/// }
///
/// int? _sortKey(Foo f) => f.date?.millisecondsSinceEpoch; // desc
///
/// Object? _stableId(Foo f) => f.id;
///
/// CustomScrollView(
///   slivers: <Widget>[
///     CupertinoSliverRefreshControl(onRefresh: _onRefresh),
///     UIGroupedSliverList<DateTime, Foo>(
///       items: items,
///       groupKeyOf: _groupKey,
///       sortKeyOf: _sortKey,
///       stableIdOf: _stableId,
///       padding: CommonPadding.of(context),
///       headerBackgroundColor: theme.uiTheme.color.secondaryBackground,
///       headerMinHeight: theme.uiTheme.padding * 2.2,
///       headerMaxHeight: theme.uiTheme.padding * 2.2,
///       headerKeyPrefix: 'foo_header',
///       listKeyPrefix: 'foo_list',
///       groupHeaderBuilder: (_, day) => CommonDateText(day, pattern: 'd MMM'),
///       groupSeparatorBuilder: (_, _) => UISpacer.paddingV(context),
///       itemSeparatorBuilder: (_) => UISpacer.paddingV(context),
///       itemBuilder: (_, item, _) => FooTile(item: item),
///     ),
///   ],
/// );
/// ```
///
/// Variants used in the app:
/// - Month groups (client visits): return `DateTime(date.year, date.month)`
///   from [groupKeyOf].
/// - Preserve source order (client visits): omit [sortKeyOf]; items are only
///   grouped, never globally re-sorted.
/// - Non-date sections (visit notifications): use any [K] such as `String` for
///   the group key.
/// - Static, non-sticky headers (visit notifications bottom sheet): set
///   [headerPinned] and [headerFloating] to `false`.
/// {@endtemplate}
class UIGroupedSliverList<K, T> extends StatefulWidget {
  const UIGroupedSliverList({
    required this.items,
    required this.groupKeyOf,
    required this.stableIdOf,
    required this.groupHeaderBuilder,
    required this.itemBuilder,
    required this.headerBackgroundColor,
    required this.headerMinHeight,
    required this.headerMaxHeight,
    this.sortKeyOf,
    this.headerKeyPrefix,
    this.listKeyPrefix,
    this.groupSeparatorBuilder,
    this.itemSeparatorBuilder,
    this.padding,
    this.headerPinned = true,
    this.headerFloating = true,
    this.stickyHandoff = false,
    super.key,
  }) : assert(headerMinHeight >= 0, 'Minimum header height must be nonnegative.'),
       assert(headerMaxHeight >= headerMinHeight && headerMaxHeight < double.infinity, 'Invalid header extent.');

  /// Creates a grouped sliver with iOS-style hand-off sticky headers.
  ///
  /// Sections render lazily (each is a [SliverList]) and the active section
  /// header stays pinned until the next section pushes it out. Header extent is
  /// intrinsic here, so [headerMinHeight] / [headerMaxHeight] are not required.
  factory UIGroupedSliverList.sticky({
    required List<T> items,
    required K? Function(T item) groupKeyOf,
    required Object? Function(T item) stableIdOf,
    required Widget Function(BuildContext context, K key) groupHeaderBuilder,
    required Widget Function(BuildContext context, T item, int indexInGroup) itemBuilder,
    required Color headerBackgroundColor,
    Comparable<Object?>? Function(T item)? sortKeyOf,
    String? headerKeyPrefix,
    String? listKeyPrefix,
    Widget Function(BuildContext context, K key)? groupSeparatorBuilder,
    Widget Function(BuildContext context)? itemSeparatorBuilder,
    EdgeInsets? padding,
    Key? key,
  }) => UIGroupedSliverList<K, T>(
    key: key,
    items: items,
    groupKeyOf: groupKeyOf,
    stableIdOf: stableIdOf,
    groupHeaderBuilder: groupHeaderBuilder,
    itemBuilder: itemBuilder,
    headerBackgroundColor: headerBackgroundColor,
    headerMinHeight: 0,
    headerMaxHeight: 0,
    sortKeyOf: sortKeyOf,
    headerKeyPrefix: headerKeyPrefix,
    listKeyPrefix: listKeyPrefix,
    groupSeparatorBuilder: groupSeparatorBuilder,
    itemSeparatorBuilder: itemSeparatorBuilder,
    padding: padding,
    stickyHandoff: true,
  );

  /// Flat items list (can be from paging / refresh).
  final List<T> items;

  /// Stable id of item (`messageID`, `itemID`, `uuid`, etc).
  /// Prefer a stable method tear-off; changing the extractor triggers regrouping.
  final Object? Function(T item) stableIdOf;

  /// Group key extractor (e.g. `DateTime` dayKey).
  /// Prefer a stable method tear-off; changing the extractor triggers regrouping.
  final K? Function(T item) groupKeyOf;

  /// Optional sort key (descending). Prefer int epoch / num (no parsing in comparator).
  /// Prefer a stable method tear-off; changing the extractor triggers regrouping.
  final Comparable<Object?>? Function(T item)? sortKeyOf;

  /// Header builder for each group key.
  final Widget Function(BuildContext context, K key) groupHeaderBuilder;

  /// Item builder for each item.
  final Widget Function(BuildContext context, T item, int indexInGroup) itemBuilder;

  /// Background color of headers.
  final Color headerBackgroundColor;

  /// Min height of headers.
  final double headerMinHeight;

  /// Max height of headers.
  final double headerMaxHeight;

  /// Optional widget.groupSeparatorBuilder after each group.
  final Widget Function(BuildContext context, K key)? groupSeparatorBuilder;

  /// Optional widget.itemSeparatorBuilder between items.
  final Widget Function(BuildContext context)? itemSeparatorBuilder;

  /// Optional padding around each group's list.
  final EdgeInsets? padding;

  /// Header key prefix to keep stable across rebuilds (e.g. 'example_header_${type.alias}').
  final String? headerKeyPrefix;

  /// List key prefix to keep stable across rebuilds (e.g. 'example_list_${type.alias}').
  final String? listKeyPrefix;

  /// Allow header to be pinned (sticky) when scrolling.
  final bool headerPinned;

  /// Allow header to float (reappear) when scrolling back.
  final bool headerFloating;

  /// Use sticky hand-off headers instead of stacked pinned headers.
  ///
  /// When `false` (default) each group header is a pinned [SliverPersistentHeader]
  /// inside a [SliverMainAxisGroup].
  ///
  /// When `true` each group renders as a hand-off sticky header (the active
  /// header stays until the next group pushes it out), like iOS section lists.
  /// In this mode [headerPinned], [headerFloating], [headerMinHeight] and
  /// [headerMaxHeight] are ignored; sections render lazily (each is a
  /// [SliverList]) without building offscreen rows.
  ///
  /// Prefer the [UIGroupedSliverList.sticky] factory over setting this directly.
  final bool stickyHandoff;

  @override
  State<UIGroupedSliverList<K, T>> createState() => _UIGroupedSliverListState<K, T>();
}

/// State for widget [UIGroupedSliverList].
class _UIGroupedSliverListState<K, T> extends State<UIGroupedSliverList<K, T>> {
  List<_UIGroupedSliverList$Data<K, T>> _groups = <_UIGroupedSliverList$Data<K, T>>[];
  List<T>? _lastItems;
  bool _canAppendWithoutRebuild(List<T> oldItems, List<T> newItems) {
    if (newItems.length <= oldItems.length) return false;

    for (var i = 0; i < oldItems.length; i++) {
      if (widget.stableIdOf(oldItems[i]) != widget.stableIdOf(newItems[i]) || oldItems[i] != newItems[i]) {
        return false;
      }
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    _rebuild(widget.items);
  }

  @override
  void didUpdateWidget(covariant UIGroupedSliverList<K, T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.groupKeyOf != widget.groupKeyOf ||
        oldWidget.stableIdOf != widget.stableIdOf ||
        oldWidget.sortKeyOf != widget.sortKeyOf) {
      _rebuild(widget.items);
      return;
    }
    if (identical(_lastItems, widget.items)) return;
    final previous = _lastItems;
    // Global sorting cannot assume that a newly appended page is older.
    if (widget.sortKeyOf != null || previous == null || !_canAppendWithoutRebuild(previous, widget.items)) {
      _rebuild(widget.items);
    } else {
      _groups = _appendToGroups(_groups, widget.items.sublist(previous.length));
      _lastItems = widget.items;
    }
  }

  void _rebuild(List<T> list) {
    _groups = _groupAll(list);
    _lastItems = list;
  }

  List<_UIGroupedSliverList$Data<K, T>> _groupAll(List<T> list) {
    final sortKeyOf = widget.sortKeyOf;

    // Iterate the source directly when no sort key is given (no extra copy).
    // Otherwise sort a lightweight decorated projection once (descending).
    final Iterable<T> ordered;
    if (sortKeyOf == null) {
      ordered = list;
    } else {
      final decorated = <({T item, Comparable<Object?> key})>[];
      for (final it in list) {
        final k = sortKeyOf(it);
        if (k == null) continue;
        decorated.add((item: it, key: k));
      }
      decorated.sort((a, b) => b.key.compareTo(a.key)); // Desc
      ordered = decorated.map((e) => e.item);
    }

    // Group by key. A LinkedHashMap preserves first-seen key order, and equal
    // keys merge even when their items are not adjacent (no duplicate headers).
    // Group lists stay growable so paging can append in place (see
    // [_appendToGroups]).
    final grouped = <K, List<T>>{};
    for (final it in ordered) {
      final k = widget.groupKeyOf(it);
      if (k == null) continue;
      (grouped[k] ??= <T>[]).add(it);
    }

    final out = <_UIGroupedSliverList$Data<K, T>>[];
    for (final entry in grouped.entries) {
      out.add((entry.key, entry.value));
    }
    return out;
  }

  /// Merges an unsorted appended page into existing groups in source order.
  List<_UIGroupedSliverList$Data<K, T>> _appendToGroups(
    List<_UIGroupedSliverList$Data<K, T>> origin,
    List<T> incoming,
  ) {
    final grouped = <K, List<T>>{for (final (key, items) in origin) key: items};
    for (final item in incoming) {
      final key = widget.groupKeyOf(item);
      if (key == null) continue;
      var group = grouped[key];
      if (group == null) {
        group = <T>[];
        grouped[key] = group;
        origin.add((key, group));
      }
      group.add(item);
    }
    return origin;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stickyHandoff) return _buildSticky(context);

    final slivers = <Widget>[];

    for (final (key, items) in _groups) {
      final headerKey = widget.headerKeyPrefix == null ? null : (widget.headerKeyPrefix!, key);
      final listKey = widget.listKeyPrefix == null ? null : (widget.listKeyPrefix!, key);

      slivers
        ..add(
          SliverPersistentHeader(
            key: headerKey == null ? null : ValueKey<(String, K)>(headerKey),
            pinned: widget.headerPinned,
            floating: widget.headerFloating,
            delegate: _SliverHeaderDelegate(
              minHeight: widget.headerMinHeight,
              maxHeight: widget.headerMaxHeight,
              headerBackgroundColor: widget.headerBackgroundColor,
              child: Builder(builder: (context) => widget.groupHeaderBuilder(context, key)),
            ),
          ),
        )
        ..add(
          SliverPadding(
            padding: widget.padding ?? EdgeInsets.zero,
            sliver: SliverList.separated(
              key: listKey == null ? null : ValueKey<(String, K)>(listKey),
              itemCount: items.length,
              itemBuilder: (context, i) => widget.itemBuilder(context, items[i], i),
              separatorBuilder: (context, _) => widget.itemSeparatorBuilder?.call(context) ?? const SizedBox.shrink(),
            ),
          ),
        );

      final groupSpacer = widget.groupSeparatorBuilder?.call(context, key);
      if (groupSpacer != null) {
        slivers.add(SliverToBoxAdapter(child: groupSpacer));
      }
    }

    return SliverMainAxisGroup(slivers: slivers);
  }

  /// Builds hand-off sticky headers (one active header at a time).
  ///
  /// Every section is a [_SliverStickyHeader] with a lazy [SliverList] child, so
  /// items are built on demand — offscreen rows remain unbuilt. Sections are combined into a single [SliverMainAxisGroup] so the
  /// widget stays a single sliver, and headers hand off (the next section pushes
  /// the current one out) instead of stacking.
  Widget _buildSticky(BuildContext context) {
    final slivers = <Widget>[];
    for (final (key, items) in _groups) {
      final headerKey = widget.headerKeyPrefix == null ? null : (widget.headerKeyPrefix!, key);
      final listKey = widget.listKeyPrefix == null ? null : (widget.listKeyPrefix!, key);
      slivers.add(
        _SliverStickyHeader(
          key: headerKey == null ? null : ValueKey<(String, K)>(headerKey),
          header: ColoredBox(
            color: widget.headerBackgroundColor,
            child: Builder(builder: (context) => widget.groupHeaderBuilder(context, key)),
          ),
          sliver: SliverPadding(
            padding: widget.padding ?? EdgeInsets.zero,
            sliver: SliverList.separated(
              key: listKey == null ? null : ValueKey<(String, K)>(listKey),
              itemCount: items.length,
              itemBuilder: (context, i) => widget.itemBuilder(context, items[i], i),
              separatorBuilder: (context, _) => widget.itemSeparatorBuilder?.call(context) ?? const SizedBox.shrink(),
            ),
          ),
        ),
      );
      final groupSpacer = widget.groupSeparatorBuilder?.call(context, key);
      if (groupSpacer != null) slivers.add(SliverToBoxAdapter(child: groupSpacer));
    }
    return SliverMainAxisGroup(slivers: slivers);
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverHeaderDelegate({
    required this.headerBackgroundColor,
    required this.minHeight,
    required this.maxHeight,
    required this.child,
    this._snapConfiguration, // ignore: unused_element_parameter
    this._vsync, // ignore: unused_element_parameter
  });

  /// Background color of the header.
  final Color headerBackgroundColor;

  /// Minimum height of the header.
  final double minHeight;

  /// Maximum height of the header.
  final double maxHeight;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  final TickerProvider? _vsync;
  final FloatingHeaderSnapConfiguration? _snapConfiguration;

  @override
  Widget build(_, _, _) => ColoredBox(color: headerBackgroundColor, child: child);

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  TickerProvider? get vsync => _vsync;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration => _snapConfiguration;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    if (oldDelegate is! _SliverHeaderDelegate) return true;
    return headerBackgroundColor != oldDelegate.headerBackgroundColor ||
        minExtent != oldDelegate.minExtent ||
        maxExtent != oldDelegate.maxExtent ||
        child != oldDelegate.child ||
        vsync != oldDelegate.vsync ||
        snapConfiguration != oldDelegate.snapConfiguration;
  }
}

/// A sliver that renders a box [header] before a lazy [sliver], keeping the
/// header pinned to the viewport start while the [sliver] is visible and
/// handing the pinned position over to the next sibling once the [sliver]
/// scrolls off.
///
/// Self-contained hand-off implementation (no external sticky-header package),
/// adapted from the algorithm used by `flutter_sticky_header`. The [sliver]
/// child stays lazy, keeping offscreen items unbuilt.
class _SliverStickyHeader extends RenderObjectWidget {
  const _SliverStickyHeader({required this.header, required this.sliver, super.key});

  /// The box header rendered before [sliver].
  final Widget header;

  /// The lazy sliver rendered after [header].
  final Widget sliver;

  @override
  RenderObjectElement createElement() => _SliverStickyHeaderElement(this);

  @override
  _RenderSliverStickyHeader createRenderObject(BuildContext context) => _RenderSliverStickyHeader();
}

/// Element that wires a box header (slot 0) and a sliver child (slot 1) into a
/// single [_RenderSliverStickyHeader].
class _SliverStickyHeaderElement extends RenderObjectElement {
  _SliverStickyHeaderElement(_SliverStickyHeader super.widget);

  @override
  _SliverStickyHeader get widget => super.widget as _SliverStickyHeader;

  @override
  _RenderSliverStickyHeader get renderObject => super.renderObject as _RenderSliverStickyHeader;

  Element? _header;
  Element? _sliver;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_header != null) visitor(_header!);
    if (_sliver != null) visitor(_sliver!);
  }

  @override
  void forgetChild(Element child) {
    super.forgetChild(child);
    if (child == _header) _header = null;
    if (child == _sliver) _sliver = null;
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _header = updateChild(_header, widget.header, 0);
    _sliver = updateChild(_sliver, widget.sliver, 1);
  }

  @override
  void update(_SliverStickyHeader newWidget) {
    super.update(newWidget);
    _header = updateChild(_header, widget.header, 0);
    _sliver = updateChild(_sliver, widget.sliver, 1);
  }

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {
    if (slot == 0) renderObject.header = child as RenderBox;
    if (slot == 1) renderObject.child = child as RenderSliver;
  }

  @override
  void moveRenderObjectChild(RenderObject child, Object? oldSlot, Object? newSlot) {
    assert(false, 'moveRenderObjectChild is not supported by _SliverStickyHeader');
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    if (renderObject.header == child) renderObject.header = null;
    if (renderObject.child == child) renderObject.child = null;
  }
}

/// Render object for [_SliverStickyHeader].
///
/// Combines a [RenderBox] header and a [RenderSliver] child. The header is
/// pinned at the leading edge while the child sliver is visible and is pushed
/// out by the next section on hand-off. Adapted from `flutter_sticky_header`.
class _RenderSliverStickyHeader extends RenderSliver with RenderSliverHelpers {
  RenderBox? _header;
  RenderBox? get header => _header;
  set header(RenderBox? value) {
    if (_header != null) dropChild(_header!);
    _header = value;
    if (_header != null) adoptChild(_header!);
  }

  RenderSliver? _child;
  RenderSliver? get child => _child;
  set child(RenderSliver? value) {
    if (_child != null) dropChild(_child!);
    _child = value;
    if (_child != null) adoptChild(_child!);
  }

  double _headerExtent = 0;
  bool _isPinned = false;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData) child.parentData = SliverPhysicalParentData();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _header?.attach(owner);
    _child?.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    _header?.detach();
    _child?.detach();
  }

  @override
  void redepthChildren() {
    if (_header != null) redepthChild(_header!);
    if (_child != null) redepthChild(_child!);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (_header != null) visitor(_header!);
    if (_child != null) visitor(_child!);
  }

  double _computeHeaderExtent() {
    final header = _header;
    if (header == null) return 0;
    assert(header.hasSize, 'Header must be laid out before measuring its extent.');
    return switch (constraints.axis) {
      Axis.vertical => header.size.height,
      Axis.horizontal => header.size.width,
    };
  }

  @override
  void performLayout() {
    final header = _header;
    final child = _child;
    if (header == null && child == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    final axisDirection = applyGrowthDirectionToAxisDirection(constraints.axisDirection, constraints.growthDirection);

    if (header != null) {
      header.layout(constraints.asBoxConstraints(), parentUsesSize: true);
      _headerExtent = _computeHeaderExtent();
    }

    final headerExtent = _headerExtent;
    final headerPaintExtent = calculatePaintOffset(constraints, from: 0, to: headerExtent);
    final headerCacheExtent = calculateCacheOffset(constraints, from: 0, to: headerExtent);

    if (child == null) {
      geometry = SliverGeometry(
        scrollExtent: headerExtent,
        maxPaintExtent: headerExtent,
        paintExtent: headerPaintExtent,
        cacheExtent: headerCacheExtent,
        hitTestExtent: headerPaintExtent,
        hasVisualOverflow: headerExtent > constraints.remainingPaintExtent || constraints.scrollOffset > 0.0,
      );
    } else {
      child.layout(
        constraints.copyWith(
          scrollOffset: math.max(0, constraints.scrollOffset - headerExtent),
          cacheOrigin: math.min(0, constraints.cacheOrigin + headerExtent),
          overlap: math.min(headerExtent, constraints.scrollOffset) + constraints.overlap,
          remainingPaintExtent: constraints.remainingPaintExtent - headerPaintExtent,
          remainingCacheExtent: constraints.remainingCacheExtent - headerCacheExtent,
        ),
        parentUsesSize: true,
      );
      final childGeometry = child.geometry!;
      if (childGeometry.scrollOffsetCorrection != null) {
        geometry = SliverGeometry(scrollOffsetCorrection: childGeometry.scrollOffsetCorrection);
        return;
      }

      final paintExtent = math.min(
        headerPaintExtent + math.max(childGeometry.paintExtent, childGeometry.layoutExtent),
        constraints.remainingPaintExtent,
      );

      geometry = SliverGeometry(
        scrollExtent: headerExtent + childGeometry.scrollExtent,
        maxScrollObstructionExtent: headerPaintExtent,
        paintExtent: paintExtent,
        layoutExtent: math.min(headerPaintExtent + childGeometry.layoutExtent, paintExtent),
        cacheExtent: math.min(headerCacheExtent + childGeometry.cacheExtent, constraints.remainingCacheExtent),
        maxPaintExtent: headerExtent + childGeometry.maxPaintExtent,
        hitTestExtent: math.max(
          headerPaintExtent + childGeometry.paintExtent,
          headerPaintExtent + childGeometry.hitTestExtent,
        ),
        hasVisualOverflow: childGeometry.hasVisualOverflow,
      );

      final childParentData = child.parentData;
      if (childParentData is! SliverPhysicalParentData) return;
      childParentData.paintOffset = switch (axisDirection) {
        AxisDirection.up => Offset.zero,
        AxisDirection.left => Offset.zero,
        AxisDirection.right => Offset(calculatePaintOffset(constraints, from: 0, to: headerExtent), 0),
        AxisDirection.down => Offset(0, calculatePaintOffset(constraints, from: 0, to: headerExtent)),
      };
    }

    if (header != null) {
      final headerParentData = header.parentData! as SliverPhysicalParentData;
      final childScrollExtent = child?.geometry?.scrollExtent ?? 0;
      final headerPosition = math.min(constraints.overlap, childScrollExtent - constraints.scrollOffset);

      _isPinned =
          (constraints.scrollOffset + constraints.overlap) > 0.0 ||
          constraints.remainingPaintExtent == constraints.viewportMainAxisExtent;

      headerParentData.paintOffset = switch (axisDirection) {
        AxisDirection.up => Offset(0, geometry!.paintExtent - headerPosition - headerExtent),
        AxisDirection.left => Offset(geometry!.paintExtent - headerPosition - headerExtent, 0),
        AxisDirection.right => Offset(headerPosition, 0),
        AxisDirection.down => Offset(0, headerPosition),
      };
    }
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    final header = _header;
    final child = _child;
    final childScrollExtent = child?.geometry?.scrollExtent ?? 0;
    final headerPosition = math.min(constraints.overlap, childScrollExtent - constraints.scrollOffset);

    if (header != null && (mainAxisPosition - headerPosition) <= _headerExtent) {
      return hitTestBoxChild(
        BoxHitTestResult.wrap(result),
        header,
        mainAxisPosition: mainAxisPosition - childMainAxisPosition(header) - headerPosition,
        crossAxisPosition: crossAxisPosition,
      );
    } else if (child != null && child.geometry!.hitTestExtent > 0) {
      return child.hitTest(
        result,
        mainAxisPosition: mainAxisPosition - childMainAxisPosition(child),
        crossAxisPosition: crossAxisPosition,
      );
    }
    return false;
  }

  @override
  double childMainAxisPosition(RenderObject? child) {
    if (child == _header) return _isPinned ? 0 : -(constraints.scrollOffset + constraints.overlap);
    if (child == _child) return calculatePaintOffset(constraints, from: 0, to: _headerExtent);
    return 0;
  }

  @override
  double? childScrollOffset(RenderObject child) {
    assert(child.parent == this, 'childScrollOffset called for a non-child render object.');
    if (child == _child) return _headerExtent;
    return super.childScrollOffset(child);
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    final childParentData = child.parentData;
    if (childParentData is! SliverPhysicalParentData) return;
    childParentData.applyPaintTransform(transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!geometry!.visible) return;
    final child = _child;
    if (child != null && child.geometry!.visible) {
      final childParentData = child.parentData! as SliverPhysicalParentData;
      context.paintChild(child, offset + childParentData.paintOffset);
    }
    // The header is painted last so it stays on top of the child while stuck.
    final header = _header;
    if (header != null) {
      final headerParentData = header.parentData! as SliverPhysicalParentData;
      context.paintChild(header, offset + headerParentData.paintOffset);
    }
  }
}
