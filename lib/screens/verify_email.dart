import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  final int _otpLength = 6;
  late final List<FocusNode> _focusNodes;
  late final List<TextEditingController> _controllers;

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
        title: const Text(
          "Verify your email",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          children: [
            Text(
              'We have sent a 6 digit code to name@example.com',
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
            const SizedBox(height: 96),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Verify'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
