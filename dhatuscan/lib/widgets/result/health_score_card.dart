import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../common/loading_shimmer.dart';

class HealthScoreCard extends StatelessWidget {
  final double? healthIndex;
  final String? healthGrade;
  final String? balanceStatus;
  final bool isLoading;

  const HealthScoreCard({
    super.key,
    this.healthIndex,
    this.healthGrade,
    this.balanceStatus,
    this.isLoading = false,
  });

  Color _getGradeColor(String? grade) {
    switch (grade) {
      case 'Excellent':
        return AppColors.success;
      case 'Good':
        return const Color(0xFF8BC34A); // Light Green
      case 'Fair':
        return AppColors.warning; // Orange
      case 'Poor':
        return AppColors.error; // Red
      default:
        return Colors.grey;
    }
  }

  Color _getBalanceColor(String? status) {
    if (status == null) return Colors.grey;
    if (status.contains('Well Balanced') || status.contains('Sama')) {
      return AppColors.success;
    }
    if (status.contains('Mild')) {
      return const Color(0xFFFFCA28); // Amber/Yellow
    }
    if (status.contains('Moderate')) {
      return AppColors.warning; // Orange
    }
    return AppColors.error; // Red
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
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
        child: const Column(
          children: [
            LoadingShimmer(height: 20, width: 150),
            SizedBox(height: 12),
            LoadingShimmer(height: 50, width: 100),
            SizedBox(height: 12),
            LoadingShimmer(height: 16, width: 200),
          ],
        ),
      );
    }

    final score = healthIndex ?? 0.0;
    final grade = healthGrade ?? 'Unknown';
    final status = balanceStatus ?? 'Unknown';
    final gradeColor = _getGradeColor(grade);
    final balanceColor = _getBalanceColor(status);

    return Container(
      padding: const EdgeInsets.all(20),
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
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ayurvedic Health Score',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: gradeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: gradeColor.withOpacity(0.3)),
                ),
                child: Text(
                  grade,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: gradeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Big score indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  fontSize: 54,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Text(
                  '/ 100',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Divider
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 14),

          // Balance status message
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.balance_rounded, color: balanceColor, size: 18),
              const SizedBox(width: 8),
              Text(
                status,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: balanceColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
