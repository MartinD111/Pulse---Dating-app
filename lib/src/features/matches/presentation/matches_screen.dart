import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/ui/glass_card.dart';

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
                  child: GlassCard(
                    opacity: 0.15,
                    borderRadius: 50, // Pill shape
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: match.wantToMatchAgain,
                            activeThumbColor: Colors.white,
                            activeTrackColor: Colors.pinkAccent,
                            inactiveThumbColor: Colors.white70,
                            inactiveTrackColor: Colors.white12,
                            thumbColor: WidgetStateProperty.resolveWith<Color>(
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
                        const SizedBox(width: 5),
                      ],
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
