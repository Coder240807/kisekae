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
