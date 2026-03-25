import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../layout/coach_layout.dart';

// Custom painter for dashed border
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
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final dashPath = _createDashPath(path, dashLength, dashSpace);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashPath(Path path, double dashLength, double dashSpace) {
    final dashPath = Path();
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      double distance = 0;
      while (distance < pathMetric.length) {
        final length = (distance + dashLength < pathMetric.length)
            ? dashLength
            : pathMetric.length - distance;
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += dashLength + dashSpace;
      }
    }
    return dashPath;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for upload icon (exact match from image - thinner arrow, inverted base/tray)
class UploadIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Create gradient for the icon
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF304CE9), // brighter blue - top
        const Color(0xFF1B2B83), // darker blue - bottom
      ],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    // Draw the base/tray shape (horizontal line with vertical lines extending UP - inverted)
    final baseY = size.height * 0.72;
    final baseWidth = size.width * 0.65;
    final baseHeight = size.height * 0.18;

    // Horizontal bottom line of the base (thicker) - this is the bottom of the inverted tray
    final basePaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(centerX - baseWidth / 2, baseY),
      Offset(centerX + baseWidth / 2, baseY),
      basePaint,
    );

    // Left vertical line extending UP (inverted)
    canvas.drawLine(
      Offset(centerX - baseWidth / 2, baseY),
      Offset(centerX - baseWidth / 2, baseY - baseHeight),
      basePaint,
    );

    // Right vertical line extending UP (inverted)
    canvas.drawLine(
      Offset(centerX + baseWidth / 2, baseY),
      Offset(centerX + baseWidth / 2, baseY - baseHeight),
      basePaint,
    );

    // Draw upward arrow (thinner shaft, proper arrowhead) - keep as is
    final arrowTopY = size.height * 0.12;
    final arrowBottomY = baseY - baseHeight - 3; // Arrow starts above the inverted tray
    final arrowWidth = size.width * 0.28;

    // Arrow shaft (vertical line - thinner)
    final arrowShaftPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(centerX, arrowBottomY),
      Offset(centerX, arrowTopY + arrowWidth * 0.35),
      arrowShaftPaint,
    );

    // Arrow head (triangle pointing up - thinner)
    final arrowPath = Path()
      ..moveTo(centerX, arrowTopY) // Top point
      ..lineTo(centerX - arrowWidth / 2.2, arrowTopY + arrowWidth * 0.35) // Bottom left
      ..lineTo(centerX + arrowWidth / 2.2, arrowTopY + arrowWidth * 0.35) // Bottom right
      ..close();

    canvas.drawPath(arrowPath, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CoachCertificationsScreen extends StatefulWidget {
  const CoachCertificationsScreen({super.key});

  @override
  State<CoachCertificationsScreen> createState() => _CoachCertificationsScreenState();
}

class _CoachCertificationsScreenState extends State<CoachCertificationsScreen> {
  List<File> _selectedFiles = [];

  void _handleChooseFile() async {
    // TODO: Implement file picker using file_picker package
    // For now, this is a placeholder that shows a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File picker will be implemented with file_picker package'),
      ),
    );

    // Example: You would use file_picker like this:
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['pdf'],
    // );
    // if (result != null && result.files.single.path != null) {
    //   setState(() {
    //     _selectedFiles.add(File(result.files.single.path!));
    //   });
    // }
  }

  void _handleContinue() {
    // TODO: Upload files to backend if any selected
    debugPrint('Selected Files: ${_selectedFiles.length}');

    // ✅ FIXED: Navigate to Coach Home Screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => CoachMainLayout(),
      ),
          (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient
            _buildHeader(),

            // Progress Indicator (Step 4 of 4 - all segments blue)
            _buildProgressIndicator(currentStep: 4),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title
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

                    // Subtitle
                    Text(
                      'Upload certificates to boost your credibility.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Upload Area - Centered and Bigger
                    _buildUploadArea(),

                    const SizedBox(height: 32),

                    // Note Section
                    _buildNoteSection(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Continue Button
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
          colors: [
            Color(0xFF1F3A93), // deep blue (darker) - left side
            Color(0xFF6FD3F5), // light blue (brighter) - right side
          ],
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
            const SizedBox(width: 48), // Balance the back button
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
              height: 6, // Thick progress indicator
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryBlue : const Color(0xFFE0E0E0),
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Dashed border using CustomPaint
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
            // Content - Centered from all directions with good spacing
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Upload Icon - Custom to match image exactly
                    CustomPaint(
                      size: const Size(100, 100),
                      painter: UploadIconPainter(),
                    ),
                    const SizedBox(height: 40),

                    // Upload Text
                    const Text(
                      'Upload certifications',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // File Type Info
                    Text(
                      'PDF Files up to 10MB',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Choose File Button
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
              colors: [
                Color(0xFF1B2B83), // darker blue - left (from Figma)
                Color(0xFF304CE9), // brighter blue - right (from Figma)
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: const Text(
            'Choose File',
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
        color: const Color(0xFFE3F2FD), // Light blue background
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
            color: Colors.black.withOpacity(0.05),
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
            onTap: _handleContinue,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF1B2B83), // darker blue - left (from Figma)
                    Color(0xFF304CE9), // brighter blue - right (from Figma)
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Center(
                child: Text(
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