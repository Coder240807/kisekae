class UserModel {
  final int id;
  final String name;
  final String email;
  final bool isSeller;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isSeller,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      isSeller: json['is_seller'] as bool? ?? false,
    );
  }
}
