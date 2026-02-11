import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../shared/ui/primary_button.dart';
import '../data/auth_repository.dart';
import 'split_background.dart';

class RegistrationFlow extends ConsumerStatefulWidget {
  const RegistrationFlow({super.key});

  @override
  ConsumerState<RegistrationFlow> createState() => _RegistrationFlowState();
}

class _RegistrationFlowState extends ConsumerState<RegistrationFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // --- Step 1: Basic Info ---
  final TextEditingController _nameController = TextEditingController();
  DateTime? _birthDate;
  final List<String> _photoUrls = []; // Mock photo storage
  String? _selectedGender; // 'Male', 'Female', 'Both'
  String _selectedLanguage = 'EN';

  // --- Step 2: About You ---
  String? _interestedIn;
  bool _isSmoker = false;
  String _occupation = 'Student'; // 'Student' or 'Employed'
  String _drinkingHabit = 'Occasionally';
  double _introvertScale = 3.0; // 1-5
  List<String> _lookingFor = [];
  List<String> _spokenLanguages = [];

  // --- Step 3: More Details ---
  List<String> _selectedHobbies = [];
  final Map<String, String> _prompts = {}; // prompt question -> answer

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

  @override
  Widget build(BuildContext context) {
    // If gender is selected, use that theme (mock logic for now).
    // If NOT selected (Step 1 initially), use SplitBackground.
    // For simplicity in this step, we keep SplitBackground on Step 1 always.

    Widget content = PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(), // Disable swipe
      onPageChanged: (p) => setState(() => _currentPage = p),
      children: [
        _buildStep1BasicInfo(),
        _buildStep2AboutYou(), // Placeholder
        _buildStep3MoreDetails(), // Placeholder
      ],
    );

    if (_currentPage == 0 && _selectedGender == null) {
      return SplitBackground(child: content);
    } else {
      // TODO: Wrap with GradientScaffold based on gender
      return Scaffold(
        backgroundColor: Colors.black, // Fallback
        body: SafeArea(child: content),
      );
    }
  }

  Widget _buildStep1BasicInfo() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
          const SizedBox(height: 20),

          // Name Input
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Ime',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
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
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white70)),
              ),
              child: Text(
                _birthDate == null
                    ? "Datum rojstva"
                    : DateFormat('dd. MM. yyyy').format(_birthDate!),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Photos (1-4)
          Text("Dodaj slike (1-4)",
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(4, (index) {
                return Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // Gender Selection
          Text("Spol",
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Male', 'Female', 'Both'].map((gender) {
              final isSelected = _selectedGender == gender;
              return ChoiceChip(
                label: Text(gender),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedGender = selected ? gender : null);
                },
                backgroundColor: Colors.white12,
                selectedColor: gender == 'Male'
                    ? Colors.blue
                    : gender == 'Female'
                        ? Colors.pink
                        : Colors.purple,
                labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70),
              );
            }).toList(),
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

  Widget _buildStep2AboutYou() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nekaj o tebi",
                style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 30),

            // Interested In
            _buildSectionLabel("Koga iščem?"),
            Wrap(
              spacing: 10,
              children: ['Male', 'Female', 'Both'].map((option) {
                return ChoiceChip(
                  label: Text(option),
                  selected: _interestedIn == option,
                  onSelected: (s) =>
                      setState(() => _interestedIn = s ? option : null),
                  selectedColor: Colors.white24,
                  backgroundColor: Colors.black26,
                  labelStyle: const TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Smoking
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionLabel("Kadil/a?"),
                Switch(
                  value: _isSmoker,
                  onChanged: (v) => setState(() => _isSmoker = v),
                  activeColor: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Occupation
            _buildSectionLabel("Status"),
            Wrap(
              spacing: 10,
              children: ['Student', 'Zaposlen'].map((option) {
                return ChoiceChip(
                  label: Text(option),
                  selected: _occupation == option,
                  onSelected: (s) => setState(() => _occupation = option),
                  selectedColor: Colors.white24,
                  backgroundColor: Colors.black26,
                  labelStyle: const TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Drinking
            _buildSectionLabel("Alkohol"),
            Wrap(
              spacing: 10,
              children: ['Nikoli', 'Občasno', 'Redno'].map((option) {
                return ChoiceChip(
                  label: Text(option),
                  selected: _drinkingHabit == option,
                  onSelected: (s) => setState(() => _drinkingHabit = option),
                  selectedColor: Colors.white24,
                  backgroundColor: Colors.black26,
                  labelStyle: const TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Introvert/Extrovert Slider
            _buildSectionLabel("Introvertiranost / Ekstrovertiranost (1-5)"),
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
            const SizedBox(height: 20),

            // Looking For
            _buildSectionLabel("Iščem"),
            Wrap(
              spacing: 10,
              children: [
                'Kratkoročna zabava',
                'Dolgoročno razmerje',
                'Prijateljstvo',
                'Klepet'
              ].map((option) {
                final isSelected = _lookingFor.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (s) {
                    setState(() {
                      if (s) {
                        _lookingFor.add(option);
                      } else {
                        _lookingFor.remove(option);
                      }
                    });
                  },
                  checkmarkColor: Colors.white,
                  selectedColor: Colors.white24,
                  backgroundColor: Colors.black26,
                  labelStyle: const TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Languages
            _buildSectionLabel("Govorim (max 5)"),
            Wrap(
              spacing: 10,
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
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (s) {
                    setState(() {
                      if (s) {
                        if (_spokenLanguages.length < 5)
                          _spokenLanguages.add(option);
                      } else {
                        _spokenLanguages.remove(option);
                      }
                    });
                  },
                  checkmarkColor: Colors.white,
                  selectedColor: Colors.white24,
                  backgroundColor: Colors.black26,
                  labelStyle: const TextStyle(color: Colors.white),
                );
              }).toList(),
            ),

            const SizedBox(height: 40),
            Row(
              children: [
                TextButton(
                  onPressed: _prevPage,
                  child: const Text("Nazaj",
                      style: TextStyle(color: Colors.white70)),
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

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500)),
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
            Text("Nekaj malo več o tebi",
                style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 30),

            // Hobbies Categories
            _buildSectionLabel("Hobiji"),
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
                        return FilterChip(
                          label: Text(hobby),
                          selected: isSelected,
                          onSelected: (s) {
                            setState(() {
                              if (s) {
                                _selectedHobbies.add(hobby);
                              } else {
                                _selectedHobbies.remove(hobby);
                              }
                            });
                          },
                          checkmarkColor: Colors.white,
                          selectedColor: Colors.white24,
                          backgroundColor: Colors.black26,
                          labelStyle: const TextStyle(color: Colors.white),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            }),
            const SizedBox(height: 30),

            // Optional Prompts
            _buildSectionLabel("Zabaven dejstvo o meni (Opcijsko)"),
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
            }).take(
                2), // Show only top 2 for now to save space, user can see more if needed ideally

            const SizedBox(height: 40),
            Row(
              children: [
                TextButton(
                  onPressed: _prevPage,
                  child: const Text("Nazaj",
                      style: TextStyle(color: Colors.white70)),
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

  void _completeRegistration() async {
    // Show Congrats Animation logic...
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.partyPopper,
                  color: Colors.amber, size: 60),
              const SizedBox(height: 20),
              Text("Čestitke!",
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Uspešno ste ustvarili račun.",
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 30),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );

    // Save Data
    final user = AuthUser(
      id: 'generated_id', // In real app comes from backend
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
      isEmailVerified: false, // Default false
    );

    await Future.delayed(const Duration(seconds: 2)); // Mock animation delay

    if (mounted) {
      Navigator.of(context).pop(); // Close dialog
      ref.read(authStateProvider.notifier).completeOnboarding(user);
    }
  }
}
