import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kisekae/screens/home_screen.dart';
import 'package:kisekae/services/email_auth.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final int _otpLength = 6;
  late final List<FocusNode> _focusNodes;
  late final List<TextEditingController> _controllers;

  bool _hasError = false;
  String _errorMessage = '';
  bool _loading = false;
  bool _isResending = false;

  String get _code => _controllers.map((c) => c.text.trim()).join();

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(
      _otpLength,
      (index) => FocusNode(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              _controllers[index].text.isEmpty &&
              index > 0) {
            _focusNodes[index - 1].requestFocus();
            _controllers[index - 1].clear();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
      ),
    );
    _controllers = List.generate(
      _otpLength,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (_hasError) {
      setState(() {
        _hasError = false;
        _errorMessage = '';
      });
    }

    if (value.length > 1) {
      final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _otpLength; i++) {
        if (i < digitsOnly.length) {
          _controllers[i].text = digitsOnly[i];
        }
      }
      if (digitsOnly.length >= _otpLength) {
        _focusNodes[_otpLength - 1].unfocus();
        _verifyCode();
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
        if (_code.length == _otpLength) {
          _verifyCode();
        }
      }
    } else if (value.isEmpty) {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_loading) return;

    if (_code.length != _otpLength) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Please enter the full 6-digit code';
      });
      return;
    }

    final otp = int.tryParse(_code);
    if (otp == null) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Invalid verification code';
      });
      return;
    }

    setState(() => _loading = true);
    final response = await EmailAuth().verifyOtp(widget.email, otp, purpose: "verify_email");
    if (!mounted) return;
    setState(() => _loading = false);

    if (response.success) {
      if (response.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Verification failed. Please try again.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _resendCode() async {
    if (_isResending || _loading) return;

    setState(() => _isResending = true);
    final response = await EmailAuth().sendOtp(
      widget.email,
      purpose: 'verify_email',
    );
    if (!mounted) return;
    setState(() => _isResending = false);

    final message = response.message.isNotEmpty
        ? response.message
        : (response.success
              ? 'Verification code resent'
              : 'Failed to resend code');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: response.success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'sans-serif'),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFEEE9E4),
        appBar: AppBar(
          backgroundColor: const Color(0xFFEEE9E4),
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
          centerTitle: true,
          title: const Text(
            'Verify Code',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.065,
              vertical: size.height * 0.01,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'We have sent a 6-digit code to',
                    style: TextStyle(fontSize: size.width * 0.04),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    widget.email,
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.035),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    _otpLength,
                    (index) => SizedBox(
                      height: size.height * 0.08,
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _onChanged(value, index),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: const Color(0xFFEEE0E2),
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
                              width: _hasError ? 1.5 : 1,
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
                if (_hasError && _errorMessage.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: size.height * 0.012),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                SizedBox(height: size.height * 0.04),
                ElevatedButton(
                  onPressed: _loading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B2E3E),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, size.height * 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'VERIFY CODE',
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                SizedBox(height: size.height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: TextStyle(
                        fontSize: size.width * 0.037,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: (_isResending || _loading) ? null : _resendCode,
                      child: Text(
                        _isResending ? 'Resending...' : 'Resend Code',
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
        ),
      ),
    );
  }
}
