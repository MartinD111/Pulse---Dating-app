import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/registration_flow.dart';

// ... (imports)

      GoRoute(
        path: '/onboarding',
        builder: (context, state) =>
            const RegistrationFlow(),
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
