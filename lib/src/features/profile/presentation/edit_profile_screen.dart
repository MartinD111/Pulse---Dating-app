import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/ui/glass_card.dart';
import '../../../shared/ui/gradient_scaffold.dart';
import '../../auth/data/auth_repository.dart';
import '../../../core/translations.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _imagePicker = ImagePicker();

  List<String> _photoUrls = [];
  String? _gender;
  String? _occupation;
  bool? _isSmoker;
  String? _drinkingHabit;
  String? _exerciseHabit;
  String? _sleepSchedule;
  String? _petPreference;
  String? _childrenPreference;
  int _introvertScale = 3;
  List<String> _hobbies = [];
  List<String> _lookingFor = [];
  List<String> _languages = [];

  String get _lang {
    final user = ref.read(authStateProvider);
    return user?.appLanguage ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider);
    if (user != null) {
      _nameController.text = user.name ?? '';
      _locationController.text = user.location ?? '';
      _photoUrls = List.from(user.photoUrls);
      _gender = user.gender;
      _occupation = user.occupation;
      _isSmoker = user.isSmoker;
      _drinkingHabit = user.drinkingHabit;
      _exerciseHabit = user.exerciseHabit;
      _sleepSchedule = user.sleepSchedule;
      _petPreference = user.petPreference;
      _childrenPreference = user.childrenPreference;
      _introvertScale = user.introvertScale ?? 3;
      _hobbies = List.from(user.hobbies);
      _lookingFor = List.from(user.lookingFor);
      _languages = List.from(user.languages);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_photoUrls.length >= 4) return;
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _photoUrls.add(picked.path));
    }
  }

  void _removePhoto(int index) {
    setState(() => _photoUrls.removeAt(index));
  }

  void _saveChanges() {
    final user = ref.read(authStateProvider);
    if (user == null) return;
    ref.read(authStateProvider.notifier).updateProfile(user.copyWith(
          name: _nameController.text,
          location: _locationController.text,
          photoUrls: _photoUrls,
          gender: _gender,
          occupation: _occupation,
          isSmoker: _isSmoker,
          drinkingHabit: _drinkingHabit,
          exerciseHabit: _exerciseHabit,
          sleepSchedule: _sleepSchedule,
          petPreference: _petPreference,
          childrenPreference: _childrenPreference,
          introvertScale: _introvertScale,
          hobbies: _hobbies,
          lookingFor: _lookingFor,
          languages: _languages,
        ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t('profile_updated', _lang))),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final lang = _lang;
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(t('edit_profile', lang),
              style: GoogleFonts.outfit(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Photos ──
              _buildSectionLabel(t('photos', lang), LucideIcons.camera),
              const SizedBox(height: 8),
              Text(t('photos_hint', lang),
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 10),
              _buildPhotoGrid(),
              const SizedBox(height: 24),

              // ── Name ──
              _buildSectionLabel(t('name', lang), LucideIcons.user),
              const SizedBox(height: 8),
              _buildTextField(_nameController, t('name', lang)),
              const SizedBox(height: 24),

              // ── Location ──
              _buildSectionLabel(t('location', lang), LucideIcons.mapPin),
              const SizedBox(height: 8),
              _buildLocationField(lang),
              const SizedBox(height: 24),

              // ── Gender ──
              _buildSectionLabel(t('gender', lang), LucideIcons.users),
              const SizedBox(height: 8),
              _buildGenderChips(lang),
              const SizedBox(height: 24),

              // ── Status / Occupation ──
              _buildSectionLabel(t('status', lang), LucideIcons.briefcase),
              const SizedBox(height: 8),
              _buildOccupationChips(lang),
              const SizedBox(height: 24),

              // ── Smoker ──
              _buildSectionLabel(t('smoking', lang), LucideIcons.cigarette),
              const SizedBox(height: 8),
              _buildSmokerSwitch(lang),
              const SizedBox(height: 24),

              // ── Drinking Habit ──
              _buildSectionLabel(t('alcohol', lang), LucideIcons.wine),
              const SizedBox(height: 8),
              _buildDrinkingChips(lang),
              const SizedBox(height: 24),

              // ── Exercise ──
              _buildSectionLabel(t('exercise', lang), LucideIcons.dumbbell),
              const SizedBox(height: 8),
              _buildExerciseChips(lang),
              const SizedBox(height: 24),

              // ── Sleep ──
              _buildSectionLabel(t('sleep', lang), LucideIcons.moon),
              const SizedBox(height: 8),
              _buildSleepChips(lang),
              const SizedBox(height: 24),

              // ── Pets ──
              _buildSectionLabel(t('pets', lang), LucideIcons.dog),
              const SizedBox(height: 8),
              _buildPetChips(lang),
              const SizedBox(height: 24),

              // ── Children ──
              _buildSectionLabel(t('children', lang), LucideIcons.baby),
              const SizedBox(height: 8),
              _buildChildrenChips(lang),
              const SizedBox(height: 24),

              // ── Introvert/Extrovert ──
              _buildSectionLabel(
                  t('introvert_extrovert', lang), LucideIcons.brain),
              const SizedBox(height: 8),
              _buildIntrovertSlider(lang),
              const SizedBox(height: 24),

              // ── Looking For ──
              _buildSectionLabel(t('looking_for', lang), LucideIcons.heart),
              const SizedBox(height: 8),
              _buildLookingForChips(lang),
              const SizedBox(height: 24),

              // ── Languages ──
              _buildSectionLabel(t('i_speak', lang), LucideIcons.languages),
              const SizedBox(height: 8),
              _buildLanguageChips(lang),
              const SizedBox(height: 24),

              // ── Hobbies ──
              _buildSectionLabel('${t('hobbies', lang)} (${_hobbies.length})',
                  LucideIcons.sparkles),
              const SizedBox(height: 8),
              _buildHobbiesSection(lang),
              const SizedBox(height: 24),

              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(t('save_changes', lang),
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // SECTION BUILDERS
  // ─────────────────────────────────────

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ..._photoUrls.asMap().entries.map((entry) {
            final index = entry.key;
            final url = entry.value;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 90,
                      height: 110,
                      child: url.startsWith('http')
                          ? Image.network(url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: Colors.grey[800]))
                          : Image.file(File(url),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: Colors.grey[800])),
                    ),
                  ),
                  // Main badge
                  if (index == 0)
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(t('main', _lang),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10)),
                      ),
                    ),
                  // Remove button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removePhoto(index),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (_photoUrls.length < 4)
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 90,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                child: const Center(
                  child:
                      Icon(LucideIcons.plus, size: 30, color: Colors.white38),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationField(String lang) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: _locationController.text),
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return locationSuggestions.where((city) =>
            city.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String selection) {
        _locationController.text = selection;
      },
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(color: Colors.white),
          onChanged: (val) => _locationController.text = val,
          decoration: InputDecoration(
            hintText: t('location_hint', lang),
            hintStyle: const TextStyle(color: Colors.white30),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            prefixIcon:
                const Icon(LucideIcons.mapPin, size: 18, color: Colors.white38),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 8,
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 340),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    leading: const Icon(LucideIcons.mapPin,
                        size: 16, color: Colors.white54),
                    title: Text(option,
                        style: const TextStyle(color: Colors.white)),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenderChips(String lang) {
    final options = [
      {'label': t('gender_male', lang), 'value': 'Moški', 'icon': Icons.male},
      {
        'label': t('gender_female', lang),
        'value': 'Ženska',
        'icon': Icons.female
      },
    ];
    return Wrap(
      spacing: 10,
      children: options.map((opt) {
        final label = opt['label'] as String;
        final value = opt['value'] as String;
        final icon = opt['icon'] as IconData;
        final sel = _gender == value;
        return ChoiceChip(
          avatar:
              Icon(icon, size: 16, color: sel ? Colors.black : Colors.white),
          label: Text(label),
          selected: sel,
          onSelected: (s) {
            if (s) setState(() => _gender = value);
          },
          selectedColor: Colors.white,
          backgroundColor: Colors.black54,
          labelStyle: TextStyle(color: sel ? Colors.black : Colors.white),
          shape: StadiumBorder(
              side:
                  BorderSide(color: sel ? Colors.transparent : Colors.white24)),
          showCheckmark: false,
        );
      }).toList(),
    );
  }

  Widget _buildOccupationChips(String lang) {
    final options = [
      {'label': t('student', lang), 'value': 'Študent'},
      {'label': t('employed', lang), 'value': 'Zaposlen'},
    ];
    return Wrap(
      spacing: 10,
      children: options.map((opt) {
        final label = opt['label']!;
        final value = opt['value']!;
        final sel = _occupation == value;
        return _chip(label, sel, (s) {
          if (s) setState(() => _occupation = value);
        });
      }).toList(),
    );
  }

  Widget _buildSmokerSwitch(String lang) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title:
          Text(t('smoking', lang), style: const TextStyle(color: Colors.white)),
      value: _isSmoker ?? false,
      activeThumbColor: Colors.pinkAccent,
      activeTrackColor: Colors.pinkAccent.withValues(alpha: 0.3),
      inactiveTrackColor: Colors.white24,
      onChanged: (val) => setState(() => _isSmoker = val),
    );
  }

  Widget _buildDrinkingChips(String lang) {
    return _lifestyleWrap([
      {'label': t('alcohol_never', lang), 'value': 'Nikoli'},
      {'label': t('alcohol_socially', lang), 'value': 'Družabno'},
      {'label': t('alcohol_occasionally', lang), 'value': 'Ob priliki'},
    ], _drinkingHabit ?? 'Družabno', (val) {
      setState(() => _drinkingHabit = val);
    });
  }

  Widget _buildExerciseChips(String lang) {
    return _lifestyleWrap([
      {'label': t('exercise_no', lang), 'value': 'Ne'},
      {'label': t('exercise_sometimes', lang), 'value': 'Včasih'},
      {'label': t('exercise_regularly', lang), 'value': 'Redno'},
      {'label': t('exercise_very_active', lang), 'value': 'Zelo aktiven'},
    ], _exerciseHabit ?? 'Včasih', (val) {
      setState(() => _exerciseHabit = val);
    });
  }

  Widget _buildSleepChips(String lang) {
    return _lifestyleWrap([
      {'label': t('night_owl', lang), 'value': 'Nočna ptica'},
      {'label': t('early_bird', lang), 'value': 'Jutranja ptica'},
    ], _sleepSchedule ?? 'Nočna ptica', (val) {
      setState(() => _sleepSchedule = val);
    });
  }

  Widget _buildPetChips(String lang) {
    return _lifestyleWrap([
      {'label': t('dog_person', lang), 'value': 'Dog person'},
      {'label': t('cat_person', lang), 'value': 'Cat person'},
    ], _petPreference ?? 'Dog person', (val) {
      setState(() => _petPreference = val);
    });
  }

  Widget _buildChildrenChips(String lang) {
    return _lifestyleWrap([
      {'label': t('children_yes', lang), 'value': 'Da'},
      {'label': t('children_no', lang), 'value': 'Ne'},
      {'label': t('children_later', lang), 'value': 'Da, ampak kasneje'},
    ], _childrenPreference ?? 'Ne', (val) {
      setState(() => _childrenPreference = val);
    });
  }

  Widget _buildIntrovertSlider(String lang) {
    String label;
    if (_introvertScale == 1) {
      label = t('full_introvert', lang);
    } else if (_introvertScale == 2) {
      label = t('more_introvert', lang);
    } else if (_introvertScale == 3) {
      label = t('somewhere_between', lang);
    } else if (_introvertScale == 4) {
      label = t('more_extrovert', lang);
    } else {
      label = t('full_extrovert', lang);
    }
    return Column(
      children: [
        Slider(
          value: _introvertScale.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          activeColor: Colors.pinkAccent,
          inactiveColor: Colors.white24,
          label: label,
          onChanged: (val) => setState(() => _introvertScale = val.round()),
        ),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildLookingForChips(String lang) {
    final options = [
      {'label': t('short_term', lang), 'value': 'Short-term fun'},
      {'label': t('long_term', lang), 'value': 'Long-term relationship'},
      {'label': t('friendship', lang), 'value': 'Friendship'},
      {'label': t('chat', lang), 'value': 'Chat'},
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final label = opt['label']!;
        final value = opt['value']!;
        final sel = _lookingFor.contains(value);
        return FilterChip(
          label: Text(label),
          selected: sel,
          onSelected: (s) {
            setState(() {
              if (s) {
                _lookingFor.add(value);
              } else {
                _lookingFor.remove(value);
              }
            });
          },
          selectedColor: Colors.white,
          backgroundColor: Colors.black54,
          labelStyle: TextStyle(color: sel ? Colors.black : Colors.white),
          shape: StadiumBorder(
              side:
                  BorderSide(color: sel ? Colors.transparent : Colors.white24)),
          showCheckmark: true,
          checkmarkColor: Colors.black,
        );
      }).toList(),
    );
  }

  Widget _buildLanguageChips(String lang) {
    final options = [
      {'label': t('lang_slovenian', lang), 'value': 'Slovenščina'},
      {'label': t('lang_english', lang), 'value': 'Angleščina'},
      {'label': t('lang_german', lang), 'value': 'Nemščina'},
      {'label': t('lang_italian', lang), 'value': 'Italijanščina'},
      {'label': t('lang_french', lang), 'value': 'Francoščina'},
      {'label': t('lang_spanish', lang), 'value': 'Španščina'},
      {'label': t('lang_croatian', lang), 'value': 'Hrvaščina'},
      {'label': t('lang_serbian', lang), 'value': 'Srbščina'},
      {'label': t('lang_hungarian', lang), 'value': 'Madžarščina'},
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final label = opt['label']!;
        final value = opt['value']!;
        final sel = _languages.contains(value);
        return FilterChip(
          label: Text(label),
          selected: sel,
          onSelected: (s) {
            setState(() {
              if (s && _languages.length < 5) {
                _languages.add(value);
              } else {
                _languages.remove(value);
              }
            });
          },
          selectedColor: Colors.white,
          backgroundColor: Colors.black54,
          labelStyle: TextStyle(color: sel ? Colors.black : Colors.white),
          shape: StadiumBorder(
              side:
                  BorderSide(color: sel ? Colors.transparent : Colors.white24)),
          showCheckmark: true,
          checkmarkColor: Colors.black,
        );
      }).toList(),
    );
  }

  Widget _buildHobbiesSection(String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_hobbies.isEmpty)
          GlassCard(
            child: Center(
              child: Text(t('no_hobbies_yet', lang),
                  style: const TextStyle(color: Colors.white38)),
            ),
          ),
        if (_hobbies.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _hobbies.map((hobby) {
              final parts = hobby.split(' ');
              final emoji = parts.length > 1 ? parts[0] : '🎯';
              final name =
                  parts.length > 1 ? parts.sublist(1).join(' ') : hobby;
              return Chip(
                avatar: Text(emoji, style: const TextStyle(fontSize: 16)),
                label: Text(name, style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.black54,
                side: const BorderSide(color: Colors.white24),
                deleteIconColor: Colors.white54,
                onDeleted: () {
                  setState(() => _hobbies.remove(hobby));
                },
              );
            }).toList(),
          ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _showAddHobbyDialog,
          icon: const Icon(LucideIcons.plus, size: 16, color: Colors.white70),
          label: Text(t('add_hobby', lang),
              style: const TextStyle(color: Colors.white70)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }

  void _showAddHobbyDialog() {
    final nameCtrl = TextEditingController();
    final emojiCtrl = TextEditingController(text: '🎯');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(t('add_hobby', _lang),
            style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: t('hobby_name', _lang),
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emojiCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: t('icon_emoji', _lang),
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 6),
            Text(t('use_emoji_keyboard', _lang),
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('cancel', _lang),
                style: const TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _hobbies
                      .add('${emojiCtrl.text.trim()} ${nameCtrl.text.trim()}');
                });
                Navigator.pop(ctx);
              }
            },
            child: Text(t('add', _lang),
                style: const TextStyle(color: Colors.pinkAccent)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────

  Widget _lifestyleWrap(
    List<Map<String, String>> options,
    String currentValue,
    ValueChanged<String> onSelected,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final label = opt['label']!;
        final value = opt['value']!;
        final sel = currentValue == value;
        return _chip(label, sel, (s) {
          if (s) onSelected(value);
        });
      }).toList(),
    );
  }

  Widget _chip(String label, bool sel, ValueChanged<bool> onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: sel,
      onSelected: onSelected,
      selectedColor: Colors.white,
      backgroundColor: Colors.black54,
      labelStyle: TextStyle(
        color: sel ? Colors.black : Colors.white,
        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
      ),
      shape: StadiumBorder(
          side: BorderSide(color: sel ? Colors.transparent : Colors.white24)),
      showCheckmark: false,
    );
  }
}
