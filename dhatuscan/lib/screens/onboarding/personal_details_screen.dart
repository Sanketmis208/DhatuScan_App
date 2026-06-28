import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl       = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _dobCtrl        = TextEditingController();
  final _ageCtrl        = TextEditingController();
  final _addressCtrl    = TextEditingController();
  final _heightCtrl     = TextEditingController();
  final _weightCtrl     = TextEditingController();
  final _bmiCtrl        = TextEditingController();
  final _bpCtrl         = TextEditingController();
  final _pulseCtrl      = TextEditingController();
  final _medHistCtrl    = TextEditingController();
  final _occupCtrl      = TextEditingController();
  final _menstrualCtrl  = TextEditingController();

  // Dropdown values
  String? _gender;
  String? _physicalActivity;
  String? _sleepDuration;
  String? _appetitePattern;
  String? _waterIntake;

  DateTime? _selectedDob;
  bool _submitted = false;

  // ── Options ─────────────────────────────────────────────────────────────────
  static const _genderOptions = ['Male', 'Female', 'Other'];
  static const _physicalActivityOptions = [
    'Sedentary', 'Light', 'Moderate', 'Active', 'Very Active',
  ];
  static const _sleepOptions = [
    'Less than 5 hrs', '5–6 hrs', '6–7 hrs', '7–8 hrs', 'More than 8 hrs',
  ];
  static const _appetiteOptions = ['Poor', 'Moderate', 'Good', 'Excessive'];
  static const _waterOptions = [
    'Less than 1 L', '1–2 L', '2–3 L', 'More than 3 L',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>().user;
      if (user != null) {
        if (user.phone != null && user.phone!.isNotEmpty) {
          _phoneCtrl.text = user.phone!;
        }
        if (user.name != null && user.name!.isNotEmpty) {
          _nameCtrl.text = user.name!;
        }
        if (user.dateOfBirth != null) {
          _selectedDob = user.dateOfBirth;
          _dobCtrl.text = DateFormat('dd/MM/yyyy').format(user.dateOfBirth!);
        }
        if (user.age != null) {
          _ageCtrl.text = user.age.toString();
        }
        if (user.gender != null) {
          setState(() {
            _gender = user.gender;
          });
        }
        if (user.address != null) {
          _addressCtrl.text = user.address!;
        }
        if (user.height != null) {
          _heightCtrl.text = user.height.toString();
        }
        if (user.weight != null) {
          _weightCtrl.text = user.weight.toString();
        }
        if (user.bmi != null) {
          _bmiCtrl.text = user.bmi!.toStringAsFixed(1);
        }
        if (user.bp != null) {
          _bpCtrl.text = user.bp!;
        }
        if (user.pulseRate != null) {
          _pulseCtrl.text = user.pulseRate.toString();
        }
        if (user.medicalHistory != null) {
          _medHistCtrl.text = user.medicalHistory!;
        }
        if (user.occupation != null) {
          _occupCtrl.text = user.occupation!;
        }
        if (user.physicalActivity != null) {
          setState(() {
            _physicalActivity = user.physicalActivity;
          });
        }
        if (user.sleepDuration != null) {
          setState(() {
            _sleepDuration = user.sleepDuration;
          });
        }
        if (user.appetitePattern != null) {
          setState(() {
            _appetitePattern = user.appetitePattern;
          });
        }
        if (user.waterIntake != null) {
          setState(() {
            _waterIntake = user.waterIntake;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _ageCtrl.dispose();
    _addressCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _bmiCtrl.dispose();
    _bpCtrl.dispose();
    _pulseCtrl.dispose();
    _medHistCtrl.dispose();
    _occupCtrl.dispose();
    _menstrualCtrl.dispose();
    super.dispose();
  }

  // ── DOB picker ──────────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
        int age = now.year - picked.year;
        if (now.month < picked.month ||
            (now.month == picked.month && now.day < picked.day)) {
          age--;
        }
        _ageCtrl.text = age.toString();
      });
    }
  }

  // ── BMI auto-compute ────────────────────────────────────────────────────────
  void _computeBmi() {
    final h = double.tryParse(_heightCtrl.text);
    final w = double.tryParse(_weightCtrl.text);
    final bmi = UserModel.calculateBmi(h, w);
    setState(() {
      _bmiCtrl.text = bmi != null ? bmi.toStringAsFixed(1) : '';
    });
  }

  // ── Submit ──────────────────────────────────────────────────────────────────
  Future<void> _onSubmit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    final userProvider = context.read<UserProvider>();

    final model = UserModel(
      phone: _phoneCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      dateOfBirth: _selectedDob,
      age: int.tryParse(_ageCtrl.text),
      gender: _gender,
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      height: double.tryParse(_heightCtrl.text),
      weight: double.tryParse(_weightCtrl.text),
      bmi: double.tryParse(_bmiCtrl.text),
      bp: _bpCtrl.text.trim().isEmpty ? null : _bpCtrl.text.trim(),
      pulseRate: int.tryParse(_pulseCtrl.text),
      medicalHistory: _medHistCtrl.text.trim().isEmpty ? null : _medHistCtrl.text.trim(),
      occupation: _occupCtrl.text.trim().isEmpty ? null : _occupCtrl.text.trim(),
      physicalActivity: _physicalActivity,
      sleepDuration: _sleepDuration,
      appetitePattern: _appetitePattern,
      waterIntake: _waterIntake,
      isProfileComplete: true,
    );

    final success = await userProvider.saveProfile(model);
    if (!mounted) return;

    if (success) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final isEdit = args != null && args['isEdit'] == true;
      if (isEdit) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.dashboard,
          (route) => false,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: userProvider.errorMessage ?? AppStrings.errorGeneric,
        backgroundColor: AppColors.error,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isEdit = args != null && args['isEdit'] == true;

    return PopScope(
      canPop: isEdit,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Column(
          children: [
            // ── Custom Header ──────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(20, topPadding + 8, 20, 24),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isEdit)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          isEdit ? 'Edit Profile' : AppStrings.personalDetailsTitle,
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEdit
                        ? 'Update your details below. Email and phone number are locked.'
                        : 'Tell us about yourself so we can personalise your Dhatu assessment.',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // ── Form Content ─────────────────────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _submitted
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Basic Info ────────────────────────────────────
                        _SectionCard(
                          icon: Icons.person_outline_rounded,
                          title: 'Basic Information',
                          children: [
                            _buildNameField(),
                            const SizedBox(height: 14),
                            _buildPhoneField(),
                            const SizedBox(height: 14),
                            _buildDobField(),
                            const SizedBox(height: 14),
                            _buildAgeField(),
                            const SizedBox(height: 14),
                            _buildGenderDropdown(),
                            const SizedBox(height: 14),
                            _buildAddressField(),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ── Physical Measurements ─────────────────────────
                        _SectionCard(
                          icon: Icons.straighten_rounded,
                          title: 'Physical Measurements',
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildHeightField()),
                                const SizedBox(width: 12),
                                Expanded(child: _buildWeightField()),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _buildBmiField(),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(child: _buildBpField()),
                                const SizedBox(width: 12),
                                Expanded(child: _buildPulseField()),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ── Medical & Lifestyle ───────────────────────────
                        _SectionCard(
                          icon: Icons.favorite_outline_rounded,
                          title: 'Medical & Lifestyle',
                          children: [
                            _buildMedHistField(),
                            const SizedBox(height: 14),
                            _buildOccupField(),
                            const SizedBox(height: 14),
                            _buildDropdown(
                              label: AppStrings.physicalActivityLabel,
                              value: _physicalActivity,
                              items: _physicalActivityOptions,
                              onChanged: (v) =>
                                  setState(() => _physicalActivity = v),
                            ),
                            const SizedBox(height: 14),
                            _buildDropdown(
                              label: AppStrings.sleepDurationLabel,
                              value: _sleepDuration,
                              items: _sleepOptions,
                              onChanged: (v) =>
                                  setState(() => _sleepDuration = v),
                            ),
                            const SizedBox(height: 14),
                            _buildDropdown(
                              label: AppStrings.appetiteLabel,
                              value: _appetitePattern,
                              items: _appetiteOptions,
                              onChanged: (v) =>
                                  setState(() => _appetitePattern = v),
                            ),
                            const SizedBox(height: 14),
                            _buildDropdown(
                              label: AppStrings.waterIntakeLabel,
                              value: _waterIntake,
                              items: _waterOptions,
                              onChanged: (v) =>
                                  setState(() => _waterIntake = v),
                            ),
                            // Gender-conditional menstrual field
                            if (_gender == 'Female') ...[
                              const SizedBox(height: 14),
                              _buildMenstrualField(),
                            ],
                          ],
                        ),

                        const SizedBox(height: 28),

                        // ── Submit button ─────────────────────────────────
                        Consumer<UserProvider>(
                          builder: (_, up, __) {
                            return GestureDetector(
                              onTap: up.isLoading ? null : _onSubmit,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                decoration: BoxDecoration(
                                  gradient: up.isLoading
                                      ? LinearGradient(colors: [
                                          Colors.grey.shade400,
                                          Colors.grey.shade400
                                        ])
                                      : const LinearGradient(
                                          colors: [
                                            Color(0xFF1A5C5A),
                                            Color(0xFF2A7D7A)
                                          ],
                                        ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: up.isLoading
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withOpacity(0.4),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                ),
                                child: up.isLoading
                                    ? const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        isEdit ? 'Save Changes' : AppStrings.saveAndContinue,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Field builders ──────────────────────────────────────────────────────────

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameCtrl,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Full Name *',
        prefixIcon: Icon(Icons.badge_outlined),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? AppStrings.errorRequired : null,
    );
  }

  Widget _buildPhoneField() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isEdit = args != null && args['isEdit'] == true;

    return TextFormField(
      controller: _phoneCtrl,
      keyboardType: TextInputType.phone,
      readOnly: isEdit,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        labelText: 'Phone Number *',
        prefixIcon: const Icon(Icons.phone_outlined),
        hintText: 'Enter 10-digit number',
        suffixIcon: isEdit
            ? const Icon(Icons.lock_outline_rounded, color: Colors.grey, size: 18)
            : null,
        filled: isEdit,
        fillColor: isEdit ? Colors.grey.shade100 : null,
      ),
      validator: (v) {
        if (isEdit) return null;
        if (v == null || v.trim().isEmpty) {
          return AppStrings.errorRequired;
        }
        final cleaned = v.trim();
        if (cleaned.length != 10) {
          return 'Enter a valid 10-digit phone number';
        }
        return null;
      },
    );
  }

  Widget _buildDobField() {
    return TextFormField(
      controller: _dobCtrl,
      readOnly: true,
      onTap: _pickDate,
      decoration: const InputDecoration(
        labelText: 'Date of Birth *',
        prefixIcon: Icon(Icons.calendar_today_outlined),
        suffixIcon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
      ),
      validator: (v) =>
          (v == null || v.isEmpty) ? AppStrings.errorRequired : null,
    );
  }

  Widget _buildAgeField() {
    return TextFormField(
      controller: _ageCtrl,
      readOnly: true,
      decoration: InputDecoration(
        labelText: AppStrings.ageLabel,
        prefixIcon: const Icon(Icons.cake_outlined),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: const InputDecoration(
        labelText: 'Gender *',
        prefixIcon: Icon(Icons.wc_outlined),
      ),
      items: _genderOptions
          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
          .toList(),
      onChanged: (v) => setState(() => _gender = v),
      validator: (v) => v == null ? AppStrings.errorRequired : null,
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressCtrl,
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: 'Address',
        prefixIcon: Icon(Icons.location_on_outlined),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildHeightField() {
    return TextFormField(
      controller: _heightCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      decoration: const InputDecoration(
        labelText: 'Height *',
        suffixText: 'cm',
      ),
      onChanged: (_) => _computeBmi(),
      validator: (v) {
        if (v == null || v.isEmpty) return AppStrings.errorRequired;
        final d = double.tryParse(v);
        if (d == null || d <= 0) return 'Invalid';
        return null;
      },
    );
  }

  Widget _buildWeightField() {
    return TextFormField(
      controller: _weightCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      decoration: const InputDecoration(
        labelText: 'Weight *',
        suffixText: 'kg',
      ),
      onChanged: (_) => _computeBmi(),
      validator: (v) {
        if (v == null || v.isEmpty) return AppStrings.errorRequired;
        final d = double.tryParse(v);
        if (d == null || d <= 0) return 'Invalid';
        return null;
      },
    );
  }

  Widget _buildBmiField() {
    final bmi = double.tryParse(_bmiCtrl.text);
    final category = bmi != null ? UserModel.getBmiCategory(bmi) : null;

    return TextFormField(
      controller: _bmiCtrl,
      readOnly: true,
      decoration: InputDecoration(
        labelText: '${AppStrings.bmiLabel} (auto-computed)',
        prefixIcon: const Icon(Icons.monitor_weight_outlined),
        suffixText: category,
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildBpField() {
    return TextFormField(
      controller: _bpCtrl,
      decoration: const InputDecoration(
        labelText: 'Blood Pressure',
        hintText: '120/80',
      ),
    );
  }

  Widget _buildPulseField() {
    return TextFormField(
      controller: _pulseCtrl,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        labelText: 'Pulse',
        suffixText: 'bpm',
      ),
    );
  }

  Widget _buildMedHistField() {
    return TextFormField(
      controller: _medHistCtrl,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Medical History',
        hintText: 'Chronic conditions, surgeries, allergies…',
        prefixIcon: Icon(Icons.medical_information_outlined),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildOccupField() {
    return TextFormField(
      controller: _occupCtrl,
      decoration: const InputDecoration(
        labelText: 'Occupation',
        prefixIcon: Icon(Icons.work_outline_rounded),
      ),
    );
  }

  Widget _buildMenstrualField() {
    return TextFormField(
      controller: _menstrualCtrl,
      decoration: const InputDecoration(
        labelText: 'Menstrual Regularity',
        hintText: 'Regular / Irregular / Post-menopausal',
        prefixIcon: Icon(Icons.calendar_month_outlined),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool required = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      isExpanded: true,
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
          .toList(),
      onChanged: onChanged,
      validator: required
          ? (v) => v == null ? AppStrings.errorRequired : null
          : null,
    );
  }
}

// ── Section Card ────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}
