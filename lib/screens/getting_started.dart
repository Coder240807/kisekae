import 'package:flutter/material.dart';
import 'package:kisekae/screens/create_account.dart';
import 'package:kisekae/screens/signin.dart';

class GettingStartedScreen extends StatelessWidget {
  const GettingStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'sans-serif'),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFEEE9E4),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06,
              vertical: 20.0,
            ),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.1),
                Image.asset(
                  'assets/images/pic1.png',
                  height: size.height * 0.3,
                  fit: BoxFit.contain,
                  color: const Color(0xFFEEE9E4),
                  colorBlendMode: BlendMode.multiply,
                ),

                SizedBox(height: size.height * 0.04),

                Text(
                  'Let’s Get Started',
                  style: TextStyle(
                    fontSize: size.width * 0.065,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'sign in to your account or create a account',
                  style: TextStyle(fontSize: size.width * 0.04),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: size.height * 0.04),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Signin()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B2E3E),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, size.height * 0.065),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'sign in',
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateAccount(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B2E3E),
                    minimumSize: Size(double.infinity, size.height * 0.065),
                    side: const BorderSide(
                      color: Color(0xFF8B2E3E),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
