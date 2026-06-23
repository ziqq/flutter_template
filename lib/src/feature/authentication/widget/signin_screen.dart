import 'dart:math' as math;

import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/localization/localization.dart';
import 'package:flutter_template_name/src/common/router/app_pages.dart';
import 'package:flutter_template_name/src/common/util/context_extension.dart';
import 'package:flutter_template_name/src/feature/authentication/controller/authentication_controller.dart';
import 'package:flutter_template_name/src/feature/authentication/model/sign_in_data.dart';
import 'package:flutter_template_name/src/feature/authentication/widget/authentication_scope.dart';

/// {@template signin_screen}
/// SignInScreen widget.
/// {@endtemplate}
class SignInScreen extends StatefulWidget {
  /// {@macro signin_screen}
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with _UsernamePasswordFormStateMixin {
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  late final Listenable _formChangedNotifier = Listenable.merge([_usernameController, _passwordController]);
  final _usernameFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(
      /// Allow only letters, numbers,
      /// and the following characters: @.-_+
      RegExp(r'\@|[A-Z]|[a-z]|[0-9]|\.|\-|\_|\+'),
    ),
    const _UsernameTextFormatter(),
  ];
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: math.max(16, (constraints.maxWidth - 620) / 2)),
              child: StateConsumer<AuthenticationController, AuthenticationState>(
                controller: _authenticationController,
                buildWhen: (previous, current) => previous != current,
                builder: (context, state, _) => Column(
                  children: <Widget>[
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(width: 50),
                          Text(
                            l10n.signInButton,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(height: 1),
                          ),
                          const SizedBox(width: 2),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: const Icon(Icons.casino),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.tightFor(width: 48, height: 48),
                              tooltip: l10n.authGeneratePasswordTooltip,
                              onPressed: state.isProcessing
                                  ? null
                                  : () {
                                      if (_obscurePassword) setState(() => _obscurePassword = false);
                                      generatePassword();
                                    },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      focusNode: _usernameFocusNode,
                      enabled: !state.isProcessing,
                      maxLines: 1,
                      minLines: 1,
                      controller: _usernameController,
                      autocorrect: false,
                      autofillHints: const <String>[AutofillHints.username, AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                      inputFormatters: _usernameFormatters,
                      decoration: InputDecoration(
                        labelText: l10n.emailLabel,
                        hintText: l10n.emailPlaceholder,
                        helperText: '',
                        helperMaxLines: 1,
                        errorText: _usernameError,
                        errorMaxLines: 1,
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      focusNode: _passwordFocusNode,
                      enabled: !state.isProcessing,
                      maxLines: 1,
                      minLines: 1,
                      controller: _passwordController,
                      autocorrect: false,
                      obscureText: _obscurePassword,
                      maxLength: Config.passwordMaxLength,
                      autofillHints: const <String>[AutofillHints.password],
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        labelText: l10n.passwordLabel,
                        hintText: l10n.passwordPlaceholder,
                        helperText: '',
                        helperMaxLines: 1,
                        errorText: _passwordError,
                        errorMaxLines: 1,
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 48,
                      child: AnimatedBuilder(
                        animation: _formChangedNotifier,
                        builder: (context, _) {
                          final formFilled =
                              _usernameController.text.length > 3 &&
                              _passwordController.text.length >= Config.passwordMinLength;
                          final signInCallback = !state.isProcessing && formFilled ? () => signIn(context) : null;
                          final signUpCallback = !state.isProcessing ? () => signUp(context) : null;
                          final key = ValueKey<int>(
                            (signInCallback == null ? 0 : 1 << 1) | (signUpCallback == null ? 0 : 1),
                          );
                          return _SignInScreen$Buttons(signIn: signInCallback, signUp: signUpCallback, key: key);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInScreen$Buttons extends StatelessWidget {
  const _SignInScreen$Buttons({required this.signIn, required this.signUp, super.key});

  final void Function()? signIn;
  final void Function()? signUp;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.max,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Expanded(
        flex: 2,
        child: ElevatedButton.icon(
          onPressed: signIn,
          icon: const Icon(Icons.login),
          label: Text(Localization.of(context).signInButton, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        flex: 1,
        child: FilledButton.tonalIcon(
          onPressed: signUp,
          icon: const Icon(Icons.person_add),
          label: Text(Localization.of(context).signUpButton, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    ],
  );
}

class _UsernameTextFormatter extends TextInputFormatter {
  const _UsernameTextFormatter();
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      TextEditingValue(text: newValue.text.toLowerCase(), selection: newValue.selection);
}

mixin _UsernamePasswordFormStateMixin on State<SignInScreen> {
  String? _usernameValidator(BuildContext context, String username) {
    final l10n = Localization.of(context);
    if (username.isEmpty) return l10n.authValidationEmailRequiredMessage;
    final length = switch (username.length) {
      0 => l10n.authValidationEmailRequiredMessage,
      < 3 => l10n.authValidationEmailInvalidMessage,
      _ => null,
    };
    if (length != null) return length;
    if (username.split('@').where((e) => e.isNotEmpty).length != 2) {
      return l10n.authValidationEmailInvalidMessage;
    }
    // If username passes all checks, return null
    return null;
  }

  String? _passwordValidator(BuildContext context, String password) {
    final l10n = Localization.of(context);
    const passwordMinLength = Config.passwordMinLength, passwordMaxLength = Config.passwordMaxLength;
    final length = switch (password.length) {
      0 => l10n.authValidationPasswordRequiredMessage,
      < passwordMinLength => l10n.authValidationPasswordTooShortMessage,
      > passwordMaxLength => l10n.authValidationPasswordTooLongMessage,
      _ => null,
    };
    if (length != null) return length;
    if (!password.contains(RegExp('[A-Z]'))) {
      return l10n.authValidationPasswordMissingUppercaseMessage;
    }
    if (!password.contains(RegExp('[a-z]'))) {
      return l10n.authValidationPasswordMissingLowercaseMessage;
    }
    // If password passes all checks, return null
    return null;
  }

  late final AuthenticationController _authenticationController;
  final TextEditingController _usernameController = TextEditingController(text: 'test@gmail.com');
  final TextEditingController _passwordController = TextEditingController();
  String? _usernameError, _passwordError;

  bool _validate(BuildContext context, String username, String password) {
    final usernameError = _usernameValidator(context, username);
    final passwordError = _passwordValidator(context, password);
    if (mounted) {
      setState(() {
        _usernameError = usernameError;
        _passwordError = passwordError;
      });
    }
    return usernameError == null && passwordError == null;
  }

  /// Signs in the user with the given username and password
  void signIn(BuildContext context) {
    final username = _usernameController.text;
    final password = _passwordController.text;
    if (!_validate(context, username, password)) return;
    FocusScope.of(context).unfocus();
    _authenticationController.signIn(SignInData(username: username, password: password));
  }

  /// Generates a random password
  void generatePassword() {
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const chars = lower + upper + numbers;
    final rnd = math.Random();
    final length = rnd.nextInt(Config.passwordMaxLength - Config.passwordMinLength) + Config.passwordMinLength;
    final password = <int>[
      lower.codeUnitAt(rnd.nextInt(lower.length)),
      upper.codeUnitAt(rnd.nextInt(upper.length)),
      numbers.codeUnitAt(rnd.nextInt(numbers.length)),
      for (var i = 0; i < length - 3; i++) chars.codeUnitAt(rnd.nextInt(chars.length)),
    ];
    _passwordController.text = String.fromCharCodes(password..shuffle());
  }

  /// Opens the sign up page in the browser
  void signUp(BuildContext context) {
    FocusScope.of(context).unfocus();
    // url_launcher.launchUrlString('...').ignore();
    // context.octopus.setState((state) => state..add(Routes.signup.node()));
    // context.octopus.push(Routes.signup);
    context.ext.navigator.push(const SignUpPage());
  }

  @override
  void initState() {
    super.initState();
    _authenticationController = AuthenticationScope.of(context);
    generatePassword();
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }
}
