import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchProfile {
  final String id;
  final String name;
  final int age;
  final String imageUrl;
  final List<String> hobbies;
  final String bio;

  const MatchProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.hobbies,
    required this.bio,
  });
}

class MatchRepository {
  final _mockMatch = const MatchProfile(
    id: 'm1',
    name: 'Ana',
    age: 24,
    imageUrl: 'https://i.pravatar.cc/150?u=ana',
    hobbies: ['Music', 'Art', 'Travel'],
    bio: "Živjo! Rad/a raziskujem nove kotičke mesta in uživam v dobri družbi.",
  );

  Stream<MatchProfile?> simulateMatches() async* {
    while (true) {
      // Simulate scanning delay
      await Future.delayed(const Duration(seconds: 10));
      yield _mockMatch;
      // Wait for interaction (handled by controller, this stream just emits)
      await Future.delayed(const Duration(seconds: 20));
    }
  }
}

final matchRepositoryProvider = Provider((ref) => MatchRepository());

final matchStreamProvider = StreamProvider<MatchProfile?>((ref) {
  return ref.watch(matchRepositoryProvider).simulateMatches();
});

// Controller to handle user actions (Like/Pass)
class MatchController extends StateNotifier<MatchProfile?> {
  MatchController() : super(null);

  void setMatch(MatchProfile? match) => state = match;
  void dismiss() => state = null;
  void like() => state = null; // In real app, send api request
}

final matchControllerProvider =
    StateNotifierProvider<MatchController, MatchProfile?>((ref) {
  return MatchController();
});
