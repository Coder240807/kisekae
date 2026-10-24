import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:kisekae/models/api_exception.dart';
import 'package:kisekae/models/ar_model.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class TryOnResult {
  final TryOnRequest? request;
  final String? errorMessage;
  final bool cancelled;

  const TryOnResult._({
    this.request,
    this.errorMessage,
    this.cancelled = false,
  });

  const TryOnResult.success(TryOnRequest r) : this._(request: r);
  const TryOnResult.failure(String message) : this._(errorMessage: message);
  const TryOnResult.cancelled() : this._(cancelled: true);

  bool get isSuccess => request != null;
  String? get resultImageUrl => request?.resultImageUrl;
}

class TryOnGenerationService extends BaseRepository {
  static const int maxImageBytes = 7 * 1024 * 1024;

  final Dio _dio;

  TryOnGenerationService([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Map<String, dynamic>? _dataMap(dynamic body) {
    if (body is Map) {
      final inner = body['data'];
      if (inner is Map) return Map<String, dynamic>.from(inner);
      return Map<String, dynamic>.from(body);
    }
    return null;
  }

  MediaType _mediaTypeFor(String path) {
    switch (path.split('.').last.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        throw ArgumentError('Photo must be JPEG, PNG or WebP.');
    }
  }

  Future<TryOnQueued> generate({
    required File personImage,
    int? productId,
    int? comboId,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onSendProgress,
  }) {
    return execute(() async {
      if ((productId == null) == (comboId == null)) {
        throw ArgumentError('Provide exactly one of productId or comboId.');
      }
      if (await personImage.length() > maxImageBytes) {
        throw ArgumentError('Photo exceeds the 7MB limit.');
      }

      final formData = FormData.fromMap({
        'person_image': await MultipartFile.fromFile(
          personImage.path,
          filename: personImage.path.split(Platform.pathSeparator).last,
          contentType: _mediaTypeFor(personImage.path),
        ),
        if (productId != null) 'product_id': productId,
        if (comboId != null) 'combo_id': comboId,
      });

      final res = await _dio.post(
        '/tryon/generate/',
        data: formData,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = _dataMap(res.data);
      if (data == null) throw const FormatException('Invalid response');
      return TryOnQueued.fromJson(data);
    });
  }

  Future<TryOnRequest> getRequest(
    String requestId, {
    CancelToken? cancelToken,
  }) {
    return execute(() async {
      final res = await _dio.get(
        '/tryon/requests/$requestId/',
        cancelToken: cancelToken,
      );

      final data = _dataMap(res.data);
      if (data == null) throw const FormatException('Invalid response');
      return TryOnRequest.fromJson(data);
    });
  }

  Future<List<TryOnRequest>> getHistory({CancelToken? cancelToken}) {
    return execute(() async {
      final res = await _dio.get('/tryon/history/', cancelToken: cancelToken);

      final body = res.data;
      if (body is! Map) return <TryOnRequest>[];

      final raw = body['data'];
      if (raw is! List) return <TryOnRequest>[];

      final items = <TryOnRequest>[];
      for (final item in raw) {
        if (item is! Map) continue;
        try {
          items.add(TryOnRequest.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {}
      }
      return items;
    });
  }

  Stream<TryOnRequest> pollRequest(
    String requestId, {
    Duration interval = const Duration(seconds: 2),
    Duration maxInterval = const Duration(seconds: 5),
    Duration maxWait = const Duration(minutes: 2),
    int maxConsecutiveErrors = 4,
    CancelToken? cancelToken,
  }) async* {
    final deadline = DateTime.now().add(maxWait);
    var delay = interval;
    var consecutiveErrors = 0;

    while (true) {
      TryOnRequest? current;
      try {
        current = await getRequest(requestId, cancelToken: cancelToken);
        consecutiveErrors = 0;
      } catch (e) {
        if (e is DioException && CancelToken.isCancel(e)) rethrow;
        if (cancelToken?.isCancelled ?? false) rethrow;
        consecutiveErrors++;
        if (consecutiveErrors >= maxConsecutiveErrors) rethrow;
      }

      if (current != null) {
        yield current;
        if (current.isTerminal) return;
      }

      if (DateTime.now().isAfter(deadline)) {
        throw TimeoutException('Try-on is taking too long. Please try again.');
      }

      await Future.delayed(delay);
      final next = Duration(
        milliseconds: (delay.inMilliseconds * 1.25).round(),
      );
      delay = next > maxInterval ? maxInterval : next;
    }
  }

  Future<TryOnRequest> generateAndWait({
    required File personImage,
    int? productId,
    int? comboId,
    CancelToken? cancelToken,
    void Function(TryOnRequest)? onProgress,
  }) async {
    final queued = await generate(
      personImage: personImage,
      productId: productId,
      comboId: comboId,
      cancelToken: cancelToken,
    );

    TryOnRequest? last;
    await for (final update in pollRequest(
      queued.requestId,
      cancelToken: cancelToken,
    )) {
      last = update;
      onProgress?.call(update);
    }

    if (last == null || last.isFailed) {
      throw Exception(last?.errorMessage ?? 'Try-on generation failed.');
    }
    return last;
  }

  Future<TryOnResult> safeGenerateAndWait({
    required File personImage,
    int? productId,
    int? comboId,
    CancelToken? cancelToken,
    void Function(TryOnRequest)? onProgress,
  }) async {
    try {
      if (!await personImage.exists()) {
        return const TryOnResult.failure(
          'We could not find that photo. Please pick it again.',
        );
      }

      final result = await generateAndWait(
        personImage: personImage,
        productId: productId,
        comboId: comboId,
        cancelToken: cancelToken,
        onProgress: (r) {
          try {
            onProgress?.call(r);
          } catch (_) {}
        },
      );

      final url = result.resultImageUrl;
      if (url == null || url.isEmpty) {
        return const TryOnResult.failure(
          'The try-on finished but no image came back. Please try again.',
        );
      }
      return TryOnResult.success(result);
    } on Object catch (e) {
      return _toFailure(e);
    }
  }

  TryOnResult _toFailure(Object e) {
    if (e is DioException && CancelToken.isCancel(e)) {
      return const TryOnResult.cancelled();
    }
    if (e is ApiException) return TryOnResult.failure(e.message);
    if (e is TimeoutException) {
      return const TryOnResult.failure(
        'Try-on is taking too long. Please try again.',
      );
    }
    if (e is ArgumentError) {
      return TryOnResult.failure(e.message?.toString() ?? 'Invalid request.');
    }
    if (e is FileSystemException) {
      return const TryOnResult.failure(
        'We could not read that photo. Please pick another one.',
      );
    }
    if (e is DioException) {
      return const TryOnResult.failure(
        'Network problem. Check your connection and try again.',
      );
    }
    if (e is FormatException) {
      return const TryOnResult.failure(
        'Unexpected response from the server. Please try again.',
      );
    }
    if (e is Exception) {
      final text = e.toString().replaceFirst('Exception: ', '').trim();
      if (text.isNotEmpty) return TryOnResult.failure(text);
    }
    return const TryOnResult.failure('Something went wrong. Please try again.');
  }
}
