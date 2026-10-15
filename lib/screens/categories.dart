import "package:flutter/material.dart";
import "package:kisekae/screens/search.dart";
import "package:kisekae/screens/subcategories.dart";
import "package:kisekae/widgets/bottom_bar.dart";

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          "Categories",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                  label: const Text(
                    'EXPLORE YOUR STYLE',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  icon: Icon(Icons.search, size: 24, color: Colors.black),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE8D8C4),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    side: BorderSide(color: const Color(0xFFB78876)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                spacing: 16,
                children: [
                  _categoryCard(
                    context,
                    "Women's fashion",
                    "assets/images/clothes/2.jpg",
                    Alignment(0, -0.5),
                  ),
                  _categoryCard(
                    context,
                    "Men's fashion",
                    "assets/images/clothes/9.jpg",
                    Alignment(0, -0.5),
                  ),
                  _categoryCard(
                    context,
                    "Kids wear",
                    "assets/images/clothes/5.jpg",
                    Alignment(0, -0.5),
                  ),
                  _categoryCard(
                    context,
                    "Traditional wear",
                    "assets/images/clothes/8.jpg",
                    Alignment.center,
                  ),
                  _categoryCard(
                    context,
                    "Casual wear",
                    "assets/images/clothes/4.jpg",
                    Alignment.topCenter,
                  ),
                  _categoryCard(
                    context,
                    "Formal wear",
                    "assets/images/clothes/6.jpg",
                    Alignment(0, -0.5),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(selectedIndex: 1),
    );
  }

  Widget _categoryCard(
    BuildContext context,
    String label,
    String imageUrl,
    Alignment alignment,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SubCategoriesScreen()));
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F2F2),
          border: Border.all(color: Color(0xFFB78876)),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            Container(
              height: 80,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFB78876), width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                alignment: alignment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
