import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'radar_animation.dart';
import '../../../shared/ui/glass_card.dart';
import '../../matches/data/match_repository.dart';
import '../../matches/presentation/match_dialog.dart';
import '../../settings/presentation/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the stream and update controller
    ref.listen(matchStreamProvider, (prev, next) {
      next.whenData((match) {
        if (match != null) {
          ref.read(matchControllerProvider.notifier).setMatch(match);
        }
      });
    });

    // Listen to controller to show dialog
    ref.listen(matchControllerProvider, (prev, match) {
      if (match != null) {
        showGeneralDialog(
          context: context,
          pageBuilder: (ctx, a1, a2) => MatchDialog(match: match),
          barrierDismissible: true,
          barrierLabel: "Dismiss",
          barrierColor: Colors.black54,
          transitionDuration: const Duration(milliseconds: 200),
        ).then((_) {
          // Ensure controller is cleared if dialog is dismissed via barrier
          ref.read(matchControllerProvider.notifier).dismiss();
        });
      }
    });

    final navIndex = ref.watch(navIndexProvider);

    return Stack(
      children: [
        IndexedStack(
          index: navIndex,
          children: const [
            Stack(
              // Radar View
              children: [
                Positioned.fill(child: RadarAnimation()),
                Center(
                  child: GlassCard(
                    opacity: 0.1,
                    borderRadius: 100,
                    padding: EdgeInsets.all(30),
                    child:
                        Icon(LucideIcons.radio, size: 60, color: Colors.white),
                  ),
                ),
              ],
            ),
            SettingsScreen(),
          ],
        ),
        if (navIndex == 0) // Only show searching text on Radar view
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: const Text(
                "Searching for nearby matches...",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: GlassCard(
            opacity: 0.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    icon: const Icon(LucideIcons.radar, color: Colors.white),
                    onPressed: () =>
                        ref.read(navIndexProvider.notifier).state = 0),
                IconButton(
                    icon: const Icon(LucideIcons.settings, color: Colors.white),
                    onPressed: () =>
                        ref.read(navIndexProvider.notifier).state = 1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final navIndexProvider = StateProvider<int>((ref) => 0);
