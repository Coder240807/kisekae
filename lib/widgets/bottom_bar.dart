import 'package:flutter/material.dart';
import 'package:kisekae/screens/cart.dart';
import 'package:kisekae/screens/categories.dart';
import 'package:kisekae/screens/profile.dart';

class BottomBar extends StatelessWidget {
  final int selectedIndex;

  const BottomBar({super.key, this.selectedIndex = 0});

  static const Color _barColor = Color(0xFF8B2E3E);
  static const Color _circleColor = Color(0xFFD9D9D9);

  Widget _selected(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: _circleColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: _barColor, size: 26),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (i) {
        if (i == selectedIndex) {
          if (i == 1) {
            Navigator.popUntil(
              context,
              (route) =>
                  route.settings.name == '/categories' || route.isFirst,
            );
          }
          return;
        }

        switch (i) {
          case 0:
            Navigator.popUntil(context, (route) => route.isFirst);
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(name: '/categories'),
                builder: (_) => const CategoriesScreen(),
              ),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(name: '/cart'),
                builder: (_) => const CartScreen(),
              ),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(name: '/profile'),
                builder: (_) => const ProfileScreen(),
              ),
            );
            break;
        }
      },
      elevation: 0,
      backgroundColor: _barColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(
        Colors.transparent,
      ), // no focus/press circle
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 0.3),
      ),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_filled, color: Colors.white),
          selectedIcon: _selected(Icons.home_filled),
          label: 'HOME',
        ),
        NavigationDestination(
          icon: const Icon(Icons.apps_rounded, color: Colors.white),
          selectedIcon: _selected(Icons.apps_rounded),
          label: 'CATEGORIES',
        ),
        NavigationDestination(
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          selectedIcon: _selected(Icons.shopping_cart),
          label: 'CART',
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_rounded, color: Colors.white),
          selectedIcon: _selected(Icons.person_rounded),
          label: 'PROFILE',
        ),
      ],
    );
  }
}
