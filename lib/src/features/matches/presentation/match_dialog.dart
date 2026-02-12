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

  IconData _getHobbyIcon(String hobby) {
    switch (hobby.toLowerCase()) {
      case 'music':
      case 'glasba':
        return LucideIcons.music;
      case 'art':
      case 'umetnost':
      case 'slikanje':
        return LucideIcons.palette;
      case 'travel':
      case 'potovanja':
        return LucideIcons.plane;
      case 'sport':
      case 'šport':
      case 'fitnes':
        return LucideIcons.dumbbell;
      case 'reading':
      case 'branje':
        return LucideIcons.book;
      case 'movies':
      case 'filmi':
        return LucideIcons.film;
      case 'gaming':
      case 'videoigre':
        return LucideIcons.gamepad2;
      default:
        return LucideIcons.star;
    }
  }

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
                      .dismiss(); // Close dialog state
                  if (context.canPop()) {
                    context.pop(); // Close dialog visually
                  }
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
                            // Name & Age - DARK TEXT for contrast on white glass
                            Text("${match.name}, ${match.age}",
                                style: GoogleFonts.outfit(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),

                            const SizedBox(height: 8),

                            // Top 3 Hobbies
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: match.hobbies.take(3).map((h) {
                                return Chip(
                                  avatar: Icon(_getHobbyIcon(h),
                                      size: 16, color: Colors.white),
                                  label: Text(h,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                  backgroundColor: Colors.black.withValues(
                                      alpha: 0.6), // Darker bg for contrast
                                  padding: const EdgeInsets.all(4),
                                  labelPadding: const EdgeInsets.only(right: 8),
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                );
                              }).toList(),
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
                  // Confirm/Tick Button (LEFT)
                  _ActionButton(
                    icon: LucideIcons.check,
                    color: Colors.greenAccent,
                    onTap: () {
                      ref.read(matchControllerProvider.notifier).like();
                      if (context.canPop()) {
                        context.pop();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Pozdrav poslan ${match.name}!")),
                      );
                    },
                  ),

                  // Ignore/X Button (RIGHT)
                  _ActionButton(
                    icon: LucideIcons.x,
                    color: Colors.redAccent,
                    onTap: () {
                      ref.read(matchControllerProvider.notifier).dismiss();
                      if (context.canPop()) {
                        context.pop(); // Explicitly close the dialog
                      }
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
            color: Colors.black
                .withValues(alpha: 0.6), // Dark background for buttons
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2)
            ]),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}
