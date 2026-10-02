/*
 * Date: 04 June 2026
 */

/// This is the main library file for the UI package.
/// It exports all the necessary components and themes for the UI layer of the application.
library;

export 'package:flutter/material.dart';

export 'src/components/_components.dart' hide OptimizedClip, RenderPaddingExtended;
export 'src/components/avatar.dart';
export 'src/components/avatar_list.dart';
export 'src/components/buttons/animated_icon_button.dart';
export 'src/components/buttons/button.dart';
export 'src/components/buttons/clear_button.dart';
export 'src/components/charts/ui_pie_chart.dart';
export 'src/components/chips/chip.dart';
export 'src/components/chips/chip_blocked.dart';
export 'src/components/chips/chip_choice.dart';
export 'src/components/chips/chip_filter.dart';
export 'src/components/chips/chip_list_scrollable.dart';
export 'src/components/chips/chip_online.dart';
export 'src/components/flyout.dart';
export 'src/components/grouped_sliver_list.dart';
export 'src/components/inputs/password_input.dart';
export 'src/components/inputs/pin_input.dart';
export 'src/components/inputs/search_input.dart';
export 'src/components/inputs/text_field_counter_wrapper.dart';
export 'src/components/inputs/text_input.dart';
export 'src/components/inputs/text_input_formatter_price.dart';
export 'src/components/lazy_load_scrollview.dart';
export 'src/components/list_loader_indicator.dart';
export 'src/components/list_tile.dart';
export 'src/components/loading.dart';
export 'src/components/local_image.dart';
export 'src/components/operation_status_messenger.dart';
export 'src/components/pickers/color_picker.dart';
export 'src/components/pickers/date_picker.dart';
export 'src/components/pickers/date_time_picker_row.dart';
export 'src/components/rich_text_builder.dart';
export 'src/components/select.dart';
export 'src/components/select_date.dart';
export 'src/components/shake_transition.dart';
export 'src/components/showcase.dart';
export 'src/components/slidable.dart';
export 'src/components/text_read_more.dart';
export 'src/components/ui_scope.dart';
export 'src/localization/localization.dart';
export 'src/media/image_editor.dart';
export 'src/media/image_editor_screen.dart';
export 'src/media/image_source.dart';
export 'src/media/media_selection.dart';
export 'src/theme/theme.dart';
export 'src/ui.dart';
export 'src/utils/color_util.dart';
