import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _logoAnim;
  late final Animation<double> _textAnim;
  late final Animation<double> _btnAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
    );
    _textAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
    );
    _btnAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
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
            children: [
              // ── Decorative background arcs ─────────────────────────────
              Positioned(
                top: -size.height * 0.05,
                right: -size.width * 0.15,
                child: _Arc(radius: size.width * 0.7),
              ),
              Positioned(
                bottom: size.height * 0.25,
                left: -size.width * 0.2,
                child: _Arc(
                  radius: size.width * 0.5,
                  color: AppColors.accent.withOpacity(0.08),
                ),
              ),
              // Gold accent dot row
              Positioned(
                top: size.height * 0.22,
                right: 28,
                child: _DotGrid(color: AppColors.accent.withOpacity(0.25)),
              ),

              // ── Main content ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: size.height * 0.10),

                    // Logo
                    ScaleTransition(
                      scale: _logoAnim,
                      child: Center(child: _buildLogo()),
                    ),

                    const SizedBox(height: 28),

                    // App name
                    FadeTransition(
                      opacity: _textAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(_textAnim),
                        child: Column(
                          children: [
                            Text(
                              AppStrings.appName,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Accent underline
                            Container(
                              width: 60,
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Subtitle
                    FadeTransition(
                      opacity: _textAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.4),
                          end: Offset.zero,
                        ).animate(_textAnim),
                        child: Text(
                          AppStrings.appSubtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 15,
                            color: Colors.white70,
                            height: 1.7,
                          ),
                        ),
                      ),
                    ),

                    // Dhatu pills row
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _textAnim,
                      child: _DhatuPills(),
                    ),

                    const Spacer(),

                    // ── CTA Buttons ────────────────────────────────────────
                    FadeTransition(
                      opacity: _btnAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(_btnAnim),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Primary: Begin Assessment
                            _GradientButton(
                              key: const Key('beginAssessmentButton'),
                              label: AppStrings.beginAssessment,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE8A838), Color(0xFFD4942A)],
                              ),
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(AppRoutes.phone),
                            ),

                            const SizedBox(height: 14),

                            // Secondary: Already have account
                            OutlinedButton(
                              key: const Key('alreadyHaveAccountButton'),
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(AppRoutes.phone),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                    color: Colors.white38, width: 1.5),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                AppStrings.alreadyHaveAccount,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.06),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.10),
        border: Border.all(color: Colors.white24, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: AppColors.accent.withOpacity(0.15),
            blurRadius: 16,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/dhatu_logo.png',
          width: 110,
          height: 110,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: Colors.white,
              size: 52,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Dhatu pills ────────────────────────────────────────────────────────────────

class _DhatuPills extends StatelessWidget {
  static const _dhatus = [
    'Rasa', 'Rakta', 'Mamsa', 'Meda', 'Asthi', 'Majja', 'Shukra'
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: _dhatus.map((d) => _pill(d)).toList(),
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: 12,
          color: Colors.white70,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Gradient button ────────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final String label;
  final Gradient gradient;
  final VoidCallback onPressed;

  const _GradientButton({
    super.key,
    required this.label,
    required this.gradient,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Decorative arc ─────────────────────────────────────────────────────────────

class _Arc extends StatelessWidget {
  final double radius;
  final Color color;

  const _Arc({
    required this.radius,
    this.color = const Color(0x141A5C5A),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1),
      ),
    );
  }
}

// ── Dot grid ──────────────────────────────────────────────────────────────────

class _DotGrid extends StatelessWidget {
  final Color color;
  const _DotGrid({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(4, (row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (col) {
            return Container(
              margin: const EdgeInsets.all(3),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            );
          }),
        );
      }),
    );
  }
}
