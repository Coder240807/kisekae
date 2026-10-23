import 'package:dio/dio.dart';
import 'package:kisekae/models/product_review.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class ReviewService extends BaseRepository {
  final Dio _dio;

  ReviewService([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<PaginatedReviewsResponse> getProductReviews(
    int productPk, {
    String? letter,
    int? minRating,
    int? rating,
    bool? verifiedOnly,
    String? ordering,
    int page = 1,
    int pageSize = 10,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final queryParams = <String, dynamic>{
        if (letter != null && letter.isNotEmpty) 'letter': letter,
        if (minRating != null) 'min_rating': minRating,
        if (rating != null) 'rating': rating,
        if (verifiedOnly != null) 'verified_only': verifiedOnly,
        if (ordering != null && ordering.isNotEmpty) 'ordering': ordering,
        'page': page,
        'page_size': pageSize,
      };

      final response = await _dio.get(
        '/products/$productPk/reviews/',
        queryParameters: queryParams,
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final reviewData = Map<String, dynamic>.from(body['data'] as Map);

      return PaginatedReviewsResponse.fromJson(reviewData);
    });
  }

  Future<ProductReview> postReview(
    int productPk, {
    required int rating,
    required String title,
    required String description,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final payload = {
        'rating': rating,
        'title': title,
        'description': description,
      };

      final response = await _dio.post(
        '/products/$productPk/reviews/',
        data: payload,
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final reviewData = Map<String, dynamic>.from(body['data'] as Map);

      return ProductReview.fromJson(reviewData);
    });
  }

  Future<ProductReview> updateReview(
    int reviewPk, {
    required int rating,
    required String title,
    required String description,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final payload = {
        'rating': rating,
        'title': title,
        'description': description,
      };

      final response = await _dio.put(
        '/reviews/$reviewPk/',
        data: payload,
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final reviewData = Map<String, dynamic>.from(body['data'] as Map);

      return ProductReview.fromJson(reviewData);
    });
  }

  Future<String> deleteReview(int reviewPk, {CancelToken? cancelToken}) async {
    return execute(() async {
      final response = await _dio.delete(
        '/reviews/$reviewPk/',
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      return body['message'] as String? ?? 'Review deleted successfully';
    });
  }
}
