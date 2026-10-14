import "package:flutter/material.dart";
import "package:kisekae/screens/checkout.dart";

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
          "My Cart",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    productCard(
                      name: "Casual blue t-shirt",
                      image: "assets/images/clothes/4.jpg",
                      size: "M",
                      price: 300,
                      quantity: 1,
                      alignment: Alignment.topCenter,
                    ),
                    const SizedBox(height: 16),
                    productCard(
                      name: "Solid maroon top",
                      image: "assets/images/clothes/10.jpg",
                      size: "M",
                      price: 271,
                      quantity: 1,
                      alignment: Alignment.topCenter,
                    ),
                  ],
                ),
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Price details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16),
                color: Color(0xFFE0E0E0),
              ),
              child: Column(
                children: [
                  priceRow("MRP", 1571),
                  priceRow("Platform fee", 20),
                  priceRow("Discounts", 1000),
                  priceRow("Total amount", 591),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.place_rounded),
                Text("Address-Home (saved address)"),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Color(0xFF8B2E3E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  "Buy Now",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget productCard({
    required String name,
    required String image,
    required String size,
    required int price,
    required int quantity,
    required Alignment alignment,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 120,
                width: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF8B2E3E), width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  alignment: alignment,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontSize: 16)),
                    Text('Size - $size', style: TextStyle(fontSize: 18)),
                    Text('₹$price', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 6),
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEE9E4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.remove, size: 20),
                            onPressed: () {},
                          ),
                          Text(
                            '$quantity',
                            style: const TextStyle(fontSize: 20),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF8B2E3E),
                    padding: EdgeInsets.all(12),
                    side: const BorderSide(color: Color(0xFF8B2E3E)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text("Wishlist", style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF8B2E3E),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF8B2E3E)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text("Remove", style: const TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget priceRow(String label, int price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 40),
          Text('₹$price', style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
