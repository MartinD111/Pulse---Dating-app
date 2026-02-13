import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/ui/primary_button.dart';
import '../data/auth_repository.dart';
import 'radar_background.dart';

class RegistrationFlow extends ConsumerStatefulWidget {
  const RegistrationFlow({super.key});

  @override
  ConsumerState<RegistrationFlow> createState() => _RegistrationFlowState();
}

class _RegistrationFlowState extends ConsumerState<RegistrationFlow> {
  final PageController _pageController = PageController();

  // --- Step 1: Basic Info ---
  final TextEditingController _nameController = TextEditingController();
  DateTime? _birthDate;
  final List<File?> _photos = [null, null, null, null];
  final ImagePicker _picker = ImagePicker();
  String? _selectedGender; // 'Moški', 'Ženska', 'Ne želim povedati'
  String _selectedLanguage = 'EN';

  // --- Step 2: About You ---
  String? _interestedIn;
  bool _isSmoker = false;
  String _occupation = 'Študent'; // 'Študent' or 'Zaposlen'
  String _drinkingHabit = 'Občasno';
  double _introvertScale = 3.0; // 1-5
  final List<String> _lookingFor = [];
  final List<String> _spokenLanguages = [];

  // --- Step 3: More Details ---
  final List<String> _selectedHobbies = [];
  final Map<String, String> _prompts = {}; // prompt question -> answer

  // New state
  RangeValues _ageRange = const RangeValues(20, 30);

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _pickImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photos[index] = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(), // Disable swipe
      children: [
        _buildStep1BasicInfo(),
        _buildStep2AboutYou(),
        _buildStep3MoreDetails(),
      ],
    );

    Color? accentColor;
    if (_selectedGender == 'Moški') {
      accentColor = Colors.cyan;
    } else if (_selectedGender == 'Ženska') {
      accentColor = Colors.pinkAccent;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: RadarBackground(
        accentColor: accentColor,
        child: content,
      ),
    );
  }

  Widget _buildStep1BasicInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center eveything
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Placeholder for alignment or back button if needed
              const SizedBox(width: 48),
              Text("Osnovni podatki",
                  style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              DropdownButton<String>(
                value: _selectedLanguage,
                dropdownColor: Colors.black87,
                style: const TextStyle(color: Colors.white),
                underline: Container(),
                icon: const Icon(Icons.language, color: Colors.white),
                items: ['EN', 'IT', 'DE', 'FR']
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedLanguage = v!),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Name Input
          TextField(
            controller: _nameController,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: const InputDecoration(
              labelText: 'Ime',
              labelStyle: TextStyle(color: Colors.white70),
              alignLabelWithHint: true,
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),

          // Date of Birth
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _birthDate = picked);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white70)),
              ),
              child: Text(
                _birthDate == null
                    ? "Datum rojstva"
                    : DateFormat('dd. MM. yyyy').format(_birthDate!),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Photos (1-4)
          Text("Dodaj slike (1-4)",
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return GestureDetector(
                onTap: () => _pickImage(index),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white30),
                        image: _photos[index] != null
                            ? DecorationImage(
                                image: FileImage(_photos[index]!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _photos[index] == null
                          ? const Icon(Icons.add, color: Colors.white)
                          : null,
                    ),
                    if (index == 0)
                      Positioned(
                        top: -8,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.star,
                              size: 12, color: Colors.black),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 30),

          // Gender Selection
          Text("Spol",
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 15),
          Column(
            children: [
              _buildGenderOption('Moški', Icons.male),
              const SizedBox(height: 10),
              _buildGenderOption('Ženska', Icons.female),
              const SizedBox(height: 10),
              _buildGenderOption('Ne želim povedati', LucideIcons.userX),
            ],
          ),

          const Spacer(),
          PrimaryButton(
            text: "Naprej",
            onPressed: () {
              if (_nameController.text.isNotEmpty &&
                  _birthDate != null &&
                  _selectedGender != null) {
                _nextPage();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Prosim izpolni vsa polja")),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String label, IconData icon) {
    final isSelected = _selectedGender == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = label),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? Colors.white : Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2AboutYou() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Center(
              child: Text("Nekaj o tebi",
                  style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            const SizedBox(height: 30),

            // Interested In
            _buildSectionLabel("Koga iščem?", LucideIcons.search),
            Wrap(
              spacing: 10,
              children: [
                {'label': 'Moški', 'icon': Icons.male},
                {'label': 'Ženska', 'icon': Icons.female},
                {'label': 'Oba', 'icon': LucideIcons.users},
              ].map((option) {
                final label = option['label'] as String;
                final icon = option['icon'] as IconData;
                return _buildChoiceChip(label, _interestedIn == label,
                    (s) => setState(() => _interestedIn = s ? label : null),
                    icon: icon);
              }).toList(),
            ),
            const SizedBox(height: 25),

            // Age Range Slider
            _buildSectionLabel("Starostni razpon", LucideIcons.calendarRange),
            RangeSlider(
              values: _ageRange,
              min: 18,
              max: 100,
              divisions: 82,
              activeColor: Colors.white,
              inactiveColor: Colors.white24,
              labels: RangeLabels(
                _ageRange.start.round().toString(),
                _ageRange.end.round().toString(),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _ageRange = values;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${_ageRange.start.round()} let",
                    style: const TextStyle(color: Colors.white70)),
                Text("${_ageRange.end.round()} let",
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 25),

            // Smoking
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionLabel("Kadil/a?", LucideIcons.cigarette),
                Switch(
                  value: _isSmoker,
                  onChanged: (v) => setState(() => _isSmoker = v),
                  thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return Colors.white70;
                  }),
                  activeTrackColor: Colors.purple.shade300,
                  inactiveTrackColor: Colors.white12,
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Occupation
            _buildSectionLabel("Status", LucideIcons.briefcase),
            Wrap(
              spacing: 10,
              children: [
                {'label': 'Študent', 'icon': LucideIcons.graduationCap},
                {'label': 'Zaposlen', 'icon': LucideIcons.briefcase},
              ].map((option) {
                final label = option['label'] as String;
                final icon = option['icon'] as IconData;
                return _buildChoiceChip(label, _occupation == label,
                    (s) => setState(() => _occupation = label),
                    icon: icon);
              }).toList(),
            ),
            const SizedBox(height: 25),

            // Drinking
            _buildSectionLabel("Alkohol", LucideIcons.beer),
            Wrap(
              spacing: 10,
              children: ['Nikoli', 'Občasno', 'Redno'].map((option) {
                return _buildChoiceChip(option, _drinkingHabit == option,
                    (s) => setState(() => _drinkingHabit = option));
              }).toList(),
            ),
            const SizedBox(height: 25),

            // Introvert/Extrovert Slider
            _buildSectionLabel("Introvert / Ekstrovert", LucideIcons.users),
            Slider(
              value: _introvertScale,
              min: 1,
              max: 5,
              divisions: 4,
              label: _introvertScale.round().toString(),
              activeColor: Colors.white,
              inactiveColor: Colors.white24,
              onChanged: (v) => setState(() => _introvertScale = v),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Introvert", style: TextStyle(color: Colors.white70)),
                Text("Ekstrovert", style: TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 25),

            // Looking For
            _buildSectionLabel("Iščem", LucideIcons.heart),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                'Kratkoročna zabava',
                'Dolgoročno razmerje',
                'Prijateljstvo',
                'Klepet'
              ].map((option) {
                final isSelected = _lookingFor.contains(option);
                return _buildFilterChip(option, isSelected, (s) {
                  setState(() {
                    if (s) {
                      _lookingFor.add(option);
                    } else {
                      _lookingFor.remove(option);
                    }
                  });
                });
              }).toList(),
            ),
            const SizedBox(height: 25),

            // Languages
            _buildSectionLabel("Govorim (max 5)", LucideIcons.languages),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                'Slovenščina',
                'Angleščina',
                'Nemščina',
                'Italijanščina',
                'Francoščina',
                'Španščina',
                'Hrvaščina'
              ].map((option) {
                final isSelected = _spokenLanguages.contains(option);
                final flag = _getLanguageFlag(option);
                return _buildFilterChip(option, isSelected, (s) {
                  setState(() {
                    if (s) {
                      if (_spokenLanguages.length < 5) {
                        _spokenLanguages.add(option);
                      }
                    } else {
                      _spokenLanguages.remove(option);
                    }
                  });
                }, avatar: Text(flag, style: const TextStyle(fontSize: 16)));
              }).toList(),
            ),

            const SizedBox(height: 40),
            Row(
              children: [
                TextButton(
                  onPressed: _prevPage,
                  child: const Text("Nazaj",
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                ),
                const Spacer(),
                PrimaryButton(
                  text: "Naprej",
                  width: 120,
                  onPressed: _nextPage,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(
      String label, bool isSelected, Function(bool) onSelected,
      {IconData? icon}) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 18, color: isSelected ? Colors.black : Colors.white),
            const SizedBox(width: 8),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: Colors.white,
      backgroundColor: Colors.black45,
      labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? Colors.white : Colors.white24),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildFilterChip(
      String label, bool isSelected, Function(bool) onSelected,
      {Widget? avatar}) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: Colors.white,
      backgroundColor: Colors.black45,
      avatar: avatar,
      labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? Colors.white : Colors.white24),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildStep3MoreDetails() {
    final Map<String, List<String>> hobbyCategories = {
      'Aktivi': [
        'Fitnes',
        'Pilates',
        'Sprehodi',
        'Tek',
        'Smučanje',
        'Snowboarding',
        'Plezanje',
        'Plavanje'
      ],
      'Prosti čas': [
        'Branje',
        'Kava',
        'Čaj',
        'Kuhanje',
        'Filmi',
        'Serije',
        'Videoigre',
        'Glasba'
      ],
      'Umetnost': [
        'Slikanje',
        'Fotografija',
        'Pisanje',
        'Muzeji',
        'Gledališče'
      ],
      'Potovanja': ['Roadtrips', 'Camping', 'City breaks', 'Backpacking'],
    };

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text("Nekaj malo več o tebi",
                style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 30),

            // Hobbies Categories
            _buildSectionLabel("Hobiji", LucideIcons.gamepad2),
            ...hobbyCategories.entries.map((entry) {
              return Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(entry.key,
                      style: const TextStyle(color: Colors.white)),
                  collapsedIconColor: Colors.white,
                  iconColor: Colors.white,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: entry.value.map((hobby) {
                        final isSelected = _selectedHobbies.contains(hobby);
                        final emoji = _getHobbyEmoji(hobby);
                        return _buildFilterChip('$emoji $hobby', isSelected,
                            (s) {
                          setState(() {
                            if (s) {
                              _selectedHobbies.add(hobby);
                            } else {
                              _selectedHobbies.remove(hobby);
                            }
                          });
                        });
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            // Custom Hobbies Section
            _buildSectionLabel("Moji hobiji (Po meri)", LucideIcons.plusCircle),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Display custom hobbies (those NOT in standard categories)
                ..._selectedHobbies
                    .where((h) =>
                        !hobbyCategories.values.any((list) => list.contains(h)))
                    .map((h) => Chip(
                          label: Text(h,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.pink.shade700,
                          deleteIcon: const Icon(Icons.close,
                              size: 14, color: Colors.white),
                          onDeleted: () =>
                              setState(() => _selectedHobbies.remove(h)),
                          side: const BorderSide(color: Colors.white30),
                          shape: const StadiumBorder(),
                        )),
                ActionChip(
                  label: const Text("Dodaj hobi",
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.white10,
                  avatar: const Icon(Icons.add, color: Colors.white, size: 16),
                  onPressed: _showAddHobbyDialog,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Optional Prompts
            _buildSectionLabel(
                "Zabaven dejstvo o meni (Opcijsko)", LucideIcons.smile),
            ...[
              'Skuham zelo dobro kavo...',
              'Najboljši koncert je bil...',
              'Moj hidden talent je...',
              'Ne morem živeti brez...',
              'Vikendi so za...'
            ].map((prompt) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: prompt,
                    labelStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30)),
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                  onChanged: (val) {
                    _prompts[prompt] = val;
                  },
                ),
              );
            }).take(2),

            const SizedBox(height: 40),
            Row(
              children: [
                TextButton(
                  onPressed: _prevPage,
                  child: const Text("Nazaj",
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                ),
                const Spacer(),
                PrimaryButton(
                  text: "Zaključi",
                  width: 140,
                  onPressed: _completeRegistration,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _getHobbyEmoji(String hobby) {
    bool isFemale = _selectedGender == 'Ženska';

    switch (hobby) {
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
      default:
        return '✨';
    }
  }

  void _completeRegistration() async {
    // Elegant "Congratulations" Animation Dialog
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Congratulations",
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (ctx, anim1, anim2) {
        return Container();
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: FadeTransition(
            opacity: anim1,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade900.withValues(alpha: 0.9),
                      Colors.blue.shade900.withValues(alpha: 0.9)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white30, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(seconds: 1),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: const Icon(LucideIcons.partyPopper,
                              color: Colors.amberAccent, size: 80),
                        );
                      },
                    ),
                    const SizedBox(height: 25),
                    Text("Čestitke!",
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    const Text(
                      "Uspešno ste ustvarili račun.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // Save Data logic (Mock)
    // ... (rest of logic remains similar, just saving photos too if needed)
    final user = AuthUser(
      id: 'generated_id',
      name: _nameController.text,
      age: (DateTime.now().difference(_birthDate!).inDays / 365).floor(),
      birthDate: _birthDate,
      gender: _selectedGender,
      interestedIn: _interestedIn,
      isSmoker: _isSmoker,
      occupation: _occupation,
      drinkingHabit: _drinkingHabit,
      introvertScale: _introvertScale.round(),
      lookingFor: _lookingFor,
      languages: _spokenLanguages,
      hobbies: _selectedHobbies,
      prompts: _prompts,
      isOnboarded: true,
      isEmailVerified: false,
      ageRangeStart: _ageRange.start.round(),
      ageRangeEnd: _ageRange.end.round(),
    );

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.of(context).pop(); // Close dialog
      await ref.read(authStateProvider.notifier).completeOnboarding(user);
      if (mounted) context.go('/'); // Assuming '/' is Home
    }
  }

  String _getLanguageFlag(String lang) {
    switch (lang) {
      case 'Slovenščina':
        return '🇸🇮';
      case 'Angleščina':
        return '🇬🇧';
      case 'Nemščina':
        return '🇩🇪';
      case 'Italijanščina':
        return '🇮🇹';
      case 'Francoščina':
        return '🇫🇷';
      case 'Španščina':
        return '🇪🇸';
      case 'Hrvaščina':
        return '🇭🇷';
      default:
        return '🏳️';
    }
  }

  void _showAddHobbyDialog() {
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
                setState(() {
                  final newHobby =
                      "${emojiController.text.trim()} ${nameController.text.trim()}";
                  _selectedHobbies.add(newHobby);
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("Dodaj", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
