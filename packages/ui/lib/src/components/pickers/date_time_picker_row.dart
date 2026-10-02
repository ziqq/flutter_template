import 'package:flutter/cupertino.dart';
import 'package:ui/ui.dart';

/// A compact SDK date/time or duration selection row.
class UIDateTimePickerRow extends StatelessWidget {
  const UIDateTimePickerRow({
    required this.onChanged,
    this.value,
    this.prefix,
    this.minDate,
    this.maxDate,
    this.mode = CupertinoDatePickerMode.dateAndTime,
    this.enabled = true,
    super.key,
  }) : timeDuration = null,
       onChangedTimeDuration = null;

  const UIDateTimePickerRow.duration({
    required this.onChangedTimeDuration,
    this.timeDuration,
    this.prefix,
    this.enabled = true,
    super.key,
  }) : value = null,
       onChanged = null,
       minDate = null,
       maxDate = null,
       mode = CupertinoDatePickerMode.dateAndTime,
       assert(timeDuration == null || timeDuration >= 0 && timeDuration < 1440, 'Duration must be within one day.');

  final Widget? prefix;
  final DateTime? value;
  final DateTime? minDate;
  final DateTime? maxDate;
  final CupertinoDatePickerMode mode;
  final ValueChanged<DateTime>? onChanged;
  final int? timeDuration;
  final ValueChanged<int>? onChangedTimeDuration;
  final bool enabled;

  Future<void> _pick(BuildContext context) async {
    var date = value ?? DateTime.now();
    if (minDate != null && date.isBefore(minDate!)) date = minDate!;
    if (maxDate != null && date.isAfter(maxDate!)) date = maxDate!;
    var duration = Duration(minutes: timeDuration ?? 15);
    final result = await UI.showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      builder: (context) => SizedBox(
        height: 300,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(UILocalizations.of(context).cancelButton),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(UILocalizations.of(context).doneButton),
                ),
              ],
            ),
            Expanded(
              child: onChangedTimeDuration != null
                  ? CupertinoTimerPicker(
                      initialTimerDuration: duration,
                      mode: CupertinoTimerPickerMode.hm,
                      onTimerDurationChanged: (next) => duration = next,
                    )
                  : CupertinoDatePicker(
                      initialDateTime: date,
                      minimumDate: minDate,
                      maximumDate: maxDate,
                      mode: mode,
                      onDateTimeChanged: (next) => date = next,
                    ),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || result != true) return;
    final current = context.widget as UIDateTimePickerRow;
    if (!current.enabled ||
        current.mode != mode ||
        (current.onChangedTimeDuration == null) != (onChangedTimeDuration == null))
      return;
    if (current.onChangedTimeDuration != null) {
      current.onChangedTimeDuration!(duration.inMinutes);
    } else {
      current.onChanged?.call(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = UILocalizations.of(context);
    final duration = Duration(minutes: timeDuration ?? 15);
    final date = value;
    return UIListTile(
      title: prefix ?? Text(onChangedTimeDuration != null ? strings.labelDuration : strings.labelDate),
      trailing: Text(
        onChangedTimeDuration != null
            ? '${duration.inHours} ${strings.hourShortLabel} ${duration.inMinutes.remainder(60)} ${strings.minuteShortLabel}'
            : date == null
            ? strings.textNoValue
            : mode == CupertinoDatePickerMode.time
            ? MaterialLocalizations.of(context).formatTimeOfDay(
                TimeOfDay.fromDateTime(date),
                alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
              )
            : mode == CupertinoDatePickerMode.dateAndTime
            ? '${MaterialLocalizations.of(context).formatMediumDate(date)} ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(date), alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context))}'
            : MaterialLocalizations.of(context).formatMediumDate(date),
      ),
      enabled: enabled,
      onTap: enabled ? () => _pick(context) : null,
    );
  }
}
