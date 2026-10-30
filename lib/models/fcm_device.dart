class FcmDevice {
  final int id;
  final String registrationToken;
  final String deviceType;
  final String deviceName;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  const FcmDevice({
    required this.id,
    required this.registrationToken,
    required this.deviceType,
    required this.deviceName,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FcmDevice.fromJson(Map<String, dynamic> json) {
    return FcmDevice(
      id: json['id'] as int? ?? 0,
      registrationToken: json['registration_token'] as String? ?? '',
      deviceType: json['device_type'] as String? ?? '',
      deviceName: json['device_name'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}
