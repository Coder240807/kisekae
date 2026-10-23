import 'package:flutter/material.dart';
import 'package:kisekae/screens/products_list.dart';
import 'package:kisekae/screens/search.dart';
import 'package:kisekae/screens/categories.dart';
import 'package:kisekae/screens/wishlist_screen.dart';
import 'package:kisekae/widgets/bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> brandImages = [
    'assets/images/brands/deals1.png',
    'assets/images/brands/deals2.png',
    'assets/images/brands/deals3.png',
  ];

  Widget _searchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const SearchScreen()));
      },
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFBF8F5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD3C7B8)),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.black87, size: 20),
            SizedBox(width: 8),
            Text(
              "EXPLORE YOUR STYLE",
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wishlistButton() {
    return Material(
      color: const Color(0xFF8B2E3E),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const WishlistScreen()));
        },
        child: const SizedBox(
          height: 46,
          width: 46,
          child: Icon(Icons.favorite, color: Color(0xFFDBBEC3), size: 22),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 135,
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 16,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "KISEKAE",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF7D2938),
                    fontFamily: 'serif',
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF8B2E3E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.place_rounded),
                Text(
                  "HOME",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Icon(Icons.keyboard_arrow_down),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _searchBar()),
                const SizedBox(width: 12),
                _wishlistButton(),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 370,
                    height: 250,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFFE5DDD3),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/banner.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CategoriesScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _CategoryImage(
                        imageUrl: 'assets/images/clothes/4.jpg',
                        alignment: Alignment.topCenter,
                        label: 'Women',
                      ),
                      _CategoryImage(
                        imageUrl: 'assets/images/clothes/7.jpg',
                        alignment: Alignment.topCenter,
                        label: 'Men',
                      ),
                      _CategoryImage(
                        imageUrl: 'assets/images/clothes/5.jpg',
                        alignment: Alignment.topCenter,
                        label: 'Kids',
                      ),
                      _CategoryImage(
                        imageUrl: 'assets/images/clothes/6.jpg',
                        alignment: Alignment(0, -0.5),
                        label: 'Formals',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.4,
                  colors: [
                    Color(0xFF8B2E3E),
                    Color(0xFF5E1F2A),
                    Color(0xFF481820),
                    Color(0xFF311016),
                  ],
                  stops: [0.2067, 0.6058, 0.8173, 1.0],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Flat ₹500 Off',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "USE CODE :",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Text(
                        "FEST500",
                        style: TextStyle(
                          color: Color(0xFFD9601A),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "T&C Apply",
                        style: TextStyle(color: Colors.white38, fontSize: 8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Brands To Explore",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/brands/deals1.png',
                          width: 110,
                          height: 170,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/brands/deals3.png',
                          width: 150,
                          height: 190,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/brands/deals2.png',
                          width: 110,
                          height: 170,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Continue Shopping For',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ProductListScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ProductCard(
                          imageUrl: 'assets/images/clothes/8.jpg',
                          title: 'floral top',
                          rating: 3.9,
                          price: 375,
                          alignment: Alignment(0, -0.4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ProductCard(
                          imageUrl: 'assets/images/clothes/6.jpg',
                          title: 'tailored blazer',
                          rating: 4.5,
                          price: 705,
                          alignment: Alignment(0, -0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Best Deals',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ProductListScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ProductCard(
                          imageUrl: 'assets/images/clothes/7.jpg',
                          title: 'tailored blazer',
                          rating: 4.5,
                          price: 705,
                          alignment: Alignment(0, -0.75),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ProductCard(
                          imageUrl: 'assets/images/clothes/9.jpg',
                          title: 'tailored blazer',
                          rating: 4.5,
                          price: 705,
                          alignment: Alignment(0, -0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double rating;
  final int price;
  final Alignment alignment;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.rating,
    required this.price,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Color(0xFF8B2E3E)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.5),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                alignment: alignment,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              const Icon(Icons.star, size: 16, color: Colors.amber),
              Text('$rating'),
            ],
          ),
          Text(
            '₹$price',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  final String imageUrl;
  final Alignment alignment;
  final String label;
  const _CategoryImage({
    required this.imageUrl,
    required this.alignment,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: const Color(0xFFDBBEC3),
            child: ClipOval(
              child: Image.asset(
                imageUrl,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                alignment: alignment,
              ),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
