int? _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

String? _asString(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

DateTime? _asDate(dynamic v) =>
    v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;

enum TryOnStatus { pending, processing, ready, failed, unknown }

TryOnStatus parseTryOnStatus(String? raw) {
  switch (raw?.toUpperCase()) {
    case 'PENDING':
      return TryOnStatus.pending;
    case 'PROCESSING':
      return TryOnStatus.processing;
    case 'READY':
      return TryOnStatus.ready;
    case 'FAILED':
      return TryOnStatus.failed;
    default:
      return TryOnStatus.unknown;
  }
}

class TryOnQueued {
  final String requestId;
  final String status;

  const TryOnQueued({required this.requestId, required this.status});

  factory TryOnQueued.fromJson(Map<String, dynamic> json) => TryOnQueued(
    requestId: json['request_id']?.toString() ?? '',
    status: json['status']?.toString() ?? 'PENDING',
  );
}

class TryOnRequest {
  final String id;
  final String statusRaw;
  final TryOnStatus status;
  final String? angle;
  final int? productId;
  final String? productName;
  final int? comboId;
  final String? comboName;
  final String? personImageUrl;
  final String? resultImageUrl;
  final String? errorMessage;
  final DateTime? createdAt;
  final DateTime? completedAt;

  const TryOnRequest({
    required this.id,
    required this.statusRaw,
    required this.status,
    this.angle,
    this.productId,
    this.productName,
    this.comboId,
    this.comboName,
    this.personImageUrl,
    this.resultImageUrl,
    this.errorMessage,
    this.createdAt,
    this.completedAt,
  });

  bool get isReady => status == TryOnStatus.ready;
  bool get isFailed => status == TryOnStatus.failed;
  bool get isTerminal => isReady || isFailed;

  factory TryOnRequest.fromJson(Map<String, dynamic> json) {
    return TryOnRequest(
      id: json['id']?.toString() ?? '',
      statusRaw: json['status']?.toString() ?? '',
      status: parseTryOnStatus(json['status']?.toString()),
      angle: _asString(json['angle']),
      productId: _asInt(json['product_id']),
      productName: _asString(json['product_name']),
      comboId: _asInt(json['combo_id']),
      comboName: _asString(json['combo_name']),
      personImageUrl: _asString(json['person_image_url']),
      resultImageUrl: _asString(json['result_image_url']),
      errorMessage: _asString(json['error_message']),
      createdAt: _asDate(json['created_at']),
      completedAt: _asDate(json['completed_at']),
    );
  }
}
