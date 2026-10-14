import "package:flutter/material.dart";
import "package:kisekae/screens/search.dart";
import "package:kisekae/widgets/bottom_bar.dart";

class SubCategoriesScreen extends StatelessWidget {
  const SubCategoriesScreen({super.key});

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
          "Women's fashion",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
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
              const SizedBox(height: 24),
              Text(
                'Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _CategoryImage(
                    imageUrl: 'assets/images/clothes/11.jpg',
                    alignment: Alignment.topCenter,
                    label: 'Women',
                  ),
                  _CategoryImage(
                    imageUrl: 'assets/images/clothes/12.jpg',
                    alignment: Alignment.topCenter,
                    label: 'Men',
                  ),
                  _CategoryImage(
                    imageUrl: 'assets/images/clothes/13.jpg',
                    alignment: Alignment.topCenter,
                    label: 'Kids',
                  ),
                  _CategoryImage(
                    imageUrl: 'assets/images/clothes/14.jpg',
                    alignment: Alignment(0, -0.5),
                    label: 'Formals',
                  ),
                ],
              ),
              Row(
                children: [
                  _CategoryImage(
                    imageUrl: 'assets/images/clothes/15.jpg',
                    alignment: Alignment.topCenter,
                    label: 'Women',
                  ),
                  _CategoryImage(
                    imageUrl: 'assets/images/clothes/16.jpg',
                    alignment: Alignment.topCenter,
                    label: 'Men',
                  ),
                  _CategoryImage(
                    imageUrl: 'assets/images/clothes/17.jpg',
                    alignment: Alignment(0, -0.25),
                    label: 'Kids',
                  ),
                  _CategoryImage(
                    imageUrl: 'assets/images/clothes/18.jpg',
                    alignment: Alignment(0, -0.5),
                    label: 'Formals',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Spotlight Steals',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.arrow_back),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (context, i) => const SizedBox(width: 12),
                  itemBuilder: (context, i) =>
                      _imageCard('assets/images/deals/${i + 1}.jpg'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Shop by brands',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.arrow_back),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (context, i) => const SizedBox(width: 12),
                  itemBuilder: (context, i) =>
                      _imageCard('assets/images/brands/${i + 1}.jpg'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }

  Widget _imageCard(String imageUrl) {
    return Container(
      height: 160,
      width: 120,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Image.asset(imageUrl, fit: BoxFit.cover),
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
