import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthUser {
  final DateTime? birthDate;
  final List<String> photoUrls;
  final String? gender; // 'Male', 'Female', 'Both'
  final String? interestedIn; // 'Male', 'Female', 'Both'
  final bool? isSmoker;
  final String? occupation; // 'Student', 'Employed'
  final String? drinkingHabit; // 'Never', 'Occasionally', 'Regularly'
  final int? introvertScale; // 1-5
  final List<String> lookingFor; // 'Short-term', 'Long-term', etc.
  final List<String> languages;
  final List<String> hobbies;
  final Map<String, String> prompts;
  final bool isEmailVerified;
  final bool isAdmin;
  final bool isPremium;

  const AuthUser({
    required this.id,
    this.name,
    this.age,
    this.birthDate,
    this.photoUrls = const [],
    this.gender,
    this.interestedIn,
    this.isSmoker,
    this.occupation,
    this.drinkingHabit,
    this.introvertScale,
    this.lookingFor = const [],
    this.languages = const [],
    this.hobbies = const [],
    this.prompts = const {},
    this.isOnboarded = false,
    this.isEmailVerified = false,
    this.isAdmin = false,
    this.isPremium = false,
  });

  AuthUser copyWith({
    String? name,
    int? age,
    DateTime? birthDate,
    List<String>? photoUrls,
    String? gender,
    String? interestedIn,
    bool? isSmoker,
    String? occupation,
    String? drinkingHabit,
    int? introvertScale,
    List<String>? lookingFor,
    List<String>? languages,
    List<String>? hobbies,
    Map<String, String>? prompts,
    bool? isOnboarded,
    bool? isEmailVerified,
    bool? isAdmin,
    bool? isPremium,
  }) {
    return AuthUser(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      birthDate: birthDate ?? this.birthDate,
      photoUrls: photoUrls ?? this.photoUrls,
      gender: gender ?? this.gender,
      interestedIn: interestedIn ?? this.interestedIn,
      isSmoker: isSmoker ?? this.isSmoker,
      occupation: occupation ?? this.occupation,
      drinkingHabit: drinkingHabit ?? this.drinkingHabit,
      introvertScale: introvertScale ?? this.introvertScale,
      lookingFor: lookingFor ?? this.lookingFor,
      languages: languages ?? this.languages,
      hobbies: hobbies ?? this.hobbies,
      prompts: prompts ?? this.prompts,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isAdmin: isAdmin ?? this.isAdmin,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}

class AuthRepository {
  AuthUser? _currentUser;

  Future<AuthUser> loginWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Mock delay
    _currentUser = const AuthUser(id: 'user_123');
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
    if (_currentUser != null) {
      _currentUser = user.copyWith(isOnboarded: true);
    }
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
