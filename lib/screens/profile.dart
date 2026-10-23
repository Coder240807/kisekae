import "package:flutter/material.dart";
import "package:kisekae/screens/addresses.dart";
import "package:kisekae/screens/onboarding_screen.dart";
import "package:kisekae/screens/personal_details.dart";
import "package:kisekae/screens/terms_conditions.dart";
import "package:kisekae/screens/wishlist_screen.dart";
import "package:kisekae/services/email_auth.dart";

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    try {
      final response = await EmailAuth().logout();
      if (!mounted) return;
      if (response.success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          (route) => false,
        );
      }
      if (response.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.success ? Colors.green : Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
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
          "Profile",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.notifications_outlined,
              size: 28,
              color: Color(0xFF8B2E3E),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: iconChip(Icons.inventory, "Your orders", onTap: () {}),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: iconChip(
                    Icons.favorite,
                    "Wishlist",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WishlistScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: iconChip(
                    Icons.checkroom,
                    "Saved AR looks",
                    iconSize: 24,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: iconChip(
                    Icons.card_giftcard,
                    "Gift cards",
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Profile Settings",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 32),
            actionChip(
              Icons.person_outline,
              "Personal information",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PersonalInformationScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            actionChip(
              Icons.person_outline,
              "Addresses",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddressesScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            actionChip(
              Icons.notifications_none,
              "Notification settings",
              onTap: () {},
            ),
            const SizedBox(height: 16),
            actionChip(
              Icons.description_outlined,
              "Terms & conditions",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            actionChip(
              Icons.headset_mic_outlined,
              "Help & support",
              onTap: () {},
            ),
            const SizedBox(height: 16),
            actionChip(
              Icons.meeting_room_outlined,
              "Logout",
              isLoading: _isLoggingOut,
              onTap: _isLoggingOut ? null : _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget iconChip(
    IconData icon,
    String label, {
    double iconSize = 18,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: const Color(0xFFFFF9F2),
          border: Border.all(color: const Color(0xFFB78876)),
        ),
        child: Row(
          children: [
            Icon(icon, size: iconSize, color: const Color(0xFF8B2E3E)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8B2E3E),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget actionChip(
    IconData icon,
    String label, {
    double iconSize = 24,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFFFFF9F2),
            border: Border.all(color: const Color(0xFFB78876)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: iconSize, color: const Color(0xFF8B2E3E)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF8B2E3E),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF8B2E3E),
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward,
                  size: iconSize,
                  color: const Color(0xFF8B2E3E),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
