import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kisekae/services/email_auth.dart';

class NewPasswordScreen extends StatefulWidget {
  final String resetToken;
  const NewPasswordScreen({super.key, required this.resetToken});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _resetting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_resetting) return;
    if (!_form.currentState!.validate()) return;

    setState(() => _resetting = true);
    try {
      final response = await EmailAuth().resetPassword(
        widget.resetToken,
        _passwordController.text,
      );
      if (!mounted) return;

      if (response.success) {
        int count = 0;
        Navigator.popUntil(context, (route) => count++ >= 3);
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
      if (mounted) setState(() => _resetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final blackBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.black, width: 1),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Reset Password",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter your new password",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text("Password", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    maxLength: 128,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
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
                    decoration: InputDecoration(
                      hintText: "Enter your new password",
                      counterText: '',
                      filled: true,
                      fillColor: colors.surfaceContainerHighest,
                      border: blackBorder,
                      enabledBorder: blackBorder,
                      focusedBorder: blackBorder,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Confirm Password",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    maxLength: 128,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleResetPassword(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Confirm your password",
                      counterText: '',
                      filled: true,
                      fillColor: colors.surfaceContainerHighest,
                      border: blackBorder,
                      enabledBorder: blackBorder,
                      focusedBorder: blackBorder,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _resetting ? null : _handleResetPassword,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _resetting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Reset Password',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
