import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
  bool _isEditMode = false;

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

  void _removeMatch(int index) {
    final match = _matches[index];
    setState(() {
      _matches.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${match.name} odstranjen/-a'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Razveljavi',
          textColor: Colors.pinkAccent,
          onPressed: () {
            setState(() {
              _matches.insert(index, match);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with edit button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text("Ljudje",
                    style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              GestureDetector(
                onTap: () => setState(() => _isEditMode = !_isEditMode),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isEditMode
                        ? Colors.pinkAccent.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isEditMode ? Colors.pinkAccent : Colors.white24,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isEditMode ? LucideIcons.check : LucideIcons.pencil,
                        size: 14,
                        color: _isEditMode ? Colors.pinkAccent : Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isEditMode ? 'Končaj' : 'Uredi',
                        style: TextStyle(
                          color:
                              _isEditMode ? Colors.pinkAccent : Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Sub-headers
          Text("Upravljaj svoje pretekle stike",
              style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 5),
          Text(
            _isEditMode
                ? "Klikni X za odstranitev osebe"
                : "Ali želiš še kdaj jih srečati ali ne",
            style: TextStyle(
                color: _isEditMode
                    ? Colors.pinkAccent.withValues(alpha: 0.7)
                    : Colors.white70,
                fontSize: 14),
          ),

          const SizedBox(height: 20),
          Expanded(
            child: _matches.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.users,
                            size: 48, color: Colors.white24),
                        const SizedBox(height: 12),
                        Text('Ni matchev',
                            style: GoogleFonts.outfit(
                                color: Colors.white38, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _matches.length,
                    itemBuilder: (context, index) {
                      final match = _matches[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: _isEditMode
                              ? null
                              : () => _openProfile(context, match),
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
                                Expanded(
                                  child: Text("${match.name}, ${match.age}",
                                      style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 18)),
                                ),

                                // Toggle or Delete
                                if (_isEditMode)
                                  GestureDetector(
                                    onTap: () => _removeMatch(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.red.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.red
                                                .withValues(alpha: 0.4)),
                                      ),
                                      child: const Icon(LucideIcons.x,
                                          color: Colors.red, size: 18),
                                    ),
                                  )
                                else
                                  GestureDetector(
                                    onTap: () {},
                                    child: Transform.scale(
                                      scale: 0.8,
                                      child: Switch(
                                        value: match.wantToMatchAgain,
                                        activeThumbColor: Colors.white,
                                        activeTrackColor: Colors.pinkAccent,
                                        inactiveThumbColor: Colors.white70,
                                        inactiveTrackColor: Colors.white12,
                                        thumbColor: WidgetStateProperty
                                            .resolveWith<Color>((states) {
                                          if (states
                                              .contains(WidgetState.selected)) {
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
