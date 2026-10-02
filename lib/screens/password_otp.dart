import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kisekae/screens/new_password.dart';
import 'package:kisekae/services/email_auth.dart';

class PasswordOTP extends StatefulWidget {
  final String email;
  const PasswordOTP({super.key, required this.email});

  @override
  State<PasswordOTP> createState() => _PasswordOTPState();
}

class _PasswordOTPState extends State<PasswordOTP> {
  final int _otpLength = 6;
  late final List<FocusNode> _focusNodes;
  late final List<TextEditingController> _controllers;

  bool _hasError = false;
  bool _verifying = false;
  bool _resending = false;

  String get _code => _controllers.map((c) => c.text.trim()).join();

  @override
  void initState() {
    super.initState();
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
    if (_hasError) setState(() => _hasError = false);
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

  Future<void> _onVerify() async {
    if (_verifying || _resending) return;
    if (_code.length != _otpLength) {
      setState(() => _hasError = true);
      return;
    }

    final otp = int.tryParse(_code);
    if (otp == null) {
      setState(() => _hasError = true);
      return;
    }

    setState(() {
      _hasError = false;
      _verifying = true;
    });

    try {
      final response = await EmailAuth().verifyOtp(widget.email, otp, purpose: "password_reset");
      if (!mounted) return;

      if (response.success) {
        final resetToken = response.data?["reset_token"]?.toString() ?? "";
        if (resetToken.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Reset token missing from response"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewPasswordScreen(resetToken: resetToken),
          ),
        );
      } else {
        setState(() => _hasError = true);
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

  Future<void> _resendCode() async {
    if (_resending) return;
    setState(() => _resending = true);
    try {
      final response = await EmailAuth().sendOtp(
        widget.email,
        purpose: "password_reset",
      );
      if (!mounted) return;
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
        title: const Text(
          "OTP Verification",
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_hasError)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "Please enter the full 6-digit code",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            const SizedBox(height: 96),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _verifying ? null : _onVerify,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _verifying
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Verify'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: TextStyle(fontSize: size.width * 0.037),
                ),
                GestureDetector(
                  onTap: (_resending) ? null : _resendCode,
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
          ],
        ),
      ),
    );
  }
}

