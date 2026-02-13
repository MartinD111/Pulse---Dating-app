import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchProfile {
  final String id;
  final String name;
  final int age;
  final String imageUrl;
  final List<String> hobbies;
  final String bio;

  // New Fields
  final String? jobTitle;
  final String? company;
  final String? school;
  final bool? isSmoker; // true = Yes, false = No, null = Sometimes/Unknown
  final bool? isDrinker; // true = Yes, false = No
  final int? introvertLevel; // 1-5 scale (1=Introvert, 5=Extrovert)
  final List<Map<String, String>> prompts; // Question -> Answer
  final String gender; // 'Male', 'Female', 'Non-binary', etc.

  const MatchProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.hobbies,
    required this.bio,
    this.jobTitle,
    this.company,
    this.school,
    this.isSmoker,
    this.isDrinker,
    this.introvertLevel,
    this.prompts = const [],
    this.gender = 'Female',
  });
}

class MatchRepository {
  final _mockMatch = const MatchProfile(
    id: 'm1',
    name: 'Eva',
    age: 22,
    imageUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
    hobbies: ['Potovanja', 'Kava', 'Glasba', 'Šport'],
    bio:
        "Uživam v dobri kavi, sprehodih v naravi in spontanih izletih. Vedno za akcijo!",
    jobTitle: 'Grafična Oblikovalka',
    company: 'Freelance',
    school: 'ALUO',
    isSmoker: false,
    isDrinker: true,
    introvertLevel: 4, // More extroverted
    gender: 'Female',
    prompts: [
      {
        'question': 'Moj idealen zmenek...',
        'answer': 'Piknik na plaži ob sončnem zahodu s kozarcem vina.'
      },
      {
        'question': 'Najbolj sem ponosna na...',
        'answer': 'Da sem pretekla ljubljanski maraton prejšnje leto!'
      },
    ],
  );

  Stream<MatchProfile?> simulateMatches() async* {
    while (true) {
      // Simulate scanning delay
      await Future.delayed(const Duration(seconds: 2));
      yield _mockMatch;
      // Wait for interaction (handled by controller, this stream just emits)
      await Future.delayed(const Duration(seconds: 300));
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
