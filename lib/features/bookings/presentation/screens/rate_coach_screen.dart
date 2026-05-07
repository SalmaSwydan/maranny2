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

    final request = CreateReviewRequest(
      coachId: widget.coachId,
      sessionId: widget.sessionId,
      rating: rating,
      comment: _commentController.text.trim(),
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
      return (data['message'] ?? data['error'] ?? 'Please check your review and try again.').toString();
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
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Back'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primaryBlue,
                  child: Text(
                    avatarLetter,
                    style: const TextStyle(color: Colors.white, fontSize: 28),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Rate Your Session',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'How was your experience with ${widget.coachName}?',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: _isSubmitting || widget.isReviewed
                          ? null
                          : () => setState(() => rating = index + 1),
                      icon: Icon(
                        Icons.star,
                        size: 32,
                        color: rating > index ? Colors.orange : Colors.grey,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _commentController,
                  enabled: !_isSubmitting && !widget.isReviewed,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'Share your experience with this coach.\nWhat did you like? What could be improved?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: widget.isReviewed ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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
                        : const Text('Submit Review'),
                  ),
                ),
              ],
            ),
          ),
          if (submitted)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 40),
                      const SizedBox(height: 12),
                      const Text(
                        'Review Submitted!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Thank you for your feedback',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Back Home',
                          style: TextStyle(color: Colors.green),
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

  const _Tag({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(text),
        backgroundColor: selected ? AppColors.lightBlue : Colors.grey.shade200,
      ),
    );
  }
}
