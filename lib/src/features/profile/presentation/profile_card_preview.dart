import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/ui/glass_card.dart';
import '../../../shared/ui/gradient_scaffold.dart';
import '../../auth/data/auth_repository.dart';

class ProfileCardPreview extends ConsumerWidget {
  const ProfileCardPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);

    if (user == null) {
      return const GradientScaffold(
          child: Center(
              child: Text('No user', style: TextStyle(color: Colors.white))));
    }

    return GradientScaffold(
      child: CustomScrollView(
        slivers: [
          // App bar with edit button
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: Text('Moja kartica',
                style: GoogleFonts.outfit(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.pencil, color: Colors.white),
                tooltip: 'Uredi profil',
                onPressed: () => context.push('/edit-profile'),
              ),
            ],
          ),

          // Main photo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Hero photo
                  Container(
                    height: 360,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white10,
                      image: user.photoUrls.isNotEmpty
                          ? DecorationImage(
                              image: user.photoUrls.first.startsWith('http')
                                  ? NetworkImage(user.photoUrls.first)
                                  : FileImage(File(user.photoUrls.first))
                                      as ImageProvider,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: user.photoUrls.isEmpty
                        ? const Center(
                            child: Icon(Icons.person,
                                size: 80, color: Colors.white24))
                        : null,
                  ),

                  const SizedBox(height: 20),

                  // Name + Age
                  Text(
                    '${user.name ?? 'Guest'}, ${user.age ?? '?'}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Location
                  if (user.location != null && user.location!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.mapPin,
                            size: 16, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text(user.location!,
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 15)),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Info badges
                  _buildInfoBadges(user),

                  const SizedBox(height: 24),

                  // Hobbies
                  if (user.hobbies.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Hobiji',
                          style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.hobbies.map((h) {
                        return Chip(
                          label: Text(h,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500)),
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          side: const BorderSide(color: Colors.white24),
                          shape: const StadiumBorder(),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Lifestyle
                  _buildLifestyleSection(user),

                  const SizedBox(height: 24),

                  // Looking for
                  if (user.lookingFor.isNotEmpty) ...[
                    _buildSection('Iščem', user.lookingFor),
                    const SizedBox(height: 24),
                  ],

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadges(AuthUser user) {
    final badges = <Widget>[];

    if (user.gender != null) {
      badges.add(_badge(
          user.gender == 'Moški' ? LucideIcons.user : LucideIcons.user,
          user.gender!));
    }
    if (user.occupation != null) {
      badges.add(_badge(LucideIcons.briefcase, user.occupation!));
    }
    if (user.isSmoker == true) {
      badges.add(_badge(LucideIcons.cigarette, 'Kadilec'));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: badges,
    );
  }

  Widget _badge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white60),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildLifestyleSection(AuthUser user) {
    final items = <Widget>[];

    if (user.exerciseHabit != null) {
      items.add(_lifestyleItem(
          LucideIcons.dumbbell, 'Telovadba', user.exerciseHabit!));
    }
    if (user.drinkingHabit != null) {
      items.add(
          _lifestyleItem(LucideIcons.wine, 'Alkohol', user.drinkingHabit!));
    }
    if (user.sleepSchedule != null) {
      items.add(_lifestyleItem(
          user.sleepSchedule == 'Nočna ptica'
              ? LucideIcons.moon
              : LucideIcons.sun,
          'Spanje',
          user.sleepSchedule!));
    }
    if (user.petPreference != null) {
      items.add(_lifestyleItem(
          LucideIcons.heart, 'Ljubljenčki', user.petPreference!));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Življenjski slog',
              style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _lifestyleItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white54),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map((item) => Chip(
                      label: Text(item,
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      side: const BorderSide(color: Colors.white24),
                      shape: const StadiumBorder(),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
