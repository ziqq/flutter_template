import 'package:ui/ui.dart';

/// An SDK calendar with caller-owned single-date or date-range selection.
class UIDatePicker extends StatefulWidget {
  const UIDatePicker({
    required this.onChange,
    this.selectedDate,
    this.minDate,
    this.maxDate,
    this.backgroundColor,
    super.key,
  }) : selectedRange = null,
       onChangeRange = null;
  const UIDatePicker.inline({
    required this.onChange,
    this.selectedDate,
    this.minDate,
    this.maxDate,
    this.backgroundColor,
    super.key,
  }) : selectedRange = null,
       onChangeRange = null;
  const UIDatePicker.range({
    required this.onChangeRange,
    this.selectedRange,
    this.minDate,
    this.maxDate,
    this.backgroundColor,
    super.key,
  }) : selectedDate = null,
       onChange = null;

  final DateTime? selectedDate;
  final DateTimeRange? selectedRange;
  final DateTime? minDate;
  final DateTime? maxDate;
  final Color? backgroundColor;
  final ValueChanged<DateTime?>? onChange;
  final ValueChanged<DateTimeRange?>? onChangeRange;

  @override
  State<UIDatePicker> createState() => _UIDatePickerState();
}

class _UIDatePickerState extends State<UIDatePicker> {
  DateTime? _rangeStart;

  @override
  void didUpdateWidget(covariant UIDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.onChangeRange == null) != (widget.onChangeRange == null) ||
        oldWidget.selectedRange != widget.selectedRange)
      _rangeStart = null;
  }

  @override
  Widget build(BuildContext context) {
    final first = DateUtils.dateOnly(widget.minDate ?? DateTime(1900));
    final last = DateUtils.dateOnly(widget.maxDate ?? DateTime(2100, 12, 31));
    assert(!last.isBefore(first), 'minDate must not follow maxDate.');
    var selected = _rangeStart ?? widget.selectedRange?.end ?? widget.selectedDate ?? DateTime.now();
    selected = selected.isBefore(first)
        ? first
        : selected.isAfter(last)
        ? last
        : selected;
    return ColoredBox(
      color: widget.backgroundColor ?? Theme.of(context).uiTheme.color.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.onChangeRange != null)
            Padding(
              padding: EdgeInsets.all(Theme.of(context).uiTheme.size.offset.small),
              child: Text(
                _rangeStart == null
                    ? widget.selectedRange == null
                          ? MaterialLocalizations.of(context).dateRangeStartLabel
                          : '${MaterialLocalizations.of(context).formatMediumDate(widget.selectedRange!.start)} – ${MaterialLocalizations.of(context).formatMediumDate(widget.selectedRange!.end)}'
                    : MaterialLocalizations.of(context).dateRangeEndLabel,
              ),
            ),
          CalendarDatePicker(
            key: ValueKey<(DateTime, DateTime, DateTime)>((selected, first, last)),
            initialDate: selected,
            firstDate: first,
            lastDate: last,
            onDateChanged: (date) {
              if (widget.onChangeRange == null) {
                widget.onChange?.call(date);
              } else if (_rangeStart == null) {
                setState(() => _rangeStart = date);
              } else {
                final start = _rangeStart!;
                setState(() => _rangeStart = null);
                widget.onChangeRange?.call(
                  DateTimeRange(start: date.isBefore(start) ? date : start, end: date.isBefore(start) ? start : date),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
