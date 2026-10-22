class UserProfile {
  final int id;
  final String name;
  final String email;
  final bool isEmailVerified;
  final bool isSeller;
  final DateTime dateJoined;
  final int addressesCount;
  final int wishlistItemsCount;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.isEmailVerified,
    required this.isSeller,
    required this.dateJoined,
    required this.addressesCount,
    required this.wishlistItemsCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isSeller: json['is_seller'] as bool? ?? false,
      dateJoined:
          DateTime.tryParse(json['date_joined'] as String? ?? '') ??
          DateTime.now(),
      addressesCount: json['addresses_count'] as int? ?? 0,
      wishlistItemsCount: json['wishlist_items_count'] as int? ?? 0,
    );
  }
}
