import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String sports;
  final String bio;
  final String? imageUrl;
  final VoidCallback? onImageTap;
  final bool isUploadingImage;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.sports,
    this.bio = '',
    this.imageUrl,
    this.onImageTap,
    this.isUploadingImage = false,
  });

  bool get _isNetworkImage {
    final image = imageUrl ?? '';
    return image.startsWith('http://') || image.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF3F7FF),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.of(context).padding.top + 18,
        18,
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR PROFILE',
            style: TextStyle(
              color: Color(0xFF9AA9C6),
              fontSize: 11,
              letterSpacing: 2.3,
              fontWeight: FontWeight.w900,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: isUploadingImage ? null : onImageTap,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.deepBlue.withValues(alpha: 0.13),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepBlue.withValues(alpha: 0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(23),
                        child: imageUrl != null && imageUrl!.isNotEmpty
                            ? _isNetworkImage
                                  ? Image.network(
                                      imageUrl!,
                                      width: 88,
                                      height: 88,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _avatarBox(),
                                    )
                                  : Image.asset(
                                      imageUrl!,
                                      width: 88,
                                      height: 88,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _avatarBox(),
                                    )
                            : _avatarBox(),
                      ),
                    ),
                    Positioned(
                      right: -3,
                      bottom: -3,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isUploadingImage
                              ? Colors.white
                              : AppColors.lightBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: isUploadingImage
                            ? const Padding(
                                padding: EdgeInsets.all(7),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryBlue,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt_rounded,
                                color: AppColors.deepBlue,
                                size: 15,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.deepBlue,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _HeaderLine(
                      icon: Icons.sports_soccer_outlined,
                      text: sports,
                    ),
                    const SizedBox(height: 7),
                    _HeaderLine(
                      icon: Icons.notes_outlined,
                      text: bio.trim().isNotEmpty ? bio.trim() : 'No bio yet',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarBox() {
    return Container(
      width: 88,
      height: 88,
      color: const Color(0xFFE8ECF7),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: AppColors.deepBlue,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}

class _HeaderLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.deepBlue.withValues(alpha: 0.65), size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6C7897),
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }
}
