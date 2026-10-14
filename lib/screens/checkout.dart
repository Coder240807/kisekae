import "package:flutter/material.dart";
import "package:kisekae/screens/home_screen.dart";

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  int method = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

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
          "CHECKOUT",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      if (i > 0)
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Divider(
                              color: Color(0xFF8B2E3E),
                              thickness: 2,
                            ),
                          ),
                        ),
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: i < _currentPage
                                ? const Color(0xFF8B2E3E)
                                : i == _currentPage
                                ? const Color(0xFFDBBEC3)
                                : Colors.white,
                            child: i < _currentPage
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ['Review', 'Payment', 'Order\nconfirm'][i],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (value) =>
                      setState(() => _currentPage = value),
                  itemBuilder: (context, index) {
                    final summary = Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          for (final row in [
                            ['MRP-', '₹999'],
                            ['Platform fee-', '₹20'],
                            ['Discounts-', '₹728'],
                            ['Total amount-', '₹291'],
                          ])
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    row[0],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    row[1],
                                    style: TextStyle(
                                      fontWeight: row[0] == 'Total amount-'
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );

                    if (index == 0) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order summary',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            productCard(
                              name: "Casual regular sleeves solid women top",
                              size: "M",
                              price: 271,
                              quantity: 1,
                              image: 'assets/images/clothes/10.jpg',
                              alignment: Alignment.topCenter,
                            ),
                            const SizedBox(height: 12),
                            summary,
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Address- ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextSpan(text: "HOME"),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Date- ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "Delivery by Wednesday, 11 Nov",
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        "Sold by- ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Text("Aluxi"),
                                          Row(
                                            children: [
                                              const SizedBox(width: 4),
                                              Text("3.2"),
                                              Icon(Icons.star_rounded),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (index == 1) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            for (final item in [
                              [Icons.credit_card, 'Credit Card'],
                              [Icons.account_balance, 'UPI'],
                              [Icons.paypal, 'Pay Pal'],
                              [Icons.local_shipping, 'Cash on delivery'],
                            ].asMap().entries)
                              GestureDetector(
                                onTap: () => setState(() => method = item.key),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFF9F2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        item.value[0] as IconData,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Text(
                                          item.value[1] as String,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        method == item.key
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
                            summary,
                          ],
                        ),
                      );
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(0xFF8B2E3E),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text('Thank you!!', style: TextStyle(fontSize: 22)),
                        SizedBox(height: 6),
                        Text(
                          'Your order has been placed successfully',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 24),
                        Text('ORDER NUMBER', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text('ORD123456', style: TextStyle(fontSize: 20)),
                        SizedBox(height: 24),
                        Text(
                          'You will recieve an email with your order details',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Color(0xFF8B2E3E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    _goToNext();
                  },
                  child: Text(
                    _currentPage < 2 ? 'CONTINUE' : 'CONTINUE SHOPPING',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
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
                height: 140,
                width: 140,
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
                    Text('Price - ₹$price', style: TextStyle(fontSize: 18)),
                    Text('Quality - $quantity', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
