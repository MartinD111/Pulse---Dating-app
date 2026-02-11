import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/ui/glass_card.dart';
import '../../../shared/ui/primary_button.dart';
import '../../auth/data/auth_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text("Nastavitve",
              style: GoogleFonts.outfit(
                  fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          if (user != null)
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Prijavljen kot:",
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 5),
                  Text("${user.name} (${user.age})",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          const Spacer(),
          PrimaryButton(
              text: "Odjava",
              isSecondary: true,
              onPressed: () {
                ref.read(authStateProvider.notifier).logout();
              }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
