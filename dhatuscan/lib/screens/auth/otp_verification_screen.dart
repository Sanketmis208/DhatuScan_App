import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _timer;
  int _secondsRemaining = 60;
  String? _inlineError;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Countdown ──────────────────────────────────────────────────────────────

  void _startCountdown() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  // ── Resend OTP ─────────────────────────────────────────────────────────────

  Future<void> _handleResend() async {
    if (_secondsRemaining > 0) return;

    final auth = context.read<AuthProvider>();
    _otpController.clear();
    setState(() => _inlineError = null);

    await auth.resendOtp();

    if (!mounted) return;

    if (auth.state == AuthState.error) {
      Fluttertoast.showToast(
        msg: auth.errorMessage ?? AppStrings.errorGeneric,
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    } else {
      _startCountdown();
      Fluttertoast.showToast(
        msg: 'OTP resent successfully',
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );
    }
  }

  // ── Verify OTP ─────────────────────────────────────────────────────────────

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      setState(() => _inlineError = 'Please enter the complete 6-digit OTP');
      return;
    }

    setState(() {
      _inlineError = null;
      _isVerifying = true;
    });

    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOtp(otp);

    if (!mounted) return;

    setState(() => _isVerifying = false);

    if (success) {
      _timer?.cancel();
      if (auth.isNewUser) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/profile/new',
          (route) => false,
        );
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/dashboard',
          (route) => false,
        );
      }
    } else {
      // Differentiate incorrect OTP vs expired OTP
      final errorMsg = auth.errorMessage ?? '';
      final isExpired = errorMsg.toLowerCase().contains('expired') ||
          errorMsg.toLowerCase().contains('session');

      if (isExpired) {
        Fluttertoast.showToast(
          msg: 'OTP has expired. Please tap "Resend OTP" to get a new code.',
          backgroundColor: AppColors.warning,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      } else {
        setState(() => _inlineError = errorMsg.isNotEmpty
            ? errorMsg
            : 'Invalid OTP. Please check and try again.');
      }

      auth.clearError();
    }
  }

  // ── Pinput Theme ───────────────────────────────────────────────────────────

  PinTheme _buildPinTheme({
    Color? borderColor,
    Color? fillColor,
    Color? textColor,
  }) {
    return PinTheme(
      width: 48,
      height: 56,
      textStyle: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor ?? AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: fillColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final phoneNumber = auth.phoneNumber ?? '';
    final maskedPhone = phoneNumber.length >= 10
        ? '+91 XXXXXX${phoneNumber.substring(phoneNumber.length - 4)}'
        : '+91 $phoneNumber';

    final bool canResend = _secondsRemaining == 0;
    final bool isLoading =
        _isVerifying || auth.state == AuthState.verifying || auth.state == AuthState.sendingOtp;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Header ───────────────────────────────────────────────────
              Text(
                AppStrings.otpVerificationTitle,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${AppStrings.otpVerificationSubtitle}\n$maskedPhone',
                style: GoogleFonts.lato(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // ── Pinput OTP Field ─────────────────────────────────────────
              Center(
                child: Pinput(
                  controller: _otpController,
                  focusNode: _focusNode,
                  length: 6,
                  autofocus: true,
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  defaultPinTheme: _buildPinTheme(),
                  focusedPinTheme: _buildPinTheme(
                    borderColor: AppColors.primary,
                    fillColor: const Color(0xFFEAF3F3),
                  ),
                  submittedPinTheme: _buildPinTheme(
                    borderColor: AppColors.primary,
                    fillColor: Colors.white,
                  ),
                  errorPinTheme: _buildPinTheme(
                    borderColor: AppColors.error,
                    fillColor: const Color(0xFFFFF5F5),
                    textColor: AppColors.error,
                  ),
                  forceErrorState: _inlineError != null,
                  errorText: _inlineError,
                  errorTextStyle: GoogleFonts.lato(
                    fontSize: 13,
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                  onCompleted: (_) => _handleVerify(),
                  onChanged: (value) {
                    if (_inlineError != null) {
                      setState(() => _inlineError = null);
                    }
                  },
                ),
              ),

              const SizedBox(height: 32),

              // ── Countdown + Resend ────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    if (!canResend)
                      Text(
                        'Resend OTP in $_secondsRemaining s',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: canResend && !isLoading ? _handleResend : null,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        disabledForegroundColor: AppColors.textLight,
                      ),
                      child: Text(
                        AppStrings.resendOtp,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Verify Button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.accent.withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          AppStrings.verifyOtp,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
