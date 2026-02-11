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
            Column(
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Prijavljen kot:",
                              style: TextStyle(color: Colors.white70)),
                          if (user.isAdmin)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text("ADMIN",
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text("${user.name ?? 'Guest'} (${user.age ?? '?'})",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(user.gender ?? 'Unknown',
                          style: TextStyle(color: Colors.white60)),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Email Verification Status
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            user.isEmailVerified
                                ? Icons.check_circle
                                : Icons.error,
                            color: user.isEmailVerified
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            user.isEmailVerified
                                ? "Email Verificiran"
                                : "Email NI Verificiran",
                            style: TextStyle(
                              color: user.isEmailVerified
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (!user.isEmailVerified)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: PrimaryButton(
                            text: "Pošlji verifikacijo (Simulacija)",
                            height: 40,
                            onPressed: () {
                              ref
                                  .read(authStateProvider.notifier)
                                  .updateProfile(
                                    user.copyWith(isEmailVerified: true),
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Email verificiran!")),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Admin Toggle
                GlassCard(
                  child: SwitchListTile(
                    title: const Text("Admin Mode (Bypass radar)",
                        style: TextStyle(color: Colors.white)),
                    value: user.isAdmin,
                    activeColor: Colors.red,
                    onChanged: (val) {
                      ref.read(authStateProvider.notifier).updateProfile(
                            user.copyWith(isAdmin: val),
                          );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                // Premium Toggle
                GlassCard(
                  borderColor:
                      user.isPremium ? Colors.amber : Colors.transparent,
                  child: SwitchListTile(
                    title: Row(
                      children: [
                        const Text("Premium Membership",
                            style: TextStyle(color: Colors.white)),
                        const SizedBox(width: 10),
                        if (user.isPremium)
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                      ],
                    ),
                    value: user.isPremium,
                    activeColor: Colors.amber,
                    onChanged: (val) {
                      ref.read(authStateProvider.notifier).updateProfile(
                            user.copyWith(isPremium: val),
                          );
                    },
                  ),
                ),
              ],
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
