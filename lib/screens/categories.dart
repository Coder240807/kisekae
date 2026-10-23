import "package:flutter/material.dart";
import "package:kisekae/screens/search.dart";
import "package:kisekae/screens/subcategories.dart";
import "package:kisekae/widgets/bottom_bar.dart";

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const _cardColor = Color(0xFFFFF8F0);

  static const _categories = <(String, String, Alignment)>[
    ("Women's Fashion", "assets/images/category1.png", Alignment(0, -0.5)),
    ("Men's Fashion", "assets/images/category2.png", Alignment(0, -0.5)),
    ("Kids Wear", "assets/images/category3.png", Alignment(0, -0.5)),
    ("Ethnic Wear", "assets/images/category4.png", Alignment.center),
    ("Formals", "assets/images/category5.png", Alignment(0, -0.5)),
    ("Sports Wear", "assets/images/category6.png", Alignment.topCenter),
    ("New Season", "assets/images/category7.png", Alignment.topCenter),
  ];

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
                  for (var i = 0; i < _categories.length; i++)
                    _categoryCard(
                      context,
                      _categories[i].$1,
                      _categories[i].$2,
                      _categories[i].$3,
                      imageOnLeft: i.isOdd,
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
    Alignment alignment, {
    required bool imageOnLeft,
  }) {
    final image = SizedBox(
      width: 110,
      height: double.infinity,
      child: Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        alignment: alignment,
        color: _cardColor,
        colorBlendMode: BlendMode.multiply,
      ),
    );

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SubCategoriesScreen()));
      },
      child: Container(
        height: 96,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            if (imageOnLeft) image,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  label,
                  textAlign: imageOnLeft ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            if (!imageOnLeft) image,
          ],
        ),
      ),
    );
  }
}
