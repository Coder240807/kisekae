class Summary {
  final int id;
  final String name;
  final String slug;
  final String? logoUrl;

  Summary({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
    );
  }
}

class UserSummary {
  final int id;
  final String name;
  final String email;

  UserSummary({required this.id, required this.name, required this.email});

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}

class InvitationSellerStore {
  final int id;
  final Summary store;
  final String email;
  final String status;
  final UserSummary invitedBy;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? respondedAt;

  InvitationSellerStore({
    required this.id,
    required this.store,
    required this.email,
    required this.status,
    required this.invitedBy,
    this.expiresAt,
    this.createdAt,
    this.respondedAt,
  });

  factory InvitationSellerStore.fromJson(Map<String, dynamic> json) {
    return InvitationSellerStore(
      id: json['id'] as int,
      store: Summary.fromJson(json['store'] as Map<String, dynamic>),
      email: json['email'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      invitedBy: UserSummary.fromJson(
        json['invited_by'] as Map<String, dynamic>,
      ),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      respondedAt: json['responded_at'] != null
          ? DateTime.tryParse(json['responded_at'].toString())
          : null,
    );
  }
}
