import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/result_model.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/history_provider.dart';
import '../../widgets/result/dhatu_bar_chart.dart';
import '../../widgets/result/health_score_card.dart';
import '../../core/utils/score_calculator.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isHistory = false;
  String? _assessmentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        setState(() {
          _isHistory = true;
          _assessmentId = args;
        });
        context.read<HistoryProvider>().fetchDetail(args);
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'No Significant Change':
        return AppColors.success;
      case 'Mild':
        return const Color(0xFFFFCA28); // Yellow/Amber
      case 'Moderate':
        return AppColors.warning; // Orange
      case 'Severe':
        return AppColors.error; // Red
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();
    final assessmentProvider = context.watch<AssessmentProvider>();

    final bool loading = _isHistory && historyProvider.isLoading;

    // Resolve results based on source
    List<DhatuVKResult> vkResults = [];
    double healthIndex = 0.0;
    String healthGrade = 'Unknown';
    String balanceStatus = 'Unknown';
    String dominantSara = 'Unknown';
    String secondarySara = 'Unknown';
    String weakestSara = 'Unknown';

    if (_isHistory) {
      final detail = historyProvider.currentDetail;
      if (detail != null) {
        vkResults = detail.vkResults;
        healthIndex = detail.healthIndex;
        healthGrade = detail.healthGrade;
        balanceStatus = detail.balanceStatus;
        dominantSara = detail.dominantSara;
        secondarySara = detail.secondarySara;
        weakestSara = detail.weakestSara;
      }
    } else {
      vkResults = assessmentProvider.vkResults;
      balanceStatus = assessmentProvider.balanceStatus;
      final sarata = assessmentProvider.sarataResult;
      if (sarata != null) {
        healthIndex = sarata.healthIndex;
        healthGrade = sarata.healthGrade;
        dominantSara = sarata.dominantSara;
        secondarySara = sarata.secondarySara;
        weakestSara = sarata.weakestSara;
      }
    }

    // Split balanced vs imbalanced dhatus
    final balancedDhatus = vkResults.where((r) =>
        r.vriddhiStatus == 'No Significant Change' &&
        r.kshayaStatus == 'No Significant Change').toList();

    final imbalancedDhatus = vkResults.where((r) =>
        r.vriddhiStatus != 'No Significant Change' ||
        r.kshayaStatus != 'No Significant Change').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (!_isHistory) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Assessment Result',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Health Score Card
                  HealthScoreCard(
                    healthIndex: healthIndex,
                    healthGrade: healthGrade,
                    balanceStatus: balanceStatus,
                    isLoading: loading,
                  ),

                  const SizedBox(height: 20),

                  // Dhatu Bar Chart
                  DhatuBarChart(vkResults: vkResults),

                  const SizedBox(height: 20),

                  // Balanced vs Imbalanced Lists
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tissue Analysis Overview',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Imbalanced Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Imbalanced (${imbalancedDhatus.length})',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.error,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (imbalancedDhatus.isEmpty)
                                    Text(
                                      'None',
                                      style: GoogleFonts.lato(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    )
                                  else
                                    ...imbalancedDhatus.map((r) {
                                      final List<String> issues = [];
                                      if (r.vriddhiStatus != 'No Significant Change') {
                                        issues.add('Vriddhi (${r.vriddhiStatus})');
                                      }
                                      if (r.kshayaStatus != 'No Significant Change') {
                                        issues.add('Kshaya (${r.kshayaStatus})');
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                        child: Text(
                                          '• ${r.dhatu}: ${issues.join(', ')}',
                                          style: GoogleFonts.lato(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Balanced Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sama / Balanced (${balancedDhatus.length})',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (balancedDhatus.isEmpty)
                                    Text(
                                      'None',
                                      style: GoogleFonts.lato(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    )
                                  else
                                    ...balancedDhatus.map((r) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                                          child: Text(
                                            '• ${r.dhatu}',
                                            style: GoogleFonts.lato(
                                              fontSize: 11.5,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sarata Constitution Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dhatu Sarata Summary',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSaraRow('Dominant Sara (उत्कृष्ट):', dominantSara, AppColors.success),
                        const SizedBox(height: 8),
                        _buildSaraRow('Secondary Sara (मध्यम):', secondarySara, const Color(0xFF8BC34A)),
                        const SizedBox(height: 8),
                        _buildSaraRow('Weakest Sara (अवर):', weakestSara, AppColors.error),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Summary Table Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detailed Summary Table',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1.5),
                            2: FlexColumnWidth(1.5),
                            3: FlexColumnWidth(3),
                          },
                          border: TableBorder(
                            horizontalInside: BorderSide(color: Colors.grey.shade100, width: 1),
                          ),
                          children: [
                            // Table Header
                            TableRow(
                              children: [
                                _buildTableHeaderCell('Dhatu'),
                                _buildTableHeaderCell('Vriddhi'),
                                _buildTableHeaderCell('Kshaya'),
                                _buildTableHeaderCell('Status'),
                              ],
                            ),
                            // Table Rows
                            ...vkResults.map((r) {
                              final isDhatuAffected = r.vriddhiStatus != 'No Significant Change' ||
                                  r.kshayaStatus != 'No Significant Change';
                              return TableRow(
                                children: [
                                  _buildTableCellText(r.dhatu, isBold: true),
                                  _buildTableCellText('${r.vriddhiPercent}%'),
                                  _buildTableCellText('${r.kshayaPercent}%'),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (r.vriddhiStatus != 'No Significant Change')
                                          Text(
                                            'Vriddhi: ${r.vriddhiStatus}',
                                            style: GoogleFonts.lato(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: _getStatusColor(r.vriddhiStatus),
                                            ),
                                          ),
                                        if (r.kshayaStatus != 'No Significant Change')
                                          Text(
                                            'Kshaya: ${r.kshayaStatus}',
                                            style: GoogleFonts.lato(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: _getStatusColor(r.kshayaStatus),
                                            ),
                                          ),
                                        if (!isDhatuAffected)
                                          Text(
                                            'Sama (Balanced)',
                                            style: GoogleFonts.lato(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.success,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Recommendations Button
                  ElevatedButton(
                    onPressed: () {
                      final affectedDhatus = ScoreCalculator.getTopAffectedDhatus(vkResults);
                      Navigator.of(context).pushNamed(
                        AppRoutes.recommendations,
                        arguments: affectedDhatus,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'View Recommendations →',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSaraRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeaderCell(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTableCellText(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
      child: Text(
        text,
        style: GoogleFonts.lato(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
