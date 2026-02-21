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
  final String? childrenPreference; // 'Da', 'Ne', 'Da, ampak kasneje'
  final String? location; // Where the user is from

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
  final String appLanguage;
  final int ageRangeStart;
  final int ageRangeEnd;
  final bool showPingAnimation;
  final int maxDistance;

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
    this.childrenPreference,
    this.location,
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
    this.appLanguage = 'en',
    this.ageRangeStart = 18,
    this.ageRangeEnd = 100,
    this.showPingAnimation = true,
    this.maxDistance = 50,
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
    String? childrenPreference,
    String? location,
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
    String? appLanguage,
    int? ageRangeStart,
    int? ageRangeEnd,
    bool? showPingAnimation,
    int? maxDistance,
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
      childrenPreference: childrenPreference ?? this.childrenPreference,
      location: location ?? this.location,
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
      appLanguage: appLanguage ?? this.appLanguage,
      ageRangeStart: ageRangeStart ?? this.ageRangeStart,
      ageRangeEnd: ageRangeEnd ?? this.ageRangeEnd,
      showPingAnimation: showPingAnimation ?? this.showPingAnimation,
      maxDistance: maxDistance ?? this.maxDistance,
    );
  }
}

class AuthRepository {
  AuthUser? _currentUser;

  Future<AuthUser> loginWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Mock delay
    _currentUser = const AuthUser(
      id: 'user_123',
      name: 'Martin',
      age: 25,
      isOnboarded: true,
      gender: 'Moški',
      interestedIn: 'Ženska',
      ageRangeStart: 20,
      ageRangeEnd: 30,
      hobbies: ['Plezanje', 'Bordanje'],
      exerciseHabit: 'Redno',
      drinkingHabit: 'Družabno',
      sleepSchedule: 'Nočna ptica',
      petPreference: 'Dog person',
      childrenPreference: 'Da, ampak kasneje',
      location: 'Koper, Slovenija',
      occupation: 'Študent',
      isEmailVerified: true,
      isAdmin: true,
      isPremium: true,
      appLanguage: 'en',
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

  Future<void> resetPassword(String email, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock: pretend to find user by email and update password
    _currentUser = const AuthUser(
      id: 'user_123',
      name: 'Martin',
      age: 25,
      isOnboarded: true,
      gender: 'Moški',
      interestedIn: 'Ženska',
      ageRangeStart: 20,
      ageRangeEnd: 30,
      hobbies: ['Plezanje', 'Bordanje'],
      exerciseHabit: 'Redno',
      drinkingHabit: 'Družabno',
      sleepSchedule: 'Nočna ptica',
      petPreference: 'Dog person',
      childrenPreference: 'Da, ampak kasneje',
      location: 'Koper, Slovenija',
      occupation: 'Študent',
      isEmailVerified: true,
      isAdmin: true,
      isPremium: true,
      appLanguage: 'en',
    );
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock user password update
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(password: newPassword);
    }
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

  Future<void> resetPassword(String email, String newPassword) async {
    await _repository.resetPassword(email, newPassword);
    state = _repository.currentUser;
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _repository.changePassword(oldPassword, newPassword);
    state = _repository.currentUser;
  }
}
