import 'package:example/src/common/widgets/component_preview_group.dart';
import 'package:example/src/common/widgets/preview_section.dart';
import 'package:ui/ui.dart';

const double _kInputsBreakpoint = 680;

/// Interactive SDK form, PIN, shake and color-selection examples.
class InputsPreview extends StatelessWidget {
  const InputsPreview({super.key});

  @override
  Widget build(BuildContext context) => const PreviewSection(title: 'UI Inputs', child: _InputFields());
}

class _InputFields extends StatefulWidget {
  const _InputFields();

  @override
  State<_InputFields> createState() => _InputFieldsState();
}

class _InputFieldsState extends State<_InputFields> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _password = TextEditingController();
  final _pin = TextEditingController();
  final _pinFocus = FocusNode();
  final _verified = ValueNotifier<bool>(false);
  final _failed = ValueNotifier<bool>(false);
  final _shake = UIShakeController();
  String _color = '#4d91ff';

  static const _colors = ['#4d91ff', '#52b788', '#f4a261', '#9b5de5'];

  @override
  void dispose() {
    _name.dispose();
    _password.dispose();
    _pin.dispose();
    _pinFocus.dispose();
    _verified.dispose();
    _failed.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiTheme = Theme.of(context).uiTheme;
    final spacing = uiTheme.size.offset;
    return Padding(
      padding: PreviewSection.contentPaddingOf(context),
      child: Form(
        key: _form,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final groups = <Widget>[
              ComponentPreviewGroup(
                title: 'Text fields',
                description: 'Validation, clear actions, and Form reset.',
                icon: Icons.text_fields_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: spacing.small,
                  children: [
                    UIShakeTransition(
                      controller: _shake,
                      child: UITextInput(
                        controller: _name,
                        labelText: 'Name',
                        backgroundColor: uiTheme.color.tertiaryBackground,
                        helperText: 'SDK validation and clear action',
                        validator: (value) => value == null || value.trim().isEmpty ? 'Enter a name' : null,
                      ),
                    ),
                    UITextInput(
                      initialValue: 'Initial value',
                      labelText: 'Internally owned text',
                      backgroundColor: uiTheme.color.tertiaryBackground,
                    ),
                    Wrap(
                      spacing: spacing.small,
                      children: [
                        TextButton(onPressed: () => _form.currentState!.reset(), child: const Text('Reset form')),
                        TextButton(
                          onPressed: () {
                            if (!_form.currentState!.validate()) _shake.shake();
                          },
                          child: const Text('Validate form'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ComponentPreviewGroup(
                title: 'Specialized fields',
                description: 'Search and password visibility.',
                icon: Icons.tune_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: spacing.small,
                  children: [
                    UISearchInput(
                      placeholder: 'Search; clear resets the query',
                      backgroundColor: uiTheme.color.tertiaryBackground,
                    ),
                    UIPasswordInput(
                      labelText: 'Password',
                      controller: _password,
                      backgroundColor: uiTheme.color.tertiaryBackground,
                    ),
                  ],
                ),
              ),
              ComponentPreviewGroup(
                title: 'PIN verification',
                description: 'Paste, verification feedback, and clearing.',
                icon: Icons.password_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: spacing.small,
                  children: [
                    const Text('PIN demo: 012345'),
                    UIPinInput(
                      label: 'Demo verification code',
                      length: 6,
                      separatorIndex: 3,
                      controller: _pin,
                      focusNode: _pinFocus,
                      verified: _verified,
                      failed: _failed,
                      onChanged: (_) {
                        _verified.value = false;
                        _failed.value = false;
                      },
                    ),
                    Wrap(
                      spacing: spacing.small,
                      children: [
                        TextButton(
                          onPressed: () {
                            _verified.value = false;
                            _failed.value = false;
                            if (_pin.text == '012345') {
                              _verified.value = true;
                            } else {
                              _failed.value = true;
                            }
                          },
                          child: const Text('Verify demo code'),
                        ),
                        TextButton(
                          onPressed: () {
                            _pin.clear();
                            _verified.value = false;
                            _failed.value = false;
                          },
                          child: const Text('Clear PIN'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ComponentPreviewGroup(
                title: 'Color selection',
                description: 'Horizontal swatches and automatic or explicit grid sizes.',
                icon: Icons.palette_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: spacing.small,
                  children: [
                    UIColorPicker.horizontal(
                      colors: _colors,
                      selectedColor: _colors.indexOf(_color),
                      backgroundColor: uiTheme.color.tertiaryBackground,
                      onChanged: (value) => setState(() => _color = value),
                    ),
                    Text('Selected color: $_color'),
                    const Text('Grid: automatic swatches / explicit 32 px'),
                    LayoutBuilder(
                      builder: (context, constraints) => Wrap(
                        spacing: spacing.regular,
                        runSpacing: spacing.regular,
                        children: [
                          for (final size in const <double?>[null, 32])
                            SizedBox(
                              width: ((constraints.maxWidth - spacing.regular) / 2).clamp(0.0, 200.0),
                              child: UIColorPicker(
                                colors: _colors,
                                bulletSize: size,
                                backgroundColor: uiTheme.color.tertiaryBackground,
                                selectedColor: _colors.indexOf(_color),
                                onChanged: (value) => setState(() => _color = value),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ];
            if (constraints.maxWidth < _kInputsBreakpoint) {
              return Column(spacing: spacing.regular, children: groups);
            }
            return Column(
              spacing: spacing.regular,
              children: [
                for (final offset in const [0, 2])
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: spacing.regular,
                    children: [
                      Expanded(child: groups[offset]),
                      Expanded(child: groups[offset + 1]),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
