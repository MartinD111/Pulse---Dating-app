import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/ui/glass_card.dart';
import '../../../shared/ui/primary_button.dart';
import '../data/match_repository.dart';

class MatchDialog extends ConsumerWidget {
  final MatchProfile match;

  const MatchDialog({super.key, required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GlassCard(
          opacity: 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Nekdo je blizu!",
                  style: GoogleFonts.outfit(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              CircleAvatar(
                  radius: 60, backgroundImage: NetworkImage(match.imageUrl)),
              const SizedBox(height: 10),
              Text("${match.name}, ${match.age}",
                  style: GoogleFonts.outfit(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                  spacing: 8,
                  children: match.hobbies
                      .map((h) => Chip(
                            label: Text(h,
                                style: const TextStyle(color: Colors.white)),
                            backgroundColor: Colors.white24,
                            side: BorderSide.none,
                          ))
                      .toList()),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: PrimaryButton(
                          text: "Ignore",
                          isSecondary: true,
                          icon: LucideIcons.xCircle,
                          onPressed: () {
                            ref
                                .read(matchControllerProvider.notifier)
                                .dismiss();
                          })),
                  const SizedBox(width: 10),
                  Expanded(
                      child: PrimaryButton(
                          text: "Greet",
                          icon: LucideIcons.hand,
                          onPressed: () {
                            ref.read(matchControllerProvider.notifier).like();
                            // Show success animation or chat
                          })),
                ],
              ),
              TextButton(
                  onPressed: () {
                    // Navigate to Profile Details
                    context.push('/profile', extra: match);
                  },
                  child: const Text("Ogled profila",
                      style: TextStyle(color: Colors.white70))),
            ],
          ),
        ),
      ),
    );
  }
}
