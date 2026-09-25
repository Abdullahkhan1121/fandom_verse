// import 'package:flutter/material.dart';

// import '../../services/auth_service.dart';
// import 'register_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key, this.authService});

//   final AuthServiceBase? authService;

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   late final AuthServiceBase _authService;

//   @override
//   void initState() {
//     super.initState();
//     _authService = widget.authService ?? AuthService();
//   }

//   bool _isLoading = false;
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await _authService.login(
//         email: _emailController.text,
//         password: _passwordController.text,
//       );

//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Login successful!')));
//     } on Exception catch (e) {
//       if (!mounted) return;

//       String message = 'Login failed. Please try again.';

//       final error = e.toString();

//       if (error.contains('user-not-found')) {
//         message = 'No account was found with this email.';
//       } else if (error.contains('wrong-password') ||
//           error.contains('invalid-credential')) {
//         message = 'Incorrect email or password.';
//       } else if (error.contains('invalid-email')) {
//         message = 'Please enter a valid email address.';
//       } else if (error.contains('too-many-requests')) {
//         message = 'Too many attempts. Please try again later.';
//       }

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _openRegister() async {
//     await Navigator.of(
//       context,
//     ).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Icon(
//                     Icons.auto_awesome,
//                     size: 72,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   const SizedBox(height: 24),
//                   Text(
//                     'Welcome to Fandom Verse',
//                     textAlign: TextAlign.center,
//                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Sign in to explore your fandom universe.',
//                     textAlign: TextAlign.center,
//                     style: Theme.of(context).textTheme.bodyLarge,
//                   ),
//                   const SizedBox(height: 36),
//                   TextFormField(
//                     controller: _emailController,
//                     keyboardType: TextInputType.emailAddress,
//                     textInputAction: TextInputAction.next,
//                     decoration: const InputDecoration(
//                       labelText: 'Email',
//                       prefixIcon: Icon(Icons.email_outlined),
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Please enter your email.';
//                       }

//                       if (!value.contains('@')) {
//                         return 'Please enter a valid email.';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _passwordController,
//                     obscureText: _obscurePassword,
//                     textInputAction: TextInputAction.done,
//                     onFieldSubmitted: (_) => _login(),
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       prefixIcon: const Icon(Icons.lock_outline),
//                       border: const OutlineInputBorder(),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscurePassword
//                               ? Icons.visibility_outlined
//                               : Icons.visibility_off_outlined,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _obscurePassword = !_obscurePassword;
//                           });
//                         },
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your password.';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   FilledButton(
//                     onPressed: _isLoading ? null : _login,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       child: _isLoading
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(strokeWidth: 2),
//                             )
//                           : const Text('Login', style: TextStyle(fontSize: 16)),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   OutlinedButton(
//                     onPressed: _isLoading ? null : _openRegister,
//                     child: const Padding(
//                       padding: EdgeInsets.symmetric(vertical: 12),
//                       child: Text('Create an Account'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
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
      await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful!')));
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openRegister() async {
    await Navigator.of(
      context,
    ).push(
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
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
                                            Icons
                                                .arrow_forward_rounded,
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