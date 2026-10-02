import 'package:example/src/common/widgets/component_preview_group.dart';
import 'package:example/src/common/widgets/preview_section.dart';
import 'package:ui/ui.dart';

/// SDK dates and durations without application scheduling dependencies.
class PickersPreview extends StatefulWidget {
  const PickersPreview({super.key});

  @override
  State<PickersPreview> createState() => _PickersPreviewState();
}

class _PickersPreviewState extends State<PickersPreview> {
  DateTime? _date;
  DateTimeRange? _range;
  int _minutes = 45;
  int _rangeRevision = 0;

  @override
  Widget build(BuildContext context) => PreviewSection(
    title: 'Date and duration',
    child: Padding(
      padding: PreviewSection.contentPaddingOf(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          ComponentPreviewGroup(
            title: 'Confirmed selection',
            description: 'Cancel leaves the caller-owned value unchanged.',
            child: Column(
              spacing: 16,
              children: [
                UISelectDate(value: _date, onChange: (date) => setState(() => _date = date)),
                UIDateTimePickerRow(value: _date, onChanged: (date) => setState(() => _date = date)),
                UIDateTimePickerRow.duration(
                  timeDuration: _minutes,
                  onChangedTimeDuration: (minutes) => setState(() => _minutes = minutes),
                ),
              ],
            ),
          ),
          ComponentPreviewGroup(
            title: 'Inline calendar',
            child: UIDatePicker.inline(selectedDate: _date, onChange: (date) => setState(() => _date = date)),
          ),
          ComponentPreviewGroup(
            title: 'Date range',
            description: 'Choose start and end in two taps. Reversed endpoints are ordered automatically.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UIDatePicker.range(
                  key: ValueKey<int>(_rangeRevision),
                  selectedRange: _range,
                  onChangeRange: (range) => setState(() => _range = range),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _date = null;
                    _range = null;
                    _rangeRevision++;
                  }),
                  child: const Text('Clear dates'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
