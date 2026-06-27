import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/result_model.dart';

class DhatuBarChart extends StatelessWidget {
  final List<DhatuVKResult> vkResults;

  const DhatuBarChart({super.key, required this.vkResults});

  Color getStatusColor(String status) {
    switch (status) {
      case 'No Significant Change':
        return AppColors.success;
      case 'Mild':
        return const Color(0xFFFFCA28); // Amber/Yellow
      case 'Moderate':
        return AppColors.warning; // Orange
      case 'Severe':
        return AppColors.error; // Red
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (vkResults.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No chart data available')),
      );
    }

    return Container(
      height: 280,
      padding: const EdgeInsets.fromLTRB(10, 20, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 12.0),
            child: Text(
              'Tissue Status Breakdown (%)',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: 100,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppColors.primary,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final dhatu = vkResults[groupIndex].dhatu;
                      final type = rodIndex == 0 ? 'Vriddhi' : 'Kshaya';
                      return BarTooltipItem(
                        '$dhatu $type\n${rod.toY.toStringAsFixed(1)}%',
                        GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= vkResults.length) {
                          return const SizedBox.shrink();
                        }
                        final dhatu = vkResults[index].dhatu;
                        // Abbreviation
                        final abbrev = dhatu.substring(0, min(3, dhatu.length));
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 6,
                          child: Text(
                            abbrev,
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: GoogleFonts.lato(
                            fontSize: 9,
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade100,
                    strokeWidth: 1,
                  ),
                ),
                barGroups: List.generate(vkResults.length, (index) {
                  final result = vkResults[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      // Vriddhi Bar
                      BarChartRodData(
                        toY: result.vriddhiPercent,
                        color: getStatusColor(result.vriddhiStatus),
                        width: 8,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      // Kshaya Bar
                      BarChartRodData(
                        toY: result.kshayaPercent,
                        color: getStatusColor(result.kshayaStatus),
                        width: 8,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                    barsSpace: 4,
                  );
                }),
              ),
            ),
          ),
          // Legend
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLegendItem('No Change', AppColors.success),
                _buildLegendItem('Mild', const Color(0xFFFFCA28)),
                _buildLegendItem('Moderate', AppColors.warning),
                _buildLegendItem('Severe', AppColors.error),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 9.5,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
