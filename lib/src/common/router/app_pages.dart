import 'package:flutter/widgets.dart';
import 'package:flutter_template_name/src/common/router/page.dart';
import 'package:flutter_template_name/src/feature/authentication/widget/signup_screen.dart';
import 'package:flutter_template_name/src/feature/developer/developer_screens.dart';
import 'package:flutter_template_name/src/feature/home/widget/home_screen.dart';

/// SignUp page.
final class SignUpPage extends AppPage {
  const SignUpPage()
    : super(arguments: null, name: 'sign-up', child: const SignUpScreen(), key: const ValueKey<String>('sign_up'));
}

/// Developer page.
final class DeveloperPage extends AppPage {
  const DeveloperPage()
    : super(
        arguments: null,
        name: 'developer',
        child: const DeveloperScreen(),
        key: const ValueKey<String>('developer'),
      );
}

/// Developer info page.
final class DeveloperInfoPage extends AppPage {
  const DeveloperInfoPage()
    : super(
        arguments: null,
        name: 'developer-info',
        child: const DeveloperInfoScreen(),
        key: const ValueKey<String>('developer_info'),
      );
}

/// Home page.
final class HomePage extends AppPage {
  const HomePage()
    : super(arguments: null, name: 'home', child: const HomeScreen(), key: const ValueKey<String>('home'));
}

/// Application log viewer.
final class DeveloperLogsScreenPage extends AppPage {
  const DeveloperLogsScreenPage()
    : super(
        arguments: null,
        name: 'developer-logs',
        child: const LogsScreen(),
        key: const ValueKey<String>('developer_logs'),
      );
}

/// Timings from the current application launch.
final class DeveloperInitializationStatsPage extends AppPage {
  const DeveloperInitializationStatsPage()
    : super(
        arguments: null,
        name: 'developer-initialization-stats',
        child: const DeveloperInitializationStatsScreen(),
        key: const ValueKey<String>('developer_initialization_stats'),
      );
}
