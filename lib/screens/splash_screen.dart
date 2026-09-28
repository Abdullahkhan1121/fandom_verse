// // import 'dart:async';
// // import 'package:flutter/material.dart';

// // class SplashScreen extends StatefulWidget {
// //   const SplashScreen({super.key});

// //   @override
// //   State<SplashScreen> createState() => _SplashScreenState();
// // }

// // class _SplashScreenState extends State<SplashScreen>
// //     with SingleTickerProviderStateMixin {
// //   late AnimationController _controller;

// //   late Animation<double> _logoScale;
// //   late Animation<double> _logoOpacity;
// //   late Animation<double> _contentOpacity;
// //   late Animation<Offset> _contentSlide;

// //   @override
// //   void initState() {
// //     super.initState();

// //     _controller = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 1600),
// //     );

// //     _logoScale = Tween<double>(
// //       begin: 0.72,
// //       end: 1.0,
// //     ).animate(
// //       CurvedAnimation(
// //         parent: _controller,
// //         curve: const Interval(
// //           0.0,
// //           0.65,
// //           curve: Curves.easeOutBack,
// //         ),
// //       ),
// //     );

// //     _logoOpacity = Tween<double>(
// //       begin: 0.0,
// //       end: 1.0,
// //     ).animate(
// //       CurvedAnimation(
// //         parent: _controller,
// //         curve: const Interval(
// //           0.0,
// //           0.35,
// //           curve: Curves.easeOut,
// //         ),
// //       ),
// //     );

// //     _contentOpacity = Tween<double>(
// //       begin: 0.0,
// //       end: 1.0,
// //     ).animate(
// //       CurvedAnimation(
// //         parent: _controller,
// //         curve: const Interval(
// //           0.45,
// //           0.9,
// //           curve: Curves.easeOut,
// //         ),
// //       ),
// //     );

// //     _contentSlide = Tween<Offset>(
// //       begin: const Offset(0, 0.15),
// //       end: Offset.zero,
// //     ).animate(
// //       CurvedAnimation(
// //         parent: _controller,
// //         curve: const Interval(
// //           0.45,
// //           0.9,
// //           curve: Curves.easeOutCubic,
// //         ),
// //       ),
// //     );

// //     _controller.forward();

// //     Timer(
// //       const Duration(milliseconds: 3000),
// //       _goNext,
// //     );
// //   }

// //   void _goNext() {
// //     if (!mounted) return;

// //     // ---------------------------------------------------------
// //     // PUT YOUR EXISTING SPLASH NAVIGATION LOGIC HERE.
// //     //
// //     // Example:
// //     //
// //     // Navigator.pushReplacement(
// //     //   context,
// //     //   MaterialPageRoute(
// //     //     builder: (_) => const LoginScreen(),
// //     //   ),
// //     // );
// //     // ---------------------------------------------------------
// //   }

// //   @override
// //   void dispose() {
// //     _controller.dispose();
// //     super.dispose();
// //   }

// //   Widget _glowCircle({
// //     required double size,
// //     required Color color,
// //     required double opacity,
// //     required double top,
// //     required double left,
// //   }) {
// //     return Positioned(
// //       top: top,
// //       left: left,
// //       child: IgnorePointer(
// //         child: Container(
// //           width: size,
// //           height: size,
// //           decoration: BoxDecoration(
// //             shape: BoxShape.circle,
// //             color: color.withOpacity(opacity),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: color.withOpacity(opacity),
// //                 blurRadius: 100,
// //                 spreadRadius: 40,
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final size = MediaQuery.of(context).size;

// //     return Scaffold(
// //       backgroundColor: const Color(0xFF080A12),
// //       body: Stack(
// //         children: [
// //           // --------------------------------------------------
// //           // BACKGROUND GLOW
// //           // --------------------------------------------------

// //           _glowCircle(
// //             size: 320,
// //             color: const Color(0xFF7C5CFC),
// //             opacity: 0.12,
// //             top: -120,
// //             left: size.width - 140,
// //           ),

// //           _glowCircle(
// //             size: 360,
// //             color: const Color(0xFFE0B45A),
// //             opacity: 0.055,
// //             top: size.height - 170,
// //             left: -170,
// //           ),

// //           _glowCircle(
// //             size: 230,
// //             color: const Color(0xFF7C5CFC),
// //             opacity: 0.045,
// //             top: size.height * 0.32,
// //             left: -130,
// //           ),

// //           // --------------------------------------------------
// //           // MAIN CONTENT
// //           // --------------------------------------------------

// //           SafeArea(
// //             child: Center(
// //               child: AnimatedBuilder(
// //                 animation: _controller,
// //                 builder: (context, child) {
// //                   return Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       // ------------------------------------------------
// //                       // LOGO
// //                       // ------------------------------------------------

// //                       Opacity(
// //                         opacity: _logoOpacity.value,
// //                         child: Transform.scale(
// //                           scale: _logoScale.value,
// //                           child: Container(
// //                             width: 142,
// //                             height: 142,
// //                             padding: const EdgeInsets.all(20),
// //                             decoration: BoxDecoration(
// //                               shape: BoxShape.circle,
// //                               gradient: const LinearGradient(
// //                                 begin: Alignment.topLeft,
// //                                 end: Alignment.bottomRight,
// //                                 colors: [
// //                                   Color(0xFF9D87FF),
// //                                   Color(0xFF7C5CFC),
// //                                 ],
// //                               ),
// //                               boxShadow: [
// //                                 BoxShadow(
// //                                   color: const Color(0xFF7C5CFC)
// //                                       .withOpacity(0.28),
// //                                   blurRadius: 45,
// //                                   spreadRadius: 4,
// //                                 ),
// //                               ],
// //                             ),
// //                             child: ClipOval(
// //                               child: Image.asset(
// //                                 'assets/fandom-logo.png',
// //                                 fit: BoxFit.contain,
// //                                 errorBuilder:
// //                                     (context, error, stackTrace) {
// //                                   return const Icon(
// //                                     Icons.auto_awesome_rounded,
// //                                     color: Color(0xFFF7F7FA),
// //                                     size: 54,
// //                                   );
// //                                 },
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),

// //                       const SizedBox(height: 32),

// //                       // ------------------------------------------------
// //                       // BRAND + TAGLINE
// //                       // ------------------------------------------------

// //                       FadeTransition(
// //                         opacity: _contentOpacity,
// //                         child: SlideTransition(
// //                           position: _contentSlide,
// //                           child: Column(
// //                             children: [
// //                               RichText(
// //                                 text: const TextSpan(
// //                                   children: [
// //                                     TextSpan(
// //                                       text: 'FANDOM',
// //                                       style: TextStyle(
// //                                         color: Color(0xFFF7F7FA),
// //                                         fontSize: 30,
// //                                         fontWeight: FontWeight.w800,
// //                                         letterSpacing: 2.2,
// //                                       ),
// //                                     ),
// //                                     TextSpan(
// //                                       text: ' VERSE',
// //                                       style: TextStyle(
// //                                         color: Color(0xFFE0B45A),
// //                                         fontSize: 30,
// //                                         fontWeight: FontWeight.w800,
// //                                         letterSpacing: 2.2,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),

// //                               const SizedBox(height: 10),

// //                               const Text(
// //                                 'Your universe. Your fandom. Your story.',
// //                                 textAlign: TextAlign.center,
// //                                 style: TextStyle(
// //                                   color: Color(0xFF969AAA),
// //                                   fontSize: 13,
// //                                   fontWeight: FontWeight.w400,
// //                                   letterSpacing: 0.3,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   );
// //                 },
// //               ),
// //             ),
// //           ),

// //           // --------------------------------------------------
// //           // BOTTOM LOADING AREA
// //           // --------------------------------------------------

// //           Positioned(
// //             left: 0,
// //             right: 0,
// //             bottom: 48,
// //             child: FadeTransition(
// //               opacity: _contentOpacity,
// //               child: Column(
// //                 children: [
// //                   SizedBox(
// //                     width: 42,
// //                     height: 3,
// //                     child: ClipRRect(
// //                       borderRadius: BorderRadius.circular(10),
// //                       child: LinearProgressIndicator(
// //                         backgroundColor:
// //                             const Color(0xFF171B2B),
// //                         valueColor:
// //                             const AlwaysStoppedAnimation<Color>(
// //                           Color(0xFF7C5CFC),
// //                         ),
// //                       ),
// //                     ),
// //                   ),

// //                   const SizedBox(height: 16),

// //                   const Text(
// //                     'DISCOVER • CONNECT • CELEBRATE',
// //                     style: TextStyle(
// //                       color: Color(0xFF55596B),
// //                       fontSize: 9,
// //                       fontWeight: FontWeight.w600,
// //                       letterSpacing: 2.0,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }




import 'dart:async';
import 'auth/auth_gate.dart';

import 'package:flutter/material.dart';

// import '../auth/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _logoScale = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.65,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.35,
          curve: Curves.easeOut,
        ),
      ),
    );

    _contentOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.45,
          0.9,
          curve: Curves.easeOut,
        ),
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.45,
          0.9,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _controller.forward();

    Timer(
      const Duration(seconds: 3),
      _goNext,
    );
  }

  void _goNext() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthGate(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _glowCircle({
    required double size,
    required Color color,
    required double opacity,
    required double top,
    required double left,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(opacity),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(opacity),
                blurRadius: 100,
                spreadRadius: 35,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF080A12),
      body: Stack(
        children: [
          // Top-right violet glow
          _glowCircle(
            size: 320,
            color: const Color(0xFF7C5CFC),
            opacity: 0.12,
            top: -120,
            left: screenSize.width - 140,
          ),

          // Bottom-left gold glow
          _glowCircle(
            size: 360,
            color: const Color(0xFFE0B45A),
            opacity: 0.055,
            top: screenSize.height - 170,
            left: -170,
          ),

          // Small violet glow
          _glowCircle(
            size: 230,
            color: const Color(0xFF7C5CFC),
            opacity: 0.045,
            top: screenSize.height * 0.32,
            left: -130,
          ),

          SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // LOGO
                      Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Container(
                            width: 142,
                            height: 142,
                            padding: const EdgeInsets.all(20),
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
                                  color: const Color(0xFF7C5CFC)
                                      .withOpacity(0.28),
                                  blurRadius: 45,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/fandom-logo.png',
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Color(0xFFF7F7FA),
                                    size: 54,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // BRANDING
                      FadeTransition(
                        opacity: _contentOpacity,
                        child: SlideTransition(
                          position: _contentSlide,
                          child: Column(
                            children: [
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'FANDOM',
                                      style: TextStyle(
                                        color: Color(0xFFF7F7FA),
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 2.2,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' VERSE',
                                      style: TextStyle(
                                        color: Color(0xFFE0B45A),
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 2.2,
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
                                  color: Color(0xFF969AAA),
                                  fontSize: 13,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Bottom loading indicator
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: FadeTransition(
              opacity: _contentOpacity,
              child: Column(
                children: [
                  SizedBox(
                    width: 42,
                    height: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        backgroundColor: Color(0xFF171B2B),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF7C5CFC),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'DISCOVER • CONNECT • CELEBRATE',
                    style: TextStyle(
                      color: Color(0xFF55596B),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}