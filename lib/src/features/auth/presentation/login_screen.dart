import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/ui/primary_button.dart';
import '../data/auth_repository.dart';
import 'radar_background.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: RadarBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.heartPulse,
                    size: 80, color: Colors.white),
                const SizedBox(height: 10),
                Text("Pulse",
                    style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 50),
                PrimaryButton(
                    text: "Login with Email",
                    onPressed: () async {
                      try {
                        await ref
                            .read(authStateProvider.notifier)
                            .login("test@example.com", "password");
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Login failed: $e")),
                          );
                        }
                      }
                    }),
                const SizedBox(height: 15),
                PrimaryButton(
                    text: "Continue with Google",
                    icon: LucideIcons.chrome,
                    isSecondary: true,
                    onPressed: () {
                      // Google Sign-In disabled as per request
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Google Sign-In is currently disabled. Please use Email.")),
                        );
                      }
                    }),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () => context.push('/onboarding'),
                  child: Text(
                    "Are you new? Click here to make a new account",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
