import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'radar_animation.dart';
import '../../../shared/ui/glass_card.dart';
import '../../matches/data/match_repository.dart';
import '../../matches/presentation/match_dialog.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../map/presentation/pulse_map_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../matches/presentation/matches_screen.dart';
import '../../../shared/ui/primary_button.dart';
import '../../auth/data/auth_repository.dart';

final isScanningProvider =
    StateProvider<bool>((ref) => false); // Manual Toggle State

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

    final user = ref.watch(authStateProvider);
    final navIndex = ref.watch(navIndexProvider);
    final isScanning = ref.watch(isScanningProvider);
    final bool canAccessRadar =
        user?.isEmailVerified == true || user?.isAdmin == true;
    final bool isPremium = user?.isPremium == true;

    // Define Screen Lists based on Premium Status

    // BASIC: [0: Radar, 1: Matches, 2: Settings]
    // PREMIUM: [0: Radar, 1: Map, 2: Matches, 3: Settings]

    final List<Widget> screens = isPremium
        ? [
            // 0: Radar
            _buildRadarView(
                ref, context, canAccessRadar, isScanning, isPremium),
            // 1: Map
            const PulseMapScreen(),
            // 2: Matches
            const MatchesScreen(),
            // 3: Settings
            const SettingsScreen(),
          ]
        : [
            // 0: Radar
            _buildRadarView(
                ref, context, canAccessRadar, isScanning, isPremium),
            // 1: Matches
            const MatchesScreen(),
            // 2: Settings
            const SettingsScreen(),
          ];

    return Stack(
      children: [
        IndexedStack(
          index: navIndex,
          children: screens,
        ),

        // Navigation Bar
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: GlassCard(
            opacity: 0.5,
            borderColor: isPremium
                ? Colors.amber
                : Colors.white.withValues(alpha: 0.2), // Premium Gold Border
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Radar Icon (Always Index 0)
                IconButton(
                    icon: Icon(LucideIcons.radar,
                        color:
                            navIndex == 0 ? Colors.pinkAccent : Colors.white),
                    onPressed: () =>
                        ref.read(navIndexProvider.notifier).state = 0),

                // Map Icon (Premium Only - Index 1)
                if (isPremium)
                  IconButton(
                      icon: Icon(LucideIcons.map,
                          color:
                              navIndex == 1 ? Colors.pinkAccent : Colors.white),
                      onPressed: () =>
                          ref.read(navIndexProvider.notifier).state = 1),

                // Matches Icon (Basic: Index 1, Premium: Index 2)
                IconButton(
                    icon: Icon(LucideIcons.users,
                        color: navIndex == (isPremium ? 2 : 1)
                            ? Colors.pinkAccent
                            : Colors.white),
                    onPressed: () => ref.read(navIndexProvider.notifier).state =
                        isPremium ? 2 : 1),

                // Settings Icon (Basic: Index 2, Premium: Index 3)
                IconButton(
                    icon: Icon(LucideIcons.settings,
                        color: navIndex == (isPremium ? 3 : 2)
                            ? Colors.pinkAccent
                            : Colors.white),
                    onPressed: () => ref.read(navIndexProvider.notifier).state =
                        isPremium ? 3 : 2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadarView(WidgetRef ref, BuildContext context,
      bool canAccessRadar, bool isScanning, bool isPremium) {
    return Stack(
      children: [
        // Radar View (Conditional)
        canAccessRadar
            ? Stack(
                children: [
                  Positioned.fill(
                      child: RadarAnimation(isScanning: isScanning)),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        final newState = !isScanning;
                        ref.read(isScanningProvider.notifier).state = newState;

                        if (newState) {
                          debugPrint(
                              "📍 Location Captured: mock_lat: 46.05, mock_lng: 14.50 [Ljubljana]");
                          // In real app, call Location Service here
                          FlutterBackgroundService().startService();
                        } else {
                          // Stop service? Or just let it run but stop notifying?
                          // Simply invoking stop might kill the isolate
                          // FlutterBackgroundService().invoke("stopService");
                        }
                      },
                      child: GlassCard(
                        opacity: 0.1,
                        borderRadius: 100,
                        padding: const EdgeInsets.all(30),
                        child: Icon(
                            isScanning ? LucideIcons.radio : LucideIcons.play,
                            size: 60,
                            color: isScanning ? Colors.white : Colors.white70),
                      ),
                    ),
                  ),
                  if (isScanning)
                    Positioned(
                      bottom: 140,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          "Skeniranje...",
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 2),
                        ),
                      ),
                    )
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.lock,
                        size: 60, color: Colors.white54),
                    const SizedBox(height: 20),
                    Text(
                      "Radar je zaklenjen.",
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Prosim preveri svoj email za dostop.",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      text: "Pojdi v nastavitve",
                      width: 200,
                      onPressed: () {
                        ref.read(navIndexProvider.notifier).state =
                            isPremium ? 3 : 2; // Settings index varies
                      },
                    )
                  ],
                ),
              ),
      ],
    );
  }
}

final navIndexProvider = StateProvider<int>((ref) => 0);
