import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/ui/primary_button.dart';
import '../data/auth_repository.dart';
import 'radar_background.dart';

/// Forgot Password flow:
/// 1. User enters email
/// 2. Mock "email sent" with confirmation
/// 3. User enters new password on same screen
/// 4. After saving → redirect to account (auto-login)
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  /// 0 = enter email, 1 = email sent / waiting, 2 = set new password, 3 = done
  int _step = 0;
  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }
    setState(() => _isLoading = true);
    // Mock sending email
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _step = 1;
      });
      // Auto-advance to step 2 after 2 seconds (simulating "clicking email link")
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _step = 2);
        }
      });
    }
  }

  Future<void> _saveNewPassword() async {
    if (_newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a new password')),
      );
      return;
    }
    if (_newPasswordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters')),
      );
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords don\'t match')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    // Mock: update the user's password and log them in
    final authNotifier = ref.read(authStateProvider.notifier);
    // Try to find user by email and update password
    await authNotifier.resetPassword(
        _emailController.text, _newPasswordController.text);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _step = 3;
      });

      // Auto-redirect to home after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.go('/');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RadarBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _buildCurrentStep(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildEmailSentStep();
      case 2:
        return _buildNewPasswordStep();
      case 3:
        return _buildDoneStep();
      default:
        return _buildEmailStep();
    }
  }

  Widget _buildEmailStep() {
    return Column(
      key: const ValueKey('email_step'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(LucideIcons.keyRound, size: 60, color: Colors.white),
        const SizedBox(height: 20),
        Text("Forgot Password",
            style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 10),
        Text("Enter your email to receive a reset link",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 15, color: Colors.white60)),
        const SizedBox(height: 40),

        // Email Field
        TextField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(LucideIcons.mail, color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white30),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(height: 25),

        if (_isLoading)
          const CircularProgressIndicator(color: Colors.white)
        else
          PrimaryButton(
            text: "Send Reset Email",
            onPressed: _sendResetEmail,
          ),

        const SizedBox(height: 20),
        TextButton(
          onPressed: () => context.pop(),
          child: const Text("Back to Login",
              style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }

  Widget _buildEmailSentStep() {
    return Column(
      key: const ValueKey('sent_step'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: const Icon(LucideIcons.mailCheck,
                  size: 70, color: Colors.greenAccent),
            );
          },
        ),
        const SizedBox(height: 25),
        Text("Email Sent!",
            style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 12),
        Text("Check your inbox for ${_emailController.text}",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 15)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.info,
                  color: Colors.lightBlueAccent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text("Click the link in the email to continue…",
                    style: GoogleFonts.outfit(
                        color: Colors.white70, fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep() {
    return Column(
      key: const ValueKey('new_pw_step'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(LucideIcons.shieldCheck, size: 60, color: Colors.white),
        const SizedBox(height: 20),
        Text("Set New Password",
            style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 10),
        Text("Create a strong new password",
            style: GoogleFonts.outfit(fontSize: 15, color: Colors.white60)),
        const SizedBox(height: 40),

        // New Password
        TextField(
          controller: _newPasswordController,
          obscureText: _obscureNew,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'New Password',
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(LucideIcons.lock, color: Colors.white70),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNew ? LucideIcons.eyeOff : LucideIcons.eye,
                color: Colors.white54,
              ),
              onPressed: () => setState(() => _obscureNew = !_obscureNew),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white30),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(height: 15),

        // Confirm Password
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(LucideIcons.lock, color: Colors.white70),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm ? LucideIcons.eyeOff : LucideIcons.eye,
                color: Colors.white54,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white30),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(height: 25),

        if (_isLoading)
          const CircularProgressIndicator(color: Colors.white)
        else
          PrimaryButton(
            text: "Save New Password",
            onPressed: _saveNewPassword,
          ),
      ],
    );
  }

  Widget _buildDoneStep() {
    return Column(
      key: const ValueKey('done_step'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 1),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: const Icon(LucideIcons.checkCircle,
                  color: Colors.greenAccent, size: 80),
            );
          },
        ),
        const SizedBox(height: 25),
        Text("Password Changed!",
            style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 12),
        Text("Redirecting to your account…",
            style: GoogleFonts.outfit(fontSize: 15, color: Colors.white60)),
        const SizedBox(height: 30),
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
        ),
      ],
    );
  }
}
