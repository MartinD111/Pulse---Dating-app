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
  final bool? isSmoker;
  final String? drinkingHabit; // 'Nikoli', 'Družabno', 'Ob priliki'
  final int? introvertLevel; // 1-5 scale (1=Introvert, 5=Extrovert)
  final List<Map<String, String>> prompts;
  final String gender;

  // Lifestyle
  final String? exerciseHabit; // 'Včasih', 'Ne', 'Redno', 'Zelo aktiven'
  final String? sleepSchedule; // 'Nočna ptica', 'Jutranja ptica'
  final String? petPreference; // 'Dog person', 'Cat person'
  final List<String> lookingFor;

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
    this.drinkingHabit,
    this.introvertLevel,
    this.prompts = const [],
    this.gender = 'Female',
    this.exerciseHabit,
    this.sleepSchedule,
    this.petPreference,
    this.lookingFor = const [],
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
    drinkingHabit: 'Družabno',
    introvertLevel: 4,
    gender: 'Female',
    exerciseHabit: 'Redno',
    sleepSchedule: 'Nočna ptica',
    petPreference: 'Cat person',
    lookingFor: ['Dolgoročno razmerje', 'Prijateljstvo'],
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
      await Future.delayed(const Duration(seconds: 2));
      yield _mockMatch;
      await Future.delayed(const Duration(seconds: 300));
    }
  }

  /// Check if a match is compatible based on gender preferences.
  /// Users with gender 'Ne želim povedati' only match with those
  /// whose interestedIn == 'Oba'.
  static bool isMatchCompatible({
    required String? userGender,
    required String? userInterestedIn,
    required String matchGender,
    required String? matchInterestedIn,
  }) {
    // If user chose 'Ne želim povedati', they can only be found
    // by people searching for 'Oba'
    if (userGender == 'Ne želim povedati') {
      if (matchInterestedIn != 'Oba') return false;
    }

    // If match chose 'Ne želim povedati', user must be searching 'Oba'
    if (matchGender == 'Ne želim povedati') {
      if (userInterestedIn != 'Oba') return false;
    }

    // Standard gender filtering
    if (userGender != 'Ne želim povedati' && matchInterestedIn != null) {
      if (matchInterestedIn != 'Oba' && matchInterestedIn != userGender) {
        return false;
      }
    }
    if (matchGender != 'Ne želim povedati' && userInterestedIn != null) {
      if (userInterestedIn != 'Oba' && userInterestedIn != matchGender) {
        return false;
      }
    }

    return true;
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
