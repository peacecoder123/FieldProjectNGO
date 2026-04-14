import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';
import 'package:ngo_volunteer_management/shared/providers/feature_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading    = false;
  bool _obscure    = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email');
      return;
    }
    if (_passCtrl.text.isEmpty) {
      setState(() => _error = 'Please enter your password');
      return;
    }
    setState(() { _loading = true; _error = null; });

    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.login(
        email:    email,
        password: _passCtrl.text,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (user == null) {
        setState(() => _error = 'Invalid email or password. Please try again.');
        return;
      }

      ref.read(currentUserProvider.notifier).login(user);
      context.go(user.role.routePath);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Connection error. Please check your internet and try again.';
      });
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() { _loading = true; _error = null; });

    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.loginWithGoogle();

      if (!mounted) return;
      setState(() => _loading = false);

      if (user == null) {
        // User canceled Google Sign-In, don't show error.
        return;
      }

      ref.read(currentUserProvider.notifier).login(user);
      context.go(user.role.routePath);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        // The exception message contains the whitelist error. Clean it up for UI.
        final errorMsg = e.toString().contains('Exception:') 
            ? e.toString().split('Exception:').last.trim() 
            : 'Google Sign-in failed. Please try again.';
        _error = errorMsg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            size: 14, color: AppColors.slate400),
                        label: const Text('Back',
                            style: TextStyle(color: AppColors.slate400)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.navy600, AppColors.navy400],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'Sign in',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter your credentials to access the portal',
                            style: TextStyle(
                              color: AppColors.slate400,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Email
                          const _FieldLabel('Email'),
                          const SizedBox(height: 6),
                          _DarkTextField(
                            controller: _emailCtrl,
                            hint: 'your@email.com',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          const _FieldLabel('Password'),
                          const SizedBox(height: 6),
                          _DarkTextField(
                            controller: _passCtrl,
                            hint: '••••••••',
                            obscure: _obscure,
                            suffix: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.slate500,
                                size: 18,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),

                          // Error
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.red500.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AppColors.red500.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppColors.red500, size: 15),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(
                                        color: AppColors.red500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Submit
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.navy500,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Google Sign-In Or Divider
                          Row(
                            children: [
                              const Expanded(child: Divider(color: Color(0xFF334155))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: AppColors.slate500,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider(color: Color(0xFF334155))),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Google Auth Button
                          // Google Auth Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _loading ? null : _loginWithGoogle,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: Color(0xFF334155)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: const Color(0xFF0F172A),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Minimalist generic icon or a custom Google svg
                                  const Icon(Icons.g_mobiledata, color: Colors.white, size: 28),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Developer Tool: Quick Register
                          if (kDebugMode)
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                onPressed: () async {
                                  setState(() => _loading = true);
                                  try {
                                    final db = FirebaseFirestore.instance;
                                    final google = GoogleSignIn(
                                      clientId: kIsWeb ? '1093449762008-vau99kj7q90uou7aau2esvidn9unl2ak.apps.googleusercontent.com' : null,
                                    );
                                    final account = await google.signIn();
                                    if (account == null) throw Exception("Sign in cancelled");
                                    
                                    await db.collection('users').add({
                                      'email': account.email.toLowerCase().trim(),
                                      'name': account.displayName ?? 'New User',
                                      'role': 'superAdmin',
                                      'avatar': (account.displayName ?? 'U').substring(0, 1),
                                    });
                                    
                                    if (!mounted) return;
                                    setState(() {
                                      _loading = false;
                                      _error = "Success! '${account.email}' is now whitelisted. You can now login.";
                                    });
                                  } catch (e) {
                                    if (!mounted) return;
                                    setState(() {
                                      _loading = false;
                                      _error = "Whitelist failed: $e";
                                    });
                                  }
                                },
                                icon: const Icon(Icons.security, size: 16, color: AppColors.slate500),
                                label: const Text(
                                  '[DEBUG] Whitelist My Google Account',
                                  style: TextStyle(color: AppColors.slate500, fontSize: 11),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Credentials reference
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Login credentials',
                            style: TextStyle(
                              color: AppColors.slate400,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const _CredentialRow(
                            email: 'vikram@hopeconnect.org',
                            pass: 'vikram123',
                            role: 'Super Admin',
                          ),
                          const SizedBox(height: 8),
                          const _CredentialRow(
                            email: 'priya@hopeconnect.org',
                            pass: 'priya123',
                            role: 'Admin',
                          ),
                          const SizedBox(height: 8),
                          const _CredentialRow(
                            email: 'anjali@hopeconnect.org',
                            pass: 'anjali123',
                            role: 'Member',
                          ),
                          const SizedBox(height: 8),
                          const _CredentialRow(
                            email: 'rahul@hopeconnect.org',
                            pass: 'rahul123',
                            role: 'Volunteer',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.slate300,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      );
}

class _DarkTextField extends StatelessWidget {
  const _DarkTextField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.slate500),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.navy500, width: 2),
        ),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12,
        ),
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  const _CredentialRow({
    required this.email,
    required this.pass,
    required this.role,
  });

  final String email;
  final String pass;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: const TextStyle(
                    color: AppColors.slate200,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Password: $pass',
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.navy600.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              role,
              style: const TextStyle(
                color: AppColors.navy100,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined,
                color: AppColors.slate500, size: 16),
            onPressed: () {
              // Copy email to clipboard — handled by platform
            },
          ),
        ],
      ),
    );
  }
}
