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
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bio Section
                      _buildBioSection(),
                      const SizedBox(height: 20),

                      // What they're looking for
                      if (match.lookingFor.isNotEmpty) ...[
                        _buildLookingForSection(),
                        const SizedBox(height: 20),
                      ],

                      // Basic Info (Job, School, etc.)
                      _buildInfoBadges(),
                      const SizedBox(height: 20),

                      // Prompts
                      if (match.prompts.isNotEmpty) ...[
                        _buildPromptsSection(),
                        const SizedBox(height: 20),
                      ],

                      // Lifestyle & Habits
                      _buildLifestyleSection(),
                      const SizedBox(height: 20),

                      // Interests
                      _buildInterestsSection(),
                      const SizedBox(height: 20),

                      // Personality
                      if (match.introvertLevel != null)
                        _buildPersonalitySection(context),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Custom Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 450,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: false,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              match.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black12,
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${match.name}, ${match.age}",
                    style: GoogleFonts.outfit(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  if (match.jobTitle != null || match.school != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(LucideIcons.briefcase,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            [match.jobTitle, match.company]
                                .where((e) => e != null)
                                .join(' @ '),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (match.school != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.graduationCap,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          match.school!,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("O meni",
            style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 8),
        Text(
          match.bio,
          style:
              const TextStyle(fontSize: 16, height: 1.5, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildLookingForSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Iščem",
            style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: match.lookingFor
              .map((item) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.pinkAccent.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.heart,
                            size: 14, color: Colors.pinkAccent),
                        const SizedBox(width: 6),
                        Text(item,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildInfoBadges() {
    final items = <Widget>[];

    void addBadge(IconData icon, String text, [Color? color]) {
      items.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color ?? Colors.white70),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ));
    }

    if (match.jobTitle != null) {
      addBadge(LucideIcons.briefcase, match.jobTitle!);
    }
    if (match.school != null) {
      addBadge(LucideIcons.graduationCap, match.school!);
    }
    addBadge(LucideIcons.mapPin, "Ljubljana, 2km", Colors.pinkAccent);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items,
    );
  }

  Widget _buildPromptsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: match.prompts.map((prompt) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: GlassCard(
            borderRadius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prompt['question']!,
                    style: GoogleFonts.outfit(
                        fontSize: 14, color: Colors.pinkAccent)),
                const SizedBox(height: 8),
                Text(prompt['answer']!,
                    style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.2)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLifestyleSection() {
    final habits = <Widget>[];

    Widget buildHabitItem(IconData icon, String label, String value) {
      return Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white10,
            radius: 20,
            child: Icon(icon, size: 20, color: Colors.white70),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500)),
            ],
          )
        ],
      );
    }

    if (match.isSmoker != null) {
      habits.add(buildHabitItem(
          LucideIcons.cigarette, "Kajenje", match.isSmoker! ? "Da" : "Ne"));
    }
    if (match.drinkingHabit != null) {
      habits.add(
          buildHabitItem(LucideIcons.wine, "Alkohol", match.drinkingHabit!));
    }
    if (match.exerciseHabit != null) {
      habits.add(buildHabitItem(
          LucideIcons.dumbbell, "Telovadba", match.exerciseHabit!));
    }
    if (match.sleepSchedule != null) {
      habits.add(
          buildHabitItem(LucideIcons.moon, "Spanje", match.sleepSchedule!));
    }
    if (match.petPreference != null) {
      habits.add(buildHabitItem(
          LucideIcons.heart,
          "Ljubljenčki",
          match.petPreference == 'Dog person'
              ? '🐶 Dog person'
              : '🐱 Cat person'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Življenjski slog",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        GlassCard(
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: habits,
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Interesi",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: match.hobbies
              .map((h) => Chip(
                    label: Text(h,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500)),
                    backgroundColor: Colors.black54,
                    side: const BorderSide(color: Colors.white24),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.all(4),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPersonalitySection(BuildContext context) {
    final val = match.introvertLevel!.toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Osebnost",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        GlassCard(
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Introvert", style: TextStyle(color: Colors.white70)),
                  Text("Ekstrovert", style: TextStyle(color: Colors.white70)),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.pinkAccent,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.white,
                  disabledThumbColor: Colors.white,
                  disabledActiveTrackColor: Colors.pinkAccent,
                  disabledInactiveTrackColor: Colors.white24,
                ),
                child: Slider(
                  value: val,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: null,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
