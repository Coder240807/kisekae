import 'package:flutter/material.dart';
import 'package:kisekae/screens/create_store.dart';
import 'package:kisekae/screens/joinstore_screen.dart';
import 'package:kisekae/services/email_auth.dart';
import 'package:kisekae/services/post_auth.dart';

class SellerOnboardingScreen extends StatefulWidget {
  const SellerOnboardingScreen({super.key});

  @override
  State<SellerOnboardingScreen> createState() => _SellerOnboardingScreenState();
}

class _SellerOnboardingScreenState extends State<SellerOnboardingScreen> {
  String? _selected;

  Future<void> _open(String key, Widget screen) async {
    setState(() => _selected = key);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(() => _selected = null);
  }

  Future<void> _logout() async {
    await EmailAuth().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surface,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => PostAuth.openSide(context, seller: false),
            child: const Text('Shop instead'),
          ),
          TextButton(
            onPressed: _logout,
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: const Text('Log out'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.08),
              Text(
                'KISEKAE',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                  fontFamily: 'Serif',
                  color: cs.primary,
                ),
              ),
              SizedBox(height: size.height * 0.09),
              _OptionCard(
                icon: Icons.storefront_outlined,
                title: 'CREATE A STORE',
                description: 'Set up your own store,showcasing your collection and start selling to a wider audience.',
                isSelected: _selected == 'create',
                colorScheme: cs,
                onTap: () => _open('create', const CreateStoreScreen()),
              ),
              SizedBox(height: size.height * 0.07),
              _OptionCard(
                icon: Icons.groups_outlined,
                title: 'JOIN A STORE',
                description: 'Already invited? Join an existing store and start managing your products',
                isSelected: _selected == 'join',
                colorScheme: cs,
                onTap: () => _open('join', const JoinStoreScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = isSelected ? Colors.white : Colors.black;
    final Color iconColor = isSelected ? Colors.white : colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 104),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 3),
              blurRadius: 8,
              color: Color(0x1F000000),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 44, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: textColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
