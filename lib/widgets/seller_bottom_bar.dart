import 'package:flutter/material.dart';
import 'package:kisekae/screens/inventory.dart';
import 'package:kisekae/screens/seller_profile.dart';
import 'package:kisekae/screens/store_order.dart';

class SellerBottomBar extends StatelessWidget {
  final int storeId;
  final int selectedIndex;
  final ValueChanged<int>? onItemTapped;

  const SellerBottomBar({
    super.key,
    required this.storeId,
    this.selectedIndex = 0,
    this.onItemTapped,
  });

  static const Color _barColor = Color(0xFF8B2E3E);
  static const Color _circleColor = Color(0xFFFFF9F2);

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
      onDestinationSelected: (i) async {
        if (onItemTapped != null) {
          onItemTapped!(i);
        }

        if (i == selectedIndex) return;

        MaterialPageRoute? targetRoute;

        switch (i) {
          case 0:
            Navigator.popUntil(context, (route) => route.isFirst);
            return;
          case 1:
            targetRoute = MaterialPageRoute(
              builder: (_) => InventoryScreen(storeId: storeId),
            );
            break;
          case 2:
            targetRoute = MaterialPageRoute(
              builder: (_) => OrdersScreen(storeId: storeId),
            );
            break;
          case 3:
            targetRoute = MaterialPageRoute(
              builder: (_) => const ProfileScreen(),
            );
            break;
        }

        if (targetRoute != null) {
          await Navigator.push(context, targetRoute);

          if (onItemTapped != null) {
            onItemTapped!(selectedIndex);
          }
        }
      },
      elevation: 0,
      backgroundColor: _barColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_rounded, color: Colors.white),
          selectedIcon: _selected(Icons.home_rounded),
          label: 'HOME',
        ),
        NavigationDestination(
          icon: const Icon(Icons.archive_outlined, color: Colors.white),
          selectedIcon: _selected(Icons.archive_outlined),
          label: 'INVENTORY',
        ),
        NavigationDestination(
          icon: const Icon(Icons.inventory_2_outlined, color: Colors.white),
          selectedIcon: _selected(Icons.inventory_2_outlined),
          label: 'ORDERS',
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
