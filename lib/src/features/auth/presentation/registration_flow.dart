import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../data/auth_repository.dart';
import 'radar_background.dart';
import '../../../core/translations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PAGE INDICES
// ─────────────────────────────────────────────────────────────────────────────
// 0  : Language
// 1  : Email / Password / Location
// 2  : Name
// 3  : Gender
// 4  : Birthday
// 5  : About you (menu list)
// 6  : Exercise sub-screen
// 7  : Drinking sub-screen
// 8  : Smoking sub-screen
// 9  : Children sub-screen
// 10 : Dating preferences
// 11 : What to meet
// 12 : Hobbies
// 13 : Photos
// 14 : Prompt
// ─────────────────────────────────────────────────────────────────────────────

class RegistrationFlow extends ConsumerStatefulWidget {
  const RegistrationFlow({super.key});

  @override
  ConsumerState<RegistrationFlow> createState() => _RegistrationFlowState();
}

class _RegistrationFlowState extends ConsumerState<RegistrationFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Language - initialize from global provider
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = ref.read(appLanguageProvider);
  }

  // Email/password/location
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  double _passwordStrength = 0.0;
  String _passwordStrengthLabel = '';
  Color _passwordStrengthColor = Colors.red;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;

  // Name
  final TextEditingController _nameController = TextEditingController();

  // Gender
  String? _selectedGender; // 'male' | 'female' | 'non_binary'

  // Birthday
  int _pickerMonth = DateTime.now().month;
  int _pickerDay = DateTime.now().day;
  int _pickerYear = DateTime.now().year - 22;
  bool _birthdayConfirmed = false;
  DateTime? _birthDate;

  // About you lifestyle
  String? _exerciseHabit; // 'active' | 'sometimes' | 'almost_never'
  String? _drinkingHabit; // 'socially' | 'never' | 'frequently' | 'sober'
  String? _smokingHabit; // 'yes' | 'no'
  String? _partnerSmokes; // 'no' | 'idc'
  String? _childrenPreference; // 'want_someday' | 'dont_want' | ...
  double _introversionLevel = 0.5; // 0.0 (Introvert) to 1.0 (Extrovert)
  String? _sleepHabit; // 'night_owl' | 'early_bird'
  String? _petPreference; // 'dog' | 'cat' | 'something_else' | 'nothing'
  final TextEditingController _customPetController = TextEditingController();
  int _languagesCount = 1;

  // Dating pref
  String? _datingPreference;
  RangeValues _ageRangePref = const RangeValues(18, 50);

  // What to meet
  final List<String> _wantToMeet = [];

  // Hobbies
  final List<String> _selectedHobbies = [];

  // Photos
  final List<File?> _photos = [null, null, null, null, null, null];
  final ImagePicker _picker = ImagePicker();

  // Prompt
  // Using a list of prompts and answers to allow swiping multiple?
  // User said: "one big square in middle, swajp levo or desno"
  String? _selectedPromptKey;
  final TextEditingController _promptAnswerController = TextEditingController();

  // helpers
  String tr(String key) => t(key, _selectedLanguage);

  void _nextPage() {
    // Notify user about verification email when leaving the email/password page
    if (_currentPage == 3) {
      _showVerificationNotification();
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage++);
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage--);
  }

  Future<void> _pickImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _photos[index] = File(image.path));
    }
  }

  void _updatePasswordStrength(String pw) {
    _hasMinLength = pw.length >= 8;
    _hasUppercase = pw.contains(RegExp(r'[A-Z]'));
    _hasDigit = pw.contains(RegExp(r'[0-9]'));
    _hasSpecialChar =
        pw.contains(RegExp(r'[!@#%^&*()_+\-=\[\]{};:,.<>?/\\|`~]'));
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUppercase) score++;
    if (_hasDigit) score++;
    if (_hasSpecialChar) score++;
    if (pw.length >= 12) score++;
    if (pw.length >= 16) score++;
    if (pw.contains(RegExp(r'[a-z]'))) score++;
    double strength = math.min(score / 5.0, 1.0);
    if (pw.isEmpty) strength = 0.0;
    String label;
    Color color;
    if (strength == 0) {
      label = '';
      color = Colors.red;
    } else if (strength < 0.3) {
      label = tr('very_weak');
      color = Colors.red;
    } else if (strength < 0.5) {
      label = tr('weak');
      color = Colors.orange;
    } else if (strength < 0.7) {
      label = tr('medium');
      color = Colors.amber;
    } else if (strength < 0.9) {
      label = tr('strong');
      color = Colors.lightGreen;
    } else {
      label = tr('very_strong');
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

  // ────── ZODIAC ──────
  String _zodiacSign(DateTime d) {
    final m = d.month;
    final day = d.day;
    if ((m == 1 && day >= 20) || (m == 2 && day <= 18)) return '♒ Aquarius';
    if ((m == 2 && day >= 19) || (m == 3 && day <= 20)) return '♓ Pisces';
    if ((m == 3 && day >= 21) || (m == 4 && day <= 19)) return '♈ Aries';
    if ((m == 4 && day >= 20) || (m == 5 && day <= 20)) return '♉ Taurus';
    if ((m == 5 && day >= 21) || (m == 6 && day <= 20)) return '♊ Gemini';
    if ((m == 6 && day >= 21) || (m == 7 && day <= 22)) return '♋ Cancer';
    if ((m == 7 && day >= 23) || (m == 8 && day <= 22)) return '♌ Leo';
    if ((m == 8 && day >= 23) || (m == 9 && day <= 22)) return '♍ Virgo';
    if ((m == 9 && day >= 23) || (m == 10 && day <= 22)) return '♎ Libra';
    if ((m == 10 && day >= 23) || (m == 11 && day <= 21)) return '♏ Scorpio';
    if ((m == 11 && day >= 22) || (m == 12 && day <= 21)) {
      return '♐ Sagittarius';
    }
    return '♑ Capricorn';
  }

  int _calcAge(DateTime d) =>
      (DateTime.now().difference(d).inDays / 365).floor();

  // ────── CONTINUE PILL ──────
  Widget _continueButton(
      {required bool enabled, required VoidCallback onTap, String? label}) {
    const teal = Color(0xFF00D9A6);
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: enabled ? teal : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(30),
          boxShadow: enabled
              ? [
                  BoxShadow(
                      color: teal.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2)
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label ?? tr('continue_btn'),
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: enabled ? Colors.black : Colors.white38,
            ),
          ),
        ),
      ),
    );
  }

  // ────── BACK BUTTON ──────
  Widget _backButton() => TextButton.icon(
        onPressed: _prevPage,
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Colors.white54, size: 16),
        label: Text(tr('back'),
            style: const TextStyle(color: Colors.white54, fontSize: 15)),
      );

  Widget _backButtonTo(int page) => TextButton.icon(
        onPressed: () {
          _pageController.animateToPage(page,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut);
          setState(() => _currentPage = page);
        },
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Colors.white54, size: 16),
        label: Text(tr('back'),
            style: const TextStyle(color: Colors.white54, fontSize: 15)),
      );

  // ────── PROGRESS BAR ──────
  Widget _buildProgressBar() {
    const totalSteps = 11;
    int step;
    if (_currentPage <= 4) {
      step = _currentPage + 1;
    } else if (_currentPage <= 9) {
      step = 6;
    } else {
      step = _currentPage - 3; // 10→7, 11→8, 12→9, 13→10, 14→11
    }
    final progress = step / totalSteps;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: progress),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (ctx, val, _) => LinearProgressIndicator(
        value: val,
        backgroundColor: Colors.white10,
        valueColor: const AlwaysStoppedAnimation(Color(0xFF00D9A6)),
        minHeight: 3,
      ),
    );
  }

  // ────── STEP HEADER ──────
  Widget _stepHeader(String title, {String? subtitle}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: GoogleFonts.outfit(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
      if (subtitle != null) ...[
        const SizedBox(height: 8),
        Text(subtitle,
            style: const TextStyle(
                color: Colors.white60, fontSize: 14, height: 1.4)),
      ],
    ]);
  }

  Widget _optionPill(String label, bool selected, VoidCallback onTap,
      {IconData? icon}) {
    const teal = Color(0xFF00D9A6);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: selected
              ? teal.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: selected ? teal : Colors.white38, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: selected ? teal : Colors.white70, size: 20),
              const SizedBox(width: 12)
            ],
            Text(label,
                style: TextStyle(
                    color: selected ? Colors.white : const Color(0xDDFFFFFF),
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500)),
            const Spacer(),
            if (selected) const Icon(Icons.check_circle, color: teal, size: 20),
          ],
        ),
      ),
    );
  }

  void _showVerificationNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('verification_email')),
        backgroundColor: const Color(0xFF00D9A6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color? accentColor;
    if (_selectedGender == 'male') {
      accentColor = Colors.cyan;
    } else if (_selectedGender == 'female') {
      accentColor = Colors.pinkAccent;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          RadarBackground(
            accentColor: accentColor,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildIntroSlide(0),
                _buildIntroSlide(1),
                _buildIntroSlide(2),
                _buildPageEmailPassword(),
                _buildPageName(),
                _buildPageGender(),
                _buildPageBirthday(),
                _buildPageAboutYouMenu(),
                _buildPageExercise(),
                _buildPageDrinking(),
                _buildPageSmoking(),
                _buildPageChildren(),
                _buildPageIntroversion(),
                _buildPageSleep(),
                _buildPagePets(),
                _buildPageLanguages(),
                _buildPageDatingPreferences(),
                _buildPageWhatToMeet(),
                _buildPageHobbies(),
                _buildPagePhotos(),
                _buildPagePrompt(),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildProgressBar(),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // INTRO SLIDES (0, 1, 2)
  // ══════════════════════════════════════════════════════
  Widget _buildIntroSlide(int index) {
    final titles = [tr('onb1_title'), tr('onb2_title'), tr('onb3_title')];
    final bodies = [tr('onb1_body'), tr('onb2_body'), tr('onb3_body')];
    final icons = [
      LucideIcons.heartPulse,
      LucideIcons.messagesSquare,
      LucideIcons.map
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icons[index], size: 100, color: const Color(0xFF00D9A6)),
            const SizedBox(height: 48),
            Text(
              titles[index],
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              bodies[index],
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16, color: Colors.white70, height: 1.6),
            ),
            const Spacer(),
            _continueButton(enabled: true, onTap: _nextPage),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // PAGE 3 – EMAIL / PASSWORD / LOCATION
  // ══════════════════════════════════════════════════════
  Widget _buildPageEmailPassword() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _backButton(),
            const SizedBox(height: 16),
            _stepHeader('Create account'),
            const SizedBox(height: 32),
            _inputField(tr('email'), _emailController,
                icon: LucideIcons.mail, keyboard: TextInputType.emailAddress),
            const SizedBox(height: 20),
            _locationAutocomplete(),
            const SizedBox(height: 20),
            _passwordInputField(),
            const SizedBox(height: 20),
            _confirmPasswordInputField(),
            if (_passwordController.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              _passwordStrengthBar(),
              const SizedBox(height: 8),
              _pwReq(tr('pw_min_length'), _hasMinLength),
              _pwReq(tr('pw_uppercase'), _hasUppercase),
              _pwReq(tr('pw_digit'), _hasDigit),
              _pwReq(tr('pw_special'), _hasSpecialChar),
              _pwReq(
                  tr('confirm_password'),
                  _passwordController.text == _confirmPasswordController.text &&
                      _confirmPasswordController.text.isNotEmpty),
            ],
            const SizedBox(height: 32),
            _continueButton(
              enabled: _emailController.text.isNotEmpty &&
                  _isPasswordValid &&
                  _passwordController.text == _confirmPasswordController.text,
              onTap: _nextPage,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl,
      {IconData? icon, TextInputType? keyboard}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white, fontSize: 17),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon:
            icon != null ? Icon(icon, color: Colors.white38, size: 20) : null,
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white30)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }

  Widget _passwordInputField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white, fontSize: 17),
      onChanged: _updatePasswordStrength,
      decoration: InputDecoration(
        labelText: tr('password'),
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon:
            const Icon(LucideIcons.lock, color: Colors.white38, size: 20),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white30)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
              color: Colors.white38, size: 20),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  Widget _passwordStrengthBar() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: _passwordStrength),
      duration: const Duration(milliseconds: 400),
      builder: (ctx, val, _) => Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
              height: 5,
              child: LinearProgressIndicator(
                value: val,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation(_passwordStrengthColor),
              )),
        ),
        const SizedBox(height: 4),
        Align(
            alignment: Alignment.centerRight,
            child: Text(_passwordStrengthLabel,
                style: TextStyle(
                    color: _passwordStrengthColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _confirmPasswordInputField() {
    return TextField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      style: const TextStyle(color: Colors.white, fontSize: 17),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: tr('confirm_password'),
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon:
            const Icon(LucideIcons.lock, color: Colors.white38, size: 20),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white30)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        suffixIcon: IconButton(
          icon: Icon(
              _obscureConfirmPassword ? LucideIcons.eyeOff : LucideIcons.eye,
              color: Colors.white38,
              size: 20),
          onPressed: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
      ),
    );
  }

  Widget _pwReq(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(children: [
        Icon(met ? LucideIcons.checkCircle2 : LucideIcons.circle,
            size: 14, color: met ? Colors.greenAccent : Colors.white30),
        const SizedBox(width: 6),
        Text(text,
            style: TextStyle(
                fontSize: 12,
                color: met ? Colors.greenAccent : Colors.white38,
                decoration: met ? TextDecoration.lineThrough : null,
                decorationColor: Colors.greenAccent.withValues(alpha: 0.5))),
      ]),
    );
  }

  Widget _locationAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (tv) {
        if (tv.text.isEmpty) return const Iterable<String>.empty();
        return locationSuggestions
            .where((c) => c.toLowerCase().contains(tv.text.toLowerCase()));
      },
      onSelected: (s) => setState(() => _locationController.text = s),
      fieldViewBuilder: (ctx, ctrl, fn, _) {
        if (_locationController.text.isNotEmpty && ctrl.text.isEmpty) {
          ctrl.text = _locationController.text;
        }
        return TextField(
          controller: ctrl,
          focusNode: fn,
          style: const TextStyle(color: Colors.white, fontSize: 17),
          onChanged: (v) {
            _locationController.text = v;
            setState(() {});
          },
          decoration: InputDecoration(
            labelText: tr('from_where'),
            labelStyle: const TextStyle(color: Colors.white60),
            prefixIcon:
                const Icon(LucideIcons.mapPin, color: Colors.white38, size: 20),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white30)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
          ),
        );
      },
      optionsViewBuilder: (ctx, onSel, opts) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 8,
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180, maxWidth: 340),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: opts.length,
              itemBuilder: (ctx, i) {
                final o = opts.elementAt(i);
                return ListTile(
                    dense: true,
                    leading: const Icon(LucideIcons.mapPin,
                        size: 14, color: Colors.white54),
                    title: Text(o, style: const TextStyle(color: Colors.white)),
                    onTap: () => onSel(o));
              },
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // PAGE 2 – NAME
  // ══════════════════════════════════════════════════════
  Widget _buildPageName() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _backButton(),
          const SizedBox(height: 40),
          _stepHeader(tr('whats_your_name')),
          const SizedBox(height: 48),
          TextField(
            controller: _nameController,
            autofocus: true,
            style: GoogleFonts.outfit(
                fontSize: 28, color: Colors.white, fontWeight: FontWeight.w500),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: tr('name_hint'),
              hintStyle:
                  GoogleFonts.outfit(fontSize: 28, color: Colors.white24),
              border: InputBorder.none,
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2)),
            ),
          ),
          const Spacer(),
          _continueButton(
              enabled: _nameController.text.trim().isNotEmpty,
              onTap: _nextPage),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // PAGE 3 – GENDER
  // ══════════════════════════════════════════════════════
  Widget _buildPageGender() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _backButton(),
          const SizedBox(height: 40),
          _stepHeader(tr('whats_your_gender')),
          const SizedBox(height: 40),
          _optionPill(tr('gender_male'), _selectedGender == 'male', () {
            setState(() => _selectedGender = 'male');
          }, icon: Icons.male),
          _optionPill(tr('gender_female'), _selectedGender == 'female', () {
            setState(() => _selectedGender = 'female');
          }, icon: Icons.female),
          _optionPill(tr('non_binary'), _selectedGender == 'non_binary', () {
            setState(() => _selectedGender = 'non_binary');
            _showNonBinaryPopup();
          }, icon: LucideIcons.userX),
          const Spacer(),
          _continueButton(enabled: _selectedGender != null, onTap: _nextPage),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showNonBinaryPopup() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.info, color: Color(0xFF00D9A6), size: 40),
            const SizedBox(height: 16),
            Text(tr('gender_nonbinary_popup_title'),
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(tr('gender_nonbinary_popup_body'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14, height: 1.5)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                    color: const Color(0xFF00D9A6),
                    borderRadius: BorderRadius.circular(30)),
                child: Center(
                    child: Text('OK',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 16))),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // PAGE 4 – BIRTHDAY
  // ══════════════════════════════════════════════════════
  Widget _buildPageBirthday() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final now = DateTime.now();
    final maxYear = now.year - 18;
    final minYear = now.year - 100;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _backButton(),
          const SizedBox(height: 24),
          _stepHeader(tr('whats_your_birthday'),
              subtitle: tr('birthday_subtitle')),
          const SizedBox(height: 32),
          // Drum picker
          SizedBox(
            height: 200,
            child: Row(children: [
              // Month
              Expanded(
                  child: _drumPicker(
                items: months,
                selectedIndex: _pickerMonth - 1,
                onChanged: (i) => setState(() => _pickerMonth = i + 1),
              )),
              // Day
              SizedBox(
                  width: 65,
                  child: _drumPicker(
                    items: List.generate(31, (i) => '${i + 1}'),
                    selectedIndex: _pickerDay - 1,
                    onChanged: (i) => setState(() => _pickerDay = i + 1),
                  )),
              // Year
              SizedBox(
                  width: 90,
                  child: _drumPicker(
                    items: List.generate(
                        maxYear - minYear + 1, (i) => '${maxYear - i}'),
                    selectedIndex: maxYear - _pickerYear,
                    onChanged: (i) => setState(() => _pickerYear = maxYear - i),
                  )),
            ]),
          ),
          const SizedBox(height: 20),
          // Preview chips
          Builder(builder: (_) {
            final d = DateTime(_pickerYear, _pickerMonth, _pickerDay);
            final age = _calcAge(d);
            final zodiac = _zodiacSign(d);
            return Row(children: [
              _chip('🎂 $age'),
              const SizedBox(width: 8),
              _chip(zodiac),
            ]);
          }),
          const Spacer(),
          _continueButton(
            enabled: true,
            onTap: () => _showBirthdayConfirmation(),
            label: _birthdayConfirmed ? tr('continue_btn') : tr('continue_btn'),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _drumPicker(
      {required List<String> items,
      required int selectedIndex,
      required ValueChanged<int> onChanged}) {
    final ctrl = FixedExtentScrollController(initialItem: selectedIndex);
    return ListWheelScrollView.useDelegate(
      controller: ctrl,
      itemExtent: 44,
      perspective: 0.004,
      diameterRatio: 1.8,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: items.length,
        builder: (ctx, i) {
          final selected = i == selectedIndex;
          return Center(
              child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.outfit(
              fontSize: selected ? 20 : 16,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? Colors.white : Colors.white38,
            ),
            child: Text(items[i]),
          ));
        },
      ),
    );
  }

  Widget _chip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white38)),
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 13)),
      );

  void _showBirthdayConfirmation() {
    final d = DateTime(_pickerYear, _pickerMonth, _pickerDay);
    final age = _calcAge(d);
    final dateStr = DateFormat('MMMM d, yyyy').format(d);
    const teal = Color(0xFF00D9A6);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: Colors.white12)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 28),
          Text(
            tr('youre_age').replaceAll('{age}', '$age'),
            style: GoogleFonts.outfit(
                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            tr('is_birthday_correct').replaceAll('{date}', dateStr),
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white60, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () {
              setState(() {
                _birthDate = d;
                _birthdayConfirmed = true;
              });
              Navigator.pop(ctx);
              _nextPage();
            },
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                  color: teal,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: teal.withValues(alpha: 0.4), blurRadius: 16)
                  ]),
              child: Center(
                  child: Text(tr('confirm_btn').toUpperCase(),
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                          letterSpacing: 1.2))),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('edit_btn').toUpperCase(),
                style: const TextStyle(
                    color: Colors.white54, letterSpacing: 1.2, fontSize: 13)),
          ),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // PAGE 5 – ABOUT YOU MENU
  // ══════════════════════════════════════════════════════
  Widget _buildPageAboutYouMenu() {
    bool allFilled = _exerciseHabit != null &&
        _drinkingHabit != null &&
        _smokingHabit != null &&
        _childrenPreference != null;

    String exerciseLabel() {
      if (_exerciseHabit == null) return '';
      switch (_exerciseHabit) {
        case 'active':
          return tr('exercise_active');
        case 'sometimes':
          return tr('exercise_sometimes');
        case 'almost_never':
          return tr('almost_never');
        default:
          return '';
      }
    }

    String drinkLabel() {
      if (_drinkingHabit == null) return '';
      switch (_drinkingHabit) {
        case 'socially':
          return tr('drink_socially');
        case 'never':
          return tr('drink_never');
        case 'frequently':
          return tr('drink_frequently');
        case 'sober':
          return tr('drink_sober');
        default:
          return '';
      }
    }

    String smokeLabel() => _smokingHabit == null
        ? ''
        : (_smokingHabit == 'yes' ? tr('smoke_yes') : tr('smoke_no'));

    String childrenLabel() =>
        _childrenPreference == null ? '' : tr(_childrenPreference!);
    String sleepLabel() => _sleepHabit == null ? '' : tr(_sleepHabit!);
    String petLabel() => _petPreference == null ? '' : tr(_petPreference!);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _backButton(),
          const SizedBox(height: 24),
          _stepHeader(tr('about_you_title')),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _menuRow(tr('do_you_exercise'), LucideIcons.dumbbell,
                    exerciseLabel(), () => _goToPage(8)),
                const Divider(color: Colors.white12),
                _menuRow(tr('do_you_drink'), LucideIcons.coffee, drinkLabel(),
                    () => _goToPage(9)),
                const Divider(color: Colors.white12),
                _menuRow(tr('do_you_smoke'), LucideIcons.wind, smokeLabel(),
                    () => _goToPage(10)),
                const Divider(color: Colors.white12),
                _menuRow(tr('do_you_want_children'), Icons.child_care,
                    childrenLabel(), () => _goToPage(11)),
                const Divider(color: Colors.white12),
                _menuRow(tr('introversion'), LucideIcons.user, '',
                    () => _goToPage(12)),
                const Divider(color: Colors.white12),
                _menuRow(tr('sleep'), LucideIcons.moon, sleepLabel(),
                    () => _goToPage(13)),
                const Divider(color: Colors.white12),
                _menuRow(tr('pets'), LucideIcons.dog, petLabel(),
                    () => _goToPage(14)),
                const Divider(color: Colors.white12),
                _menuRow(tr('i_speak'), LucideIcons.languages,
                    '$_languagesCount', () => _goToPage(15)),
              ],
            ),
          ),
          _continueButton(
            enabled: allFilled,
            onTap: () => _goToPage(16),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _goToPage(int page) {
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    setState(() => _currentPage = page);
  }

  Widget _menuRow(
      String title, IconData icon, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 16),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          if (value.isNotEmpty)
            Text(value,
                style: const TextStyle(color: Color(0xFF00D9A6), fontSize: 14)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.white30, size: 20),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // PAGE 6 – EXERCISE
  // ══════════════════════════════════════════════════════
  Widget _buildPageExercise() {
    return _subScreen(
      title: tr('do_you_exercise'),
      backTarget: 7,
      options: [
        {
          'key': 'active',
          'label': tr('exercise_active'),
          'icon': LucideIcons.zap
        },
        {
          'key': 'sometimes',
          'label': tr('exercise_sometimes'),
          'icon': LucideIcons.activity
        },
        {
          'key': 'almost_never',
          'label': tr('almost_never'),
          'icon': LucideIcons.moon
        },
      ],
      selected: _exerciseHabit,
      onSelect: (k) {
        setState(() => _exerciseHabit = k);
        Future.delayed(const Duration(milliseconds: 300), () {
          _goToPage(7);
        });
      },
    );
  }

  // ══════════════════════════════════════════════════════
  // PAGE 7 – DRINKING
  // ══════════════════════════════════════════════════════
  Widget _buildPageDrinking() {
    return _subScreen(
      title: tr('do_you_drink'),
      backTarget: 7,
      options: [
        {
          'key': 'socially',
          'label': tr('drink_socially'),
          'icon': LucideIcons.users
        },
        {'key': 'never', 'label': tr('drink_never'), 'icon': LucideIcons.ban},
        {
          'key': 'frequently',
          'label': tr('drink_frequently'),
          'icon': LucideIcons.trendingUp
        },
        {'key': 'sober', 'label': tr('drink_sober'), 'icon': LucideIcons.heart},
      ],
      selected: _drinkingHabit,
      onSelect: (k) {
        setState(() => _drinkingHabit = k);
        Future.delayed(const Duration(milliseconds: 300), () {
          _goToPage(7);
        });
      },
    );
  }

  // ══════════════════════════════════════════════════════
  // PAGE 10 – SMOKING (Updated with partner pref)
  // ══════════════════════════════════════════════════════
  Widget _buildPageSmoking() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _backButtonTo(7),
          const SizedBox(height: 24),
          _stepHeader(tr('do_you_smoke')),
          const SizedBox(height: 32),
          _optionPill(tr('smoke_yes'), _smokingHabit == 'yes',
              () => setState(() => _smokingHabit = 'yes')),
          _optionPill(tr('smoke_no'), _smokingHabit == 'no',
              () => setState(() => _smokingHabit = 'no')),
          if (_smokingHabit == 'no') ...[
            const SizedBox(height: 32),
            _stepHeader(tr('partner_smokes_q')),
            const SizedBox(height: 16),
            _optionPill(tr('no_pref'), _partnerSmokes == 'no',
                () => setState(() => _partnerSmokes = 'no')),
            _optionPill(tr('idc'), _partnerSmokes == 'idc',
                () => setState(() => _partnerSmokes = 'idc')),
          ],
          const Spacer(),
          _continueButton(
            enabled: _smokingHabit != null &&
                (_smokingHabit == 'yes' || _partnerSmokes != null),
            onTap: () => _goToPage(7),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _subScreen({
    required String title,
    required int backTarget,
    required List<Map<String, Object>> options,
    required String? selected,
    required ValueChanged<String> onSelect,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextButton.icon(
            onPressed: () {
              _goToPage(backTarget);
            },
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white54, size: 16),
            label: Text(tr('back'),
                style: const TextStyle(color: Colors.white54, fontSize: 15)),
          ),
          const SizedBox(height: 24),
          _stepHeader(title),
          const SizedBox(height: 40),
          ...options.map((o) => _optionPill(
                o['label'] as String,
                selected == o['key'],
                () => onSelect(o['key'] as String),
                icon: o['icon'] as IconData,
              )),
          const Spacer(),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // PAGE 9 – CHILDREN PREFERENCE
  // ══════════════════════════════════════════════════════
  Widget _buildPageChildren() {
    return _subScreen(
      title: tr('do_you_want_children'),
      backTarget: 7,
      options: [
        {
          'key': 'want_someday',
          'label': tr('children_want_someday'),
          'icon': LucideIcons.heart
        },
        {
          'key': 'dont_want',
          'label': tr('children_dont_want'),
          'icon': LucideIcons.ban
        },
        {
          'key': 'have_and_want_more',
          'label': tr('children_have_and_want_more'),
          'icon': LucideIcons.users
        },
        {
          'key': 'have_and_dont_want_more',
          'label': tr('children_have_and_dont_want_more'),
          'icon': LucideIcons.userCheck
        },
        {
          'key': 'not_sure',
          'label': tr('children_not_sure'),
          'icon': LucideIcons.helpCircle
        },
      ],
      selected: _childrenPreference,
      onSelect: (k) {
        setState(() => _childrenPreference = k);
        Future.delayed(const Duration(milliseconds: 300), () {
          _goToPage(7);
        });
      },
    );
  }

  // ══════════════════════════════════════════════════════
  // NEW LIFESTYLE SCREENS
  // ══════════════════════════════════════════════════════
  Widget _buildPageIntroversion() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(children: [
          _backButtonTo(7),
          const SizedBox(height: 40),
          _stepHeader(tr('introversion')),
          const SizedBox(height: 80),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(tr('introvert'),
                style: const TextStyle(color: Colors.white70)),
            Text(tr('extrovert'),
                style: const TextStyle(color: Colors.white70)),
          ]),
          Slider(
            value: _introversionLevel,
            onChanged: (v) => setState(() => _introversionLevel = v),
            activeColor: const Color(0xFF00D9A6),
            inactiveColor: Colors.white12,
          ),
          const Spacer(),
          _continueButton(enabled: true, onTap: () => _goToPage(7)),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _buildPageSleep() {
    return _subScreen(
      title: tr('sleep'),
      backTarget: 7,
      options: [
        {
          'key': 'night_owl',
          'label': tr('night_owl'),
          'icon': LucideIcons.moon
        },
        {
          'key': 'early_bird',
          'label': tr('early_bird'),
          'icon': LucideIcons.sun
        },
      ],
      selected: _sleepHabit,
      onSelect: (k) {
        setState(() => _sleepHabit = k);
        _goToPage(7);
      },
    );
  }

  Widget _buildPagePets() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(children: [
          _backButtonTo(7),
          const SizedBox(height: 24),
          _stepHeader(tr('pets')),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _optionPill(tr('dog_person'), _petPreference == 'dog',
                    () => setState(() => _petPreference = 'dog')),
                _optionPill(tr('cat_person'), _petPreference == 'cat',
                    () => setState(() => _petPreference = 'cat')),
                _optionPill(
                    tr('something_else'),
                    _petPreference == 'something_else',
                    () => setState(() => _petPreference = 'something_else')),
                if (_petPreference == 'something_else')
                  TextField(
                    controller: _customPetController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        hintText: tr('write_answer'),
                        hintStyle: const TextStyle(color: Colors.white30)),
                  ),
                _optionPill(tr('nothing'), _petPreference == 'nothing',
                    () => setState(() => _petPreference = 'nothing')),
              ],
            ),
          ),
          _continueButton(
              enabled: _petPreference != null, onTap: () => _goToPage(7)),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _buildPageLanguages() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(children: [
          _backButtonTo(7),
          const SizedBox(height: 40),
          _stepHeader(tr('how_many_languages')),
          const SizedBox(height: 48),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(5, (i) {
              final val = i + 1;
              final sel = _languagesCount == val;
              return GestureDetector(
                onTap: () => setState(() => _languagesCount = val),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFF00D9A6) : Colors.white12,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                      child: Text('$val',
                          style: TextStyle(
                              color: sel ? Colors.black : Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold))),
                ),
              );
            }),
          ),
          const Spacer(),
          _continueButton(enabled: true, onTap: () => _goToPage(7)),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // PAGE 16 – DATING PREFERENCES (Updated)
  // ══════════════════════════════════════════════════════
  Widget _buildPageDatingPreferences() {
    final opts = [
      {'key': 'short_term_fun', 'label': tr('short_term_fun')},
      {'key': 'long_term_partner', 'label': tr('long_term_partner')},
      {'key': 'short_open_long', 'label': tr('short_open_long')},
      {'key': 'long_open_short', 'label': tr('long_open_short')},
      {'key': 'undecided', 'label': tr('undecided')},
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _backButton(),
          const SizedBox(height: 24),
          _stepHeader(tr('dating_preference')),
          const SizedBox(height: 24),
          ...opts.map((o) => _optionPill(
              o['label']!,
              _datingPreference == o['key'],
              () => setState(() => _datingPreference = o['key']))),
          const SizedBox(height: 32),
          _stepHeader(tr('age_range')),
          const SizedBox(height: 16),
          RangeSlider(
            values: _ageRangePref,
            min: 18,
            max: 100,
            divisions: 82,
            labels: RangeLabels('${_ageRangePref.start.round()}',
                '${_ageRangePref.end.round()}'),
            onChanged: (v) => setState(() => _ageRangePref = v),
            activeColor: const Color(0xFF00D9A6),
          ),
          const Spacer(),
          _continueButton(enabled: _datingPreference != null, onTap: _nextPage),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // PAGE 11 – WHAT TO MEET
  // ══════════════════════════════════════════════════════
  Widget _buildPageWhatToMeet() {
    final opts = [
      {'key': 'male', 'label': tr('gender_male'), 'icon': Icons.male},
      {'key': 'female', 'label': tr('gender_female'), 'icon': Icons.female},
      {
        'key': 'non_binary',
        'label': tr('non_binary'),
        'icon': LucideIcons.userX
      },
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _backButton(),
          const SizedBox(height: 24),
          _stepHeader(tr('what_to_meet_title')),
          const SizedBox(height: 36),
          ...opts.map((o) {
            final k = o['key'] as String;
            final sel = _wantToMeet.contains(k);
            return _optionPill(o['label'] as String, sel, () {
              setState(() {
                if (sel) {
                  _wantToMeet.remove(k);
                } else {
                  _wantToMeet.add(k);
                }
              });
            }, icon: o['icon'] as IconData);
          }),
          const Spacer(),
          _continueButton(enabled: _wantToMeet.isNotEmpty, onTap: _nextPage),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // PAGE 18 – HOBBIES (Improved)
  // ══════════════════════════════════════════════════════
  Widget _buildPageHobbies() {
    final Map<String, List<String>> cats = {
      'Active 🏋️': [
        'Fitnes',
        'Pilates',
        'Sprehodi',
        'Tek',
        'Smučanje',
        'Snowboarding',
        'Plezanje',
        'Plavanje'
      ],
      'Prosti čas ☕': [
        'Branje',
        'Kava',
        'Čaj',
        'Kuhanje',
        'Filmi',
        'Serije',
        'Videoigre',
        'Glasba'
      ],
      'Umetnost 🎨': [
        'Slikanje',
        'Fotografija',
        'Pisanje',
        'Muzeji',
        'Gledališče'
      ],
      'Potovanja ✈️': ['Roadtrips', 'Camping', 'City breaks', 'Backpacking'],
    };
    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _backButton(),
            const SizedBox(height: 16),
            _stepHeader(tr('hobbies'),
                subtitle:
                    '${_selectedHobbies.length} ${tr('hobbies_selected').replaceAll('{count}', '')}'),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...cats.entries.map((e) => Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(
                          '${e.key} (${e.value.where((h) => _selectedHobbies.contains(h)).length})',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      collapsedIconColor: Colors.white,
                      iconColor: const Color(0xFF00D9A6),
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ...e.value.map((hobby) {
                              final sel = _selectedHobbies.contains(hobby);
                              return FilterChip(
                                label: Text(hobby,
                                    style: TextStyle(
                                        color: sel
                                            ? Colors.black
                                            : Colors.white70)),
                                selected: sel,
                                onSelected: (s) => setState(() => s
                                    ? _selectedHobbies.add(hobby)
                                    : _selectedHobbies.remove(hobby)),
                                selectedColor: const Color(0xFF00D9A6),
                                backgroundColor: Colors.white12,
                                checkmarkColor: Colors.black,
                              );
                            }),
                            ActionChip(
                              label: Text(tr('add_own'),
                                  style: const TextStyle(color: Colors.black)),
                              backgroundColor: const Color(0xFF00D9A6),
                              onPressed: () => _showAddHobbyDialog(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  )),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: _continueButton(enabled: true, onTap: _nextPage),
        ),
      ]),
    );
  }

  void _showAddHobbyDialog() {
    final ctrl = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1E1E2E),
              title: Text(tr('add_hobby'),
                  style: const TextStyle(color: Colors.white)),
              content: TextField(
                  controller: ctrl,
                  style: const TextStyle(color: Colors.white),
                  autofocus: true),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(tr('cancel'))),
                TextButton(
                    onPressed: () {
                      if (ctrl.text.isNotEmpty) {
                        setState(() => _selectedHobbies.add(ctrl.text));
                        Navigator.pop(ctx);
                      }
                    },
                    child: Text(tr('add'),
                        style: const TextStyle(color: Color(0xFF00D9A6)))),
              ],
            ));
  }

  // ══════════════════════════════════════════════════════
  // PAGE 13 – PHOTOS
  // ══════════════════════════════════════════════════════
  Widget _buildPagePhotos() {
    final hasAtLeastOne = _photos.any((p) => p != null);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _backButton(),
          const SizedBox(height: 24),
          _stepHeader(tr('select_photo_title')),
          const SizedBox(height: 8),
          Text(tr('photos_hint'),
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: 6,
              itemBuilder: (ctx, i) => GestureDetector(
                onTap: () => _pickImage(i),
                child: Stack(clipBehavior: Clip.none, children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: _photos[i] != null
                              ? const Color(0xFF00D9A6)
                              : Colors.white24),
                      image: _photos[i] != null
                          ? DecorationImage(
                              image: FileImage(_photos[i]!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _photos[i] == null
                        ? const Center(
                            child: Icon(Icons.add,
                                color: Colors.white38, size: 28))
                        : null,
                  ),
                  if (i == 0)
                    Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                              color: Colors.amber, shape: BoxShape.circle),
                          child: const Icon(Icons.star,
                              size: 10, color: Colors.black),
                        )),
                  if (_photos[i] != null)
                    Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () => setState(() => _photos[i] = null),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                                color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close,
                                size: 12, color: Colors.white),
                          ),
                        )),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _continueButton(enabled: hasAtLeastOne, onTap: _nextPage),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // PAGE 20 – PROMPT (Swiping Cards)
  // ══════════════════════════════════════════════════════
  Widget _buildPagePrompt() {
    final promptKeys = [
      'prompt_1',
      'prompt_2',
      'prompt_3',
      'prompt_4',
      'prompt_5',
      'prompt_6',
      'prompt_7',
      'prompt_8',
      'prompt_9',
      'prompt_10'
    ];
    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _backButton(),
            const SizedBox(height: 16),
            _stepHeader(tr('select_prompt_title')),
          ]),
        ),
        Expanded(
          child: PageView.builder(
            itemCount: promptKeys.length,
            controller: PageController(viewportFraction: 0.85),
            itemBuilder: (ctx, i) {
              final pk = promptKeys[i];
              final sel = _selectedPromptKey == pk;
              return Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 400,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: sel ? const Color(0xFF00D9A6) : Colors.white12,
                        width: sel ? 3 : 1),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                                color: const Color(0xFF00D9A6)
                                    .withValues(alpha: 0.2),
                                blurRadius: 20)
                          ]
                        : [],
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(tr(pk),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        TextField(
                          onChanged: (v) =>
                              setState(() => _selectedPromptKey = pk),
                          onTap: () => setState(() => _selectedPromptKey = pk),
                          controller: sel ? _promptAnswerController : null,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          decoration: InputDecoration(
                              hintText: tr('write_answer'),
                              hintStyle: const TextStyle(color: Colors.white24),
                              border: InputBorder.none),
                        ),
                      ]),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: _continueButton(enabled: true, onTap: completeRegistration),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════
  // COMPLETE REGISTRATION
  // ══════════════════════════════════════════════════════
  void completeRegistration() async {
    final photoUrls =
        _photos.where((p) => p != null).map((p) => p!.path).toList();
    final Map<String, String> prompts = {};
    if (_selectedPromptKey != null && _promptAnswerController.text.isNotEmpty) {
      prompts[_selectedPromptKey!] = _promptAnswerController.text;
    }

    final genderMap = {
      'male': 'Moški',
      'female': 'Ženska',
      'non_binary': 'Nebinarno'
    };
    final datingMap = {
      'short_term_fun': 'Kratkoročna zabava',
      'long_term_partner': 'Dolgoročni partner',
      'short_open_long': 'Kratkoročno, odprto za dolgo',
      'long_open_short': 'Dolgoročno, odprto za kratko',
      'undecided': 'Neodločen',
    };

    final user = AuthUser(
      id: 'generated_id',
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      photoUrls: photoUrls,
      age: _birthDate != null ? _calcAge(_birthDate!) : 20,
      birthDate: _birthDate,
      gender: genderMap[_selectedGender ?? 'male'],
      location:
          _locationController.text.isNotEmpty ? _locationController.text : null,
      interestedIn: _wantToMeet.join(', '),
      isSmoker: _smokingHabit == 'yes',
      occupation: 'Študent',
      drinkingHabit: _drinkingHabit ?? 'never',
      introvertScale: 3,
      exerciseHabit: _exerciseHabit ?? 'sometimes',
      sleepSchedule: 'Nočna ptica',
      petPreference: 'Dog person',
      childrenPreference: _childrenPreference ?? 'not_sure',
      lookingFor: _datingPreference != null
          ? [datingMap[_datingPreference!] ?? _datingPreference!]
          : [],
      languages: [],
      hobbies: _selectedHobbies,
      prompts: prompts,
      isOnboarded: true,
      isEmailVerified: false,
      ageRangeStart: 18,
      ageRangeEnd: 45,
      appLanguage: _selectedLanguage,
    );

    await ref.read(authStateProvider.notifier).completeOnboarding(user);
    if (mounted) {
      context.go('/onboarding');
    }
  }
}
