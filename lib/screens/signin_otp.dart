import 'package:flutter/material.dart';
import 'package:kisekae/screens/home_screen.dart';
import 'package:kisekae/services/email_auth.dart';
import 'package:flutter/services.dart';

class SigninOtp extends StatefulWidget {
  final String email;
  const SigninOtp({super.key, required this.email});

  @override
  State<SigninOtp> createState() => _SigninOtpState();
}

class _SigninOtpState extends State<SigninOtp> {
  final int _otpLength = 6;
  late final List<FocusNode> _focusNodes;
  late final List<TextEditingController> _controllers;

  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    sendOtp();
    _focusNodes = List.generate(_otpLength, (index) => FocusNode());
    _controllers = List.generate(
      _otpLength,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (_hasError) {
      setState(() {
        _hasError = false;
      });
    }
    if (value.length > 1) {
      String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _otpLength; i++) {
        if (i < digitsOnly.length) {
          _controllers[i].text = digitsOnly[i];
        }
      }
      if (digitsOnly.length >= _otpLength) {
        _focusNodes[_otpLength - 1].unfocus();
      } else if (digitsOnly.isNotEmpty) {
        _focusNodes[digitsOnly.length].requestFocus();
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
        title: Text(
          "Sign in using OTP",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          children: [
            Text(
              'We have sent a 6 digit code to ${widget.email}',
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
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    autofocus: index == 0,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) => _onChanged(value, index),
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: colors.surfaceContainerHighest,
                      errorText: _hasError ? "Incorrect OTP enter again" : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 96),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: verifyOtp,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Sign In'),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> sendOtp() async {
    await EmailAuth().sendOtp(widget.email);
  }

  Future<void> verifyOtp() async {
    final otp = int.tryParse(_controllers.map((c) => c.text).join());
    if (otp == null) {
      setState(() => _hasError = true);
      return;
    }
    final success = await EmailAuth().verifyOtp(widget.email, otp);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signed in successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
