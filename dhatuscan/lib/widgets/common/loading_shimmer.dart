import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';

/// A generic shimmer placeholder that can be sized as needed.
class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Pre-built shimmer layout for the Dashboard while data is loading.
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner placeholder
            _shimmerBox(height: 100, borderRadius: 20),
            const SizedBox(height: 20),

            // Health score card placeholder
            _shimmerBox(height: 160, borderRadius: 20),
            const SizedBox(height: 24),

            // Section title
            _shimmerBox(height: 20, width: 140),
            const SizedBox(height: 12),

            // Quick actions row
            Row(
              children: [
                Expanded(child: _shimmerBox(height: 90, borderRadius: 16)),
                const SizedBox(width: 12),
                Expanded(child: _shimmerBox(height: 90, borderRadius: 16)),
                const SizedBox(width: 12),
                Expanded(child: _shimmerBox(height: 90, borderRadius: 16)),
              ],
            ),
            const SizedBox(height: 28),

            // Section title
            _shimmerBox(height: 20, width: 180),
            const SizedBox(height: 12),

            // Assessment list items
            _shimmerBox(height: 76, borderRadius: 14),
            const SizedBox(height: 10),
            _shimmerBox(height: 76, borderRadius: 14),
            const SizedBox(height: 10),
            _shimmerBox(height: 76, borderRadius: 14),
          ],
        ),
      ),
    );
  }

  static Widget _shimmerBox({
    double height = 16,
    double? width,
    double borderRadius = 8,
  }) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
