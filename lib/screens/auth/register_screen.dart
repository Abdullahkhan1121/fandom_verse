// import 'package:flutter/material.dart';

// import '../../services/auth_service.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();

//   final _authService = AuthService();

//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   Future<void> _register() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await _authService.register(
//         name: _nameController.text,
//         email: _emailController.text,
//         password: _passwordController.text,
//       );

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Account created successfully!')),
//       );

//       Navigator.of(context).pop();
//     } on Exception catch (e) {
//       if (!mounted) return;

//       String message = 'Registration failed. Please try again.';

//       final error = e.toString();

//       if (error.contains('email-already-in-use')) {
//         message = 'An account already exists with this email.';
//       } else if (error.contains('invalid-email')) {
//         message = 'Please enter a valid email address.';
//       } else if (error.contains('weak-password')) {
//         message = 'Password is too weak.';
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Create Account')),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 20),

//                 Icon(
//                   Icons.auto_awesome,
//                   size: 64,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),

//                 const SizedBox(height: 20),

//                 Text(
//                   'Join Fandom Verse',
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 Text(
//                   'Create your account and enter the fandom universe.',
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),

//                 const SizedBox(height: 32),

//                 TextFormField(
//                   controller: _nameController,
//                   textInputAction: TextInputAction.next,
//                   decoration: const InputDecoration(
//                     labelText: 'Name',
//                     prefixIcon: Icon(Icons.person_outline),
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Please enter your name.';
//                     }

//                     if (value.trim().length < 2) {
//                       return 'Name must be at least 2 characters.';
//                     }

//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 16),

//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   textInputAction: TextInputAction.next,
//                   decoration: const InputDecoration(
//                     labelText: 'Email',
//                     prefixIcon: Icon(Icons.email_outlined),
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Please enter your email.';
//                     }

//                     if (!value.contains('@')) {
//                       return 'Please enter a valid email.';
//                     }

//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 16),

//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscurePassword,
//                   textInputAction: TextInputAction.next,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     prefixIcon: const Icon(Icons.lock_outline),
//                     border: const OutlineInputBorder(),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility_outlined
//                             : Icons.visibility_off_outlined,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword = !_obscurePassword;
//                         });
//                       },
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a password.';
//                     }

//                     if (value.length < 6) {
//                       return 'Password must be at least 6 characters.';
//                     }

//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 16),

//                 TextFormField(
//                   controller: _confirmPasswordController,
//                   obscureText: _obscureConfirmPassword,
//                   textInputAction: TextInputAction.done,
//                   onFieldSubmitted: (_) => _register(),
//                   decoration: InputDecoration(
//                     labelText: 'Confirm Password',
//                     prefixIcon: const Icon(Icons.lock_outline),
//                     border: const OutlineInputBorder(),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscureConfirmPassword
//                             ? Icons.visibility_outlined
//                             : Icons.visibility_off_outlined,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscureConfirmPassword = !_obscureConfirmPassword;
//                         });
//                       },
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please confirm your password.';
//                     }

//                     if (value != _passwordController.text) {
//                       return 'Passwords do not match.';
//                     }

//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 24),

//                 FilledButton(
//                   onPressed: _isLoading ? null : _register,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     child: _isLoading
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : const Text(
//                             'Create Account',
//                             style: TextStyle(fontSize: 16),
//                           ),
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 TextButton(
//                   onPressed: _isLoading
//                       ? null
//                       : () {
//                           Navigator.of(context).pop();
//                         },
//                   child: const Text('Already have an account? Login'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';

// import '../../services/auth_service.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();

//   final _authService = AuthService();

//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   Future<void> _register() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await _authService.register(
//         name: _nameController.text,
//         email: _emailController.text,
//         password: _passwordController.text,
//       );

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Account created successfully!')),
//       );

//       Navigator.of(context).pop();
//     } on Exception catch (e) {
//       if (!mounted) return;

//       String message = 'Registration failed. Please try again.';

//       final error = e.toString();

//       if (error.contains('email-already-in-use')) {
//         message = 'An account already exists with this email.';
//       } else if (error.contains('invalid-email')) {
//         message = 'Please enter a valid email address.';
//       } else if (error.contains('weak-password')) {
//         message = 'Password is too weak.';
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

//   @override
//   Widget build(BuildContext context) {
//     const background = Color(0xFFF7F5F0);
//     const navy = Color(0xFF18202B);
//     const gold = Color(0xFFB08A3E);
//     const muted = Color(0xFF77746E);
//     const fieldBackground = Color(0xFFFFFFFF);
//     const border = Color(0xFFE5E1D8);

//     return Scaffold(
//       backgroundColor: background,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 28,
//             vertical: 20,
//           ),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Top navigation
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: IconButton(
//                     onPressed: _isLoading
//                         ? null
//                         : () {
//                             Navigator.of(context).pop();
//                           },
//                     icon: const Icon(Icons.arrow_back_rounded),
//                     color: navy,
//                     iconSize: 25,
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                   ),
//                 ),

//                 const SizedBox(height: 32),

//                 // Brand
//                 const Text(
//                   'FANDOM',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: navy,
//                     fontSize: 30,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: 3.5,
//                   ),
//                 ),

//                 const SizedBox(height: 2),

//                 const Text(
//                   'VERSE',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: gold,
//                     fontSize: 17,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 6,
//                   ),
//                 ),

//                 const SizedBox(height: 28),

//                 const Text(
//                   'Create your account',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: navy,
//                     fontSize: 27,
//                     fontWeight: FontWeight.w700,
//                     letterSpacing: -0.4,
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 const Text(
//                   'Join the community and explore your favorite fandoms.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: muted,
//                     fontSize: 14,
//                     height: 1.5,
//                   ),
//                 ),

//                 const SizedBox(height: 34),

//                 // Form container
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: fieldBackground,
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: border),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.04),
//                         blurRadius: 20,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       _buildField(
//                         controller: _nameController,
//                         label: 'Full Name',
//                         icon: Icons.person_outline_rounded,
//                         validator: (value) {
//                           if (value == null || value.trim().isEmpty) {
//                             return 'Please enter your name.';
//                           }

//                           if (value.trim().length < 2) {
//                             return 'Name must be at least 2 characters.';
//                           }

//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 16),

//                       _buildField(
//                         controller: _emailController,
//                         label: 'Email Address',
//                         icon: Icons.mail_outline_rounded,
//                         keyboardType: TextInputType.emailAddress,
//                         textInputAction: TextInputAction.next,
//                         validator: (value) {
//                           if (value == null || value.trim().isEmpty) {
//                             return 'Please enter your email.';
//                           }

//                           if (!value.contains('@')) {
//                             return 'Please enter a valid email.';
//                           }

//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 16),

//                       _buildField(
//                         controller: _passwordController,
//                         label: 'Password',
//                         icon: Icons.lock_outline_rounded,
//                         obscureText: _obscurePassword,
//                         textInputAction: TextInputAction.next,
//                         suffixIcon: IconButton(
//                           onPressed: () {
//                             setState(() {
//                               _obscurePassword = !_obscurePassword;
//                             });
//                           },
//                           icon: Icon(
//                             _obscurePassword
//                                 ? Icons.visibility_outlined
//                                 : Icons.visibility_off_outlined,
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter a password.';
//                           }

//                           if (value.length < 6) {
//                             return 'Password must be at least 6 characters.';
//                           }

//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 16),

//                       _buildField(
//                         controller: _confirmPasswordController,
//                         label: 'Confirm Password',
//                         icon: Icons.lock_outline_rounded,
//                         obscureText: _obscureConfirmPassword,
//                         textInputAction: TextInputAction.done,
//                         onFieldSubmitted: (_) => _register(),
//                         suffixIcon: IconButton(
//                           onPressed: () {
//                             setState(() {
//                               _obscureConfirmPassword =
//                                   !_obscureConfirmPassword;
//                             });
//                           },
//                           icon: Icon(
//                             _obscureConfirmPassword
//                                 ? Icons.visibility_outlined
//                                 : Icons.visibility_off_outlined,
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please confirm your password.';
//                           }

//                           if (value != _passwordController.text) {
//                             return 'Passwords do not match.';
//                           }

//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 24),

//                       // Register button
//                       SizedBox(
//                         width: double.infinity,
//                         height: 54,
//                         child: FilledButton(
//                           onPressed: _isLoading ? null : _register,
//                           style: FilledButton.styleFrom(
//                             backgroundColor: navy,
//                             foregroundColor: Colors.white,
//                             disabledBackgroundColor:
//                                 navy.withOpacity(0.45),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(13),
//                             ),
//                             elevation: 0,
//                           ),
//                           child: _isLoading
//                               ? const SizedBox(
//                                   height: 21,
//                                   width: 21,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color: Colors.white,
//                                   ),
//                                 )
//                               : const Text(
//                                   'Create Account',
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.w700,
//                                     letterSpacing: 0.2,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 25),

//                 // Login
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Already have an account?',
//                       style: TextStyle(
//                         color: muted,
//                         fontSize: 14,
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: _isLoading
//                           ? null
//                           : () {
//                               Navigator.of(context).pop();
//                             },
//                       style: TextButton.styleFrom(
//                         foregroundColor: gold,
//                         padding: const EdgeInsets.only(left: 5),
//                       ),
//                       child: const Text(
//                         'Login',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 12),

//                 const Text(
//                   'By creating an account, you agree to our terms and conditions.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: muted,
//                     fontSize: 11,
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     required String? Function(String?) validator,
//     TextInputType? keyboardType,
//     TextInputAction? textInputAction,
//     bool obscureText = false,
//     Widget? suffixIcon,
//     void Function(String)? onFieldSubmitted,
//   }) {
//     const navy = Color(0xFF18202B);
//     const gold = Color(0xFFB08A3E);
//     const muted = Color(0xFF77746E);
//     const fieldBackground = Color(0xFFFFFFFF);
//     const border = Color(0xFFE5E1D8);

//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       textInputAction: textInputAction,
//       obscureText: obscureText,
//       onFieldSubmitted: onFieldSubmitted,
//       validator: validator,
//       cursorColor: gold,
//       style: const TextStyle(
//         color: navy,
//         fontSize: 15,
//         fontWeight: FontWeight.w500,
//       ),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(
//           color: muted,
//           fontSize: 14,
//         ),
//         floatingLabelStyle: const TextStyle(
//           color: gold,
//           fontWeight: FontWeight.w600,
//         ),
//         prefixIcon: Icon(
//           icon,
//           color: muted,
//           size: 21,
//         ),
//         suffixIcon: suffixIcon,
//         filled: true,
//         fillColor: fieldBackground,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 17,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(
//             color: border,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(
//             color: gold,
//             width: 1.4,
//           ),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(
//             color: Colors.redAccent,
//           ),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(
//             color: Colors.redAccent,
//             width: 1.2,
//           ),
//         ),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

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

  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );

      Navigator.of(context).pop();
    } on Exception catch (e) {
      if (!mounted) return;

      String message = 'Registration failed. Please try again.';

      final error = e.toString();

      if (error.contains('email-already-in-use')) {
        message = 'An account already exists with this email.';
      } else if (error.contains('invalid-email')) {
        message = 'Please enter a valid email address.';
      } else if (error.contains('weak-password')) {
        message = 'Password is too weak.';
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
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 35),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Top bar
                    // Row(
                    //   children: [
                    //     _roundIconButton(
                    //       icon: Icons.arrow_back_rounded,
                    //       onPressed: _isLoading
                    //           ? null
                    //           : () {
                    //               Navigator.of(context).pop();
                    //             },
                    //     ),
                    //     const Spacer(),
                    //     const Text(
                    //       'JOIN THE VERSE',
                    //       style: TextStyle(
                    //         color: muted,
                    //         fontSize: 10,
                    //         fontWeight: FontWeight.w700,
                    //         letterSpacing: 2,
                    //       ),
                    //     ),
                    //     const SizedBox(width: 46),
                    //   ],
                    // ),

                    const SizedBox(height: 42),

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

                    const Align(
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
                            controller: _nameController,
                            label: 'Full Name',
                            hint: 'Enter your name',
                            icon: Icons.person_outline_rounded,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
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
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
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
                            hint: 'Create a strong password',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
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
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            hint: 'Repeat your password',
                            icon: Icons.verified_user_outlined,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _register(),
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
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password.';
                              }

                              if (value != _passwordController.text) {
                                return 'Passwords do not match.';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 22),

                          // Button
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
                                onPressed: _isLoading ? null : _register,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  disabledBackgroundColor:
                                      Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _isLoading
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
                                          Text(
                                            'Create Account',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
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

                    // Login section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            padding: const EdgeInsets.only(left: 6),
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

                    // Bottom detail
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 28,
                          height: 1,
                          color: Colors.white.withOpacity(0.10),
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
                          color: Colors.white.withOpacity(0.10),
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

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF111522),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 19,
          color: const Color(0xFFF7F7FA),
        ),
      ),
    );
  }
}
