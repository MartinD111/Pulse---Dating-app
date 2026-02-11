import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/onboarding_screen.dart';
import '../features/auth/data/auth_repository.dart';
import '../shared/ui/gradient_scaffold.dart';
import '../features/matches/data/match_repository.dart';
import '../features/profile/presentation/profile_detail_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

// Placeholder for Home (Dashboard)
import '../features/dashboard/presentation/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state to trigger redirects
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const GradientScaffold(child: LoginScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) =>
            const GradientScaffold(child: OnboardingScreen()),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const GradientScaffold(child: HomeScreen()),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) {
          final match = state.extra as MatchProfile;
          return ProfileDetailScreen(match: match);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) =>
            const GradientScaffold(child: SettingsScreen()),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authState != null;
      final isOnboarded = authState?.isOnboarded ?? false;
      final isLoginRoute = state.uri.toString() == '/login';
      final isOnboardingRoute = state.uri.toString() == '/onboarding';

      if (!isLoggedIn) {
        return isLoginRoute ? null : '/login';
      }

      if (!isOnboarded) {
        return isOnboardingRoute ? null : '/onboarding';
      }

      if (isLoggedIn && isOnboarded && (isLoginRoute || isOnboardingRoute)) {
        return '/';
      }

      return null;
    },
  );
});
