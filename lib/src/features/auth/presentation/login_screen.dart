import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/ui/primary_button.dart';
import '../../../core/translations.dart';
import '../data/auth_repository.dart';
import 'radar_background.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Local state for text fields provided by hooks or just use StatefulWidget if needed.
    // Since this is ConsumerWidget, we can't use setState easily without converting.
    // Let's convert to ConsumerStatefulWidget to handle text controllers.
    return _LoginScreenStateful();
  }
}

class _LoginScreenStateful extends ConsumerStatefulWidget {
  @override
  ConsumerState<_LoginScreenStateful> createState() =>
      _LoginScreenStatefulState();
}

class _LoginScreenStatefulState extends ConsumerState<_LoginScreenStateful> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(appLanguageProvider);
    String tr(String key) => t(key, lang);

    return Scaffold(
      body: RadarBackground(
        child: Stack(
          children: [
            Center(
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
                    const SizedBox(height: 8),
                    Text(tr('onb1_title'), // Using a translation for subtitle
                        style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: Colors.white60,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 50),

                    // Email Input
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: tr('email'),
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon:
                            const Icon(LucideIcons.mail, color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Password Input
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: tr('password'),
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon:
                            const Icon(LucideIcons.lock, color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Forgot password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => context.push('/forgot-password'),
                        child: Text(
                          tr('forgot_password_link'),
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white70,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (_isLoading)
                      const CircularProgressIndicator(color: Colors.white)
                    else
                      PrimaryButton(
                          text: "Login", // Should probably be translated
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            try {
                              await ref.read(authStateProvider.notifier).login(
                                  _emailController.text,
                                  _passwordController.text);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Login failed: $e")),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          }),

                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () => context.push('/onboarding'),
                      child: Text(
                        tr('are_you_new'),
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
            // Language selector in top right
            Positioned(
              top: 50,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: lang,
                    dropdownColor: const Color(0xFF1E1E2E),
                    icon: const Icon(Icons.language,
                        color: Colors.white70, size: 18),
                    items: availableLanguages.map((l) {
                      return DropdownMenuItem(
                        value: l['code'],
                        child: Text(l['label']!,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(appLanguageProvider.notifier).state = val;
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
