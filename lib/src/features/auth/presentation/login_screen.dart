import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/ui/primary_button.dart';
import '../data/auth_repository.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.heartPulse, size: 80, color: Colors.white),
            const SizedBox(height: 10),
            Text("Pulse",
                style: GoogleFonts.outfit(
                    fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            PrimaryButton(
                text: "Login with Email",
                onPressed: () async {
                  await ref
                      .read(authStateProvider.notifier)
                      .login("test@example.com", "password");
                  // Router redirect will handle navigation
                }),
            const SizedBox(height: 15),
            PrimaryButton(
                text: "Continue with Google",
                icon: LucideIcons.chrome,
                isSecondary: true,
                onPressed: () {
                  // TODO: Implement Google Sign In
                }),
          ],
        ),
      ),
    );
  }
}
