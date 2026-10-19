import 'package:flutter/material.dart';
import 'package:kisekae/services/storage.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  String? selectedRole;

  final TokenStorage _tokenStorage = TokenStorage();

  void _selectRole(String role) async {
    setState(() {
      selectedRole = role;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    final accessToken = await _tokenStorage.readAccessToken();
    final isLoggedIn = accessToken != null && accessToken.isNotEmpty;

    if (!mounted) return;

    if (!isLoggedIn) {
      Navigator.pushNamed(context, '/login', arguments: {'selectedRole': role});
      return;
    }

    if (role == 'seller') {
      Navigator.pushReplacementNamed(context, '/seller-dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'KISEKAE',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2.5,
                    fontFamily: 'Serif',
                    color: colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 48),

                Text(
                  'Are you here\nto shop or sell?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    height: 1.25,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Choose your role to get started',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 48),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RoleCard(
                      title: 'Buyer',
                      subtitle: 'Shop & try on',
                      icon: Icons.shopping_bag_outlined,
                      isSelected: selectedRole == 'buyer',
                      colorScheme: colorScheme,
                      onTap: () => _selectRole('buyer'),
                    ),
                    _RoleCard(
                      title: 'Seller',
                      subtitle: 'Manage your store',
                      icon: Icons.storefront_outlined,
                      isSelected: selectedRole == 'seller',
                      colorScheme: colorScheme,
                      onTap: () => _selectRole('seller'),
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

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 124,
            height: 124,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? colorScheme.primary : colorScheme.surface,
              border: Border.all(color: colorScheme.primary, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 4),
                  blurRadius: 8,
                  spreadRadius: 0,
                  color: Color(0x1A000000),
                ),
                BoxShadow(
                  offset: Offset(0, 14),
                  blurRadius: 14,
                  spreadRadius: 0,
                  color: Color(0x17000000),
                ),
                BoxShadow(
                  offset: Offset(0, 32),
                  blurRadius: 19,
                  spreadRadius: 0,
                  color: Color(0x0D000000),
                ),
                BoxShadow(
                  offset: Offset(0, 57),
                  blurRadius: 23,
                  spreadRadius: 0,
                  color: Color(0x03000000),
                ),
                BoxShadow(
                  offset: Offset(0, 89),
                  blurRadius: 25,
                  spreadRadius: 0,
                  color: Color(0x00000000),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 46,
              color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 120,
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface.withOpacity(0.65),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
