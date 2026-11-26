import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
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
    _navTimer =
        Timer(const Duration(milliseconds: 2400), _navigateToNextScreen);
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
      backgroundColor: const Color(0xFF07060A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient Radial Crimson Core Glow
          Positioned(
            top: MediaQuery.of(context).size.height * 0.12,
            left: 0,
            right: 0,
            height: 420,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.1),
                  radius: 0.8,
                  colors: [
                    Color(0x40E11D48),
                    Color(0x14E11D48),
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

                    // Central High-Performance Tachometer Artwork
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 460,
                            maxWidth: 380,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.asset(
                              'assets/images/splash_bg.jpg',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    GlowingParkingEmblem(size: 130),
                                    SizedBox(height: 24),
                                    AppLogo.wordmark(
                                      size: 28,
                                      showSubtitle: true,
                                      isItalic: true,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Bottom: Neon Crimson Glowing Rotating Spinner
                    const GlowingCrimsonSpinner(size: 46),
                    const SizedBox(height: 28),

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
