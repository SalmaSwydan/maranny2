import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/reviews_payments_models.dart';
import '../../data/repositories/reviews_payments_repository.dart';
import '../utils/bookings_refresh_notifier.dart';

class RateSessionScreen extends StatefulWidget {
  final int bookingId;
  final int? sessionId;
  final int coachId;
  final String coachName;
  final String sportName;
  final bool isReviewed;
  final VoidCallback onSubmitted;

  const RateSessionScreen({
    super.key,
    required this.bookingId,
    this.sessionId,
    required this.coachId,
    required this.coachName,
    required this.sportName,
    required this.isReviewed,
    required this.onSubmitted,
  });

  @override
  State<RateSessionScreen> createState() => _RateSessionScreenState();
}

class _RateSessionScreenState extends State<RateSessionScreen> {
  static const List<String> _availableTags = <String>[
    'Great Communication',
    'Knowledgeable',
    'Very Professional',
    'Motivating',
    'Patient',
    'Friendly',
    'Well Prepared',
  ];

  final ReviewsRepository _reviewsRepository = ReviewsRepository();
  final TextEditingController _commentController = TextEditingController();

  int rating = 0;
  bool submitted = false;
  bool _isSubmitting = false;
  final Set<String> _selectedTags = <String>{};

  @override
  void initState() {
    super.initState();
    developer.log(
      'RateSessionScreen selected past session -> '
      'coachId=${widget.coachId} bookingId=${widget.bookingId} sessionId=${widget.sessionId} '
      'coachName=${widget.coachName} sportName=${widget.sportName} isReviewed=${widget.isReviewed}',
      name: 'RateSessionScreen',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_isSubmitting || submitted || widget.isReviewed) {
      return;
    }

    if (rating <= 0) {
      _showMessage('Please select a rating before submitting.');
      return;
    }

    final rawComment = _commentController.text.trim();
    final tags = _selectedTags.toList(growable: false);
    final commentParts = <String>[
      if (rawComment.isNotEmpty) rawComment,
      if (tags.isNotEmpty) 'Highlights: ${tags.join(', ')}',
    ];

    final request = CreateReviewRequest(
      coachId: widget.coachId,
      sessionId: widget.sessionId,
      rating: rating,
      comment: commentParts.join('\n\n'),
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _reviewsRepository.submitReview(request);
      developer.log(
        'RateSessionScreen submit success -> coachId=${widget.coachId} bookingId=${widget.bookingId}',
        name: 'RateSessionScreen',
      );

      if (!mounted) {
        return;
      }

      BookingsRefreshNotifier.notifyUpdated();
      widget.onSubmitted();
      setState(() {
        submitted = true;
      });
    } on DioException catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(_friendlyReviewError(error));
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('Could not submit your review right now. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _friendlyReviewError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    if (statusCode == 400 && data is Map<String, dynamic>) {
      return (data['message'] ??
              data['error'] ??
              'Please check your review and try again.')
          .toString();
    }
    if (statusCode == 401) {
      return 'Your session expired. Please sign in again and retry.';
    }
    if (statusCode == 404) {
      return 'This session review could not be found.';
    }
    if (statusCode == 409) {
      return 'This session has already been reviewed.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server error while submitting your review. Please try again.';
    }
    return 'Could not submit your review right now. Please try again.';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final avatarLetter = widget.coachName.trim().isNotEmpty
        ? widget.coachName.trim()[0].toUpperCase()
        : 'C';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xFFF3F7FF),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(22),
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFFEAF0FB),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.deepBlue,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                title: const Text(
                  'Rate session',
                  style: TextStyle(
                    color: AppColors.deepBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFFDDE6F6)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.deepBlue.withValues(alpha: 0.08),
                              blurRadius: 22,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundColor: AppColors.deepBlue,
                              child: Text(
                                avatarLetter,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'How was your session?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.deepBlue,
                                fontSize: 26,
                                height: 1.05,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${widget.sportName} with ${widget.coachName}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF6C7897),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                final active = rating > index;
                                return IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: _isSubmitting || widget.isReviewed
                                      ? null
                                      : () =>
                                            setState(() => rating = index + 1),
                                  icon: Icon(
                                    active
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    size: 38,
                                    color: active
                                        ? const Color(0xFFFFC44D)
                                        : const Color(0xFFB8C2D8),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _commentController,
                        enabled: !_isSubmitting && !widget.isReviewed,
                        maxLines: 5,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText:
                              'Share what went well, what improved, or what the coach can do better.',
                          hintStyle: const TextStyle(
                            color: Color(0xFF8A96B2),
                            fontWeight: FontWeight.w600,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDE6F6),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDE6F6),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: AppColors.deepBlue,
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 9,
                        runSpacing: 10,
                        children: _availableTags
                            .map(
                              (tag) => _Tag(
                                text: tag,
                                selected: _selectedTags.contains(tag),
                                onTap: _isSubmitting || widget.isReviewed
                                    ? null
                                    : () => _toggleTag(tag),
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: widget.isReviewed ? null : _submitReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deepBlue,
                            disabledBackgroundColor: const Color(0xFFCFD8EA),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 8,
                            shadowColor: AppColors.deepBlue.withValues(
                              alpha: 0.24,
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  widget.isReviewed
                                      ? 'Already reviewed'
                                      : 'Submit review',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (submitted)
            Container(
              color: Colors.black.withValues(alpha: 0.28),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 34,
                        backgroundColor: Color(0xFF5EDCF4),
                        child: Icon(
                          Icons.check_rounded,
                          color: AppColors.deepBlue,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Review Submitted!',
                        style: TextStyle(
                          color: AppColors.deepBlue,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Thanks for helping other athletes choose with confidence.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF6C7897),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Back to bookings',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  const _Tag({required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.deepBlue : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.deepBlue : const Color(0xFFDDE6F6),
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: AppColors.deepBlue.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.deepBlue,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
