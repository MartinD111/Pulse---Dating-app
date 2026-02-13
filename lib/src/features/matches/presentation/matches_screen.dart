import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/ui/glass_card.dart';
import '../../matches/data/match_repository.dart'; // Import MatchProfile

class MatchItem {
  final String name;
  final int age;
  final String imageUrl;
  bool wantToMatchAgain;

  MatchItem({
    required this.name,
    required this.age,
    required this.imageUrl,
    this.wantToMatchAgain = true,
  });
}

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  // Mock Data
  final List<MatchItem> _matches = [
    MatchItem(
        name: "Ana",
        age: 24,
        imageUrl: "https://randomuser.me/api/portraits/women/44.jpg"),
    MatchItem(
        name: "Marko",
        age: 28,
        imageUrl: "https://randomuser.me/api/portraits/men/32.jpg"),
    MatchItem(
        name: "Eva",
        age: 22,
        imageUrl: "https://randomuser.me/api/portraits/women/68.jpg"),
    MatchItem(
        name: "Luka",
        age: 26,
        imageUrl: "https://randomuser.me/api/portraits/men/85.jpg",
        wantToMatchAgain: false),
  ];

  void _openProfile(BuildContext context, MatchItem item) {
    final profile = MatchProfile(
      id: item.name,
      name: item.name,
      age: item.age,
      imageUrl: item.imageUrl,
      bio: item.name == "Eva"
          ? "Uživam v dobri kavi, sprehodih v naravi in spontanih izletih. Vedno za akcijo!"
          : "Rada potujem in spoznavam nove ljudi. Vedno za kavo in dober pogovor.",
      hobbies: item.name == "Eva"
          ? ["Potovanja", "Kava", "Glasba", "Šport"]
          : ["Knjige", "Kino", "Kuhanje"],
      jobTitle: item.name == "Eva" ? "Grafična Oblikovalka" : "Študentka",
      company: item.name == "Eva" ? "Freelance" : null,
      school: item.name == "Eva" ? "ALUO" : "Filozofska fakulteta",
      isSmoker: false,
      drinkingHabit: 'Družabno',
      introvertLevel: item.name == "Ana" ? 2 : 4,
      gender: 'Female',
      exerciseHabit: 'Včasih',
      sleepSchedule: item.name == "Eva" ? 'Nočna ptica' : 'Jutranja ptica',
      petPreference: item.name == "Eva" ? 'Cat person' : 'Dog person',
      lookingFor: item.name == "Eva"
          ? ['Dolgoročno razmerje', 'Prijateljstvo']
          : ['Kratkoročna zabava'],
      prompts: [
        {
          'question': 'Moj idealen zmenek...',
          'answer': 'Piknik na plaži ob sončnem zahodu s kozarcem vina.'
        },
        {
          'question': 'Zmano nikoli ni dolgčas, ker...',
          'answer': 'Vedno najdem neko novo avanturo.'
        }
      ],
    );

    context.push('/profile', extra: profile);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Ljudje",
              style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 10),

          // New Headers
          Text("Upravljaj svoje pretekle stike",
              style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 5),
          const Text("Ali želiš še kdaj jih srečati ali ne",
              style: TextStyle(color: Colors.white70, fontSize: 14)),

          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                final match = _matches[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => _openProfile(context, match),
                    child: GlassCard(
                      opacity: 0.15,
                      borderRadius: 50, // Pill shape
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(match.imageUrl),
                          ),
                          const SizedBox(width: 15),

                          // Name & Age
                          Text("${match.name}, ${match.age}",
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18)),

                          const Spacer(),

                          // Toggle
                          // Wrap switch in GestureDetector to prevent opening profile when toggling
                          GestureDetector(
                            onTap: () {}, // Capture tap to prevent bubbling
                            child: Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: match.wantToMatchAgain,
                                activeThumbColor: Colors.white,
                                activeTrackColor: Colors.pinkAccent,
                                inactiveThumbColor: Colors.white70,
                                inactiveTrackColor: Colors.white12,
                                thumbColor:
                                    WidgetStateProperty.resolveWith<Color>(
                                        (states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Colors.white;
                                  }
                                  return Colors.white70;
                                }),
                                onChanged: (val) {
                                  setState(() {
                                    match.wantToMatchAgain = val;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
