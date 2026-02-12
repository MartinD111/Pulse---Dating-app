import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/ui/glass_card.dart';
import '../../../shared/ui/primary_button.dart';
import '../../auth/data/auth_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showAddHobbyDialog(BuildContext context, WidgetRef ref, AuthUser user) {
    final nameController = TextEditingController();
    final emojiController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Dodaj svoj hobi",
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Ime hobija",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emojiController,
              style: const TextStyle(color: Colors.white),
              maxLength: 2,
              decoration: const InputDecoration(
                labelText: "Ikona (Emoji)",
                labelStyle: TextStyle(color: Colors.white70),
                helperText: "Uporabi sistemsko tipkovnico za emoji",
                helperStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text("Prekliči", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newHobby =
                    "${emojiController.text.trim()} ${nameController.text.trim()}";
                final updatedHobbies = List<String>.from(user.hobbies)
                  ..add(newHobby);

                ref
                    .read(authStateProvider.notifier)
                    .updateProfile(user.copyWith(hobbies: updatedHobbies));

                Navigator.pop(ctx);
              }
            },
            child: const Text("Dodaj", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);

    if (user == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text("Nastavitve",
              style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // TOP: Profile Section
                  GlassCard(
                    child: Column(
                      children: [
                        // Profile Pic
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: user.photoUrls.isNotEmpty
                              ? NetworkImage(user.photoUrls.first)
                              : null,
                          child: user.photoUrls.isEmpty
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        const SizedBox(height: 15),

                        // Name & Age
                        Text("${user.name ?? 'Guest'}, ${user.age ?? '?'}",
                            style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 15),

                        // Hobbies
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            ...user.hobbies.map((h) => Chip(
                                  label: Text(h,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.white24,
                                  side: BorderSide.none,
                                  shape: const StadiumBorder(),
                                )),

                            // Add Hobby Button
                            ActionChip(
                              label: const Icon(Icons.add,
                                  color: Colors.white, size: 18),
                              backgroundColor:
                                  Colors.pinkAccent.withValues(alpha: 0.5),
                              side: BorderSide.none,
                              shape: const StadiumBorder(),
                              onPressed: () =>
                                  _showAddHobbyDialog(context, ref, user),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // MIDDLE: Preferences (Admin, Email, etc.)
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Nastavitve računa",
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),

                        // Email Verification Status
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            user.isEmailVerified
                                ? LucideIcons.checkCircle
                                : LucideIcons.alertCircle,
                            color: user.isEmailVerified
                                ? Colors.green
                                : Colors.orange,
                          ),
                          title: Text(
                            user.isEmailVerified
                                ? "Email Verificiran"
                                : "Email NI Verificiran",
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: !user.isEmailVerified
                              ? TextButton(
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
                                  child: const Text("Verificiraj"),
                                )
                              : null,
                        ),

                        Divider(color: Colors.white.withValues(alpha: 0.1)),

                        // Admin Mode
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Admin Mode (Bypass radar)",
                              style: TextStyle(color: Colors.white)),
                          value: user.isAdmin,
                          activeThumbColor: Colors.red,
                          onChanged: (val) {
                            ref.read(authStateProvider.notifier).updateProfile(
                                  user.copyWith(isAdmin: val),
                                );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BOTTOM: Premium
                  GlassCard(
                    borderColor: Colors.amber,
                    child: SwitchListTile(
                      title: const Row(
                        children: [
                          Text("Aktiviraj Premium Račun",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(width: 10),
                          Icon(LucideIcons.crown,
                              color: Colors.amber, size: 20),
                        ],
                      ),
                      value: user.isPremium,
                      activeThumbColor: Colors.amber,
                      onChanged: (val) {
                        ref.read(authStateProvider.notifier).updateProfile(
                              user.copyWith(isPremium: val),
                            );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  PrimaryButton(
                      text: "Odjava",
                      isSecondary: true,
                      onPressed: () {
                        ref.read(authStateProvider.notifier).logout();
                      }),
                  const SizedBox(height: 80), // Space for Nav Bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
