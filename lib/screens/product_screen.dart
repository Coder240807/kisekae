import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _imageController = PageController();
  String _selectedSize = 'M';

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  void _previousImage() {
    _imageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextImage() {
    _imageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final panelColor = scheme.onSurface.withValues(alpha: 0.08);
    final valueStyle = TextStyle(
      fontSize: size.width * 0.038,
      color: scheme.onSurface,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image carousel with arrows
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: AspectRatio(
                        aspectRatio: 1.08,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            children: [
                              PageView(
                                controller: _imageController,
                                children: [
                                  Image.asset(
                                    'assets/images/clothes/10.jpg',
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ],
                              ),
                              Positioned(
                                left: 8,
                                bottom: 8,
                                child: _ArrowButton(
                                  icon: Icons.arrow_back,
                                  onTap: _previousImage,
                                ),
                              ),
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: _ArrowButton(
                                  icon: Icons.arrow_forward,
                                  onTap: _nextImage,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Brand + title + sizes + price
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOPTUNE',
                            style: TextStyle(
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurface,
                            ),
                          ),
                          Text(
                            'Casual regular sleeves solid women top',
                            style: TextStyle(
                              fontSize: size.width * 0.04,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select Size',
                            style: TextStyle(
                              fontSize: size.width * 0.04,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: ['XS', 'S', 'M', 'L', 'XL'].map((s) {
                              final selected = s == _selectedSize;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedSize = s),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 52,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? scheme.primary.withValues(alpha: 0.3)
                                        : Colors.white.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: selected
                                          ? scheme.primary
                                          : scheme.primary.withValues(
                                              alpha: 0.4,
                                            ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      fontSize: size.width * 0.04,
                                      fontWeight: FontWeight.w500,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '↓73%',
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '999',
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₹271',
                                style: TextStyle(
                                  fontSize: size.width * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Try now with AR band
                    Container(
                      width: double.infinity,
                      color: panelColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Try now with\nAR',
                            style: TextStyle(
                              fontSize: size.width * 0.042,
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurface,
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.42,
                            height: 48,
                            child: FilledButton(
                              onPressed: () {
                                // TODO: open AR try-on
                              },
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'TRY NOW',
                                style: TextStyle(
                                  fontSize: size.width * 0.038,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Delivery details
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery details',
                            style: TextStyle(
                              fontSize: size.width * 0.042,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: panelColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: scheme.primary,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _DetailRow(
                                  label: 'Address-',
                                  value: Text('HOME', style: valueStyle),
                                ),
                                const SizedBox(height: 8),
                                _DetailRow(
                                  label: 'Date-',
                                  value: Text(
                                    'Delivery by sunday,11 oct',
                                    style: valueStyle,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _DetailRow(
                                  label: 'Sold by-',
                                  value: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Aluxi', style: valueStyle),
                                      Row(
                                        children: [
                                          Text(
                                            '3.2',
                                            style: TextStyle(
                                              fontSize: size.width * 0.036,
                                              color: scheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.star,
                                            size: 16,
                                            color: scheme.onSurface,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Fixed bottom actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: add to cart
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: BorderSide(color: scheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: () {
                          // TODO: buy now
                        },
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'BUY NOW',
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
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

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Icon(icon, size: 18, color: Colors.black),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: size.width * 0.24,
          child: Text(
            label,
            style: TextStyle(
              fontSize: size.width * 0.038,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
        Expanded(child: value),
      ],
    );
  }
}
