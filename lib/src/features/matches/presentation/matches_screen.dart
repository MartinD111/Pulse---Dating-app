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
          const SizedBox(height: 5),
          const Text("Upravljaj svoje pretekle stike",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                final match = _matches[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    opacity: 0.1,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(match.imageUrl),
                      ),
                      title: Text("${match.name}, ${match.age}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Switch(
                            value: match.wantToMatchAgain,
                            activeThumbColor: Colors.pinkAccent,
                            onChanged: (val) {
                              setState(() {
                                match.wantToMatchAgain = val;
                              });
                              // Logic to save preference would go here
                            },
                          ),
                        ],
                      ),
                      subtitle: Text(
                        match.wantToMatchAgain
                            ? "Ponovno matchanje: DA"
                            : "Ponovno matchanje: NE",
                        style: TextStyle(
                            color: match.wantToMatchAgain
                                ? Colors.greenAccent
                                : Colors.white38,
                            fontSize: 12),
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
