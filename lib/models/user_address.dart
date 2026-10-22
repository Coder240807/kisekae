class CustomerAddress {
  final int id;
  final String title;
  final String recipientName;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String pinCode;
  final String country;
  final String? latitude;
  final String? longitude;
  final bool isDefault;
  final DateTime dateCreated;
  final DateTime dateUpdated;

  const CustomerAddress({
    required this.id,
    required this.title,
    required this.recipientName,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.pinCode,
    required this.country,
    this.latitude,
    this.longitude,
    required this.isDefault,
    required this.dateCreated,
    required this.dateUpdated,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      recipientName: json['recipient_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      addressLine1: json['address_line_1'] as String? ?? '',
      addressLine2: json['address_line_2'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      pinCode: json['pin_code'] as String? ?? '',
      country: json['country'] as String? ?? '',
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      isDefault: json['is_default'] as bool? ?? false,
      dateCreated:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      dateUpdated:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
