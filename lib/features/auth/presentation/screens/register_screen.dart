import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:maranny_two/layout/main_layout.dart';
import '../../../become_coach/presentation/screens/coach_info_screen.dart';
// ✅ NEW: import the 2 new onboarding screens
import '../../../onboarding/presentation/screens/sports_selection_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String userType;

  const RegisterScreen({
    Key? key,
    this.userType = 'trainee',
  }) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool get _isCoach => widget.userType == 'coach';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error',
        desc: 'Passwords do not match.',
      ).show();
      return;
    }

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await credential.user
          ?.updateDisplayName(_nameController.text.trim());

      if (!mounted) return;

      if (_isCoach) {
        // Coach → start become-a-coach flow
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const CoachInfoScreen()),
              (route) => false,
        );
      } else {
        // ✅ Client → go to sports selection first
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => const SportsSelectionScreen()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg = 'Registration failed. Please try again.';
      if (e.code == 'weak-password') {
        msg = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        msg = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        msg = 'Invalid email address.';
      }
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error',
        desc: msg,
      ).show();
    } catch (e) {
      debugPrint('Register error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage('assets/images/background_screen.png'),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/maranny_logo.png',
                          width: 160,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'MARANNY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        _isCoach ? 'Join as a Coach!' : 'Join Us!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 30),

                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isCoach) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F4FD),
                                  borderRadius:
                                  BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFF6FD3F5)
                                          .withValues(alpha: 0.5)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: Color(0xFF1F3A93),
                                        size: 18),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "After registering, you'll complete your coach profile.",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF1F3A93),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            TextField(
                              controller: _nameController,
                              decoration: _inputDeco('Full Name'),
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration:
                              _inputDeco('Email Address'),
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration:
                              _inputDeco('Password').copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() =>
                                  _obscurePassword =
                                  !_obscurePassword),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration:
                              _inputDeco('Confirm Password')
                                  .copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() =>
                                  _obscureConfirmPassword =
                                  !_obscureConfirmPassword),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Checkbox(
                                    value: _agreeToTerms,
                                    onChanged: (v) => setState(
                                            () =>
                                        _agreeToTerms = v ?? false),
                                    activeColor:
                                    const Color(0xFF303F9F),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(4)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'I agree to terms and Conditions',
                                    style: TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: 13),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                _agreeToTerms ? _register : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  const Color(0xFF303F9F),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                  Colors.grey[300],
                                  disabledForegroundColor:
                                  Colors.grey[500],
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: Text(
                                  _isCoach
                                      ? 'REGISTER & CONTINUE'
                                      : 'REGISTER',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
      TextStyle(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide:
        const BorderSide(color: Color(0xFF303F9F), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide:
        const BorderSide(color: Color(0xFF303F9F), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(
            color: Color(0xFF303F9F), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 16),
    );
  }
}