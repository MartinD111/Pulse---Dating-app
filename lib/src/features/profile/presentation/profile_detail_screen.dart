import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/ui/gradient_scaffold.dart';
import '../../../shared/ui/glass_card.dart';
import '../../matches/data/match_repository.dart';

class ProfileDetailScreen extends StatelessWidget {
  final MatchProfile match;

  const ProfileDetailScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Hero(
              tag: match.imageUrl,
              child: CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(match.imageUrl),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "${match.name}, ${match.age}",
              style:
                  GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GlassCard(
              child: Text(
                match.bio,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Interests",
                style: GoogleFonts.outfit(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: match.hobbies
                    .map((h) => Chip(
                          label: Text(h,
                              style: const TextStyle(color: Colors.white)),
                          backgroundColor: Colors.white24,
                          side: BorderSide.none,
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
