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

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

  void _updateProfile(AuthUser updatedUser) {
    // Save scroll position before update
    final offset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;
    ref.read(authStateProvider.notifier).updateProfile(updatedUser);
    // Restore scroll position after rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(offset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = ref.watch(authStateProvider);

    if (user == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Text("Nastavitve",
              style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  _buildProfileSection(user),
                  const SizedBox(height: 20),
                  _buildAppSettingsSection(user),
                  const SizedBox(height: 20),
                  _buildPreferencesSection(user),
                  const SizedBox(height: 20),
                  _buildLifestyleSection(user),
                  const SizedBox(height: 20),
                  _buildAccountSection(user),
                  const SizedBox(height: 20),
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
          Text("${user.name ?? 'Guest'}, ${user.age ?? '?'}",
              style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 15),
          // Hobbies with emoji icons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ...user.hobbies.map((h) {
                final emoji = _getHobbyEmoji(h, user.gender);
                final displayText = '$emoji $h';
                return Chip(
                  label: Text(displayText,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500)),
                  backgroundColor: Colors.black54,
                  side: const BorderSide(color: Colors.white24),
                  shape: const StadiumBorder(),
                );
              }),
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
              _updateProfile(user.copyWith(isDarkMode: val));
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
                _updateProfile(user.copyWith(isPrideMode: val));
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
              _updateProfile(user.copyWith(
                ageRangeStart: values.start.round(),
                ageRangeEnd: values.end.round(),
              ));
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
                    _updateProfile(user.copyWith(interestedIn: label));
                  }
                },
                selectedColor: Colors.white,
                backgroundColor: Colors.black54,
                labelStyle:
                    TextStyle(color: isSelected ? Colors.black : Colors.white),
                shape: StadiumBorder(
                    side: BorderSide(
                        color:
                            isSelected ? Colors.transparent : Colors.white24)),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Partner Smoking - Pill shaped selector
          const Text("Partner kadi?", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: ['Ne', 'Vseeno'].map((option) {
              final isSelected =
                  (user.partnerSmokingPreference ?? 'Vseeno') == option;
              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (s) {
                  if (s) {
                    _updateProfile(
                        user.copyWith(partnerSmokingPreference: option));
                  }
                },
                selectedColor: Colors.white,
                backgroundColor: Colors.black54,
                labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal),
                shape: StadiumBorder(
                    side: BorderSide(
                        color:
                            isSelected ? Colors.transparent : Colors.white24)),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

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
              _updateProfile(user.copyWith(introvertScale: val.round()));
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

  Widget _buildLifestyleSection(AuthUser user) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Življenjski slog",
              style: TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Exercise
          const Text("Telovadba", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Ne', 'Včasih', 'Redno', 'Zelo aktiven'].map((option) {
              final isSelected = (user.exerciseHabit ?? 'Včasih') == option;
              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (s) {
                  if (s) {
                    _updateProfile(user.copyWith(exerciseHabit: option));
                  }
                },
                selectedColor: Colors.white,
                backgroundColor: Colors.black54,
                labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal),
                shape: StadiumBorder(
                    side: BorderSide(
                        color:
                            isSelected ? Colors.transparent : Colors.white24)),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Alcohol
          const Text("Alkohol", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Nikoli', 'Družabno', 'Ob priliki'].map((option) {
              final isSelected = (user.drinkingHabit ?? 'Družabno') == option;
              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (s) {
                  if (s) {
                    _updateProfile(user.copyWith(drinkingHabit: option));
                  }
                },
                selectedColor: Colors.white,
                backgroundColor: Colors.black54,
                labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal),
                shape: StadiumBorder(
                    side: BorderSide(
                        color:
                            isSelected ? Colors.transparent : Colors.white24)),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Sleep Schedule
          const Text("Spanje", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: ['Nočna ptica', 'Jutranja ptica'].map((option) {
              final isSelected =
                  (user.sleepSchedule ?? 'Nočna ptica') == option;
              return ChoiceChip(
                avatar: Icon(
                  option == 'Nočna ptica' ? LucideIcons.moon : LucideIcons.sun,
                  size: 16,
                  color: isSelected ? Colors.black : Colors.white,
                ),
                label: Text(option),
                selected: isSelected,
                onSelected: (s) {
                  if (s) {
                    _updateProfile(user.copyWith(sleepSchedule: option));
                  }
                },
                selectedColor: Colors.white,
                backgroundColor: Colors.black54,
                labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal),
                shape: StadiumBorder(
                    side: BorderSide(
                        color:
                            isSelected ? Colors.transparent : Colors.white24)),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Dog/Cat Person
          const Text("Hišni ljubljenčki",
              style: TextStyle(color: Colors.white)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: ['Dog person 🐶', 'Cat person 🐱'].map((option) {
              final val =
                  option.startsWith('Dog') ? 'Dog person' : 'Cat person';
              final isSelected = (user.petPreference ?? 'Dog person') == val;
              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (s) {
                  if (s) {
                    _updateProfile(user.copyWith(petPreference: val));
                  }
                },
                selectedColor: Colors.white,
                backgroundColor: Colors.black54,
                labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal),
                shape: StadiumBorder(
                    side: BorderSide(
                        color:
                            isSelected ? Colors.transparent : Colors.white24)),
                showCheckmark: false,
              );
            }).toList(),
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

  Widget _buildAccountSection(AuthUser user) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Nastavitve računa",
              style: TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
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
                      _updateProfile(user.copyWith(isEmailVerified: true));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Email verificiran!")),
                      );
                    },
                    child: const Text("Verificiraj"),
                  )
                : null,
          ),
          Divider(color: Colors.white.withValues(alpha: 0.1)),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Admin Mode (Bypass radar)",
                style: TextStyle(color: Colors.white)),
            value: user.isAdmin,
            activeThumbColor: Colors.red,
            activeTrackColor: Colors.red.withValues(alpha: 0.5),
            inactiveTrackColor: Colors.white24,
            onChanged: (val) {
              _updateProfile(user.copyWith(isAdmin: val));
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
          _updateProfile(user.copyWith(isPremium: val));
        },
      ),
    );
  }

  String _getHobbyEmoji(String hobby, String? gender) {
    bool isFemale = gender == 'Ženska';
    // Strip any existing emoji prefix (custom hobbies may already have one)
    final cleanHobby = hobby
        .replaceAll(
            RegExp(r'^[\p{So}\p{Cn}\p{Sk}\p{Sm}]+\s*', unicode: true), '')
        .trim();
    switch (cleanHobby) {
      case 'Fitnes':
        return isFemale ? '🏋️‍♀️' : '🏋️‍♂️';
      case 'Pilates':
        return isFemale ? '🧘‍♀️' : '🧘‍♂️';
      case 'Sprehodi':
        return isFemale ? '🚶‍♀️' : '🚶‍♂️';
      case 'Tek':
        return isFemale ? '🏃‍♀️' : '🏃‍♂️';
      case 'Smučanje':
        return '⛷️';
      case 'Snowboarding':
        return '🏂';
      case 'Plezanje':
        return isFemale ? '🧗‍♀️' : '🧗‍♂️';
      case 'Plavanje':
        return isFemale ? '🏊‍♀️' : '🏊‍♂️';
      case 'Branje':
        return '📖';
      case 'Kava':
        return '☕';
      case 'Čaj':
        return '🍵';
      case 'Kuhanje':
        return isFemale ? '👩‍🍳' : '👨‍🍳';
      case 'Filmi':
        return '🎬';
      case 'Serije':
        return '📺';
      case 'Videoigre':
        return '🎮';
      case 'Glasba':
        return '🎵';
      case 'Slikanje':
        return '🎨';
      case 'Fotografija':
        return '📸';
      case 'Pisanje':
        return '✍️';
      case 'Muzeji':
        return '🏛️';
      case 'Gledališče':
        return '🎭';
      case 'Roadtrips':
        return '🚗';
      case 'Camping':
        return '⛺';
      case 'City breaks':
        return '🏙️';
      case 'Backpacking':
        return '🎒';
      case 'Bordanje':
        return '🏂';
      default:
        return '✨';
    }
  }
}
