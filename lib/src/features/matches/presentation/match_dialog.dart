import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/ui/glass_card.dart';
import '../data/match_repository.dart';

class MatchDialog extends ConsumerWidget {
  final MatchProfile match;

  const MatchDialog({super.key, required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  ref
                      .read(matchControllerProvider.notifier)
                      .dismiss(); // Close dialog
                  context.push('/profile', extra: match); // Open full profile
                },
                child: GlassCard(
                  opacity: 0.9,
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image Area
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                          image: DecorationImage(
                            image: NetworkImage(match.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Name & Age
                            Text("${match.name}, ${match.age}",
                                style: GoogleFonts.outfit(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 8),

                            // Top 3 Hobbies
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              children: match.hobbies
                                  .take(3)
                                  .map((h) => Chip(
                                        label: Text(h,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12)),
                                        backgroundColor: Colors.white24,
                                        padding: EdgeInsets.zero,
                                        labelPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8),
                                        side: BorderSide.none,
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons (Outside the card)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Ignore Button
                  _ActionButton(
                    icon: LucideIcons.x,
                    color: Colors.redAccent,
                    onTap: () {
                      ref.read(matchControllerProvider.notifier).dismiss();
                    },
                  ),

                  // Greet Button
                  _ActionButton(
                    icon: LucideIcons.messageCircle,
                    color: Colors.greenAccent,
                    onTap: () {
                      ref.read(matchControllerProvider.notifier).like();
                      // Optionally show toast/snackbar here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Pozdrav poslan ${match.name}!")),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2)
            ]),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}
