import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/ui/glass_card.dart';
import '../../../shared/ui/primary_button.dart';
import '../../auth/data/auth_repository.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _showAddHobbyDialog(BuildContext context, AuthUser user) {
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
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);

    if (user == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60), // More top spacing
          Text("Nastavitve",
              style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  // TOP: Profile Section
                  _buildProfileSection(user),
                  const SizedBox(height: 20),

                  // THEME & APP SETTINGS
                  _buildAppSettingsSection(user),
                  const SizedBox(height: 20),

                  // PREFERENCES
                  _buildPreferencesSection(user),
                  const SizedBox(height: 20),

                  // ACCOUNT SETTINGS
                  _buildAccountSection(user),
                  const SizedBox(height: 20),

                  // PREMIUM
                  _buildPremiumSection(user),
                  const SizedBox(height: 30),

                  PrimaryButton(
                      text: "Odjava",
                      isSecondary: true,
                      onPressed: () {
                        ref.read(authStateProvider.notifier).logout();
                      }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(AuthUser user) {
    return GlassCard(
      child: Column(
        children: [
          // Profile Pic
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white24,
            backgroundImage: user.photoUrls.isNotEmpty
                ? NetworkImage(user.photoUrls.first)
                : null,
            onBackgroundImageError:
                user.photoUrls.isNotEmpty ? (_, __) {} : null,
            child: user.photoUrls.isEmpty
                ? const Icon(Icons.person, size: 50, color: Colors.white)
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
                    label: Text(h, style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.white24,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  )),

              // Add Hobby Button
              ActionChip(
                label: const Icon(Icons.add, color: Colors.white, size: 18),
                backgroundColor: Colors.pinkAccent.withValues(alpha: 0.5),
                side: BorderSide.none,
                shape: const StadiumBorder(),
                onPressed: () => _showAddHobbyDialog(context, user),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsSection(AuthUser user) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Videz aplikacije",
              style: TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title:
                const Text("Dark Mode", style: TextStyle(color: Colors.white)),
            value: user.isDarkMode,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.grey[800],
            inactiveTrackColor: Colors.white24,
            onChanged: (val) {
              ref
                  .read(authStateProvider.notifier)
                  .updateProfile(user.copyWith(isDarkMode: val));
            },
          ),
          if (user.interestedIn == 'Oba' || user.interestedIn == 'Both')
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Pride Mode 🏳️‍🌈",
                  style: TextStyle(color: Colors.white)),
              value: user.isPrideMode,
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.purple.withValues(alpha: 0.5),
              inactiveTrackColor: Colors.white24,
              onChanged: (val) {
                ref
                    .read(authStateProvider.notifier)
                    .updateProfile(user.copyWith(isPrideMode: val));
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(AuthUser user) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Preference",
              style: TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Age Range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Starostni razpon",
                  style: TextStyle(color: Colors.white)),
              Text("${user.ageRangeStart} - ${user.ageRangeEnd}",
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
          RangeSlider(
            values: RangeValues(
                user.ageRangeStart.toDouble(), user.ageRangeEnd.toDouble()),
            min: 18,
            max: 100,
            divisions: 82,
            activeColor: Colors.pinkAccent,
            inactiveColor: Colors.white24,
            labels: RangeLabels(
              user.ageRangeStart.toString(),
              user.ageRangeEnd.toString(),
            ),
            onChanged: (RangeValues values) {
              ref.read(authStateProvider.notifier).updateProfile(
                    user.copyWith(
                      ageRangeStart: values.start.round(),
                      ageRangeEnd: values.end.round(),
                    ),
                  );
            },
          ),
          const SizedBox(height: 20),

          // Interested In
          const Text("Koga iščem?", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              {'label': 'Moški', 'icon': Icons.male},
              {'label': 'Ženska', 'icon': Icons.female},
              {'label': 'Oba', 'icon': LucideIcons.users},
            ].map((option) {
              final label = option['label'] as String;
              final icon = option['icon'] as IconData;
              final isSelected = user.interestedIn == label;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon,
                        size: 16,
                        color: isSelected ? Colors.black : Colors.white),
                    const SizedBox(width: 5),
                    Text(label),
                  ],
                ),
                selected: isSelected,
                onSelected: (s) {
                  if (s) {
                    ref
                        .read(authStateProvider.notifier)
                        .updateProfile(user.copyWith(interestedIn: label));
                  }
                },
                selectedColor: Colors.white,
                backgroundColor: Colors.white10,
                labelStyle:
                    TextStyle(color: isSelected ? Colors.black : Colors.white),
                shape: const StadiumBorder(side: BorderSide.none),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Partner Habits
          const Text("Moje preference", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 10),

          // Smoking
          _buildDropdownPreference(
              "Partner kadi?",
              user.partnerSmokingPreference ?? 'Vseeno',
              ['Ne', 'Da', 'Vseeno'],
              (val) => ref
                  .read(authStateProvider.notifier)
                  .updateProfile(user.copyWith(partnerSmokingPreference: val))),

          const SizedBox(height: 10),

          // Introvert/Extrovert
          const Text("Tip osebnosti (Introvert/Ekstrovert)",
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          Slider(
            value: (user.introvertScale ?? 3).toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: Colors.pinkAccent,
            inactiveColor: Colors.white24,
            label: _getIntrovertLabel(user.introvertScale ?? 3),
            onChanged: (val) {
              ref
                  .read(authStateProvider.notifier)
                  .updateProfile(user.copyWith(introvertScale: val.round()));
            },
          ),
          Center(
            child: Text(
              _getIntrovertLabel(user.introvertScale ?? 3),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _getIntrovertLabel(int value) {
    if (value == 1) return "Popoln Introvert";
    if (value == 2) return "Bolj Introvert";
    if (value == 3) return "Nekje vmes";
    if (value == 4) return "Bolj Ekstrovert";
    if (value == 5) return "Popoln Ekstrovert";
    return "";
  }

  Widget _buildDropdownPreference(String title, String currentValue,
      List<String> options, Function(String) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        DropdownButton<String>(
          value: options.contains(currentValue) ? currentValue : options.last,
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          underline: Container(height: 1, color: Colors.white54),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (val) => val != null ? onChanged(val) : null,
        ),
      ],
    );
  }

  Widget _buildAccountSection(AuthUser user) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Nastavitve računa",
              style: TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Email Verification Status
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              user.isEmailVerified
                  ? LucideIcons.checkCircle
                  : LucideIcons.alertCircle,
              color: user.isEmailVerified ? Colors.green : Colors.orange,
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
                      ref.read(authStateProvider.notifier).updateProfile(
                            user.copyWith(isEmailVerified: true),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Email verificiran!")),
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
            activeTrackColor: Colors.red.withValues(alpha: 0.5),
            inactiveTrackColor: Colors.white24,
            onChanged: (val) {
              ref.read(authStateProvider.notifier).updateProfile(
                    user.copyWith(isAdmin: val),
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSection(AuthUser user) {
    return GlassCard(
      borderColor: Colors.amber,
      child: SwitchListTile(
        title: const Row(
          children: [
            Text("Aktiviraj Premium Račun",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(width: 10),
            Icon(LucideIcons.crown, color: Colors.amber, size: 20),
          ],
        ),
        value: user.isPremium,
        activeThumbColor: Colors.amber,
        activeTrackColor: Colors.amber.withValues(alpha: 0.5),
        inactiveTrackColor: Colors.white24,
        onChanged: (val) {
          ref.read(authStateProvider.notifier).updateProfile(
                user.copyWith(isPremium: val),
              );
        },
      ),
    );
  }
}
