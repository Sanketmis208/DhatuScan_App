import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/assessment_model.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/assessment/vk_question_card.dart';

class Stage {
  final String dhatu;
  final String subsection; // 'vriddhi' or 'kshaya'

  const Stage(this.dhatu, this.subsection);
}

class Section1Screen extends StatefulWidget {
  const Section1Screen({super.key});

  @override
  State<Section1Screen> createState() => _Section1ScreenState();
}

class _Section1ScreenState extends State<Section1Screen> {
  static const List<Stage> _stages = [
    Stage('Rasa', 'vriddhi'),
    Stage('Rasa', 'kshaya'),
    Stage('Rakta', 'vriddhi'),
    Stage('Rakta', 'kshaya'),
    Stage('Mamsa', 'vriddhi'),
    Stage('Mamsa', 'kshaya'),
    Stage('Meda', 'vriddhi'),
    Stage('Meda', 'kshaya'),
    Stage('Asthi', 'vriddhi'),
    Stage('Asthi', 'kshaya'),
    Stage('Majja', 'vriddhi'),
    Stage('Majja', 'kshaya'),
    Stage('Shukra', 'vriddhi'),
    Stage('Shukra', 'kshaya'),
  ];

  int _currentStageIndex = 0;
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

    final gender = context.read<UserProvider>().user?.gender;

    // Scan stages to find the first unanswered one
    int resumeStage = 0;
    for (int i = 0; i < _stages.length; i++) {
      final stage = _stages[i];
      final questions = QuestionBank.questions[stage.dhatu]![stage.subsection]!
          .where((q) => !q.isMaleOnly || gender == 'Male')
          .toList();

      final answeredMap = provider.vkAnswers[stage.dhatu];
      final currentAnswers = stage.subsection == 'vriddhi'
          ? answeredMap?.vriddhiAnswers
          : answeredMap?.kshayaAnswers;

      bool stageComplete = true;
      for (final q in questions) {
        if (currentAnswers == null || !currentAnswers.containsKey(q.symptom)) {
          stageComplete = false;
          break;
        }
      }

      if (!stageComplete) {
        resumeStage = i;
        break;
      }
    }

    setState(() {
      _currentStageIndex = resumeStage;
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
    final userProvider = context.watch<UserProvider>();
    final gender = userProvider.user?.gender;

    final currentStage = _stages[_currentStageIndex];
    final allQuestions = QuestionBank
        .questions[currentStage.dhatu]![currentStage.subsection]!;
    final filteredQuestions = allQuestions
        .where((q) => !q.isMaleOnly || gender == 'Male')
        .toList();

    final answers = provider.vkAnswers[currentStage.dhatu];
    final answerMap = currentStage.subsection == 'vriddhi'
        ? answers?.vriddhiAnswers
        : answers?.kshayaAnswers;

    int answeredCount = 0;
    for (final q in filteredQuestions) {
      if (answerMap != null && answerMap.containsKey(q.symptom)) {
        answeredCount++;
      }
    }

    final overallProgress = (_currentStageIndex + 1) / _stages.length;

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
              '${currentStage.dhatu} Dhatu',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Text(
              currentStage.subsection == 'vriddhi'
                  ? 'Vriddhi (Excess / वृद्धि)'
                  : 'Kshaya (Deficiency / क्षय)',
              style: GoogleFonts.lato(
                fontSize: 12,
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
      body: Column(
        children: [
          // Stage Progress Indicator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stage ${_currentStageIndex + 1} of ${_stages.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Answered: $answeredCount / ${filteredQuestions.length}',
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: answeredCount == filteredQuestions.length
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Questions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: filteredQuestions.length,
              itemBuilder: (context, index) {
                final q = filteredQuestions[index];
                return VKQuestionCard(
                  symptom: q.symptom,
                  selectedScore: answerMap?[q.symptom],
                  onChanged: (score) {
                    provider.setVKAnswer(
                      currentStage.dhatu,
                      currentStage.subsection,
                      q.symptom,
                      score,
                    );
                  },
                );
              },
            ),
          ),

          // Bottom Navigation Buttons
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
                // Previous Button
                if (_currentStageIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _currentStageIndex--;
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

                // Next or Finish Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate all questions answered in current stage
                      bool allAnswered = true;
                      for (final q in filteredQuestions) {
                        if (answerMap == null || !answerMap.containsKey(q.symptom)) {
                          allAnswered = false;
                          break;
                        }
                      }

                      if (!allAnswered) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.error,
                            content: Text(
                              'Please answer all questions on this page.',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ),
                        );
                        return;
                      }

                      if (_currentStageIndex < _stages.length - 1) {
                        setState(() {
                          _currentStageIndex++;
                        });
                      } else {
                        // Final stage complete, finish Section 1
                        provider.finishSection1(gender: gender);
                        Navigator.of(context).pop();
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
                      _currentStageIndex < _stages.length - 1 ? 'Next' : 'Finish Section 1',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
