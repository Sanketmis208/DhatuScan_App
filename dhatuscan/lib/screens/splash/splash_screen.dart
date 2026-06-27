import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../services/local_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Logo scale + glow animation
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  // Tagline + button slide-up
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _slideFade;

  // Pulse ring animation
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // ── Logo scale-in ──────────────────────────────────────────────────────
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    // ── Text slide-up ──────────────────────────────────────────────────────
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeIn),
    );

    // ── Pulse ring ────────────────────────────────────────────────────────
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    // Start sequence
    _scaleController.forward().then((_) {
      _slideController.forward();
    });

    // Navigate after 2.5 s
    Future.delayed(const Duration(milliseconds: 2500), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final isLoggedIn = LocalStorageService.isLoggedIn;
    Navigator.of(context).pushReplacementNamed(
      isLoggedIn ? AppRoutes.dashboard : AppRoutes.landing,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF061A19),
              Color(0xFF0D3D3B),
              Color(0xFF1A5C5A),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Background decorative orbs ─────────────────────────────
              Positioned(
                top: size.height * 0.08,
                right: -40,
                child: _Orb(
                  size: 180,
                  color: AppColors.primary.withOpacity(0.18),
                ),
              ),
              Positioned(
                bottom: size.height * 0.12,
                left: -50,
                child: _Orb(
                  size: 200,
                  color: AppColors.accent.withOpacity(0.10),
                ),
              ),
              Positioned(
                top: size.height * 0.35,
                left: 20,
                child: _Orb(
                  size: 80,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),

              // ── Main content ───────────────────────────────────────────
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pulse ring + logo
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: _buildLogoSection(),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // App name + tagline
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _slideFade,
                      child: Column(
                        children: [
                          Text(
                            AppStrings.appName,
                            style: GoogleFonts.poppins(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.tagline,
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: Colors.white60,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 72),

                  // Loading dots
                  FadeTransition(
                    opacity: _slideFade,
                    child: _LoadingDots(),
                  ),
                ],
              ),

              // ── Bottom tagline ─────────────────────────────────────────
              Positioned(
                bottom: 32,
                child: FadeTransition(
                  opacity: _slideFade,
                  child: Text(
                    'Scan • Analyse • Balance',
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      color: Colors.white30,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (_, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse ring
            Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(
                      (1.4 - _pulseAnimation.value) * 0.4,
                    ),
                    width: 2,
                  ),
                ),
              ),
            ),
            // Inner glow
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            // Logo container
            child!,
          ],
        );
      },
      child: Container(
        width: 116,
        height: 116,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.12),
          border: Border.all(color: Colors.white30, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/dhatu_logo.png',
            width: 116,
            height: 116,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallbackIcon(),
          ),
        ),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.health_and_safety_rounded,
        color: Colors.white,
        size: 56,
      ),
    );
  }
}

// ── Loading dots animation ─────────────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final t = (_ctrl.value - delay).clamp(0, 1);
            final opacity = (t < 0.5 ? t * 2 : (1 - t) * 2).toDouble();
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3 + 0.6 * opacity),
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Decorative orb ─────────────────────────────────────────────────────────────

class _Orb extends StatelessWidget {
  final double size;
  final Color color;

  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
