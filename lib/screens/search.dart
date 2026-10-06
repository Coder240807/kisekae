import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

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
        title: Text("Search", style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {},
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Search',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Clear All',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              children: [
                _inputChip("Jacket"),
                _inputChip("Traditional attire"),
                _inputChip("Hoodies"),
                _inputChip("Black top"),
                _inputChip("Oversized t-shirt"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputChip(String label) {
    return InputChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      deleteIcon: Icon(Icons.clear),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFFDBBEC3),
      side: BorderSide.none,
      padding: const EdgeInsets.all(12),
      onDeleted: () {},
    );
  }
}
