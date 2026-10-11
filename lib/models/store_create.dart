class Store {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String? logoUrl;
  final String? bannerUrl;
  final String contactEmail;
  final String contactPhone;
  final String status;
  final String myRole;
  final int memberCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  Store({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.logoUrl,
    this.bannerUrl,
    required this.contactEmail,
    required this.contactPhone,
    required this.status,
    required this.myRole,
    required this.memberCount,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      contactEmail: json['contact_email'] as String? ?? '',
      contactPhone: json['contact_phone'] as String? ?? '',
      status: json['status'] as String,
      myRole: json['my_role'] as String,
      memberCount: json['member_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      archivedAt: json['archived_at'] != null
          ? DateTime.tryParse(json['archived_at'])
          : null,
    );
  }
}

class PaginatedStoreResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Store> results;

  PaginatedStoreResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedStoreResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedStoreResponse(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results:
          (json['results'] as List<dynamic>?)
              ?.map((item) => Store.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class StoreUser {
  final int id;
  final String name;
  final String email;

  StoreUser({required this.id, required this.name, required this.email});

  factory StoreUser.fromJson(Map<String, dynamic> json) {
    return StoreUser(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}

class StoreMember {
  final int id;
  final StoreUser user;
  final String role;
  final DateTime createdAt;

  StoreMember({
    required this.id,
    required this.user,
    required this.role,
    required this.createdAt,
  });

  factory StoreMember.fromJson(Map<String, dynamic> json) {
    return StoreMember(
      id: json['id'] as int,
      user: StoreUser.fromJson(json['user'] as Map<String, dynamic>),
      role: json['role'] as String? ?? 'MEMBER',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
