import 'package:flutter/material.dart';

// ── Auth ──────────────────────────────────────────────────────
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen2.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forget_password_screen.dart';

// ── Onboarding ────────────────────────────────────────────────
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';

// ── Layouts ───────────────────────────────────────────────────
import '../../layout/main_layout.dart';
import '../../layout/coach_layout.dart';

// ── Become a Coach ────────────────────────────────────────────
import '../../features/become_coach/data/model/become_coach_models.dart';
import '../../features/become_coach/presentation/screens/coach_info_screen.dart';
import '../../features/become_coach/presentation/screens/coach_specialties_screen.dart';
import '../../features/become_coach/presentation/screens/coach_days_screen.dart';
import '../../features/become_coach/presentation/screens/coach_certifications_screen.dart';

// ── Settings / Support ────────────────────────────────────────
import '../../features/settings/presentation/screens/support_screen.dart';
import '../../features/settings/presentation/screens/safety_moderation_screen.dart';

// ── Reviews ───────────────────────────────────────────────────
import '../../features/reviews/presentation/screens/all_reviews_screen.dart';

// ── Guest ─────────────────────────────────────────────────────
import '../../features/home/presentation/screens/guest_homescreen.dart';

class UserTypeArgs {
  final String userType;
  const UserTypeArgs(this.userType);
}

class CoachInfoArgs {
  final String email;
  final String password;

  const CoachInfoArgs({
    required this.email,
    required this.password,
  });
}

class CoachRequestArgs {
  final CompleteCoachOnboardingRequest request;

  const CoachRequestArgs(this.request);
}

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String welcome2 = '/welcome2';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String clientHome = '/client';
  static const String coachHome = '/coach';
  static const String becomeCoachInfo = '/become-coach/info';
  static const String becomeCoachSpecialties = '/become-coach/specialties';
  static const String becomeCoachDays = '/become-coach/days';
  static const String becomeCoachCertifications = '/become-coach/certifications';
  static const String support = '/support';
  static const String safety = '/safety';
  static const String allReviews = '/reviews';
  static const String guestHome = '/guest';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case splash:
        return _fade(const SplashScreen());

      case onboarding:
        return _slide(const OnboardingScreen());

      case welcome:
        return _build(const WelcomeScreen());

      case welcome2:
        final userType = args is UserTypeArgs ? args.userType : 'trainee';
        return _build(WelcomeScreen2(userType: userType));

      case login:
        final userType = args is UserTypeArgs ? args.userType : 'trainee';
        return _build(LoginScreen(userType: userType));

      case register:
        final userType = args is UserTypeArgs ? args.userType : 'trainee';
        return _build(RegisterScreen(userType: userType));

      case forgotPassword:
        return _build(const ForgotPasswordScreen());

      case clientHome:
        return _build(const MainLayout());

      case coachHome:
        return _build(const CoachMainLayout());

      case becomeCoachInfo:
        if (args is CoachInfoArgs) {
          return _build(
            CoachInfoScreen(
              email: args.email,
              password: args.password,
            ),
          );
        }
        return _build(
          const _RouteArgsErrorScreen(
            message: 'CoachInfoScreen requires CoachInfoArgs(email, password)',
          ),
        );

      case becomeCoachSpecialties:
        if (args is CoachRequestArgs) {
          return _build(
            CoachSpecialtiesScreen(request: args.request),
          );
        }
        return _build(
          const _RouteArgsErrorScreen(
            message: 'CoachSpecialtiesScreen requires CoachRequestArgs(request)',
          ),
        );

      case becomeCoachDays:
        if (args is CoachRequestArgs) {
          return _build(
            CoachDaysScreen(request: args.request),
          );
        }
        return _build(
          const _RouteArgsErrorScreen(
            message: 'CoachDaysScreen requires CoachRequestArgs(request)',
          ),
        );

      case becomeCoachCertifications:
        if (args is CoachRequestArgs) {
          return _build(
            CoachCertificationsScreen(request: args.request),
          );
        }
        return _build(
          const _RouteArgsErrorScreen(
            message: 'CoachCertificationsScreen requires CoachRequestArgs(request)',
          ),
        );

      case support:
        final userType = args is UserTypeArgs ? args.userType : 'client';
        return _build(SupportScreen(userType: userType));

      case safety:
        final userType = args is UserTypeArgs ? args.userType : 'client';
        return _build(SafetyModerationScreen(userType: userType));

      case allReviews:
        return _build(const AllReviewsScreen());

      case guestHome:
        return _build(GuestHomeScreen(onAuthRequired: () {}));

      default:
        return _build(_NotFoundScreen(routeName: settings.name ?? '?'));
    }
  }

  static Future<T?> pushNamed<T>(
      BuildContext context,
      String routeName, {
        Object? args,
      }) =>
      Navigator.pushNamed<T>(context, routeName, arguments: args);

  static Future<T?> pushReplacementNamed<T, TO>(
      BuildContext context,
      String routeName, {
        Object? args,
      }) =>
      Navigator.pushReplacementNamed<T, TO>(
        context,
        routeName,
        arguments: args,
      );

  static Future<T?> pushNamedAndClearStack<T>(
      BuildContext context,
      String routeName, {
        Object? args,
      }) =>
      Navigator.pushNamedAndRemoveUntil<T>(
        context,
        routeName,
            (route) => false,
        arguments: args,
      );

  static void pop<T>(BuildContext context, [T? result]) =>
      Navigator.pop<T>(context, result);

  static void popUntil(BuildContext context, String routeName) =>
      Navigator.popUntil(context, ModalRoute.withName(routeName));

  static MaterialPageRoute<dynamic> _build(Widget page) =>
      MaterialPageRoute(builder: (_) => page);

  static PageRouteBuilder<dynamic> _fade(Widget page) =>
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      );

  static PageRouteBuilder<dynamic> _slide(Widget page) =>
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
          ),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      );
}

class _RouteArgsErrorScreen extends StatelessWidget {
  final String message;

  const _RouteArgsErrorScreen({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Arguments Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  final String routeName;

  const _NotFoundScreen({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Route "$routeName" not found.',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}