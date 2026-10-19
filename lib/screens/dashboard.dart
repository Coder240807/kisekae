import 'package:flutter/material.dart';
import 'package:kisekae/widgets/seller_bottom_bar.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

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
              _buildQuickActionsRow(size, colorScheme),
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

  Widget _buildQuickActionsRow(Size size, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickActionItem(
          size,
          colorScheme,
          Icons.add_box_outlined,
          'Add\nProducts',
        ),
        _buildQuickActionItem(
          size,
          colorScheme,
          Icons.inventory_2_outlined,
          'View\nOrders',
        ),
        _buildQuickActionItem(
          size,
          colorScheme,
          Icons.align_vertical_bottom_rounded,
          'Analytics',
        ),
        _buildQuickActionItem(
          size,
          colorScheme,
          Icons.credit_card_outlined,
          'Payment',
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(
    Size size,
    ColorScheme colorScheme,
    IconData icon,
    String label,
  ) {
    final buttonWidth = size.width * (68 / 360);
    final buttonHeight = size.height * (68 / 840);

    return Column(
      children: [
        Container(
          width: buttonWidth,
          height: buttonHeight,
          decoration: BoxDecoration(
            color: _widgetBgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            height: 1.2,
          ),
        ),
      ],
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
              Icons.inventory_2_outlined,
            ),
            _buildStatCard(
              size,
              colorScheme,
              'Visitors',
              '–',
              Icons.people_outline_rounded,
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
              Icons.archive_outlined,
            ),
            _buildStatCard(
              size,
              colorScheme,
              'Conversion',
              '–',
              Icons.bar_chart_rounded,
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
    IconData icon,
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
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Icon(icon, color: colorScheme.primary, size: 22),
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
