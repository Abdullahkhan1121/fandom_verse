import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fandom_verse/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../admin/admin_panel_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, authSnapshot) {
        // ==============================================================
        // AUTHENTICATION LOADING
        // ==============================================================

        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF080A12),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7C5CFC),
              ),
            ),
          );
        }

        final user = authSnapshot.data;

        // ==============================================================
        // NO LOGGED-IN USER
        // ==============================================================

        if (user == null) {
          return const LoginScreen();
        }

        // ==============================================================
        // EMAIL VERIFICATION
        // ==============================================================
        //
        // Normal email/password users MUST verify their email.
        //
        // Google users are already considered verified because Google
        // authenticates their email identity.
        //
        // IMPORTANT:
        //
        // Firebase Auth is the source of truth for emailVerified.
        // Firestore's emailVerified field is synchronized after the
        // verification link has been confirmed.
        //

        final isGoogleUser = user.providerData.any(
          (provider) => provider.providerId == 'google.com',
        );

        if (!isGoogleUser && !user.emailVerified) {
          return _EmailVerificationRequiredScreen(
            user: user,
            authService: authService,
          );
        }

        // ==============================================================
        // FIRESTORE USER PROFILE
        // ==============================================================

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            // ----------------------------------------------------------
            // FIRESTORE LOADING
            // ----------------------------------------------------------

            if (userSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFF080A12),
                body: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF7C5CFC),
                  ),
                ),
              );
            }

            // ----------------------------------------------------------
            // FIRESTORE ERROR
            // ----------------------------------------------------------

            if (userSnapshot.hasError) {
              return const Scaffold(
                backgroundColor: Color(0xFF080A12),
                body: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Unable to load your account profile.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF7F7FA),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              );
            }

            if (!userSnapshot.hasData) {
              return const Scaffold(
                backgroundColor: Color(0xFF080A12),
                body: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF7C5CFC),
                  ),
                ),
              );
            }

            // ----------------------------------------------------------
            // PROFILE DATA
            // ----------------------------------------------------------

            final userData = userSnapshot.data!.data();

            if (userData == null) {
              return const Scaffold(
                backgroundColor: Color(0xFF080A12),
                body: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'User profile could not be loaded.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF7F7FA),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              );
            }

            // ==========================================================
            // ACTIVE ACCOUNT CHECK
            // ==========================================================
            //
            // Firestore snapshots() is realtime.
            //
            // If admin changes:
            //
            // active: true
            //
            // to:
            //
            // active: false
            //
            // the user will immediately be shown the inactive screen.
            //

            final activeValue = userData['active'];

            if (activeValue == false) {
              return _AccountInactiveScreen(
                authService: authService,
              );
            }

            // ==========================================================
            // EMAIL VERIFIED SYNCHRONIZATION
            // ==========================================================
            //
            // At this point:
            //
            // - Google users are verified
            // - Normal users have Firebase emailVerified == true
            //
            // Make sure Firestore has the same status.
            //
            // This fixes the situation where the user verified through
            // the Firebase email link but Firestore still contains:
            //
            // emailVerified: false
            //
            // Firestore is updated only if necessary.
            //

            final firestoreEmailVerified =
                userData['emailVerified'] == true;

            if (!firestoreEmailVerified) {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .update({
                'emailVerified': true,
                'active': true,
                'updatedAt': FieldValue.serverTimestamp(),
              }).catchError((_) {
                // Do not break the user's application if the background
                // Firestore synchronization temporarily fails.
              });
            }

            // ==========================================================
            // ROLE
            // ==========================================================

            final role = userData['role'] as String?;

            if (role == 'admin') {
              return const AdminPanelScreen();
            }

            return const HomePage();
          },
        );
      },
    );
  }
}

// ============================================================================
// EMAIL VERIFICATION REQUIRED SCREEN
// ============================================================================

class _EmailVerificationRequiredScreen extends StatefulWidget {
  final User user;
  final AuthService authService;

  const _EmailVerificationRequiredScreen({
    required this.user,
    required this.authService,
  });

  @override
  State<_EmailVerificationRequiredScreen> createState() =>
      _EmailVerificationRequiredScreenState();
}

class _EmailVerificationRequiredScreenState
    extends State<_EmailVerificationRequiredScreen> {
  bool _isChecking = false;
  bool _isSending = false;

  // ==========================================================================
  // CHECK EMAIL VERIFICATION
  // ==========================================================================

  Future<void> _checkVerification() async {
    if (_isChecking || _isSending) return;

    setState(() {
      _isChecking = true;
    });

    try {
      // --------------------------------------------------------------
      // IMPORTANT:
      //
      // Reload the Firebase Auth user.
      //
      // When the user clicks the verification link from their email,
      // Firebase changes emailVerified on the server.
      //
      // reload() gets that latest value.
      // --------------------------------------------------------------

      await widget.user.reload();

      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your session has expired. Please log in again.',
            ),
          ),
        );

        return;
      }

      // --------------------------------------------------------------
      // EMAIL STILL NOT VERIFIED
      // --------------------------------------------------------------

      if (!refreshedUser.emailVerified) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your email is still not verified. Please open the verification link sent to your email first.',
            ),
          ),
        );

        return;
      }

      // ==============================================================
      // EMAIL IS VERIFIED
      // ==============================================================
      //
      // Now synchronize Firestore.
      //
      // This is the missing part from the previous implementation.
      //
      // Firebase Auth:
      //
      // emailVerified = true
      //
      // Firestore:
      //
      // emailVerified = true
      // active = true
      //

      await FirebaseFirestore.instance
          .collection('users')
          .doc(refreshedUser.uid)
          .set(
        {
          'emailVerified': true,
          'active': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      // --------------------------------------------------------------
      // DIRECTLY GO BACK THROUGH AUTHGATE
      // --------------------------------------------------------------
      //
      // We intentionally do NOT use Navigator.pop().
      //
      // The user should NOT return to LoginScreen.
      //
      // AuthGate will now:
      //
      // 1. See Firebase emailVerified == true
      // 2. Read Firestore profile
      // 3. Check active
      // 4. Check role
      // 5. Open AdminPanelScreen or FandomHomePage
      //

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const AuthGate(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message =
          e.message ?? 'Could not check email verification.';

      if (e.code == 'user-token-expired') {
        message =
            'Your session has expired. Please log in again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ??
                'Your email was verified, but we could not update your account profile.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not check email verification. Please try again.',
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

  // ==========================================================================
  // RESEND VERIFICATION EMAIL
  // ==========================================================================

  Future<void> _resendVerification() async {
    if (_isChecking || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your session has expired. Please log in again.',
            ),
          ),
        );

        return;
      }

      // --------------------------------------------------------------
      // If already verified, synchronize Firestore instead of sending
      // another email.
      // --------------------------------------------------------------

      await currentUser.reload();

      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser != null && refreshedUser.emailVerified) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(refreshedUser.uid)
            .set(
          {
            'emailVerified': true,
            'active': true,
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

      // --------------------------------------------------------------
      // SEND VERIFICATION EMAIL
      // --------------------------------------------------------------

      await refreshedUser?.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification email sent again. Please check your inbox.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message =
          e.message ?? 'Could not send verification email.';

      if (e.code == 'too-many-requests') {
        message =
            'Too many verification emails were requested. Please wait a while and try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not send verification email. Please try again.',
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

  // ==========================================================================
  // LOGOUT
  // ==========================================================================

  Future<void> _logout() async {
    try {
      await widget.authService.logout();
    } catch (_) {
      // Keep the screen stable if logout encounters an error.
    }
  }

  // ==========================================================================
  // UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF080A12);
    const panel = Color(0xFF111522);
    const violet = Color(0xFF7C5CFC);
    const violetLight = Color(0xFF9D87FF);
    const gold = Color(0xFFE0B45A);
    const white = Color(0xFFF7F7FA);
    const muted = Color(0xFF969AAA);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // --------------------------------------------------------------
          // TOP GLOW
          // --------------------------------------------------------------

          Positioned(
            top: -140,
            right: -120,
            child: Container(
              width: 330,
              height: 330,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: violet.withOpacity(0.08),
                boxShadow: [
                  BoxShadow(
                    color: violet.withOpacity(0.14),
                    blurRadius: 100,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          // --------------------------------------------------------------
          // BOTTOM GLOW
          // --------------------------------------------------------------

          Positioned(
            bottom: -180,
            left: -150,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: gold.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: gold.withOpacity(0.08),
                    blurRadius: 100,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          // --------------------------------------------------------------
          // CONTENT
          // --------------------------------------------------------------

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 460,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: panel,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.07),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.30),
                          blurRadius: 35,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // ------------------------------------------------
                        // ICON
                        // ------------------------------------------------

                        Container(
                          width: 78,
                          height: 78,
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
                                color: violet.withOpacity(0.30),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mark_email_unread_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Verify your email',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: white,
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Your account has been created, but you must verify your email before entering Fandom Verse.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: muted,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ------------------------------------------------
                        // EMAIL
                        // ------------------------------------------------

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF171B2B),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.06),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                color: violetLight,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.user.email ?? '',
                                  overflow: TextOverflow.ellipsis,
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

                        const SizedBox(height: 22),

                        // ------------------------------------------------
                        // CHECK VERIFICATION
                        // ------------------------------------------------

                        SizedBox(
                          width: double.infinity,
                          height: 54,
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
                            ),
                            child: FilledButton(
                              onPressed:
                                  _isChecking || _isSending
                                      ? null
                                      : _checkVerification,
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
                              child: _isChecking
                                  ? const SizedBox(
                                      width: 21,
                                      height: 21,
                                      child: CircularProgressIndicator(
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
                                          size: 19,
                                        ),
                                        SizedBox(width: 9),
                                        Text(
                                          'I\'ve Verified My Email',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ------------------------------------------------
                        // RESEND
                        // ------------------------------------------------

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed:
                                _isChecking || _isSending
                                    ? null
                                    : _resendVerification,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: gold,
                              side: BorderSide(
                                color: gold.withOpacity(0.30),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                            ),
                            icon: _isSending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: gold,
                                    ),
                                  )
                                : const Icon(
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

                        const SizedBox(height: 18),

                        const Text(
                          'Check your spam or junk folder if you cannot find the email.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF666A7A),
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ------------------------------------------------
                        // SIGN OUT
                        // ------------------------------------------------

                        TextButton.icon(
                          onPressed:
                              _isChecking || _isSending
                                  ? null
                                  : _logout,
                          icon: const Icon(
                            Icons.logout_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'Sign out',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                const Color(0xFF969AAA),
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
}

// ============================================================================
// INACTIVE ACCOUNT SCREEN
// ============================================================================

class _AccountInactiveScreen extends StatefulWidget {
  final AuthService authService;

  const _AccountInactiveScreen({
    required this.authService,
  });

  @override
  State<_AccountInactiveScreen> createState() =>
      _AccountInactiveScreenState();
}

class _AccountInactiveScreenState
    extends State<_AccountInactiveScreen> {
  bool _isLoggingOut = false;

  // ==========================================================================
  // BACK TO LOGIN
  // ==========================================================================

  Future<void> _backToLogin() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await widget.authService.logout();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoggingOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not sign out. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF080A12);
    const panel = Color(0xFF111522);
    const violet = Color(0xFF7C5CFC);
    const violetLight = Color(0xFF9D87FF);
    const gold = Color(0xFFE0B45A);
    const white = Color(0xFFF7F7FA);
    const muted = Color(0xFF969AAA);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // --------------------------------------------------------------
          // TOP GLOW
          // --------------------------------------------------------------

          Positioned(
            top: -140,
            right: -120,
            child: Container(
              width: 330,
              height: 330,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: violet.withOpacity(0.08),
                boxShadow: [
                  BoxShadow(
                    color: violet.withOpacity(0.14),
                    blurRadius: 100,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          // --------------------------------------------------------------
          // BOTTOM GLOW
          // --------------------------------------------------------------

          Positioned(
            bottom: -180,
            left: -150,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: gold.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: gold.withOpacity(0.08),
                    blurRadius: 100,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          // --------------------------------------------------------------
          // CONTENT
          // --------------------------------------------------------------

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 440,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: panel,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.07),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.30),
                          blurRadius: 35,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ------------------------------------------------
                        // ICON
                        // ------------------------------------------------

                        Container(
                          width: 78,
                          height: 78,
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
                                color: violet.withOpacity(0.28),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.block_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ------------------------------------------------
                        // TITLE
                        // ------------------------------------------------

                        const Text(
                          'Account inactive',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: white,
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ------------------------------------------------
                        // DESCRIPTION
                        // ------------------------------------------------

                        const Text(
                          'Your account is currently inactive. You cannot access Fandom Verse until your account is activated again.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: muted,
                            fontSize: 13,
                            height: 1.55,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ------------------------------------------------
                        // STATUS CARD
                        // ------------------------------------------------

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF171B2B),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: gold.withOpacity(0.18),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: gold,
                                  boxShadow: [
                                    BoxShadow(
                                      color: gold.withOpacity(0.35),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Account access is currently disabled.',
                                  style: TextStyle(
                                    color: white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ------------------------------------------------
                        // BACK TO LOGIN
                        // ------------------------------------------------

                        SizedBox(
                          width: double.infinity,
                          height: 54,
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
                                  color: violet.withOpacity(0.20),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: FilledButton(
                              onPressed:
                                  _isLoggingOut
                                      ? null
                                      : _backToLogin,
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
                              child: _isLoggingOut
                                  ? const SizedBox(
                                      width: 21,
                                      height: 21,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_back_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 9),
                                        Text(
                                          'Back to Login',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'If you believe this is a mistake, please contact support.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF666A7A),
                            fontSize: 11,
                            height: 1.4,
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
}
