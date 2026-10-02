import 'package:example/src/widgets/accessibility_preview.dart';
import 'package:example/src/widgets/animations_preview.dart';
import 'package:example/src/widgets/avatar_list_preview.dart';
import 'package:example/src/widgets/avatar_preview.dart';
import 'package:example/src/widgets/buttons_preview.dart';
import 'package:example/src/widgets/charts_preview.dart';
import 'package:example/src/widgets/chips_preview.dart';
import 'package:example/src/widgets/colors_preview.dart';
import 'package:example/src/widgets/feedback_preview.dart';
import 'package:example/src/widgets/forms_preview.dart';
import 'package:example/src/widgets/grouped_lists_preview.dart';
import 'package:example/src/widgets/icons_preview.dart';
import 'package:example/src/widgets/inputs_preview.dart';
import 'package:example/src/widgets/list_states_preview.dart';
import 'package:example/src/widgets/media_preview.dart';
import 'package:example/src/widgets/operation_status_preview.dart';
import 'package:example/src/widgets/operations_preview.dart';
import 'package:example/src/widgets/overlays_preview.dart';
import 'package:example/src/widgets/pickers_preview.dart';
import 'package:example/src/widgets/price_preview.dart';
import 'package:example/src/widgets/selection_preview.dart';
import 'package:example/src/widgets/sheets_preview.dart';
import 'package:example/src/widgets/text_content_preview.dart';
import 'package:example/src/widgets/tokens_preview.dart';
import 'package:example/src/widgets/typography_preview.dart';
import 'package:ui/ui.dart';

/// A capability available in the template's public UI package.
enum CatalogCategory {
  media('media', 'Media', 'Typed images, avatars, crop data, and fallbacks.', Icons.image_outlined),
  inputs('inputs', 'Inputs', 'Text, search, password, PIN, price, and color selection.', Icons.text_fields_rounded),
  feedback(
    'feedback',
    'Feedback',
    'Scoped loading, operation status, progress, toast, and Rive.',
    Icons.hourglass_top_rounded,
  ),
  buttons(
    'buttons',
    'Buttons',
    'Primary, secondary, disabled, loading, and icon actions.',
    Icons.smart_button_outlined,
  ),
  typography('typography', 'Typography', 'Shared text styles and hierarchy.', Icons.title_rounded),
  icons('icons', 'Icons', 'Render-object icons and optional configured icon fonts.', Icons.interests_outlined),
  lists('lists', 'Lists', 'List rows, switches, flyouts, and sticky grouped scrolling.', Icons.view_list_outlined),
  colors('colors', 'Colors', 'Semantic light and dark palettes.', Icons.palette_outlined),
  tokens('tokens', 'Tokens', 'Spacing, corners, and component sizing.', Icons.straighten_rounded),
  chips('chips', 'Chips', 'Selection, filters, statuses, and horizontal collections.', Icons.label_outline),
  pickers('pickers', 'Pickers', 'SDK dates, date ranges, and duration selection.', Icons.date_range_outlined),
  charts('charts', 'Charts', 'Interactive segments, tooltips, and representative data.', Icons.pie_chart_outline),
  sheets(
    'sheets',
    'Sheets',
    'Snapping, keyboard forms, pinned actions, and typed results.',
    Icons.vertical_align_bottom,
  ),
  motion('motion', 'Motion', 'Press, shake, notifications, expansion, and animation curves.', Icons.animation),
  overlays('overlays', 'Overlays', 'Anchored flyouts and repeatable onboarding sequences.', Icons.layers_outlined),
  accessibility(
    'accessibility',
    'Accessibility',
    'Text scale, RTL, long labels, and keyboard focus.',
    Icons.accessibility_new,
  );

  const CatalogCategory(this.id, this.title, this.description, this.icon);

  /// Stable identity for route names, keys, and diagnostic labels.
  final String id;

  final String title;
  final String description;
  final IconData icon;
}

/// Registers only previews backed by components available in this template.
extension CatalogPreviewRegistry on CatalogCategory {
  List<Widget> buildPreviews(BuildContext context) => switch (this) {
    CatalogCategory.media => const [AvatarPreview(), AvatarListPreview(), MediaPreview()],
    CatalogCategory.inputs => const [InputsPreview(), SelectionPreview(), PricePreview()],
    CatalogCategory.feedback => const [FeedbackPreview(), OperationsPreview(), OperationStatusPreview()],
    CatalogCategory.buttons => const [UIButtonsPreview()],
    CatalogCategory.typography => const [TypographyPreview(), TextContentPreview()],
    CatalogCategory.icons => [
      const UIIconsPreview$LeafRenderObject(),
      if (UIIcons.values.isNotEmpty) const UIIconsPreview.font(),
    ],
    CatalogCategory.lists => const [FormsPreview(), GroupedListsPreview(), ListStatesPreview()],
    CatalogCategory.colors => const [UIColorsPreview()],
    CatalogCategory.tokens => const [UITokensPreview()],
    CatalogCategory.chips => const [ChipsPreview()],
    CatalogCategory.pickers => const [PickersPreview()],
    CatalogCategory.charts => const [UIChartsPreview()],
    CatalogCategory.sheets => const [SheetsPreview()],
    CatalogCategory.motion => const [AnimationsPreview()],
    CatalogCategory.overlays => const [UIOverlaysPreview()],
    CatalogCategory.accessibility => const [AccessibilityPreview()],
  };
}
