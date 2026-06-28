import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/assessment_model.dart';
import '../../providers/assessment_provider.dart';
import '../../widgets/assessment/sarata_group_card.dart';

class Section2Screen extends StatefulWidget {
  const Section2Screen({super.key});

  @override
  State<Section2Screen> createState() => _Section2ScreenState();
}

class _Section2ScreenState extends State<Section2Screen> {
  int _currentCategoryIndex = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFromCache();
    });
  }

  void _initFromCache() {
    final provider = context.read<AssessmentProvider>();
    provider.restoreFromCache();

    // Resume from the first unanswered / unvisited Sara category
    int resumeIndex = 0;
    for (int i = 0; i < SarataQuestionBank.sections.length; i++) {
      final section = SarataQuestionBank.sections[i];
      if (!provider.sarataSelections.containsKey(section.dhatu)) {
        resumeIndex = i;
        break;
      }
    }

    setState(() {
      _currentCategoryIndex = resumeIndex;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final provider = context.watch<AssessmentProvider>();
    final currentSection = SarataQuestionBank.sections[_currentCategoryIndex];
    final selections = provider.sarataSelections[currentSection.dhatu] ?? {};

    final overallProgress = (_currentCategoryIndex + 1) / SarataQuestionBank.sections.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Text(
              '${currentSection.dhatu} Sarata',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Text(
              'Section 2 — Tissue Quality / सारता',
              style: GoogleFonts.lato(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: overallProgress,
            backgroundColor: AppColors.primary.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            minHeight: 6,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Page Tracker
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category ${_currentCategoryIndex + 1} of ${SarataQuestionBank.sections.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox.shrink(),
                  ],
                ),
              ),

              // Groups List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: currentSection.groups.length,
                  itemBuilder: (context, index) {
                    final group = currentSection.groups[index];
                    return SarataGroupCard(
                      group: group,
                      selections: selections,
                      onChanged: (itemText, selected) {
                        provider.setSarataSelection(
                          currentSection.dhatu,
                          itemText,
                          selected,
                        );
                      },
                    );
                  },
                ),
              ),

              // Bottom buttons
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Row(
                  children: [
                    // Previous
                    if (_currentCategoryIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _currentCategoryIndex--;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Previous',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    else
                      const Spacer(),

                    const SizedBox(width: 16),

                    // Next or Finish
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Mark as visited in selections map if it has no entries yet
                          if (!provider.sarataSelections.containsKey(currentSection.dhatu)) {
                            provider.setSarataSelection(currentSection.dhatu, '_visited', true);
                          }

                          if (_currentCategoryIndex < SarataQuestionBank.sections.length - 1) {
                            setState(() {
                              _currentCategoryIndex++;
                            });
                          } else {
                            // Finish and Submit
                            provider.finishSection2();
                            await provider.submitAssessment();

                            if (!mounted) return;

                            if (provider.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.error,
                                  content: Text(
                                    provider.errorMessage!,
                                    style: GoogleFonts.poppins(color: Colors.white),
                                  ),
                                ),
                              );
                            }

                            // Navigate to Result screen and clear assessment stacks
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.result,
                              (route) => route.settings.name == AppRoutes.dashboard,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          _currentCategoryIndex < SarataQuestionBank.sections.length - 1
                              ? 'Next'
                              : 'Finish Section 2',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Loading Overlay during submission
          if (provider.isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: AppColors.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Submitting Assessment...',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Calculating your Ayurvedic health profile',
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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
