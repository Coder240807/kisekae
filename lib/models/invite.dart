class SellerInvitation {
  final int id;
  final int storeId;
  final String storeName;
  final String storeSlug;
  final String? storeLogoUrl;
  final String email;
  final String status;
  final String invitedByName;
  final String invitedByEmail;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime? respondedAt;

  SellerInvitation({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.storeSlug,
    this.storeLogoUrl,
    required this.email,
    required this.status,
    required this.invitedByName,
    required this.invitedByEmail,
    this.expiresAt,
    required this.createdAt,
    this.respondedAt,
  });

  factory SellerInvitation.fromJson(Map<String, dynamic> json) {
    final store = json['store'] as Map<String, dynamic>? ?? {};
    final invitedBy = json['invited_by'] as Map<String, dynamic>? ?? {};
    final logo = store['logo_url'] as String?;

    return SellerInvitation(
      id: json['id'] as int? ?? 0,
      storeId: store['id'] as int? ?? 0,
      storeName: store['name'] as String? ?? '',
      storeSlug: store['slug'] as String? ?? '',
      storeLogoUrl: (logo == null || logo.isEmpty) ? null : logo,
      email: json['email'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      invitedByName: invitedBy['name'] as String? ?? '',
      invitedByEmail: invitedBy['email'] as String? ?? '',
      expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      respondedAt: DateTime.tryParse(json['responded_at']?.toString() ?? ''),
    );
  }
}
