import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RateSessionScreen extends StatefulWidget {
  final VoidCallback onSubmitted;

  const RateSessionScreen({super.key, required this.onSubmitted});

  @override
  State<RateSessionScreen> createState() => _RateSessionScreenState();
}

class _RateSessionScreenState extends State<RateSessionScreen> {
  int rating = 0;
  bool submitted = false;

  @override
  Widget build(BuildContext context) {
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
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primaryBlue,
                  child: Text('N',
                      style:
                      TextStyle(color: Colors.white, fontSize: 28)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Rate Your Session',
                  style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'How was your experience with Nancy Ali?',
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                /// Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () =>
                          setState(() => rating = index + 1),
                      icon: Icon(
                        Icons.star,
                        size: 32,
                        color: rating > index
                            ? Colors.orange
                            : Colors.grey,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                /// Review Box
                TextField(
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

                /// Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _Tag('Great Communication'),
                    _Tag('Knowledgeable'),
                    _Tag('Very Professional'),
                    _Tag('Motivating'),
                    _Tag('Patient'),
                    _Tag('Friendly'),
                    _Tag('Well Prepared'),
                  ],
                ),

                const SizedBox(height: 24),

                /// Submit
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => submitted = true);
                      widget.onSubmitted();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Submit Review'),
                  ),
                ),
              ],
            ),
          ),

          /// Success Overlay
          if (submitted)
            Container(
              color: Colors.black.withOpacity(.4),
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
                      const Icon(Icons.star,
                          color: Colors.white, size: 40),
                      const SizedBox(height: 12),
                      const Text(
                        'Review Submitted!',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Thank you for your feedback',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
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

  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text),
      backgroundColor: Colors.grey.shade200,
    );
  }
}
