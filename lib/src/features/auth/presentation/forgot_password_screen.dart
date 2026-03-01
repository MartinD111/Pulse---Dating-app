import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/ui/primary_button.dart';
import '../data/auth_repository.dart';
import 'radar_background.dart';

/// Forgot Password flow (real Firebase):
/// 1. User enters email → Firebase sends reset link
/// 2. Confirmation shown — user clicks link in their email → resets on Firebase page
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  /// 0 = enter email, 1 = email sent confirmation
  int _step = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authStateProvider.notifier).sendPasswordReset(email);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _step = 1;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
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
}
