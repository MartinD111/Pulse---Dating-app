import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

// -----------------------------------------------------------------------------
// MAIN ENTRY POINT
// -----------------------------------------------------------------------------

void main() {
  runApp(
    const ProviderScope(
      child: PulseApp(),
    ),
  );
}

// -----------------------------------------------------------------------------
// APP ROOT & THEMED
// -----------------------------------------------------------------------------

class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.transparent, // Handled by gradient wrapper
        primaryColor: const Color(0xFFE91E63), // Rose Pinkish
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF87CEEB), // Sky Blue
          secondary: const Color(0xFFE91E63),
        ),
        textTheme: GoogleFonts.outfitTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const GradientScaffold(child: AuthSwitch()),
    );
  }
}

// -----------------------------------------------------------------------------
// STATE MANAGEMENT (PROVIDERS)
// -----------------------------------------------------------------------------

// Auth State
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

class AuthState {
  final bool isAuthenticated;
  final bool isOnboarded;
  final String? email;

  AuthState({this.isAuthenticated = false, this.isOnboarded = false, this.email});

  AuthState copyWith({bool? isAuthenticated, bool? isOnboarded, String? email}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      email: email ?? this.email,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  bool login(String email, String password) {
    if (email == 'admin' && password == 'admin') {
      state = state.copyWith(isAuthenticated: true, email: email);
      return true;
    }
    return false;
  }

  void completeOnboarding() {
    state = state.copyWith(isOnboarded: true);
  }
  
  void logout() {
    state = AuthState();
  }
}

// Tier State (Basic vs Advanced)
final tierProvider = StateProvider<bool>((ref) => false); // false = Basic, true = Advanced

// Navigation State
final navIndexProvider = StateProvider<int>((ref) => 0);

// Radar State
final radarRadiusProvider = Provider<double>((ref) {
  final isAdvanced = ref.watch(tierProvider);
  return isAdvanced ? 100.0 : 50.0;
});

// Match Simulation State
final matchProvider = StateNotifierProvider<MatchNotifier, MatchEvent?>((ref) => MatchNotifier());

class MatchEvent {
  final String name;
  final String imageUrl;
  final int age;

  MatchEvent({required this.name, required this.imageUrl, required this.age});
}

class MatchNotifier extends StateNotifier<MatchEvent?> {
  Timer? _timer;
  MatchNotifier() : super(null);

  void startSimulation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (state == null) {
        state = MatchEvent(
          name: 'Ana', 
          imageUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704d', 
          age: 24
        );
        timer.cancel();
      }
    });
  }

  void dismiss() {
    state = null;
    startSimulation();
  }
  
  void wave() {
    state = null;
    startSimulation();
  }
}

// -----------------------------------------------------------------------------
// UI COMPONENTS (The Design System)
// -----------------------------------------------------------------------------

class GradientScaffold extends StatelessWidget {
  final Widget child;
  const GradientScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFFE91E63),
            ],
          ),
        ),
        child: SafeArea(
          child: child,
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double blur;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const GlassCard({
    super.key,
    required this.child,
    this.opacity = 0.2,
    this.blur = 15.0,
    this.borderRadius,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(28.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(opacity),
              borderRadius: borderRadius ?? BorderRadius.circular(28.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.0,
              ),
              boxShadow: [
                 BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.9),
          foregroundColor: isSecondary ? Colors.white : const Color(0xFFE91E63),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class FloatingTextField extends StatelessWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController controller;

  const FloatingTextField({
    super.key,
    required this.hint,
    this.isPassword = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SCREENS & LOGIC
// -----------------------------------------------------------------------------

class AuthSwitch extends ConsumerWidget {
  const AuthSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      return const LoginScreen();
    }
    if (!authState.isOnboarded) {
      return const OnboardingScreen();
    }
    return const MainScaffold();
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  void _handleLogin() {
    final success = ref.read(authProvider.notifier).login(
          _emailCtrl.text,
          _passCtrl.text,
        );
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid credentials. Try admin/admin"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.heartPulse, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              "Pulse",
              style: GoogleFonts.outfit(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "Find your rhythm.",
              style: GoogleFonts.outfit(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 60),
            FloatingTextField(hint: "Email", controller: _emailCtrl),
            const SizedBox(height: 16),
            FloatingTextField(hint: "Password", isPassword: true, controller: _passCtrl),
            const SizedBox(height: 32),
            PrimaryButton(text: "Login", onPressed: _handleLogin),
            const SizedBox(height: 16),
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Container(height: 1, width: 60, color: Colors.white30),
                 const Padding(
                   padding: EdgeInsets.symmetric(horizontal: 10),
                   child: Text("OR", style: TextStyle(color: Colors.white60)),
                 ),
                 Container(height: 1, width: 60, color: Colors.white30),
               ],
             ),
             const SizedBox(height: 16),
             const GlassCard(
               padding: EdgeInsets.all(12),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(LucideIcons.chrome, color: Colors.white),
                   SizedBox(width: 10),
                   Text("Continue with Google", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                 ],
               ),
             )
          ],
        ),
      ),
    );
  }
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Text(
            "Setup Profile",
            style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: List.generate(4, (index) {
                return GlassCard(
                  child: Center(
                    child: Icon(LucideIcons.plus, color: Colors.white.withOpacity(0.5)),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          FloatingTextField(hint: "Full Name", controller: TextEditingController()),
          const SizedBox(height: 12),
          FloatingTextField(hint: "Age", controller: TextEditingController()),
          const SizedBox(height: 40),
          PrimaryButton(
            text: "Start Pulsing",
            onPressed: () {
              ref.read(authProvider.notifier).completeOnboarding();
              ref.read(matchProvider.notifier).startSimulation();
            },
          ),
        ],
      ),
    );
  }
}

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navIndex = ref.watch(navIndexProvider);
    
    ref.listen(matchProvider, (prev, next) {
      if (next != null) {
        showMatchDialog(context, next, ref);
      }
    });

    return Stack(
      children: [
        IndexedStack(
          index: navIndex,
          children: const [
            HomeScreen(),
            SettingsScreen(),
          ],
        ),
        
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: GlassCard(
            blur: 20,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: LucideIcons.radar, 
                  label: "Radar", 
                  isActive: navIndex == 0,
                  onTap: () => ref.read(navIndexProvider.notifier).state = 0,
                ),
                 _NavItem(
                  icon: LucideIcons.users, 
                  label: "Matches", 
                  isActive: false,
                   onTap: () {},
                ),
                 _NavItem(
                  icon: LucideIcons.messageCircle, 
                  label: "Chat", 
                  isActive: false,
                   onTap: () {},
                ),
                _NavItem(
                  icon: LucideIcons.settings, 
                  label: "Settings", 
                  isActive: navIndex == 1,
                  onTap: () => ref.read(navIndexProvider.notifier).state = 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void showMatchDialog(BuildContext context, MatchEvent match, WidgetRef ref) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Match",
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 100, left: 20, right: 20),
            child: Material(
              color: Colors.transparent,
              child: GlassCard(
                opacity: 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Someone is close!", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(match.imageUrl),
                    ),
                    const SizedBox(height: 12),
                    Text("${match.name}, ${match.age}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: "Ignore", 
                            isSecondary: true,
                            onPressed: () {
                              ref.read(matchProvider.notifier).dismiss();
                              Navigator.of(ctx).pop();
                            }
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            text: "Pozdrav", 
                            onPressed: () {
                              ref.read(matchProvider.notifier).wave();
                               Navigator.of(ctx).pop();
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text("Wave sent!"))
                               );
                            }
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            color: isActive ? const Color(0xFFE91E63) : Colors.white.withOpacity(0.6),
            size: 26,
          ),
          const SizedBox(height: 4),
          if (isActive)
            Container(
              width: 5, 
              height: 5, 
              decoration: const BoxDecoration(color: Color(0xFFE91E63), shape: BoxShape.circle)
            )
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HOME SCREEN (RADAR)
// -----------------------------------------------------------------------------

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = ref.watch(radarRadiusProvider);

    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: MediaQuery.of(context).size,
          painter: RadarPainter(_controller),
        ),
        
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
            boxShadow: [
              BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
            ],
          ),
          child: const Center(
            child: Icon(LucideIcons.radio, size: 40, color: Colors.white),
          ),
        ),

        Positioned(
          top: 60,
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Text(
                  "Scanning...",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
                Text("Radius: ${radius.toInt()}m"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RadarPainter extends CustomPainter {
  final Animation<double> animation;
  RadarPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, 100, paint);
    canvas.drawCircle(center, 200, paint);
    canvas.drawCircle(center, 300, paint);

    final pulsePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.white.withOpacity(1.0 - animation.value);

    canvas.drawCircle(center, 50.0 + (animation.value * 300), pulsePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// -----------------------------------------------------------------------------
// SETTINGS SCREEN
// -----------------------------------------------------------------------------

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(tierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Text(
            "Settings",
            style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          GlassCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Subscription Tier", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                        Text(isPremium ? "Advanced Plan" : "Basic Plan", style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                    Switch(
                      value: isPremium,
                      onChanged: (val) => ref.read(tierProvider.notifier).state = val,
                      activeThumbColor: const Color(0xFFE91E63),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          PrimaryButton(
            text: "Logout", 
            isSecondary: true,
            onPressed: () {
               ref.read(authProvider.notifier).logout();
            }
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
