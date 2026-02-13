import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthUser {
  final String id;
  final String? name;
  final int? age;
  final bool isOnboarded;
  final DateTime? birthDate;
  final List<String> photoUrls;
  final String? gender; // 'Moški', 'Ženska', 'Oba' (or english)
  final String? interestedIn; // 'Moški', 'Ženska', 'Oba'

  // Auth fields
  final String? email;
  final String? password;

  // New Preferences
  final bool? isSmoker; // User's status
  final String? partnerSmokingPreference; // 'Ne', 'Vseeno'

  final String? occupation; // 'Student', 'Employed'
  final String? drinkingHabit; // 'Nikoli', 'Družabno', 'Ob priliki'

  final int? introvertScale; // User's scale 1-5
  final String? partnerIntrovertPreference; // 'Introvert', 'Extrovert', 'Idc'

  // Lifestyle
  final String? exerciseHabit; // 'Včasih', 'Ne', 'Redno', 'Zelo aktiven'
  final String? sleepSchedule; // 'Nočna ptica', 'Jutranja ptica'
  final String? petPreference; // 'Dog person', 'Cat person'

  final List<String> lookingFor; // 'Short-term', 'Long-term', etc.
  final List<String> languages;
  final List<String> hobbies;
  final Map<String, String> prompts;
  final bool isEmailVerified;
  final bool isAdmin;
  final bool isPremium;

  // Theme Settings
  final bool isDarkMode;
  final bool isPrideMode;

  final int ageRangeStart;
  final int ageRangeEnd;

  const AuthUser({
    required this.id,
    this.name,
    this.age,
    this.birthDate,
    this.email,
    this.password,
    this.photoUrls = const [],
    this.gender,
    this.interestedIn,
    this.isSmoker,
    this.partnerSmokingPreference,
    this.occupation,
    this.drinkingHabit,
    this.introvertScale,
    this.partnerIntrovertPreference,
    this.exerciseHabit,
    this.sleepSchedule,
    this.petPreference,
    this.lookingFor = const [],
    this.languages = const [],
    this.hobbies = const [],
    this.prompts = const {},
    this.isOnboarded = false,
    this.isEmailVerified = false,
    this.isAdmin = false,
    this.isPremium = false,
    this.isDarkMode = false,
    this.isPrideMode = false,
    this.ageRangeStart = 18,
    this.ageRangeEnd = 100,
  });

  AuthUser copyWith({
    String? id,
    String? name,
    int? age,
    DateTime? birthDate,
    String? email,
    String? password,
    List<String>? photoUrls,
    String? gender,
    String? interestedIn,
    bool? isSmoker,
    String? partnerSmokingPreference,
    String? occupation,
    String? drinkingHabit,
    int? introvertScale,
    String? partnerIntrovertPreference,
    String? exerciseHabit,
    String? sleepSchedule,
    String? petPreference,
    List<String>? lookingFor,
    List<String>? languages,
    List<String>? hobbies,
    Map<String, String>? prompts,
    bool? isOnboarded,
    bool? isEmailVerified,
    bool? isAdmin,
    bool? isPremium,
    bool? isDarkMode,
    bool? isPrideMode,
    int? ageRangeStart,
    int? ageRangeEnd,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      birthDate: birthDate ?? this.birthDate,
      email: email ?? this.email,
      password: password ?? this.password,
      photoUrls: photoUrls ?? this.photoUrls,
      gender: gender ?? this.gender,
      interestedIn: interestedIn ?? this.interestedIn,
      isSmoker: isSmoker ?? this.isSmoker,
      partnerSmokingPreference:
          partnerSmokingPreference ?? this.partnerSmokingPreference,
      occupation: occupation ?? this.occupation,
      drinkingHabit: drinkingHabit ?? this.drinkingHabit,
      introvertScale: introvertScale ?? this.introvertScale,
      partnerIntrovertPreference:
          partnerIntrovertPreference ?? this.partnerIntrovertPreference,
      exerciseHabit: exerciseHabit ?? this.exerciseHabit,
      sleepSchedule: sleepSchedule ?? this.sleepSchedule,
      petPreference: petPreference ?? this.petPreference,
      lookingFor: lookingFor ?? this.lookingFor,
      languages: languages ?? this.languages,
      hobbies: hobbies ?? this.hobbies,
      prompts: prompts ?? this.prompts,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isAdmin: isAdmin ?? this.isAdmin,
      isPremium: isPremium ?? this.isPremium,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isPrideMode: isPrideMode ?? this.isPrideMode,
      ageRangeStart: ageRangeStart ?? this.ageRangeStart,
      ageRangeEnd: ageRangeEnd ?? this.ageRangeEnd,
    );
  }
}

class AuthRepository {
  AuthUser? _currentUser;

  Future<AuthUser> loginWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Mock delay
    _currentUser = const AuthUser(
      id: 'user_123',
      isOnboarded: true,
      gender: 'Moški', // Default to Male for testing Blue theme
      interestedIn: 'Oba', // Default to Both to test Pride Mode toggle
      ageRangeStart: 20,
      ageRangeEnd: 30,
      hobbies: ['Plezanje', 'Bordanje'],
      isEmailVerified: true,
      isAdmin: true,
      isPremium: true,
    );
    return _currentUser!;
  }

  Future<AuthUser> loginWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1)); // Mock delay
    // In a real app, this would get token from GoogleSignIn
    _currentUser = const AuthUser(
      id: 'google_user_456',
      name: 'Google User',
      isEmailVerified: true,
      gender: 'Moški',
      interestedIn: 'Oba',
    );
    return _currentUser!;
  }

  Future<void> updateProfile(AuthUser updatedUser) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_currentUser != null) {
      _currentUser = updatedUser;
    }
  }

  Future<void> completeOnboarding(AuthUser user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Set the user as logged in and onboarded
    _currentUser = user.copyWith(
        id: 'new_user_${DateTime.now().millisecondsSinceEpoch}',
        isOnboarded: true);
  }

  AuthUser? get currentUser => _currentUser;

  void logout() {
    _currentUser = null;
  }
}

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthUser?>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthUser?> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(null);

  Future<void> login(String email, String password) async {
    state = await _repository.loginWithEmail(email, password);
  }

  Future<void> loginWithGoogle() async {
    state = await _repository.loginWithGoogle();
  }

  Future<void> updateProfile(AuthUser user) async {
    await _repository.updateProfile(user);
    state = _repository.currentUser;
  }

  Future<void> completeOnboarding(AuthUser user) async {
    await _repository.completeOnboarding(user);
    state = _repository.currentUser;
  }

  void logout() {
    _repository.logout();
    state = null;
  }
}
