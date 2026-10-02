/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 */

import 'dart:async';

import 'package:example/main.dart';
import 'package:example/src/common/widgets/preview_section.dart';
import 'package:flutter/foundation.dart';
import 'package:ui/ui.dart';

/// Demonstrates the package's built-in renderers and context-based commands.
///
/// Settings are local listenables, not application preferences. Every preview
/// closes after three seconds so blocking input cannot lock the catalog.
class OperationStatusPreview extends StatefulWidget {
  /// Creates the status preview sliver.
  const OperationStatusPreview({super.key});

  @override
  State<OperationStatusPreview> createState() => _OperationStatusPreviewState();
}

class _OperationStatusPreviewState extends State<OperationStatusPreview> {
  final _blocking = ValueNotifier<bool>(false);
  final _dismissOnTap = ValueNotifier<bool>(true);
  final _showMessage = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _blocking.dispose();
    _dismissOnTap.dispose();
    _showMessage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiTheme = Theme.of(context).uiTheme;
    return PreviewSection(
      title: 'Operation status',
      child: Padding(
        padding: PreviewSection.contentPaddingOf(context),
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: uiTheme.size.offset.regular,
            children: <Widget>[
              const Text('Show, replace, and dismiss a status. Previews close automatically after three seconds.'),
              ValueListenableBuilder<UIOperationStatusIndicatorStyle>(
                valueListenable: operationStatusIndicatorStyleSwitcher,
                builder: (context, indicatorStyle, child) => SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Rive indicator'),
                  value: indicatorStyle == UIOperationStatusIndicatorStyle.rive,
                  onChanged: (value) => operationStatusIndicatorStyleSwitcher.value = value
                      ? UIOperationStatusIndicatorStyle.rive
                      : UIOperationStatusIndicatorStyle.standard,
                ),
              ),
              for (final (label, notifier) in [
                ('Block interaction', _blocking),
                ('Tap to dismiss', _dismissOnTap),
                ('Show message', _showMessage),
              ])
                ValueListenableBuilder<bool>(
                  valueListenable: notifier,
                  builder: (context, value, child) => SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(label),
                    value: value,
                    onChanged: (value) => notifier.value = value,
                  ),
                ),
              _OperationStatusControls(blocking: _blocking, dismissOnTap: _dismissOnTap, showMessage: _showMessage),
            ],
          ),
        ),
      ),
    );
  }
}

class _OperationStatusControls extends StatefulWidget {
  const _OperationStatusControls({required this.blocking, required this.dismissOnTap, required this.showMessage});

  final ValueListenable<bool> blocking;
  final ValueListenable<bool> dismissOnTap;
  final ValueListenable<bool> showMessage;

  @override
  State<_OperationStatusControls> createState() => _OperationStatusControlsState();
}

class _OperationStatusControlsState extends State<_OperationStatusControls> {
  final _progress = ValueNotifier<double>(.25);
  final _backgroundTaps = ValueNotifier<int>(0);

  @override
  void dispose() {
    _progress.dispose();
    _backgroundTaps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiTheme = Theme.of(context).uiTheme;
    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: uiTheme.size.offset.regular,
        children: <Widget>[
          ValueListenableBuilder<double>(
            valueListenable: _progress,
            builder: (context, progress, child) => Row(
              children: <Widget>[
                const Text('Progress'),
                Expanded(
                  child: Slider(
                    value: progress,
                    onChanged: (value) {
                      _progress.value = value;
                      _show(.progress, progress: value);
                    },
                  ),
                ),
                Text('${(progress * 100).round()}%'),
              ],
            ),
          ),
          Wrap(
            spacing: uiTheme.size.offset.small,
            runSpacing: uiTheme.size.offset.small,
            children: <Widget>[
              OutlinedButton(onPressed: () => _show(.loading), child: const Text('Loading')),
              OutlinedButton(onPressed: () => _show(.success), child: const Text('Success')),
              OutlinedButton(onPressed: () => _show(.error), child: const Text('Error')),
              OutlinedButton(onPressed: () => _show(.info), child: const Text('Info')),
              OutlinedButton(onPressed: () => _show(.toast), child: const Text('Toast')),
              OutlinedButton(
                onPressed: () => _showToast(status: .success, message: 'Draft saved'),
                child: const Text('Toast success'),
              ),
              OutlinedButton(
                onPressed: () => _showToast(status: .error, message: 'Could not save draft'),
                child: const Text('Toast error'),
              ),
              OutlinedButton(onPressed: () => _show(.custom), child: const Text('Custom')),
              OutlinedButton(
                onPressed: () => unawaited(UIOperationStatusMessenger.of(context).dismiss()),
                child: const Text('Dismiss'),
              ),
            ],
          ),
          ValueListenableBuilder<int>(
            valueListenable: _backgroundTaps,
            builder: (context, taps, child) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(onPressed: () => _backgroundTaps.value++, child: Text('Background taps: $taps')),
            ),
          ),
        ],
      ),
    );
  }

  void _show(UIOperationStatus status, {double? progress}) {
    final messenger = UIOperationStatusMessenger.of(context);
    final blocking = widget.blocking.value;
    final dismissOnTap = widget.dismissOnTap.value;
    final progressValue = progress ?? _progress.value;
    String message(String value) => widget.showMessage.value ? value : '';
    const duration = Duration(seconds: 3);
    unawaited(switch (status) {
      UIOperationStatus.loading => messenger.show(
        status: message('Saving changes'),
        duration: duration,
        blockInteraction: blocking,
        dismissOnTap: dismissOnTap,
      ),
      UIOperationStatus.progress => messenger.showProgress(
        progressValue,
        status: message('Uploading ${(progressValue * 100).round()}%'),
        duration: duration,
        blockInteraction: blocking,
        dismissOnTap: dismissOnTap,
      ),
      UIOperationStatus.success => messenger.showSuccess(
        message('Changes saved'),
        duration: duration,
        blockInteraction: blocking,
        dismissOnTap: dismissOnTap,
      ),
      UIOperationStatus.error => messenger.showError(
        message('Could not save changes'),
        duration: duration,
        blockInteraction: blocking,
        dismissOnTap: dismissOnTap,
      ),
      UIOperationStatus.info => messenger.showInfo(
        message('Everything is up to date'),
        duration: duration,
        blockInteraction: blocking,
        dismissOnTap: dismissOnTap,
      ),
      UIOperationStatus.toast => messenger.showToast(
        'Draft saved',
        duration: duration,
        blockInteraction: blocking,
        dismissOnTap: dismissOnTap,
      ),
      UIOperationStatus.custom => messenger.showCustom(
        TextButton(onPressed: () => unawaited(messenger.dismiss()), child: const Text('Close custom content')),
        duration: duration,
        blockInteraction: blocking,
      ),
    });
  }

  void _showToast({required UIOperationStatus status, required String message}) {
    unawaited(
      UIOperationStatusMessenger.of(context).showToast(
        message,
        status: status,
        duration: const Duration(seconds: 3),
        blockInteraction: widget.blocking.value,
        dismissOnTap: widget.dismissOnTap.value,
      ),
    );
  }
}
