import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/symptom_translations.dart';

class VKQuestionCard extends StatelessWidget {
  final String symptom;
  final int? selectedScore;
  final ValueChanged<int> onChanged;

  const VKQuestionCard({
    super.key,
    required this.symptom,
    this.selectedScore,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final translation = SymptomTranslations.translations[symptom];
    final titleHi = translation?.titleHindi ?? symptom;
    final descEn = translation?.descEn ?? '';
    final descHi = translation?.descHi ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: selectedScore != null
              ? AppColors.primary.withOpacity(0.3)
              : Colors.grey.shade100,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bilingual Title
            Text(
              symptom,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (titleHi.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                titleHi,
                style: const TextStyle(
                  fontFamily: 'NotoSansDevanagari',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
            const SizedBox(height: 12),

            // Bilingual Descriptions
            if (descEn.isNotEmpty)
              Text(
                descEn,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            if (descHi.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                descHi,
                style: const TextStyle(
                  fontFamily: 'NotoSansDevanagari',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 18),

            // 4-point radio buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRadioButton(context, 0, 'No', 'नहीं'),
                _buildRadioButton(context, 1, 'Mild', 'हल्का'),
                _buildRadioButton(context, 2, 'Moderate', 'मध्यम'),
                _buildRadioButton(context, 3, 'Severe', 'गंभीर'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton(
      BuildContext context, int value, String labelEn, String labelHi) {
    final isSelected = selectedScore == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.08)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Radio indicator
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Bilingual label
              Text(
                labelEn,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              Text(
                labelHi,
                style: TextStyle(
                  fontFamily: 'NotoSansDevanagari',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
