import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';

class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final double? calculatedBmi = user != null ? UserModel.calculateBmi(user.height, user.weight) : null;
    final String bmiString = calculatedBmi != null ? calculatedBmi.toStringAsFixed(1) : 'N/A';
    final String bmiCategory = calculatedBmi != null ? ' (${UserModel.getBmiCategory(calculatedBmi)})' : '';

    final screenWidth = MediaQuery.of(context).size.width;
    final double childAspectRatio = screenWidth < 360 ? 1.4 : 1.8;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.personalDetails,
                arguments: {'isEdit': true},
              );
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.accent.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppColors.accent,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name ?? 'Guest User',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.occupation ?? 'Ayurvedic Enthusiast',
                                style: GoogleFonts.lato(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 1: Vitals
                  _buildSectionHeader('Body Parameters & Vitals', Icons.favorite_outline_rounded),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: childAspectRatio,
                    children: [
                      _buildVitalCard('Height', '${user.height ?? "N/A"} cm', Icons.height_rounded, Colors.blue),
                      _buildVitalCard('Weight', '${user.weight ?? "N/A"} kg', Icons.monitor_weight_outlined, Colors.orange),
                      _buildVitalCard('BMI', '$bmiString$bmiCategory', Icons.analytics_outlined, Colors.purple),
                      _buildVitalCard('Blood Pressure', user.bp ?? 'N/A', Icons.speed_rounded, Colors.red),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Section 2: Lifestyle
                  _buildSectionHeader('Ayurvedic Lifestyle & Habits', Icons.spa_outlined),
                  const SizedBox(height: 12),
                  _buildProfileField('Appetite Pattern', user.appetitePattern ?? 'N/A', Icons.restaurant_menu_rounded),
                  _buildProfileField('Water Intake', user.waterIntake ?? 'N/A', Icons.local_drink_rounded),
                  _buildProfileField('Sleep Duration', user.sleepDuration ?? 'N/A', Icons.dark_mode_rounded),
                  _buildProfileField('Physical Activity', user.physicalActivity ?? 'N/A', Icons.directions_run_rounded),

                  const SizedBox(height: 28),

                  // Section 3: General
                  _buildSectionHeader('General Info', Icons.info_outline_rounded),
                  const SizedBox(height: 12),
                  _buildProfileField('Age', user.age != null ? '${user.age} years' : 'N/A', Icons.cake_rounded),
                  _buildProfileField('Gender', user.gender ?? 'N/A', Icons.wc_rounded),
                  _buildProfileField('Address', user.address ?? 'N/A', Icons.home_rounded),
                  _buildProfileField('Email Address', user.email ?? 'N/A', Icons.email_rounded),
                  _buildProfileField('Phone Number', user.phone ?? 'N/A', Icons.phone_rounded),
                  _buildProfileField('Medical History', user.medicalHistory ?? 'No active medical history', Icons.history_edu_rounded),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildVitalCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.12), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: GoogleFonts.lato(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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
