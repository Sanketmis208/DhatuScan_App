import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../providers/assessment_provider.dart';

class AssessmentHomeScreen extends StatefulWidget {
  const AssessmentHomeScreen({super.key});

  @override
  State<AssessmentHomeScreen> createState() => _AssessmentHomeScreenState();
}

class _AssessmentHomeScreenState extends State<AssessmentHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Restore state from cache when home is opened.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssessmentProvider>().restoreFromCache();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssessmentProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard),
        ),
        title: Text(
          'Ayurvedic Assessment',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Banner
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary, Color(0xFF0F3E3C)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analyze Your Dhatus',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete both sections to get a comprehensive analysis of your tissue balance and constitution.',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: AppColors.accent, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Total Time: 20-30 mins',
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // Section 1 Card
                  _buildSectionCard(
                    context,
                    title: 'Section 1: Dhatu Vriddhi-Kshaya',
                    subtitle: 'Symptom-based Tissue Balance',
                    description:
                        'Evaluates the excess (Vriddhi) or deficiency (Kshaya) of all 7 Dhatus based on your current physical & physiological symptoms.',
                    estimatedTime: '10-15 mins',
                    isComplete: provider.section1Complete,
                    icon: Icons.analytics_outlined,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.section1);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Section 2 Card
                  _buildSectionCard(
                    context,
                    title: 'Section 2: Dhatu Sarata',
                    subtitle: 'Constitutional Tissue Excellence',
                    description:
                        'Identifies your dominant Dhatus and constitutional strength (Sarata) based on your physical features, mental traits, and habits.',
                    estimatedTime: '10-15 mins',
                    isComplete: provider.section2Complete,
                    // Section 2 requires Section 1 completion in most flows,
                    // but we allow starting if they wish, or we can check.
                    isEnabled: provider.section1Complete,
                    icon: Icons.health_and_safety_outlined,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.section2);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Help card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary, size: 24),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Your progress is saved automatically. You can close the app and resume from where you left off at any time.',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required String estimatedTime,
    required bool isComplete,
    bool isEnabled = true,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? onTap : null,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isComplete
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isComplete ? Icons.check : icon,
                            color: isComplete ? AppColors.success : AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                subtitle,
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      description,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              estimatedTime,
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        isComplete
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Completed',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              )
                            : isEnabled
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Start',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_forward,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Locked',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
