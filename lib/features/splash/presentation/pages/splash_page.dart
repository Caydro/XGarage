import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../widgets/glowing_emblem.dart';
import '../widgets/glowing_spinner.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();

    // Trigger auth status check in background
    context.read<AuthCubit>().checkAuthStatus();

    // Allow splash animation to play smoothly for 2.4s before routing
    _navTimer = Timer(const Duration(milliseconds: 2400), _navigateToNextScreen);
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    final authState = context.read<AuthCubit>().state;

    if (authState is Authenticated) {
      if (authState.user.isEmployee) {
        context.go('/employee/queue');
      } else {
        context.go('/owner/dashboard');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A090D),
      body: Stack(
        children: [
          // Ambient Radial Crimson Glow in background
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            height: 320,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 0.8,
                  colors: [
                    Color(0x38E11D48),
                    Color(0x10E11D48),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Top: Glowing Concentric Tachometer Brand Emblem
                    const GlowingParkingEmblem(size: 124),
                    const SizedBox(height: 20),

                    // Branded Wordmark with Glowing Crimson X
                    const AppLogo.wordmark(
                      size: 26,
                      showSubtitle: true,
                      isItalic: true,
                    ),

                    const Spacer(flex: 2),

                    // Center: Dark McLaren Supercar with Crimson Neon Contours
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Soft ground red reflection
                          Container(
                            height: 34,
                            width: 260,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x44E11D48),
                                  blurRadius: 36,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          Image.asset(
                            'assets/images/splash_car.png',
                            height: 190,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Elegant fallback if asset file is not ready
                              return Container(
                                height: 160,
                                margin: const EdgeInsets.symmetric(horizontal: 24),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceCard,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primaryCrimson.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.directions_car_filled_rounded,
                                    size: 72,
                                    color: AppColors.primaryCrimson,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Bottom: Neon Crimson Glowing Rotating Spinner
                    const GlowingCrimsonSpinner(size: 48),
                    const SizedBox(height: 20),

                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
