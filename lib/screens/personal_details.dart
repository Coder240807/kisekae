import 'package:flutter/material.dart';
import 'package:kisekae/models/userprofile.dart';
import 'package:kisekae/screens/onboarding_screen.dart';
import 'package:kisekae/services/profile_details.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final ProfileDetails _userRepository = ProfileDetails();
  final TextEditingController _nameController = TextEditingController();

  bool _isLoading = true;
  bool _isEditingName = false;
  bool _isSavingName = false;
  String? _errorMessage;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _userRepository.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _nameController.text = profile.name;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == _profile?.name) {
      setState(() => _isEditingName = false);
      return;
    }

    setState(() => _isSavingName = true);

    try {
      final updatedProfile = await _userRepository.updateProfileName(newName);
      if (!mounted) return;
      setState(() {
        _profile = updatedProfile;
        _nameController.text = updatedProfile.name;
        _isEditingName = false;
        _isSavingName = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSavingName = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  // Deactivation Confirmation Dialog
  Future<void> _showDeactivateConfirmationDialog() async {
    bool isDeactivating = false;

    await showDialog(
      context: context,
      barrierDismissible: !isDeactivating,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFF9F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Color(0xFFB78876)),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Deactivate Account",
                    style: TextStyle(
                      color: Color(0xFF8B2E3E),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: const Text(
                "Are you sure you confirm that you want to deactivate your account? This action will log you out and deactivate your profile.",
                style: TextStyle(
                  color: Color(0xFF8B2E3E),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isDeactivating
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: isDeactivating
                      ? null
                      : () async {
                          setDialogState(() => isDeactivating = true);

                          try {
                            final message = await _userRepository
                                .deleteAccount();

                            if (!mounted) return;
                            Navigator.pop(dialogContext);

                            // Clear navigation stack and redirect to onboarding screen
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OnboardingScreen(),
                              ),
                              (route) => false,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            setDialogState(() => isDeactivating = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: isDeactivating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Confirm",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
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
          "Personal Information",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: _showDeactivateConfirmationDialog,
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 26,
                color: Colors.red,
              ),
              tooltip: "Deactivate Account",
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B2E3E)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Color(0xFF8B2E3E),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF8B2E3E),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchUserProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B2E3E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Retry",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final profile = _profile!;

    return RefreshIndicator(
      color: const Color(0xFF8B2E3E),
      onRefresh: _fetchUserProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Avatar Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: const Color(0xFFFFF9F2),
                border: Border.all(color: const Color(0xFFB78876)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFF8B2E3E),
                    child: Text(
                      profile.name.isNotEmpty
                          ? profile.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B2E3E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF8B2E3E).withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Inline Editable Full Name Tile
            _buildNameTile(profile.name),

            const SizedBox(height: 12),
            _detailTile(
              icon: Icons.email_outlined,
              label: "Email Address",
              value: profile.email,
              trailingWidget: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: profile.isEmailVerified
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: profile.isEmailVerified
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                child: Text(
                  profile.isEmailVerified ? "Verified" : "Unverified",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: profile.isEmailVerified
                        ? Colors.green.shade800
                        : Colors.orange.shade800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _detailTile(
              icon: Icons.storefront_outlined,
              label: "Account Type",
              value: profile.isSeller ? "Seller Account" : "Buyer Account",
            ),
            const SizedBox(height: 12),
            _detailTile(
              icon: Icons.calendar_today_outlined,
              label: "Member Since",
              value:
                  "${profile.dateJoined.day}/${profile.dateJoined.month}/${profile.dateJoined.year}",
            ),
            const SizedBox(height: 12),
            _detailTile(
              icon: Icons.location_on_outlined,
              label: "Saved Addresses",
              value: "${profile.addressesCount} Saved",
            ),
            const SizedBox(height: 12),
            _detailTile(
              icon: Icons.favorite_border,
              label: "Wishlist Items",
              value: "${profile.wishlistItemsCount} Items",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameTile(String currentName) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFFFFF9F2),
        border: Border.all(
          color: _isEditingName
              ? const Color(0xFF8B2E3E)
              : const Color(0xFFB78876),
          width: _isEditingName ? 2 : 1,
        ),
      ),
      child: _isEditingName
          ? Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 22,
                  color: Color(0xFF8B2E3E),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    autofocus: true,
                    enabled: !_isSavingName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B2E3E),
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: "Enter full name",
                    ),
                  ),
                ),
                if (_isSavingName)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF8B2E3E),
                    ),
                  )
                else ...[
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    onPressed: () {
                      setState(() {
                        _isEditingName = false;
                        _nameController.text = currentName;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.check,
                      color: Color(0xFF8B2E3E),
                      size: 22,
                    ),
                    onPressed: _saveName,
                  ),
                ],
              ],
            )
          : Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 22,
                  color: Color(0xFF8B2E3E),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Full Name",
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF8B2E3E)
                              .withValues(alpha: 0.65),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B2E3E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditingName = true;
                      _nameController.text = currentName;
                    });
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Color(0xFF8B2E3E),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _detailTile({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailingWidget,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFFFFF9F2),
        border: Border.all(color: const Color(0xFFB78876)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF8B2E3E)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF8B2E3E).withValues(alpha: 0.65),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B2E3E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailingWidget != null) trailingWidget,
        ],
      ),
    );
  }
}
