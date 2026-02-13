import 'dart:io';
import 'dart:math' as math;
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _obscurePassword = true;
  double _passwordStrength = 0.0;
  String _passwordStrengthLabel = '';
  Color _passwordStrengthColor = Colors.red;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;
  DateTime? _birthDate;
  final List<File?> _photos = [null, null, null, null];
  final ImagePicker _picker = ImagePicker();
  String? _selectedGender; // 'Moški', 'Ženska', 'Ne želim povedati'
  String _selectedLanguage = 'EN';

  // --- Step 2: About You ---
  String? _interestedIn;
  bool _isSmoker = false;
  String _occupation = 'Študent'; // 'Študent' or 'Zaposlen'
  String _drinkingHabit = 'Družabno';
  double _introvertScale = 3.0; // 1-5
  final List<String> _lookingFor = [];
  final List<String> _spokenLanguages = [];
  String _exerciseHabit = 'Včasih';
  String _sleepSchedule = 'Nočna ptica';
  String _petPreference = 'Dog person';

  // --- Step 3: More Details ---
  final List<String> _selectedHobbies = [];
  final Map<String, String> _prompts = {}; // prompt question -> answer

  // New state
  RangeValues _ageRange = const RangeValues(20, 30);

  void _updatePasswordStrength(String password) {
    _hasMinLength = password.length >= 8;
    _hasUppercase = password.contains(RegExp(r'[A-Z]'));
    _hasDigit = password.contains(RegExp(r'[0-9]'));
    _hasSpecialChar =
        password.contains(RegExp(r'[!@#%^&*()_+\-=\[\]{};:,.<>?/\\|`~]'));

    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUppercase) score++;
    if (_hasDigit) score++;
    if (_hasSpecialChar) score++;
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;

    double strength = math.min(score / 5.0, 1.0);
    if (password.isEmpty) strength = 0.0;

    String label;
    Color color;
    if (strength == 0) {
      label = '';
      color = Colors.red;
    } else if (strength < 0.3) {
      label = 'Zelo šibko';
      color = Colors.red;
    } else if (strength < 0.5) {
      label = 'Šibko';
      color = Colors.orange;
    } else if (strength < 0.7) {
      label = 'Srednje';
      color = Colors.amber;
    } else if (strength < 0.9) {
      label = 'Močno';
      color = Colors.lightGreen;
    } else {
      label = 'Zelo močno';
      color = Colors.green;
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthLabel = label;
      _passwordStrengthColor = color;
    });
  }

  bool get _isPasswordValid =>
      _hasMinLength && _hasUppercase && _hasDigit && _hasSpecialChar;

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
        _buildStep1bPhotosGender(),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
          const SizedBox(height: 20),

          // Email
          TextField(
            controller: _emailController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: const InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.white70),
              alignLabelWithHint: true,
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),

          // Location
          TextField(
            controller: _locationController,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: const InputDecoration(
              labelText: 'Iz kje sem',
              labelStyle: TextStyle(color: Colors.white70),
              alignLabelWithHint: true,
              prefixIcon:
                  Icon(LucideIcons.mapPin, color: Colors.white54, size: 20),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),

          // Password
          TextField(
            controller: _passwordController,
            textAlign: TextAlign.center,
            obscureText: _obscurePassword,
            onChanged: _updatePasswordStrength,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              labelText: 'Geslo',
              labelStyle: const TextStyle(color: Colors.white70),
              alignLabelWithHint: true,
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                  color: Colors.white54,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Password Strength Bar & Requirements
          if (_passwordController.text.isNotEmpty) ...[
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: _passwordStrength),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        height: 6,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: value,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _passwordStrengthColor.withValues(
                                          alpha: 0.7),
                                      _passwordStrengthColor,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _passwordStrengthColor.withValues(
                                          alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _passwordStrengthLabel,
                        style: TextStyle(
                          color: _passwordStrengthColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            _buildPasswordRequirement('Vsaj 8 znakov', _hasMinLength),
            _buildPasswordRequirement(
                'Vsaj 1 velika črka (A-Z)', _hasUppercase),
            _buildPasswordRequirement('Vsaj 1 številka (0-9)', _hasDigit),
            _buildPasswordRequirement(
                'Vsaj 1 poseben znak (!@#...)', _hasSpecialChar),
          ],

          const Spacer(),
          PrimaryButton(
            text: "Naprej",
            onPressed: () {
              if (_nameController.text.isEmpty ||
                  _birthDate == null ||
                  _emailController.text.isEmpty ||
                  _passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Prosim izpolni vsa polja")),
                );
              } else if (!_isPasswordValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Geslo ne izpolnjuje vseh zahtev"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              } else {
                _nextPage();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep1bPhotosGender() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Slike & Spol",
              style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
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
          const SizedBox(height: 40),

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
          // Warning for 'Ne želim povedati'
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _selectedGender == 'Ne želim povedati'
                ? Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.alertTriangle,
                            color: Colors.amber, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Opomba: Matchani boste samo z osebami, ki iščejo spol \"Oba\".",
                            style: TextStyle(
                                color: Colors.amber.shade200, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const Spacer(),
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
                onPressed: () {
                  if (_selectedGender != null) {
                    _nextPage();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Prosim izberi spol")),
                    );
                  }
                },
              ),
            ],
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
              children: ['Nikoli', 'Družabno', 'Ob priliki'].map((option) {
                return _buildChoiceChip(option, _drinkingHabit == option,
                    (s) => setState(() => _drinkingHabit = option));
              }).toList(),
            ),
            const SizedBox(height: 25),

            // Exercise
            _buildSectionLabel("Telovadba", LucideIcons.dumbbell),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['Ne', 'Včasih', 'Redno', 'Zelo aktiven'].map((option) {
                return _buildChoiceChip(option, _exerciseHabit == option,
                    (s) => setState(() => _exerciseHabit = option));
              }).toList(),
            ),
            const SizedBox(height: 25),

            // Sleep Schedule
            _buildSectionLabel("Spanje", LucideIcons.moon),
            Wrap(
              spacing: 10,
              children: ['Nočna ptica', 'Jutranja ptica'].map((option) {
                return _buildChoiceChip(option, _sleepSchedule == option,
                    (s) => setState(() => _sleepSchedule = option),
                    icon: option == 'Nočna ptica'
                        ? LucideIcons.moon
                        : LucideIcons.sun);
              }).toList(),
            ),
            const SizedBox(height: 25),

            // Dog/Cat Person
            _buildSectionLabel("Hišni ljubljenčki", LucideIcons.heart),
            Wrap(
              spacing: 10,
              children: ['Dog person 🐶', 'Cat person 🐱'].map((option) {
                final val =
                    option.startsWith('Dog') ? 'Dog person' : 'Cat person';
                return _buildChoiceChip(option, _petPreference == val,
                    (s) => setState(() => _petPreference = val));
              }).toList(),
            ),

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
            _buildSectionLabel("Hobiji (${_selectedHobbies.length} izbranih)",
                LucideIcons.gamepad2),
            ...hobbyCategories.entries.map((entry) {
              return Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                      '${entry.key} (${entry.value.where((h) => _selectedHobbies.contains(h)).length})',
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

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              isMet ? LucideIcons.checkCircle2 : LucideIcons.circle,
              key: ValueKey(isMet),
              size: 16,
              color: isMet ? Colors.greenAccent : Colors.white30,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.greenAccent : Colors.white38,
              fontSize: 12,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
              decoration: isMet ? TextDecoration.lineThrough : null,
              decorationColor: Colors.greenAccent.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
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
                    const SizedBox(height: 20),

                    // Email verification notification
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.mail,
                                color: Colors.lightBlueAccent, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Verifikacijski email poslan!",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Preverite ${_emailController.text}",
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
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
    // Convert photos to file paths for photoUrls
    final photoUrls =
        _photos.where((p) => p != null).map((p) => p!.path).toList();

    final user = AuthUser(
      id: 'generated_id',
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      photoUrls: photoUrls,
      age: (DateTime.now().difference(_birthDate!).inDays / 365).floor(),
      birthDate: _birthDate,
      gender: _selectedGender,
      location:
          _locationController.text.isNotEmpty ? _locationController.text : null,
      interestedIn: _interestedIn,
      isSmoker: _isSmoker,
      occupation: _occupation,
      drinkingHabit: _drinkingHabit,
      introvertScale: _introvertScale.round(),
      exerciseHabit: _exerciseHabit,
      sleepSchedule: _sleepSchedule,
      petPreference: _petPreference,
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
