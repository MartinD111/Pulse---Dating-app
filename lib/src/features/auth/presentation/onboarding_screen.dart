import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_repository.dart';
import '../../../core/translations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String get _lang => ref.read(authStateProvider)?.appLanguage ?? 'en';
  String tr(String key) => t(key, _lang);

  final List<_OnboardingData> _slides = const [
    _OnboardingData(
      titleKey: 'onb1_title',
      bodyKey: 'onb1_body',
      emoji: '👋',
      gradient: [Color(0xFF0D3B2E), Color(0xFF0A1628)],
      accentColor: Color(0xFF00D9A6),
    ),
    _OnboardingData(
      titleKey: 'onb2_title',
      bodyKey: 'onb2_body',
      emoji: '🚫',
      gradient: [Color(0xFF2D1B4E), Color(0xFF0A1628)],
      accentColor: Color(0xFF9B59B6),
    ),
    _OnboardingData(
      titleKey: 'onb3_title',
      bodyKey: 'onb3_body',
      emoji: '🗺️',
      gradient: [Color(0xFF1A2C4E), Color(0xFF0A1628)],
      accentColor: Color(0xFF3498DB),
    ),
  ];

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      setState(() => _currentPage++);
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: slide.gradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 24, 0),
                  child: isLast
                      ? const SizedBox.shrink()
                      : TextButton(
                          onPressed: () => context.go('/'),
                          child: const Text('Skip',
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 14)),
                        ),
                ),
              ),
              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (ctx, i) => _buildSlide(_slides[i]),
                ),
              ),
              // Dots + button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (i) {
                        final active = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active ? slide.accentColor : Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),
                    // Continue button (always active)
                    GestureDetector(
                      onTap: _next,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: slide.accentColor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                                color: slide.accentColor.withValues(alpha: 0.4),
                                blurRadius: 16,
                                spreadRadius: 2)
                          ],
                        ),
                        child: Center(
                          child: Text(
                            isLast
                                ? tr('confirm_btn').toUpperCase()
                                : tr('continue_btn').toUpperCase(),
                            style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 1.2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(_OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji in glowing circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.accentColor.withValues(alpha: 0.12),
              border: Border.all(
                  color: data.accentColor.withValues(alpha: 0.4), width: 2),
              boxShadow: [
                BoxShadow(
                    color: data.accentColor.withValues(alpha: 0.2),
                    blurRadius: 32,
                    spreadRadius: 4)
              ],
            ),
            child: Center(
                child: Text(data.emoji, style: const TextStyle(fontSize: 52))),
          ),
          const SizedBox(height: 48),
          Text(
            tr(data.titleKey),
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 20),
          Text(
            tr(data.bodyKey),
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white60, fontSize: 15, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String titleKey;
  final String bodyKey;
  final String emoji;
  final List<Color> gradient;
  final Color accentColor;

  const _OnboardingData({
    required this.titleKey,
    required this.bodyKey,
    required this.emoji,
    required this.gradient,
    required this.accentColor,
  });
}
