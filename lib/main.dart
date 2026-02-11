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
// APP ROOT & THEME
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
        scaffoldBackgroundColor: Colors.transparent,
        primaryColor: const Color(0xFFE91E63),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF87CEEB),
          secondary: const Color(0xFFE91E63),
        ),
        textTheme: GoogleFonts.outfitTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const GradientScaffold(child: AuthSwitch()),
    );
  }
}

// -----------------------------------------------------------------------------
// STATE MANAGEMENT
// -----------------------------------------------------------------------------

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

class AuthState {
  final bool isAuthenticated;
  final bool isOnboarded;
  final String? name;
  final int? age;

  AuthState({this.isAuthenticated = false, this.isOnboarded = false, this.name, this.age});

  AuthState copyWith({bool? isAuthenticated, bool? isOnboarded, String? name, int? age}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  void login() => state = state.copyWith(isAuthenticated: true);
  
  void completeOnboarding(String name, int age) {
    state = state.copyWith(isOnboarded: true, name: name, age: age);
  }

  void logout() => state = AuthState();
}

final navIndexProvider = StateProvider<int>((ref) => 0);
final matchProvider = StateNotifierProvider<MatchNotifier, MatchEvent?>((ref) => MatchNotifier());

class MatchEvent {
  final String name;
  final String imageUrl;
  final int age;
  final List<String> hobbies;
  final String bio;

  MatchEvent({
    required this.name, 
    required this.imageUrl, 
    required this.age, 
    required this.hobbies,
    this.bio = "Živjo! Rad/a raziskujem nove kotičke mesta in uživam v dobri družbi.",
  });
}

class MatchNotifier extends StateNotifier<MatchEvent?> {
  Timer? _timer;
  MatchNotifier() : super(null);

  void startSimulation() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), () {
      state = MatchEvent(
        name: 'Ana', 
        imageUrl: 'https://i.pravatar.cc/150?u=ana', 
        age: 24,
        hobbies: ['Music', 'Art', 'Travel'],
      );
    });
  }

  void dismiss() { state = null; startSimulation(); }
  void wave() { state = null; startSimulation(); }
}

// -----------------------------------------------------------------------------
// UI COMPONENTS
// -----------------------------------------------------------------------------

class GradientScaffold extends StatelessWidget {
  final Widget child;
  const GradientScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF87CEEB), Color(0xFFE91E63)],
          ),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double opacity;
  const GlassCard({super.key, required this.child, this.opacity = 0.2});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;
  final IconData? icon;

  const PrimaryButton({super.key, required this.text, required this.onPressed, this.isSecondary = false, this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary ? Colors.white.withOpacity(0.2) : Colors.white,
        foregroundColor: isSecondary ? Colors.white : const Color(0xFFE91E63),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      onPressed: onPressed,
      icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
      label: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

// -----------------------------------------------------------------------------
// SCREENS
// -----------------------------------------------------------------------------

class AuthSwitch extends ConsumerWidget {
  const AuthSwitch({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) return const LoginScreen();
    if (!auth.isOnboarded) return const OnboardingScreen();
    return const MainScaffold();
  }
}

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.heartPulse, size: 80, color: Colors.white),
            const SizedBox(height: 10),
            Text("Pulse", style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            PrimaryButton(text: "Login with Email", onPressed: () => ref.read(authProvider.notifier).login()),
            const SizedBox(height: 15),
            PrimaryButton(text: "Continue with Google", icon: LucideIcons.chrome, isSecondary: true, onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final nameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  bool agreed = false;

  void submit(WidgetRef ref) {
    int age = int.tryParse(ageCtrl.text) ?? 0;
    if (nameCtrl.text.isEmpty || age < 18 || !agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Moraš biti star vsaj 18 let in se strinjati s pogoji.")),
      );
      return;
    }
    ref.read(authProvider.notifier).completeOnboarding(nameCtrl.text, age);
    ref.read(matchProvider.notifier).startSimulation();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text("Nastavi profil", style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: "Ime", hintStyle: TextStyle(color: Colors.white70))),
            TextField(controller: ageCtrl, decoration: const InputDecoration(hintText: "Starost", hintStyle: TextStyle(color: Colors.white70)), keyboardType: TextInputType.number),
            const Spacer(),
            Row(
              children: [
                Checkbox(value: agreed, onChanged: (v) => setState(() => agreed = v!), side: const BorderSide(color: Colors.white)),
                const Expanded(child: Text("Strinjam se s Terms & Conditions")),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(text: "Začni", onPressed: () => submit(ref)),
          ],
        ),
      );
    });
  }
}

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navIndex = ref.watch(navIndexProvider);
    ref.listen(matchProvider, (prev, next) {
      if (next != null) showMatchDialog(context, next, ref);
    });

    return Stack(
      children: [
        IndexedStack(index: navIndex, children: const [HomeScreen(), SettingsScreen()]),
        Positioned(
          bottom: 30, left: 20, right: 20,
          child: GlassCard(
            opacity: 0.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(icon: const Icon(LucideIcons.radar, color: Colors.white), onPressed: () => ref.read(navIndexProvider.notifier).state = 0),
                IconButton(icon: const Icon(LucideIcons.settings, color: Colors.white), onPressed: () => ref.read(navIndexProvider.notifier).state = 1),
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
      pageBuilder: (ctx, a1, a2) => Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GlassCard(
            opacity: 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Nekdo je blizu!", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                CircleAvatar(radius: 60, backgroundImage: NetworkImage(match.imageUrl)),
                const SizedBox(height: 10),
                Text("${match.name}, ${match.age}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, children: match.hobbies.map((h) => Chip(label: Text(h), backgroundColor: Colors.white24)).toList()),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: PrimaryButton(text: "Ignore", isSecondary: true, icon: LucideIcons.xCircle, onPressed: () { ref.read(matchProvider.notifier).dismiss(); Navigator.pop(ctx); })),
                    const SizedBox(width: 10),
                    Expanded(child: PrimaryButton(text: "Greet", icon: LucideIcons.hand, onPressed: () { ref.read(matchProvider.notifier).wave(); Navigator.pop(ctx); })),
                  ],
                ),
                TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileDetailScreen(match: match))), child: const Text("Ogled profila", style: TextStyle(color: Colors.white70))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Icon(LucideIcons.radio, size: 100, color: Colors.white24));
  }
}

class ProfileDetailScreen extends StatelessWidget {
  final MatchEvent match;
  const ProfileDetailScreen({super.key, required this.match});
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Column(
        children: [
          AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(LucideIcons.arrowLeft), onPressed: () => Navigator.pop(context))),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(radius: 80, backgroundImage: NetworkImage(match.imageUrl)),
                  const SizedBox(height: 20),
                  Text("${match.name}, ${match.age}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  GlassCard(child: Text(match.bio)),
                  const SizedBox(height: 20),
                  const Text("Interests", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 10, children: match.hobbies.map((h) => Chip(label: Text(h))).toList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text("Nastavitve", style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          GlassCard(child: Text("Prijavljen kot: ${auth.name}")),
          const Spacer(),
          PrimaryButton(text: "Odjava", isSecondary: true, onPressed: () => ref.read(authProvider.notifier).logout()),
        ],
      ),
    );
  }
}
