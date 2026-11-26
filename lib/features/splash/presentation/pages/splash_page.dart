import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_typography.dart';
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
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnim = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();

    // Trigger auth status check in background
    context.read<AuthCubit>().checkAuthStatus();

    // Allow the 30-frame fiery tachometer GIF to complete its full loop (3.2s) before routing
    _navTimer =
        Timer(const Duration(milliseconds: 3200), _navigateToNextScreen);
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF07060A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient Radial Crimson Core Glow behind the tachometer
          Positioned(
            top: size.height * 0.22,
            left: 0,
            right: 0,
            height: 380,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.1),
                  radius: 0.75,
                  colors: [
                    Color(0x55E11D48),
                    Color(0x18E11D48),
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
                    const Spacer(flex: 3),

                    // Central High-Performance Animated Tachometer GIF
                    // Seamlessly blended with vertical edge vignetting so it fits the screen edge-to-edge
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black,
                                Colors.black,
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.06, 0.94, 1.0],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Image.asset(
                            'assets/images/splash_anim.gif',
                            width: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Graceful fallback to static artwork or emblem if GIF fails
                              return Image.asset(
                                'assets/images/splash_bg.jpg',
                                width: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Column(
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
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Bottom: Neon Crimson Glowing Rotating Spinner
                    const GlowingCrimsonSpinner(size: 44),
                    const SizedBox(height: 16),

                    // Telemetry Initialization Status
                    Text(
                      "INITIALIZING SECURE VALET OS",
                      style: AppTypography.getTelemetry(
                        fontSize: 10,
                        color: Colors.white38,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

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
