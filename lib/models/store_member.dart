class StoreMember {
  final int id;
  final int userId;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  StoreMember({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  bool get isOwner => role.toUpperCase() == 'OWNER';
  bool get isManager => role.toUpperCase() == 'MANAGER';

  String get displayName => name.trim().isNotEmpty ? name.trim() : email;

  String get roleLabel {
    if (role.isEmpty) return '';
    final lower = role.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }

  factory StoreMember.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};

    return StoreMember(
      id: json['id'] as int? ?? 0,
      userId: user['id'] as int? ?? 0,
      name: user['name'] as String? ?? '',
      email: user['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
