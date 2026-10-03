import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kisekae/screens/home_screen.dart';
import 'package:kisekae/services/email_auth.dart';

class SigninOtp extends StatefulWidget {
  final String email;
  const SigninOtp({super.key, required this.email});

  @override
  State<SigninOtp> createState() => _SigninOtpState();
}

class _SigninOtpState extends State<SigninOtp> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  bool _sendingOtp = false;
  String get _code => _otpControllers.map((c) => c.text.trim()).join();

  // OTP step state
  bool _otpSent = false;
  late String _confirmedEmail;
  String _errorText = '';
  Timer? _timer;
  int _secondsLeft = 0;

  final int _otpLength = 6;
  late final List<FocusNode> _focusNodes;
  late final List<TextEditingController> _otpControllers;

  bool _hasError = false;
  bool _verifying = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
    _confirmedEmail = '';
    _focusNodes = List.generate(_otpLength, (index) => FocusNode());
    _otpControllers = List.generate(
      _otpLength,
      (index) => TextEditingController(),
    );
    _startTimer();
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (_sendingOtp) return;
    if (!_form.currentState!.validate()) return;

    setState(() => _sendingOtp = true);
    try {
      final email = _emailController.text.trim();
      final response = await EmailAuth().sendOtp(email);

      if (!mounted) return;
      if (response.success) {
        setState(() {
          _confirmedEmail = email;
          _otpSent = true;
        });
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
      if (mounted) setState(() => _sendingOtp = false);
    }
  }

  void _onOtpChanged(String value, int index) {
    if (_hasError) setState(() => _hasError = false);
    if (value.length > 1) {
      final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _otpLength; i++) {
        if (i < digitsOnly.length) {
          _otpControllers[i].value = TextEditingValue(
            text: digitsOnly[i],
            selection: const TextSelection.collapsed(offset: 1),
          );
        }
      }
      if (digitsOnly.isNotEmpty) {
        final target = digitsOnly.length >= _otpLength
            ? _otpLength - 1
            : digitsOnly.length;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _focusNodes[target].requestFocus();
        });
      }
      return;
    }

    if (value.length == 1) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty) {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final visible = name.length <= 2 ? 1 : 2;
    final stars = (name.length - visible).clamp(1, 5);
    return '${name.substring(0, visible)}${'*' * stars}@${parts[1]}';
  }

  Future<void> _verifyOtp() async {
    if (_verifying || _resending) return;
    if (_code.length != _otpLength) {
      setState(() {
        _hasError = true;
        _errorText = "Please enter the full 6-digit code";
      });
      return;
    }

    final otp = int.tryParse(_code);
    if (otp == null) {
      setState(() => _hasError = true);
      return;
    }
    setState(() => _verifying = true);
    try {
      final response = await EmailAuth().verifyOtp(
        _confirmedEmail,
        otp,
        purpose: "login",
      );
      if (!mounted) return;
      if (response.success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        setState(() {
          _hasError = true;
          _errorText = "Incorrect code. Please try again.";
        });
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
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_resending || _verifying) return;
    setState(() => _resending = true);
    try {
      final response = await EmailAuth().sendOtp(_confirmedEmail);
      if (!mounted) return;
      if (response.success) _startTimer();
      if (response.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.success ? Colors.green : Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _otpSent ? _buildOtpStep() : _buildEmailStep();
  }

  Widget _buildEmailStep() {
    ColorScheme colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final simpleBlackBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.black, width: 1),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Container(
            padding: EdgeInsets.all(size.width * 0.01),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Sign in with OTP",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.065,
              vertical: size.height * 0.01,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your email address and we will send you a sign in code',
                  style: TextStyle(fontSize: size.width * 0.045),
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Email",
                          style: TextStyle(fontSize: size.width * 0.04),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.01),
                    SizedBox(
                      child: TextFormField(
                        controller: _emailController,
                        maxLength: 100,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.04,
                            vertical: size.height * 0.015,
                          ),
                          hintText: "Enter your email",
                          counterText: '',
                          filled: true,
                          fillColor: colors.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          enabledBorder: simpleBlackBorder,
                          focusedBorder: simpleBlackBorder,
                          errorBorder: simpleBlackBorder,
                          focusedErrorBorder: simpleBlackBorder,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.08),
                SizedBox(
                  width: double.infinity,
                  height: size.height * 0.065,
                  child: FilledButton(
                    onPressed: _sendingOtp ? null : _handleSendOtp,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _sendingOtp
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Send code',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpStep() {
    ColorScheme colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            setState(() {
              _otpSent = false;
              _hasError = false;
              for (var c in _otpControllers) {
                c.clear();
              }
            });
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
        title: Text(
          "OTP Verification",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          children: [
            Text(
              'We have sent a 6 digit code to ${_maskEmail(_confirmedEmail)}',
              style: TextStyle(fontSize: size.width * 0.045),
            ),
            SizedBox(height: size.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                _otpLength,
                (index) => SizedBox(
                  height: size.height * 0.09,
                  width: size.width * 0.125,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    autofocus: index == 0,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) => _onOtpChanged(value, index),
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: colors.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: _hasError ? Colors.red : Colors.black,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: _hasError ? Colors.red : Colors.black,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_hasError)
              Padding(
                padding: EdgeInsets.only(top: size.height * 0.01),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _errorText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: TextStyle(fontSize: size.width * 0.037),
                ),
                if (_secondsLeft > 0)
                  Text(
                    '0:${_secondsLeft.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: size.width * 0.037,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8B2E3E),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: (_resending) ? null : _resendOtp,
                    child: Text(
                      _resending ? 'Resending...' : 'Resend Code',
                      style: TextStyle(
                        fontSize: size.width * 0.037,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8B2E3E),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 68),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: (_verifying || _resending) ? null : _verifyOtp,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _verifying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Sign In'),
              ),
            ),
            SizedBox(height: 16),
            /*Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: TextStyle(fontSize: size.width * 0.037),
                ),
                GestureDetector(
                  onTap: (_resending || _verifying) ? null : _resendOtp,
                  child: Text(
                    _resending ? 'Resending...' : 'Resend Code',
                    style: TextStyle(
                      fontSize: size.width * 0.037,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8B2E3E),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),*/
          ],
        ),
      ),
    );
  }
}
