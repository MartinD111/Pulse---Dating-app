import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/ui/primary_button.dart';
import '../data/auth_repository.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final nameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  bool agreed = false;

  void submit() async {
    int age = int.tryParse(ageCtrl.text) ?? 0;
    if (nameCtrl.text.isEmpty || age < 18 || !agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Moraš biti star vsaj 18 let in se strinjati s pogoji.")),
      );
      return;
    }

    final currentUser = ref.read(authStateProvider);
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      name: nameCtrl.text,
      age: age,
      isOnboarded: true,
    );

    await ref.read(authStateProvider.notifier).completeOnboarding(updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text("Nastavi profil",
              style: GoogleFonts.outfit(
                  fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          // Styling for input fields should be moved to a shared component or theme in production
          TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Ime",
                hintStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70)),
              )),
          const SizedBox(height: 20),
          TextField(
              controller: ageCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Starost",
                hintStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70)),
              )),
          const Spacer(),
          Row(
            children: [
              Checkbox(
                  value: agreed,
                  onChanged: (v) => setState(() => agreed = v!),
                  side: const BorderSide(color: Colors.white)),
              const Expanded(
                  child: Text(
                "Strinjam se s Terms & Conditions",
                style: TextStyle(color: Colors.white),
              )),
            ],
          ),
          const SizedBox(height: 20),
          PrimaryButton(text: "Začni", onPressed: submit),
        ],
      ),
    );
  }
}
