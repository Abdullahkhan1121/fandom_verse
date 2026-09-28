import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'auth_gate.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _googleNameController = TextEditingController();
  final _googlePasswordController = TextEditingController();
  final _googleConfirmPasswordController = TextEditingController();

  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _obscureGooglePassword = true;
  bool _obscureGoogleConfirmPassword = true;

  bool _verificationSent = false;
  bool _showGoogleSetup = false;

  String? _verificationEmail;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _googleNameController.dispose();
    _googlePasswordController.dispose();
    _googleConfirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // NORMAL EMAIL REGISTRATION
  // ============================================================

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _verificationSent = true;
        _verificationEmail = _emailController.text.trim();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification email sent. Please verify your email before continuing.',
          ),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;

      _showError(_getRegistrationError(e));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getRegistrationError(Exception e) {
    final error = e.toString().toLowerCase();

    if (error.contains('email-already-in-use')) {
      return 'An account already exists with this email.';
    }

    if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }

    if (error.contains('weak-password')) {
      return 'Password is too weak.';
    }

    if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    }

    return 'Registration failed. Please try again.';
  }

  // ============================================================
  // RESEND VERIFICATION EMAIL
  // ============================================================

  Future<void> _resendVerificationEmail() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.resendVerificationEmail();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification email sent again. Please check your inbox.',
          ),
        ),
      );
    } on Exception catch (_) {
      if (!mounted) return;

      _showError(
        'Could not resend verification email. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // CHECK EMAIL VERIFICATION
  // ============================================================

  Future<void> _checkEmailVerification() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final verified =
          await _authService.checkEmailVerification();

      if (!mounted) return;

      if (verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email verified successfully! Welcome to Fandom Verse.',
            ),
          ),
        );

        // --------------------------------------------------------
        // IMPORTANT:
        //
        // DO NOT return to LoginScreen.
        //
        // The user is already authenticated. Open AuthGate again
        // so it reads the verified Firebase/Firestore state and
        // sends the user directly to:
        //
        // AdminPanelScreen OR FandomHomePage
        // --------------------------------------------------------

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const AuthGate(),
          ),
          (route) => false,
        );

        return;
      }

      _showError(
        'Your email is not verified yet. Please open the verification link sent to your email.',
      );
    } on Exception catch (_) {
      if (!mounted) return;

      _showError(
        'Could not check email verification. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // GOOGLE REGISTRATION
  // ============================================================

  Future<void> _continueWithGoogle() async {
    if (_isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      // --------------------------------------------------------
      // Google account chooser is controlled by AuthService.
      //
      // The service should use:
      //
      // prompt = select_account
      //
      // so the Google account chooser appears instead of silently
      // using the currently signed-in browser account.
      // --------------------------------------------------------

      await _authService.signInWithGoogle();

      if (!mounted) return;

      // --------------------------------------------------------
      // Google authentication succeeded.
      //
      // Now show the Fandom Verse-specific setup screen.
      // --------------------------------------------------------

      setState(() {
        _showGoogleSetup = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Google account connected. Complete your profile below.',
          ),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;

      _showError(_getGoogleError(e));
    } finally {
      // --------------------------------------------------------
      // IMPORTANT:
      //
      // This ALWAYS turns the Google button loading off,
      // including when the user cancels the Google account
      // selection popup.
      // --------------------------------------------------------

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getGoogleError(Exception e) {
    final error = e.toString().toLowerCase();

    if (error.contains('cancel') ||
        error.contains('popup-closed-by-user') ||
        error.contains('popup_closed')) {
      return 'Google sign-in was cancelled.';
    }

    if (error.contains('network')) {
      return 'Network error. Please check your internet connection.';
    }

    if (error.contains('account-exists-with-different-credential')) {
      return 'An account already exists with this email using another sign-in method.';
    }

    return 'Google sign-in failed. Please try again.';
  }

  // ============================================================
  // COMPLETE GOOGLE PROFILE
  // ============================================================

  Future<void> _completeGoogleRegistration() async {
    if (_isLoading) {
      return;
    }

    final name = _googleNameController.text.trim();
    final password = _googlePasswordController.text;
    final confirmPassword =
        _googleConfirmPasswordController.text;

    if (name.isEmpty) {
      _showError('Please enter your name.');
      return;
    }

    if (name.length < 2) {
      _showError('Name must be at least 2 characters.');
      return;
    }

    if (password.isEmpty) {
      _showError('Please create an app password.');
      return;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.completeGoogleRegistration(
        name: name,
        password: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account setup completed successfully! Welcome to Fandom Verse.',
          ),
        ),
      );

      // --------------------------------------------------------
      // DO NOT RETURN TO LOGIN.
      //
      // Google authentication is already active.
      // Open AuthGate and let it route the user directly to the
      // correct panel.
      // --------------------------------------------------------

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const AuthGate(),
        ),
        (route) => false,
      );
    } on Exception catch (_) {
      if (!mounted) return;

      _showError(
        'Could not complete your account setup. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF080A12);
    // const panel = Color(0xFF111522);

    const violet = Color(0xFF7C5CFC);
    const violetLight = Color(0xFF9D87FF);
    const gold = Color(0xFFE0B45A);

    const white = Color(0xFFF7F7FA);
    const muted = Color(0xFF969AAA);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: -140,
            right: -120,
            child: _glowCircle(
              size: 330,
              color: violet.withOpacity(0.16),
            ),
          ),

          Positioned(
            bottom: -180,
            left: -150,
            child: _glowCircle(
              size: 360,
              color: gold.withOpacity(0.08),
            ),
          ),

          Positioned(
            top: 180,
            left: -170,
            child: _glowCircle(
              size: 260,
              color: violet.withOpacity(0.06),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                22,
                18,
                22,
                35,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 42),

                    // ======================================================
                    // LOGO
                    // ======================================================

                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            violetLight,
                            violet,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: violet.withOpacity(0.35),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ======================================================
                    // BRAND
                    // ======================================================

                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'FANDOM ',
                            style: TextStyle(
                              color: white,
                              fontSize: 29,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                          TextSpan(
                            text: 'VERSE',
                            style: TextStyle(
                              color: gold,
                              fontSize: 29,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Your universe. Your fandom. Your story.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: muted,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 38),

                    // ======================================================
                    // CONTENT
                    // ======================================================

                    if (_showGoogleSetup)
                      _buildGoogleSetup(
                        white: white,
                        muted: muted,
                        violet: violet,
                        gold: gold,
                      )
                    else if (_verificationSent)
                      _buildVerificationSection(
                        white: white,
                        muted: muted,
                        violet: violet,
                        gold: gold,
                      )
                    else
                      _buildRegistrationForm(
                        white: white,
                        muted: muted,
                        violet: violet,
                        gold: gold,
                      ),

                    const SizedBox(height: 24),

                    // ======================================================
                    // LOGIN
                    // ======================================================

                    if (!_showGoogleSetup && !_verificationSent)
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already part of the Verse?',
                            style: TextStyle(
                              color: muted,
                              fontSize: 13,
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.of(context).pop();
                                  },
                            style: TextButton.styleFrom(
                              foregroundColor: gold,
                              padding:
                                  const EdgeInsets.only(left: 6),
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 4),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 28,
                          height: 1,
                          color:
                              Colors.white.withOpacity(0.10),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.auto_awesome,
                          size: 11,
                          color: gold,
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 28,
                          height: 1,
                          color:
                              Colors.white.withOpacity(0.10),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'DISCOVER • CONNECT • CELEBRATE',
                      style: TextStyle(
                        color: Color(0xFF666A7A),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NORMAL REGISTRATION FORM
  // ============================================================

  Widget _buildRegistrationForm({
    required Color white,
    required Color muted,
    required Color violet,
    required Color gold,
  }) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Create your account',
            style: TextStyle(
              color: white,
              fontSize: 25,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
        ),

        const SizedBox(height: 7),

        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Start building your personal fandom experience.',
            style: TextStyle(
              color: muted,
              fontSize: 13,
            ),
          ),
        ),

        const SizedBox(height: 22),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF111522).withOpacity(0.96),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.07),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 35,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your name',
                icon: Icons.person_outline_rounded,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter your name.';
                  }

                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              _buildField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'you@example.com',
                icon: Icons.alternate_email_rounded,
                keyboardType:
                    TextInputType.emailAddress,
                textInputAction:
                    TextInputAction.next,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter your email.';
                  }

                  final emailRegex = RegExp(
                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                  );

                  if (!emailRegex.hasMatch(
                    value.trim(),
                  )) {
                    return 'Please enter a valid email address.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              _buildField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Create a strong password',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                textInputAction:
                    TextInputAction.next,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword =
                          !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Please enter a password.';
                  }

                  if (value.length < 6) {
                    return 'Password must be at least 6 characters.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              _buildField(
                controller:
                    _confirmPasswordController,
                label: 'Confirm Password',
                hint: 'Repeat your password',
                icon:
                    Icons.verified_user_outlined,
                obscureText:
                    _obscureConfirmPassword,
                textInputAction:
                    TextInputAction.done,
                onFieldSubmitted: (_) =>
                    _register(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword =
                          !_obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Please confirm your password.';
                  }

                  if (value !=
                      _passwordController.text) {
                    return 'Passwords do not match.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 22),

              _buildPrimaryButton(
                text: 'Create Account',
                icon: Icons.arrow_forward_rounded,
                onPressed:
                    _isLoading ? null : _register,
                loading: _isLoading,
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color:
                          Colors.white.withOpacity(0.08),
                    ),
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Color(0xFF666A7A),
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color:
                          Colors.white.withOpacity(0.08),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : _continueWithGoogle,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        const Color(0xFF171B2B),
                    side: BorderSide(
                      color:
                          Colors.white.withOpacity(0.08),
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(
                    Icons.g_mobiledata_rounded,
                    size: 28,
                  ),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMAIL VERIFICATION
  // ============================================================

  Widget _buildVerificationSection({
    required Color white,
    required Color muted,
    required Color violet,
    required Color gold,
  }) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: violet.withOpacity(0.12),
            border: Border.all(
              color: violet.withOpacity(0.25),
            ),
          ),
          child: const Icon(
            Icons.mark_email_unread_outlined,
            color: Color(0xFF9D87FF),
            size: 35,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Verify your email',
          style: TextStyle(
            color: white,
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'We sent a verification link to:',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: muted,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          _verificationEmail ??
              _emailController.text.trim(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFE0B45A),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF111522),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.07),
            ),
          ),
          child: const Text(
            'Open your email and tap the verification link. '
            'After verifying, return here and press '
            '"I\'ve Verified My Email".',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF969AAA),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 20),

        _buildPrimaryButton(
          text: 'I\'ve Verified My Email',
          icon: Icons.verified_rounded,
          onPressed: _isLoading
              ? null
              : _checkEmailVerification,
          loading: _isLoading,
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _isLoading
                ? null
                : _resendVerificationEmail,
            style: OutlinedButton.styleFrom(
              foregroundColor: gold,
              side: BorderSide(
                color: gold.withOpacity(0.30),
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(
              Icons.refresh_rounded,
              size: 19,
            ),
            label: const Text(
              'Resend Verification Email',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 15),

        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  setState(() {
                    _verificationSent = false;
                    _verificationEmail = null;
                  });
                },
          child: const Text(
            'Use a different email',
            style: TextStyle(
              color: Color(0xFF9D87FF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GOOGLE PROFILE SETUP
  // ============================================================

  Widget _buildGoogleSetup({
    required Color white,
    required Color muted,
    required Color violet,
    required Color gold,
  }) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF9D87FF),
                Color(0xFF7C5CFC),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: violet.withOpacity(0.30),
                blurRadius: 25,
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),

        const SizedBox(height: 22),

        Text(
          'Complete your profile',
          style: TextStyle(
            color: white,
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Your Google account is connected. '
          'Create your Fandom Verse profile password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: muted,
            fontSize: 13,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 22),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF111522),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.07),
            ),
          ),
          child: Column(
            children: [
              _buildField(
                controller:
                    _googleNameController,
                label: 'Full Name',
                hint: 'Enter your name',
                icon:
                    Icons.person_outline_rounded,
                textInputAction:
                    TextInputAction.next,
                validator: (_) => null,
              ),

              const SizedBox(height: 15),

              _buildField(
                controller:
                    _googlePasswordController,
                label: 'App Password',
                hint:
                    'Create your Fandom Verse password',
                icon:
                    Icons.lock_outline_rounded,
                obscureText:
                    _obscureGooglePassword,
                textInputAction:
                    TextInputAction.next,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureGooglePassword =
                          !_obscureGooglePassword;
                    });
                  },
                  icon: Icon(
                    _obscureGooglePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                validator: (_) => null,
              ),

              const SizedBox(height: 15),

              _buildField(
                controller:
                    _googleConfirmPasswordController,
                label: 'Confirm Password',
                hint:
                    'Repeat your app password',
                icon:
                    Icons.verified_user_outlined,
                obscureText:
                    _obscureGoogleConfirmPassword,
                textInputAction:
                    TextInputAction.done,
                onFieldSubmitted: (_) =>
                    _completeGoogleRegistration(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureGoogleConfirmPassword =
                          !_obscureGoogleConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _obscureGoogleConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                validator: (_) => null,
              ),

              const SizedBox(height: 22),

              _buildPrimaryButton(
                text: 'Complete Registration',
                icon: Icons.check_rounded,
                onPressed: _isLoading
                    ? null
                    : _completeGoogleRegistration,
                loading: _isLoading,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PRIMARY BUTTON
  // ============================================================

  Widget _buildPrimaryButton({
    required String text,
    required IconData icon,
    required VoidCallback? onPressed,
    required bool loading,
  }) {
    const violet = Color(0xFF7C5CFC);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              violet,
              Color(0xFF6748E8),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: violet.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor:
                Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 21,
                  height: 21,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      icon,
                      size: 19,
                      color: Colors.white,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    void Function(String)? onFieldSubmitted,
  }) {
    const panelLight = Color(0xFF171B2B);
    const violet = Color(0xFF7C5CFC);
    const white = Color(0xFFF7F7FA);
    const muted = Color(0xFF85899B);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      cursorColor: violet,
      style: const TextStyle(
        color: white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: muted,
          fontSize: 12,
        ),
        floatingLabelStyle:
            const TextStyle(
          color: violet,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF55596B),
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: muted,
          size: 20,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: panelLight,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 17,
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(13),
          borderSide: BorderSide(
            color:
                Colors.white.withOpacity(0.06),
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: violet,
            width: 1.2,
          ),
        ),
        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BACKGROUND GLOW
  // ============================================================

  Widget _glowCircle({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100,
            spreadRadius: 30,
          ),
        ],
      ),
    );
  }
}
