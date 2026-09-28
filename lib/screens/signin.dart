import 'package:flutter/material.dart';
import 'package:kisekae/screens/forgot_password.dart';
import 'package:kisekae/screens/verify_email.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final _form = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  void _submitForm() {
    if (_form.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Login Successfully!')));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
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
            SizedBox(height: size.height * 0.02),
            DefaultTabController(
              length: 2,
              child: Form(
                key: _form,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(text: 'Email'),
                        Tab(text: 'Mobile'),
                      ],
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFF81253A),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: colors.onSurface,
                    ),
                    SizedBox(
                      height: size.height * 0.27,
                      child: TabBarView(
                        children: [
                          Column(
                            children: [
                              SizedBox(height: size.height * 0.02),
                              _TextInput(
                                label: 'Email',
                                hint: 'enter your email',
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: size.height * 0.02),
                              _TextInput(
                                label: 'Password',
                                hint: 'enter your password',
                                controller: _passwordController,
                                obscureText: _obscurePassword,
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
                                  return null;
                                },
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(height: size.height * 0.02),
                              _TextInput(
                                label: 'Mobile number',
                                hint: 'enter your mobile number',
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your mobile number';
                                  }
                                  if (value.trim().length < 10) {
                                    return 'Enter a valid mobile number';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: size.height * 0.02),
                              _TextInput(
                                label: 'Password',
                                hint: 'enter your password',
                                controller: _passwordController,
                                obscureText: _obscurePassword,
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
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPassword(),
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
                onPressed: _submitForm,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VerifyEmail(),
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
                  'sign in with otp instead',
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
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Image.asset('assets/images/icons/apple.png'),
                  ),
                ),
                SizedBox(width: size.width * 0.14),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Image.asset('assets/images/icons/google.png'),
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
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const _TextInput({
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: size.width * 0.04)),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: colors.surfaceContainerHighest,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
