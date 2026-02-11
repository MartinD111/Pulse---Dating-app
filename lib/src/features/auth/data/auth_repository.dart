import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthUser {
  final String id;
  final String? name;
  final int? age;
  final bool isOnboarded;

  const AuthUser({
    required this.id,
    this.name,
    this.age,
    this.isOnboarded = false,
  });

  AuthUser copyWith({String? name, int? age, bool? isOnboarded}) {
    return AuthUser(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      isOnboarded: isOnboarded ?? this.isOnboarded,
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

  Future<void> completeOnboarding(String name, int age) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_currentUser != null) {
      _currentUser =
          _currentUser!.copyWith(name: name, age: age, isOnboarded: true);
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

  Future<void> completeOnboarding(String name, int age) async {
    await _repository.completeOnboarding(name, age);
    state = _repository.currentUser;
  }

  void logout() {
    _repository.logout();
    state = null;
  }
}
