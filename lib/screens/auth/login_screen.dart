import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'auth_gate.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.authService});

  final AuthServiceBase? authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AuthServiceBase _authService;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
  }

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = credential.user ?? FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Unable to find the signed-in user.',
        );
      }

      // ------------------------------------------------------------
      // IMPORTANT:
      // Firebase Auth is the source of truth for email verification.
      // Do NOT allow an unverified email user into the application.
      // ------------------------------------------------------------

      await user.reload();

      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Unable to find the signed-in user.',
        );
      }

      if (!refreshedUser.emailVerified) {
        if (!mounted) return;

        // Stop loading before opening verification screen.
        setState(() {
          _isLoading = false;
        });

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(
              user: refreshedUser,
            ),
          ),
        );

        return;
      }

      // ------------------------------------------------------------
      // Email IS verified.
      //
      // Synchronize Firestore status.
      // We intentionally update emailVerified only here.
      // active remains controlled by your account/admin system.
      // ------------------------------------------------------------

      await FirebaseFirestore.instance
          .collection('users')
          .doc(refreshedUser.uid)
          .set(
        {
          'emailVerified': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
        ),
      );

      // AuthGate is responsible for:
      // - checking active status
      // - checking role
      // - opening AdminPanelScreen or FandomHomePage
      //
      // This also prevents users from bypassing the auth flow.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const AuthGate(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Login failed. Please try again.';

      switch (e.code) {
        case 'user-not-found':
          message = 'No account was found with this email.';
          break;

        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
          message = 'Incorrect email or password.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;

        default:
          if (e.message != null && e.message!.isNotEmpty) {
            message = e.message!;
          }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;

      String message = 'Login failed. Please try again.';

      final error = e.toString();

      if (error.contains('user-not-found')) {
        message = 'No account was found with this email.';
      } else if (error.contains('wrong-password') ||
          error.contains('invalid-credential')) {
        message = 'Incorrect email or password.';
      } else if (error.contains('invalid-email')) {
        message = 'Please enter a valid email address.';
      } else if (error.contains('too-many-requests')) {
        message = 'Too many attempts. Please try again later.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } finally {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openRegister() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF080A12);
    const panel = Color(0xFF111522);
    // const panelLight = Color(0xFF171B2B);

    const violet = Color(0xFF7C5CFC);
    const violetLight = Color(0xFF9D87FF);
    const gold = Color(0xFFE0B45A);

    const white = Color(0xFFF7F7FA);
    const muted = Color(0xFF969AAA);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // Decorative background glow
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
              padding: const EdgeInsets.fromLTRB(22, 35, 22, 35),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Logo
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

                    // Brand
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

                    // Heading
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Welcome back',
                        style: TextStyle(
                          color: white,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sign in to continue your personal fandom experience.',
                        style: TextStyle(
                          color: muted,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Form panel
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: panel.withOpacity(0.96),
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
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'you@example.com',
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter your email.';
                              }

                              if (!value.contains('@')) {
                                return 'Please enter a valid email.';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 15),

                          _buildField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter your password',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _login(),
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
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password.';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 22),

                          // Login button
                          SizedBox(
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
                                onPressed:
                                    _isLoading ? null : _login,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  disabledBackgroundColor:
                                      Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 21,
                                        height: 21,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Sign In',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight:
                                                  FontWeight.w700,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 19,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Register section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'New to the Verse?',
                          style: TextStyle(
                            color: muted,
                            fontSize: 13,
                          ),
                        ),
                        TextButton(
                          onPressed:
                              _isLoading ? null : _openRegister,
                          style: TextButton.styleFrom(
                            foregroundColor: gold,
                            padding:
                                const EdgeInsets.only(left: 6),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Bottom decorative detail
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
        floatingLabelStyle: const TextStyle(
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 17,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: violet,
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.2,
          ),
        ),
      ),
    );
  }

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

// ============================================================================
// EMAIL VERIFICATION SCREEN
// ============================================================================

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({
    super.key,
    required this.user,
  });

  final User user;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends State<EmailVerificationScreen> {
  bool _isChecking = false;
  bool _isSending = false;

  Future<void> _checkVerification() async {
    if (_isChecking || _isSending) return;

    setState(() {
      _isChecking = true;
    });

    try {
      // Reload Firebase Auth user so emailVerified gets the
      // latest value after the user clicks the email link.
      await widget.user.reload();

      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Your account session has expired.',
        );
      }

      if (!refreshedUser.emailVerified) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your email is not verified yet. Please open the verification link from your email first.',
            ),
          ),
        );

        return;
      }

      // ------------------------------------------------------------
      // Verification confirmed.
      // Update Firestore emailVerified = true.
      // ------------------------------------------------------------

      await FirebaseFirestore.instance
          .collection('users')
          .doc(refreshedUser.uid)
          .set(
        {
          'emailVerified': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email verified successfully!',
          ),
        ),
      );

      // ------------------------------------------------------------
      // Do NOT go back to Login.
      // Go directly through AuthGate.
      // AuthGate will decide:
      //   active == false -> inactive screen
      //   role == admin   -> AdminPanelScreen
      //   otherwise       -> FandomHomePage
      // ------------------------------------------------------------

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const AuthGate(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Unable to check email verification.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to check verification right now. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_isChecking || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Your account session has expired.',
        );
      }

      await user.reload();

      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Your account session has expired.',
        );
      }

      // If already verified, don't send another email.
      if (refreshedUser.emailVerified) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(refreshedUser.uid)
            .set(
          {
            'emailVerified': true,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const AuthGate(),
          ),
          (route) => false,
        );

        return;
      }

      await refreshedUser.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification email sent. Please check your inbox.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message =
          e.message ?? 'Unable to send verification email.';

      if (e.code == 'too-many-requests') {
        message =
            'Too many verification emails were requested. Please wait a little and try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to send verification email. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _backToLogin() async {
    if (_isChecking || _isSending) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF080A12);
    const panel = Color(0xFF111522);
    const panelLight = Color(0xFF171B2B);

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
            child: _verificationGlowCircle(
              size: 330,
              color: violet.withOpacity(0.16),
            ),
          ),
          Positioned(
            bottom: -180,
            left: -150,
            child: _verificationGlowCircle(
              size: 360,
              color: gold.withOpacity(0.08),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 480,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: panel.withOpacity(0.97),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.07),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 35,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 82,
                          height: 82,
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
                                color: violet.withOpacity(0.32),
                                blurRadius: 30,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mark_email_unread_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          'Verify your email',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Your email address has not been verified yet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: muted,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: panelLight,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: violet.withOpacity(0.18),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.alternate_email_rounded,
                                color: violetLight,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.user.email ??
                                      'your email address',
                                  style: const TextStyle(
                                    color: white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'Open the verification email we sent you and click the verification link. Then return here and press the button below.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: muted,
                            fontSize: 13,
                            height: 1.55,
                          ),
                        ),

                        const SizedBox(height: 26),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
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
                              onPressed:
                                  (_isChecking || _isSending)
                                      ? null
                                      : _checkVerification,
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    Colors.transparent,
                                disabledBackgroundColor:
                                    Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                              ),
                              child: _isChecking
                                  ? const SizedBox(
                                      width: 21,
                                      height: 21,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.verified_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'I’ve Verified My Email',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight:
                                                FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 13),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed:
                                (_isChecking || _isSending)
                                    ? null
                                    : _resendVerificationEmail,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: gold,
                              side: BorderSide(
                                color: gold.withOpacity(0.35),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                            ),
                            child: _isSending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: gold,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.refresh_rounded,
                                        size: 19,
                                      ),
                                      SizedBox(width: 9),
                                      Text(
                                        'Resend Verification Email',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight:
                                              FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        TextButton(
                          onPressed:
                              (_isChecking || _isSending)
                                  ? null
                                  : _backToLogin,
                          child: const Text(
                            'Back to Login',
                            style: TextStyle(
                              color: muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verificationGlowCircle({
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
