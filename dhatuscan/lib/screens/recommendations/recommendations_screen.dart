import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/recommendations_data.dart';
import '../../core/utils/score_calculator.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Severe':
        return AppColors.error;
      case 'Moderate':
        return AppColors.warning;
      case 'Mild':
        return const Color(0xFFFFCA28);
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final List<AffectedDhatu> affectedDhatus =
        (args is List<AffectedDhatu>) ? args : [];

    final isBalanced = affectedDhatus.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Recommendations',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isBalanced)
              _buildBalancedStateCard()
            else ...[
              _buildHeaderCard(),
              const SizedBox(height: 20),
              ...affectedDhatus.map((ad) => _buildRecommendationTile(context, ad)),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personalized Guidelines',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ayurveda suggests diet, lifestyle modifications, and herbs to bring your imbalanced tissues back to equilibrium.',
            style: GoogleFonts.lato(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalancedStateCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.accent,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Sama Dhatu (Sustained Balance)',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Congratulations! Your Dhatus are in a state of perfect balance. Maintain your healthy lifestyle, pure diet, and regular daily routines.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'बधाई हो! आपके सभी धातु संतुलित स्थिति (सम धातु) में हैं। स्वस्थ जीवनशैली, शुद्ध आहार और नियमित दिनचर्या बनाए रखें।',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'NotoSansDevanagari',
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationTile(BuildContext context, AffectedDhatu ad) {
    final statusColor = _getStatusColor(ad.status);
    final rec = RecommendationsData.getRecommendation(ad.dhatu, ad.type);

    if (rec == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textSecondary,
          title: Row(
            children: [
              Container(
                width: 6,
                height: 36,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ad.dhatu} Dhatu — ${ad.type}',
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Status: ${ad.status}',
                      style: GoogleFonts.lato(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),

                  _buildCategoryBlock(
                    titleEn: 'Pathya Aahar (Recommended Diet)',
                    titleHi: 'पथ्य आहार (अनुकूल भोजन)',
                    textEn: rec.pathyaAahar,
                    textHi: rec.pathyaAaharHi,
                    icon: Icons.restaurant,
                    color: AppColors.success,
                  ),
                  _buildCategoryBlock(
                    titleEn: 'Apathya Aahar (Diet to Avoid)',
                    titleHi: 'अपथ्य आहार (परहेज योग्य भोजन)',
                    textEn: rec.apathyaAahar,
                    textHi: rec.apathyaAaharHi,
                    icon: Icons.no_food,
                    color: AppColors.error,
                  ),
                  _buildCategoryBlock(
                    titleEn: 'Pathya Vihara (Recommended Lifestyle)',
                    titleHi: 'पथ्य विहार (अनुकूल जीवनशैली)',
                    textEn: rec.pathyaVihara,
                    textHi: rec.pathyaViharaHi,
                    icon: Icons.directions_walk,
                    color: AppColors.success,
                  ),
                  _buildCategoryBlock(
                    titleEn: 'Apathya Vihara (Lifestyle to Avoid)',
                    titleHi: 'अपथ्य विहार (परहेज योग्य आदतें)',
                    textEn: rec.apathyaVihara,
                    textHi: rec.apathyaViharaHi,
                    icon: Icons.block,
                    color: AppColors.error,
                  ),
                  _buildCategoryBlock(
                    titleEn: 'Aushadha (Ayurvedic Medicine)',
                    titleHi: 'औषध (आयुर्वेदिक औषधियाँ)',
                    textEn: rec.aushadha,
                    textHi: rec.aushadhaHi,
                    icon: Icons.spa,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBlock({
    required String titleEn,
    required String titleHi,
    required String textEn,
    required String textHi,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleEn,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  titleHi,
                  style: const TextStyle(
                    fontFamily: 'NotoSansDevanagari',
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  textEn,
                  style: GoogleFonts.lato(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  textHi,
                  style: const TextStyle(
                    fontFamily: 'NotoSansDevanagari',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
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
