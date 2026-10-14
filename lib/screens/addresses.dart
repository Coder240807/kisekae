import "package:flutter/material.dart";
import "package:kisekae/screens/new_address.dart";

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

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
          "Addresses",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Saved Addresses",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    addressCard(
                      title: 'Home',
                      name: 'Chetanya Saxena',
                      society: 'ABC Society',
                      phone: '78965XXXXX',
                      onEdit: () {},
                      onDelete: () {},
                    ),
                    const SizedBox(height: 16),
                    addressCard(
                      title: 'Hostel',
                      name: 'Chetanya Saxena',
                      society: 'Girls hostel',
                      phone: '78965XXXXX',
                      isSelected: false,
                      onEdit: () {},
                      onDelete: () {},
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NewAddressScreen()),
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
                  "ADD NEW ADDRESS",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget addressCard({
    required String title,
    required String name,
    required String society,
    required String phone,
    bool isSelected = true,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.edit),
            ],
          ),
          infoRow(Icons.person, name),
          infoRow(Icons.phone, society),
          Row(
            children: [
              Expanded(child: infoRow(Icons.location_on, phone)),
              const Icon(Icons.delete),
            ],
          ),
        ],
      ),
    );
  }

  Widget infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 40),
          Text(text, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
