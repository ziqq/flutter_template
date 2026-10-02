import 'package:ui/ui.dart';

/// A date form field whose confirmed value belongs to its caller.
class UISelectDate extends FormField<DateTime> {
  UISelectDate({
    this.value,
    DateTime? minDate,
    DateTime? maxDate,
    String? labelText,
    this.onChange,
    super.validator,
    super.onSaved,
    super.onReset,
    super.enabled,
    super.autovalidateMode,
    super.key,
  }) : super(
         initialValue: value,
         builder: (field) =>
             _DateField(field: field, minDate: minDate, maxDate: maxDate, labelText: labelText, onChange: onChange),
       );
  final DateTime? value;
  final ValueChanged<DateTime?>? onChange;

  @override
  FormFieldState<DateTime> createState() => _UISelectDateState();
}

class _UISelectDateState extends FormFieldState<DateTime> {
  @override
  UISelectDate get widget => super.widget as UISelectDate;

  @override
  void didUpdateWidget(covariant UISelectDate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) setValue(widget.value);
  }

  @override
  void reset() {
    super.reset();
    widget.onChange?.call(value);
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.field, this.minDate, this.maxDate, this.labelText, this.onChange});
  final FormFieldState<DateTime> field;
  final DateTime? minDate;
  final DateTime? maxDate;
  final String? labelText;
  final ValueChanged<DateTime?>? onChange;

  Future<void> _pick(BuildContext context) async {
    final first = minDate ?? DateTime(1900);
    final last = maxDate ?? DateTime(2100, 12, 31);
    var initial = field.value ?? DateTime.now();
    initial = initial.isBefore(first)
        ? first
        : initial.isAfter(last)
        ? last
        : initial;
    final result = await showDatePicker(context: context, initialDate: initial, firstDate: first, lastDate: last);
    if (!field.mounted || !field.widget.enabled || result == null) return;
    field.didChange(result);
    (field.widget as UISelectDate).onChange?.call(result);
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: InkWell(
          onTap: field.widget.enabled ? () => _pick(context) : null,
          borderRadius: UIBorderRadius.regular(context),
          child: InputDecorator(
            isEmpty: field.value == null,
            decoration: InputDecoration(
              enabled: field.widget.enabled,
              labelText: labelText ?? UILocalizations.of(context).labelDate,
              errorText: field.errorText,
              border: OutlineInputBorder(borderRadius: UIBorderRadius.regular(context)),
              suffixIcon: const Icon(Icons.calendar_today_outlined),
            ),
            child: Text(field.value == null ? '' : MaterialLocalizations.of(context).formatMediumDate(field.value!)),
          ),
        ),
      ),
      if (field.value != null)
        IconButton(
          tooltip: UILocalizations.of(context).clearLabel,
          icon: const Icon(Icons.clear),
          onPressed: field.widget.enabled
              ? () {
                  field.didChange(null);
                  onChange?.call(null);
                }
              : null,
        ),
    ],
  );
}
