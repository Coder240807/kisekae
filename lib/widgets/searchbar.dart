import 'package:flutter/material.dart';
import 'package:kisekae/screens/search.dart';

class KisekaeSearchBar extends StatelessWidget {
  final VoidCallback? onTap;

  const KisekaeSearchBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
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
}
