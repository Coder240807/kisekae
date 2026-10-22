import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kisekae/screens/add_product.dart';
import 'package:kisekae/screens/store_order.dart';
import 'package:kisekae/widgets/seller_bottom_bar.dart';

class SellerDashboardScreen extends StatefulWidget {
  final int storeId;

  const SellerDashboardScreen({super.key, required this.storeId});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  int _currentIndex = 0;

  static const Color _widgetBgColor = Color(0xFFFFF9F2);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    final horizontalPadding = size.width * (20 / 360);
    final verticalPadding = size.height * (16 / 840);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "KISEKAE",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF7D2938),
                  fontFamily: 'serif',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.place_rounded),
                Text("HOME", style: TextStyle(fontSize: 18)),
                Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_none_rounded,
              color: colorScheme.primary,
              size: 28,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStoreBanner(size, colorScheme),
              SizedBox(height: size.height * (20 / 840)),
              _buildTotalSalesCard(size, colorScheme),
              SizedBox(height: size.height * (24 / 840)),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: size.width * (20 / 360),
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: size.height * (12 / 840)),
              _buildQuickActionsRow(context, size, colorScheme),
              SizedBox(height: size.height * (20 / 840)),
              _buildStatsGrid(size, colorScheme),
              SizedBox(height: size.height * (16 / 840)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SellerBottomBar(
        selectedIndex: _currentIndex,
        onItemTapped: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  Widget _buildStoreBanner(Size size, ColorScheme colorScheme) {
    final bannerWidth = size.width * (320 / 360);
    final bannerHeight = size.height * (182 / 840);

    final buttonWidth = size.width * (123 / 360);
    final buttonHeight = size.height * (48 / 840);
    final buttonTop = size.height * (120 / 840);
    final buttonLeft = size.width * (173 / 360);

    return Center(
      child: Container(
        width: bannerWidth,
        height: bannerHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: _widgetBgColor,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/StoreBanner.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: buttonTop,
              left: buttonLeft,
              child: SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'View Store',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSalesCard(Size size, ColorScheme colorScheme) {
    final cardWidth = size.width * (320 / 360);
    final cardHeight = size.height * (88 / 840);

    return Center(
      child: Container(
        width: cardWidth,
        height: cardHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _widgetBgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total sales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Last 7 days',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            Text(
              '–',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsRow(
    BuildContext context,
    Size size,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickActionItem(
          size,
          colorScheme,
          'assets/icons/addproducts.svg',
          'Add\nProducts',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddProductScreen()),
            );
          },
        ),
        _buildQuickActionItem(
          size,
          colorScheme,
          'assets/icons/vieworders.svg',
          'View\nOrders',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrdersScreen(storeId: widget.storeId),
              ),
            );
          },
        ),
        _buildQuickActionItem(
          size,
          colorScheme,
          'assets/icons/analytics.svg',
          'Analytics',
          onTap: () {
            // Navigate to Analytics screen
          },
        ),
        _buildQuickActionItem(
          size,
          colorScheme,
          'assets/icons/payment.svg',
          'Payment',
          onTap: () {
            // Navigate to Payment screen
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(
    Size size,
    ColorScheme colorScheme,
    String assetPath,
    String label, {
    VoidCallback? onTap,
  }) {
    final buttonWidth = size.width * (68 / 360);
    final buttonHeight = size.height * (68 / 840);
    final labelHeight = size.height * (32 / 840);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: buttonWidth,
            height: buttonHeight,
            decoration: BoxDecoration(
              color: _widgetBgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: SvgPicture.asset(
                assetPath,
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(
                  colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: buttonWidth,
            height: labelHeight,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Size size, ColorScheme colorScheme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatCard(
              size,
              colorScheme,
              'Orders',
              '–',
              'assets/icons/vieworders.svg',
            ),
            _buildStatCard(
              size,
              colorScheme,
              'Visitors',
              '–',
              'assets/icons/visitors.svg',
            ),
          ],
        ),
        SizedBox(height: size.height * (16 / 840)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatCard(
              size,
              colorScheme,
              'Products',
              '–',
              'assets/icons/products.svg',
            ),
            _buildStatCard(
              size,
              colorScheme,
              'Conversion',
              '–',
              'assets/icons/conversion.svg',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    Size size,
    ColorScheme colorScheme,
    String title,
    String value,
    String assetPath,
  ) {
    final cardWidth = size.width * (152 / 360);
    final cardHeight = size.height * (88 / 840);

    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _widgetBgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface,
                ),
              ),
              SvgPicture.asset(
                assetPath,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
