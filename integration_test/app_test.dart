// Autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'dart:io' as io;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/app.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/feature/authentication/model/user.dart';
import 'package:flutter_template_name/src/feature/authentication/widget/authentication_scope.dart';
import 'package:flutter_template_name/src/feature/initialization/data/initialization.dart';
import 'package:flutter_template_name/src/feature/settings/widget/settings_scope.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';

import '../test/src/util/mocks/mock_service.dart';
import '../test/src/util/mocks/setup_firebase_messaging_mocks.dart';
import 'util/screen_builder.dart';
import 'util/tester_extension.dart';

final IntegrationTestWidgetsFlutterBinding $binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

void main() {
  setUpAll(() async {
    // Ensure the binding is initialized.
    $binding; // ignore: unnecessary_statements
    // io.Directory('integration_test/screenshots').createSync(recursive: true);

    // Initialize Firebase
    setupFirebaseMessagingMocks();
    await Firebase.initializeApp();
  });

  group('end2end -', () {
    group('Expired session startup -', () {
      late Dependencies mockDependencies;

      tearDown(() async {
        await $disposeApp();

        if ($binding.inTest) await $binding.setSurfaceSize(null);
      });

      testWidgets('Shows onboarding screen after expired session restore', (tester) async {
        await tester.pumpWidget(
          screenBuilder(
            () => const AuthenticationScope(child: SizedBox.shrink()),
            user: MockService.user.authenticated,
            init: (dependencies) {
              mockDependencies = dependencies;
              when(
                mockDependencies.authenticationRepository.restore(),
              ).thenAnswer((_) async => const User.unauthenticated());
            },
          ),
        );

        expect(mockDependencies.authenticationController.state.user.isAuthenticated, isTrue);

        await mockDependencies.authenticationController.restore();
        await tester.pump();

        expect(mockDependencies.authenticationController.state.user.isAuthenticated, isFalse);

        final signInButton = find.byKey(const ValueKey<String>('onboarding_sign_in_button'));

        expect(signInButton, findsOneWidget);
        verify(mockDependencies.authenticationRepository.restore()).called(1);
      });
    });

    group('Fake authentication -', () {
      const locales = /* Locales.values */ [Config.locale];
      // const user = User.unauthenticated();
      const screenSizes = <Size>[
        Size(2250, 1440), // Large screen
        Size(768, 1024), // Tablet
        Size(430, 932), // Large phone
        Size(320, 640), // Small phone
      ];

      late Dependencies mockDependencies; // ignore: unused_local_variable
      // late Widget app;

      setUp(() async {
        // mockDependencies = $initializeFakeDependencies(user: user);
        // app = mockDependencies.inject(child: const SettingsScope(child: App()));
      });

      tearDown(() async {
        await $disposeApp();

        // Reset the binding to its default state
        if ($binding.inTest) await $binding.setSurfaceSize(null);
      });

      testWidgets('Unautorized flow', (tester) async {
        for (final size in screenSizes) {
          for (final locale in locales) {
            await tester.pumpWidget(
              screenBuilder(
                () => const SettingsScope(child: App()),
                init: (dependenceies) => mockDependencies = dependenceies,
                locale: locale,
              ),
            );

            await tester.setSize(size);

            // Allow UI to settle after size and locale changes
            await tester.pupmTime();

            // Make screenshot with apropriate name
            final screenshotData = await tester.takeScreenshot();
            final screenshotFile = io.File(
              'integration_test/screenshots'
              'AuthPhoneScreen'
              '_'
              '${size.width.toStringAsFixed(0)}x${size.height.toStringAsFixed(0)}'
              '_'
              '${locale.languageCode}'
              '.png',
            );
            screenshotFile.writeAsBytesSync(screenshotData); // ignore: cascade_invocations
            await tester.pump(const Duration(seconds: 1));
          }
        }

        // Whait a bit and close app
        await Future<void>.delayed(const Duration(seconds: 5));
      });
    });
  });
}
