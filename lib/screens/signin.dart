import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kisekae/screens/forgot_password.dart';
import 'package:kisekae/screens/home_screen.dart';
import 'package:kisekae/screens/signin_otp.dart';
import 'package:kisekae/screens/verify_code.dart';
import 'package:kisekae/services/email_auth.dart';
import 'package:kisekae/services/oauth.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final _form = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;
  bool _isOauthLoading = false;

  Future<void> _submitForm() async {
    if (_loading || _isOauthLoading) return;
    if (_form.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        final email = _emailController.text.trim();

        final response = await EmailAuth().signIn(
          email,
          _passwordController.text,
        );
        if (!mounted) return;
        if (response.success) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
        if (response.message.toLowerCase().contains("email is not verified")) {
          final otpResponse = await EmailAuth().sendOtp(
            email,
            purpose: "verify_email",
          );
          if (!mounted) return;
          if (otpResponse.message.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(otpResponse.message),
                backgroundColor: otpResponse.success
                    ? Colors.green
                    : Colors.red,
              ),
            );
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VerifyCodeScreen(email: email)),
          );
          return;
        }
        if (response.message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: response.success ? Colors.green : Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isOauthLoading = false);
      }
    }
  }

  Future<void> _googleAuth() async {
    if (_loading || _isOauthLoading) return;
    setState(() => _isOauthLoading = true);
    try {
      final response = await SocialAuth().signInWithGoogle();
      if (!mounted) return;
      if (response.success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
      if (response.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.success ? Colors.green : Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isOauthLoading = false);
    }
  }

  Future<void> _githubAuth() async {
    if (_loading || _isOauthLoading) return;
    setState(() => _isOauthLoading = true);
    try {
      final response = await SocialAuth().signInWithGitHub();
      if (!mounted) return;
      if (response.success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
      if (response.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.success ? Colors.green : Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isOauthLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
        ),
        centerTitle: true,
        title: Text("Sign in", style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          children: [
            Text(
              'Hi, welcome back sign in to continue your styling journey',
              style: TextStyle(fontSize: size.width * 0.045),
            ),
            SizedBox(height: 16),
            Form(
              key: _form,
              child: Column(
                children: [
                  _TextInput(
                    label: 'Email',
                    hint: 'Enter your email',
                    maxLength: 100,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (value.length >= 100) {
                        return 'You have reached the maximum limit';
                      }
                      final emailRegex = RegExp(
                        r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$',
                      );
                      if (!emailRegex.hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  _TextInput(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    maxLength: 128,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      if (value.length >= 128) {
                        return 'You have reached the maximum limit';
                      }
                      final passwordRegex = RegExp(
                        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,128}$',
                      );
                      if (!passwordRegex.hasMatch(value)) {
                        return 'Password must include a letter, a number, and a special character';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ForgotPassword(email: _emailController.text.trim()),
                    ),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.normal,
                    fontSize: size.width * 0.04,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: size.height * 0.065,
              child: FilledButton(
                onPressed: (_loading || _isOauthLoading) ? null : _submitForm,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'SIGN IN',
                        style: TextStyle(fontSize: size.width * 0.04),
                      ),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Row(
              children: [
                Expanded(child: Divider()),
                SizedBox(width: 8),
                Text("or", style: TextStyle(fontSize: size.width * 0.04)),
                SizedBox(width: 8),
                Expanded(child: Divider()),
              ],
            ),
            SizedBox(height: size.height * 0.02),
            SizedBox(
              width: double.infinity,
              height: size.height * 0.065,
              child: OutlinedButton(
                onPressed: (_loading || _isOauthLoading)
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SigninOtp(
                              email: _emailController.text.trim(),
                            ),
                          ),
                        );
                      },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Sign in with otp instead',
                  style: TextStyle(fontSize: size.width * 0.04),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Row(
              children: [
                Expanded(child: Divider()),
                SizedBox(width: 8),
                Text(
                  "or sign in with",
                  style: TextStyle(fontSize: size.width * 0.04),
                ),
                SizedBox(width: 8),
                Expanded(child: Divider()),
              ],
            ),
            SizedBox(height: size.height * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: (_loading) ? null : _googleAuth,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset('assets/icons/google.png'),
                    ),
                  ),
                ),
                SizedBox(width: 24),
                GestureDetector(
                  onTap: (_loading) ? null : _githubAuth,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset('assets/icons/github.png'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final int? maxLength;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const _TextInput({
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.maxLength,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final simpleBlackBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Colors.black, width: 1),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: size.width * 0.04)),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          maxLength: maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            filled: true,
            fillColor: colors.surfaceContainerHighest,
            border: simpleBlackBorder,
            enabledBorder: simpleBlackBorder,
            focusedBorder: simpleBlackBorder,
            errorBorder: simpleBlackBorder,
            focusedErrorBorder: simpleBlackBorder,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
