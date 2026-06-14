import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/models/auth_models.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../data/models/coach_onboarding_draft.dart';

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashSpace;
  final double radius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashSpace,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashLength)
            .clamp(0.0, metric.length)
            .toDouble();
        dashPath.addPath(metric.extractPath(distance, end), Offset.zero);
        distance += dashLength + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class UploadIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF304CE9), Color(0xFF1B2B83)],
    ).createShader(rect);

    final strokePaint = Paint()
      ..shader = shader
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()..shader = shader;

    final baseY = size.height * 0.72;
    final baseWidth = size.width * 0.65;
    final baseHeight = size.height * 0.18;

    canvas.drawLine(
      Offset(centerX - baseWidth / 2, baseY),
      Offset(centerX + baseWidth / 2, baseY),
      strokePaint,
    );
    canvas.drawLine(
      Offset(centerX - baseWidth / 2, baseY),
      Offset(centerX - baseWidth / 2, baseY - baseHeight),
      strokePaint,
    );
    canvas.drawLine(
      Offset(centerX + baseWidth / 2, baseY),
      Offset(centerX + baseWidth / 2, baseY - baseHeight),
      strokePaint,
    );

    final arrowTopY = size.height * 0.12;
    final arrowBottomY = baseY - baseHeight - 3;
    final arrowWidth = size.width * 0.28;

    canvas.drawLine(
      Offset(centerX, arrowBottomY),
      Offset(centerX, arrowTopY + arrowWidth * 0.35),
      Paint()
        ..shader = shader
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.round,
    );

    final arrowPath = Path()
      ..moveTo(centerX, arrowTopY)
      ..lineTo(centerX - arrowWidth / 2.2, arrowTopY + arrowWidth * 0.35)
      ..lineTo(centerX + arrowWidth / 2.2, arrowTopY + arrowWidth * 0.35)
      ..close();

    canvas.drawPath(arrowPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CoachCertificationsScreen extends StatefulWidget {
  final CoachOnboardingDraft draft;

  const CoachCertificationsScreen({required this.draft, super.key});

  @override
  State<CoachCertificationsScreen> createState() =>
      _CoachCertificationsScreenState();
}

class _CoachCertificationsScreenState extends State<CoachCertificationsScreen> {
  final AuthRepository _authRepository = AuthRepository();
  List<File> _selectedFiles = <File>[];
  bool _isSubmitting = false;

  Future<void> _handleChooseFile() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    final path = image?.path;
    if (path == null || path.trim().isEmpty) return;

    setState(() {
      _selectedFiles = [File(path)];
    });
  }

  Future<void> _handleContinue() async {
    if (_isSubmitting) return;

    if (widget.draft.unsupportedSports.isNotEmpty) {
      _showErrorDialog(
        'These sports are not supported by the backend yet: '
        '${widget.draft.unsupportedSports.join(', ')}.\n'
        'Please choose supported sports only.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final updatedDraft = widget.draft.copyWith(
        certificateUrl: _selectedFiles.isNotEmpty
            ? _selectedFiles.first.path
            : null,
      );
      final request = updatedDraft.toRequest();

      developer.log(
        'Coach onboarding selected dayToHours=${jsonEncode(updatedDraft.selectedDayToHours)}',
        name: 'CoachCertificationsScreen',
      );
      developer.log(
        'Coach onboarding request body=${jsonEncode(request.toJson())}',
        name: 'CoachCertificationsScreen',
      );

      final response = await _authRepository.completeCoachOnboarding(request);

      if (!mounted) return;

      await AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Success',
        desc: response.message,
        btnOkOnPress: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(userType: 'coach'),
            ),
            (route) => false,
          );
        },
      ).show();
    } on ApiError catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.fullMessage);
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(
        'Could not complete coach onboarding. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'Error',
      desc: message,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressIndicator(currentStep: 4),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Certifications (Optional)',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload certificates to boost your credibility.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildUploadArea(),
                    if (_selectedFiles.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        _selectedFiles.first.path
                            .split(Platform.pathSeparator)
                            .last,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    _buildNoteSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F3A93), Color(0xFF6FD3F5)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const Expanded(
              child: Text(
                'Become a coach',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator({required int currentStep}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index < currentStep;
          return Expanded(
            child: Container(
              height: 6,
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryBlue
                    : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUploadArea() {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 70),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: DashedBorderPainter(
                  color: AppColors.primaryBlue,
                  strokeWidth: 3,
                  dashLength: 12,
                  dashSpace: 6,
                  radius: 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedFiles.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(
                          _selectedFiles.first,
                          width: 150,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      CustomPaint(
                        size: const Size(100, 100),
                        painter: UploadIconPainter(),
                      ),
                    const SizedBox(height: 40),
                    const Text(
                      'Upload certificate image',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Choose a clear photo of your certificate',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 50),
                    _buildChooseFileButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChooseFileButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleChooseFile,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF1B2B83), Color(0xFF304CE9)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'Choose Image',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Note: ',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          Expanded(
            child: Text(
              'Your profile will be reviewed by our team before going live. This usually takes 24-48 hours.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isSubmitting ? null : _handleContinue,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF1B2B83), Color(0xFF304CE9)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Continue',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
