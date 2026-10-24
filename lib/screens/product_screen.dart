import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kisekae/models/api_exception.dart';
import 'package:kisekae/models/product_detail.dart';
import 'package:kisekae/models/product_review.dart';
import 'package:kisekae/models/user_address.dart';
import 'package:kisekae/models/wishlist.dart';
import 'package:kisekae/screens/ar_screen.dart';

import 'package:kisekae/screens/cart.dart';
import 'package:kisekae/services/buyer_address.dart';
import 'package:kisekae/services/buyer_product.dart';

import 'package:kisekae/services/cart_service.dart';
import 'package:kisekae/services/profile_details.dart';
import 'package:kisekae/services/reviews_service.dart';
import 'package:kisekae/services/wishlist_service.dart';
import 'package:kisekae/widgets/add_to_combo.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final Product _productService = Product();
  final WishlistService _wishlistService = WishlistService();
  final CartService _cartService = CartService();
  final AddressService _addressService = AddressService();
  final ReviewService _reviewService = ReviewService();
  final ProfileDetails _profileService = ProfileDetails();

  CancelToken? _cancelToken;
  ProductDetail? _product;
  CustomerAddress? _selectedAddress;
  int? _currentUserId;
  PaginatedReviewsResponse? _reviewsData;
  final List<ProductReview> _apiReviews = [];
  int _reviewPage = 1;
  bool _hasMoreReviews = false;
  bool _isLoadingMoreReviews = false;

  bool _isLoading = true;
  bool _isWishlisted = false;
  bool _isUpdatingWishlist = false;
  bool _isAddingToCart = false;

  int _selectedImageIndex = 0;
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadCurrentUserId();
  }

  @override
  void dispose() {
    _cancelToken?.cancel("ProductDetailsScreen disposed");
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    _cancelToken = CancelToken();
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _productService.getProductDetail(
          widget.productId,
          cancelToken: _cancelToken,
        ),
        _addressService
            .getAddresses(cancelToken: _cancelToken)
            .catchError((_) => <CustomerAddress>[]),
        _wishlistService.getWishlistItems().catchError((_) => <WishlistItem>[]),
        _reviewService
            .getProductReviews(widget.productId, cancelToken: _cancelToken)
            .then<PaginatedReviewsResponse?>((value) => value)
            .catchError((_) => null),
      ]);

      final detail = results[0] as ProductDetail;
      final addresses = results[1] as List<CustomerAddress>;
      final wishlist = results[2] as List<WishlistItem>;
      final reviewsData = results[3] as PaginatedReviewsResponse?;
      final isWishlisted = wishlist.any((item) => item.product.id == detail.id);

      CustomerAddress? defaultAddr;
      if (addresses.isNotEmpty) {
        defaultAddr = addresses.firstWhere(
          (addr) => addr.isDefault,
          orElse: () => addresses.first,
        );
      }

      if (mounted) {
        setState(() {
          _product = detail;
          _selectedAddress = defaultAddr;
          _isWishlisted = isWishlisted;
          _reviewsData = reviewsData;
          _apiReviews
            ..clear()
            ..addAll(reviewsData?.results ?? const <ProductReview>[]);
          _reviewPage = 1;
          _hasMoreReviews = reviewsData?.next != null;
          _isLoading = false;
          if (detail.availableSizes.isNotEmpty) {
            _selectedSize = detail.availableSizes.first;
          }
        });
      }
    } catch (e) {
      if (!mounted || (e is DioException && CancelToken.isCancel(e))) return;
      setState(() => _isLoading = false);
      final message = e is ApiException
          ? e.message
          : 'Failed to load product details';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _loadMoreReviews() async {
    if (_isLoadingMoreReviews || !_hasMoreReviews) return;
    setState(() => _isLoadingMoreReviews = true);

    try {
      final nextPage = _reviewPage + 1;
      final response = await _reviewService.getProductReviews(
        widget.productId,
        page: nextPage,
        cancelToken: _cancelToken,
      );
      if (!mounted) return;
      setState(() {
        final seenIds = _apiReviews.map((review) => review.id).toSet();
        _apiReviews.addAll(response.results.where((r) => seenIds.add(r.id)));
        _reviewPage = nextPage;
        _hasMoreReviews = response.next != null;
      });
    } catch (e) {
      if (!mounted || (e is DioException && CancelToken.isCancel(e))) return;
      final message = e is ApiException
          ? e.message
          : 'Could not load more reviews';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isLoadingMoreReviews = false);
    }
  }

  String _formatAddressDisplay(CustomerAddress? address) {
    if (address == null) return "No address added";

    final parts = [
      if (address.addressLine1.isNotEmpty) address.addressLine1,
      if (address.addressLine2.isNotEmpty) address.addressLine2,
      if (address.city.isNotEmpty) address.city,
      if (address.pinCode.isNotEmpty)
        address.pinCode
      else if (address.postalCode.isNotEmpty)
        address.postalCode,
    ];

    return parts.join(", ");
  }

  String _formatPrice(String? value) {
    final number = double.tryParse(value ?? '');
    if (number == null) return value ?? '';
    return number == number.roundToDouble()
        ? number.toInt().toString()
        : number.toStringAsFixed(2);
  }

  String _currencySymbol(String currency) =>
      currency.toUpperCase() == 'INR' ? '₹' : '$currency ';

  Widget _imagePlaceholder() => const Center(
    child: Icon(
      Icons.image_not_supported_outlined,
      size: 48,
      color: Colors.black38,
    ),
  );

  Future<void> _toggleWishlist() async {
    final product = _product;
    if (product == null || _isUpdatingWishlist) return;

    final wasWishlisted = _isWishlisted;
    setState(() {
      _isWishlisted = !wasWishlisted;
      _isUpdatingWishlist = true;
    });

    try {
      String message;
      if (wasWishlisted) {
        message = await _wishlistService.removeWishlistItem(product.id);
      } else {
        await _wishlistService.addToWishlist(productId: product.id);
        message = 'Added to Wishlist';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isWishlisted = wasWishlisted);
      final message = e is ApiException
          ? e.message
          : 'Could not update wishlist';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isUpdatingWishlist = false);
    }
  }

  Future<void> _addToCart({bool openCart = true}) async {
    final product = _product;
    if (product == null || _isAddingToCart) return;

    if (product.availableSizes.isNotEmpty && _selectedSize == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please select a size")));
      return;
    }

    setState(() => _isAddingToCart = true);

    try {
      await _cartService.addToCart(
        productId: product.id,
        size: _selectedSize ?? "",
        quantity: 1,
      );
      if (!mounted) return;
      if (openCart) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const CartScreen()));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Added to cart")));
      }
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException ? e.message : 'Could not add to cart';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final profile = await _profileService.getProfile();
      if (!mounted) return;
      setState(() => _currentUserId = profile.id);
    } catch (_) {}
  }

  Future<void> _confirmDeleteReview(ProductReview review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete review?"),
        content: const Text("This can't be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final message = await _reviewService.deleteReview(
        review.id,
        cancelToken: _cancelToken,
      );
      if (!mounted) return;
      setState(() => _apiReviews.removeWhere((r) => r.id == review.id));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      _refreshReviewSummary();
    } catch (e) {
      if (!mounted || (e is DioException && CancelToken.isCancel(e))) return;
      final message = e is ApiException ? e.message : 'Could not delete review';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _refreshReviewSummary() async {
    try {
      final data = await _reviewService.getProductReviews(
        widget.productId,
        cancelToken: _cancelToken,
      );
      if (!mounted) return;
      setState(() => _reviewsData = data);
    } catch (_) {}
  }

  void _showAddReviewBottomSheet({ProductReview? existing}) {
    final editingId = existing?.id;
    final isEditing = editingId != null;
    final messenger = ScaffoldMessenger.of(context);
    final titleController = TextEditingController(text: existing?.title);
    final reviewController = TextEditingController(text: existing?.description);
    int selectedRating = existing?.rating ?? 5;
    bool isSubmitting = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFF8F0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> submit() async {
              final title = titleController.text.trim();
              final text = reviewController.text.trim();
              if (title.isEmpty || text.isEmpty) {
                setModalState(
                  () => errorMessage = "Please add a title and your review",
                );
                return;
              }

              setModalState(() {
                isSubmitting = true;
                errorMessage = null;
              });

              try {
                final posted = isEditing
                    ? await _reviewService.updateReview(
                        editingId,
                        rating: selectedRating,
                        title: title,
                        description: text,
                        cancelToken: _cancelToken,
                      )
                    : await _reviewService.postReview(
                        widget.productId,
                        rating: selectedRating,
                        title: title,
                        description: text,
                        cancelToken: _cancelToken,
                      );
                if (!mounted) return;
                setState(() {
                  final index = _apiReviews.indexWhere(
                    (r) => r.id == posted.id,
                  );
                  if (isEditing && index != -1) {
                    _apiReviews[index] = posted;
                  } else {
                    _apiReviews.removeWhere((r) => r.id == posted.id);
                    _apiReviews.insert(0, posted);
                  }
                });
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing
                          ? "Review updated successfully!"
                          : "Review added successfully!",
                    ),
                  ),
                );
                _refreshReviewSummary();
              } catch (e) {
                if (!ctx.mounted) return;
                setModalState(() {
                  isSubmitting = false;
                  errorMessage = e is ApiException
                      ? e.message
                      : "Could not submit your review";
                });
              }
            }

            InputDecoration fieldDecoration(String hint) => InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFD3C7B8)),
              ),
            );

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? "Edit Review" : "Write a Review",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                setModalState(() => selectedRating = starIndex);
                              },
                        icon: Icon(
                          starIndex <= selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    enabled: !isSubmitting,
                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                    decoration: fieldDecoration("Title"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reviewController,
                    enabled: !isSubmitting,
                    maxLines: 3,
                    inputFormatters: [LengthLimitingTextInputFormatter(500)],
                    decoration: fieldDecoration(
                      "Share your experience with this product...",
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF8B2E3E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: isSubmitting ? null : submit,
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEditing ? "Update Review" : "Submit Review",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFEFE8DF);
    const primaryColor = Color(0xFF8B2E3E);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    if (_product == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(backgroundColor: backgroundColor),
        body: const Center(child: Text("Product not found")),
      );
    }

    final product = _product!;
    final averageRating =
        _reviewsData?.ratingSummary.averageRating ?? product.averageRating;
    final reviewCount =
        _reviewsData?.ratingSummary.totalReviews ?? product.reviewCount;
    final apiReviews = _apiReviews;
    final symbol = _currencySymbol(product.currency);
    final price = double.tryParse(product.price);
    final compare = double.tryParse(product.compareAtPrice ?? '');
    final discountPercent =
        (price != null && compare != null && compare > price)
        ? (((compare - price) / compare) * 100).round()
        : null;

    final imageList =
        (product.images.isNotEmpty
                ? product.images.map((e) => e.imageUrl)
                : [product.imageUrl ?? product.thumbnail ?? ''])
            .where((url) => url.isNotEmpty)
            .toList();
    final sizes = product.availableSizes;
    final description = product.description?.trim() ?? '';
    final addressTitle = _selectedAddress?.title.trim() ?? '';
    final addressText = _formatAddressDisplay(_selectedAddress);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                Stack(
                  children: [
                    Container(
                      height: 380,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: const Color(0xFFE0D8CD),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: PageView.builder(
                        itemCount: imageList.isEmpty ? 1 : imageList.length,
                        onPageChanged: (index) {
                          setState(() => _selectedImageIndex = index);
                        },
                        itemBuilder: (context, index) {
                          if (imageList.isEmpty) return _imagePlaceholder();
                          return Image.network(
                            imageList[index],
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          );
                        },
                      ),
                    ),

                    Positioned(
                      top: 12,
                      left: 12,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        children: [
                          _circleIconButton(
                            customChild: Image.asset(
                              'assets/icons/cart.png',
                              width: 18,
                              height: 18,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.shopping_bag_outlined,
                                size: 18,
                                color: Colors.black,
                              ),
                            ),

                            onTap: () => _addToCart(openCart: false),
                          ),
                          const SizedBox(width: 8),
                          _circleIconButton(
                            customChild: Image.asset(
                              _isWishlisted
                                  ? 'assets/icons/wishlist.png'
                                  : 'assets/icons/wishlist1.png',
                              width: 18,
                              height: 18,
                              errorBuilder: (_, __, ___) => Icon(
                                _isWishlisted
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: primaryColor,
                                size: 18,
                              ),
                            ),
                            onTap: _toggleWishlist,
                          ),
                          const SizedBox(width: 8),
                          _circleIconButton(
                            customChild: Image.asset(
                              'assets/icons/share.png',
                              width: 18,
                              height: 18,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.share_outlined,
                                size: 18,
                                color: Colors.black,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    if (imageList.length > 1)
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            imageList.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _selectedImageIndex == index ? 10 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: _selectedImageIndex == index
                                    ? primaryColor
                                    : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                if (product.storeName.isNotEmpty)
                  Text(
                    product.storeName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),

                const SizedBox(height: 16),

                if (sizes.isNotEmpty) ...[
                  const Text(
                    "Select Size",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: sizes.map((sz) {
                      final isSelected = _selectedSize == sz;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSize = sz),
                        child: Container(
                          width: 44,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFD3A4AC)
                                : const Color(0xFFFBF8F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : const Color(0xFFD3C7B8),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              sz,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? primaryColor
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                if (reviewCount > 0) ...[
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "${averageRating.toStringAsFixed(1)} | $reviewCount",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "$symbol${_formatPrice(product.price)}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (discountPercent != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        "MRP $symbol${_formatPrice(product.compareAtPrice)}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$discountPercent% off",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ],
                ),
                const Text(
                  "Price inclusive of all taxes",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5DDD2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _deliveryRow(
                        "Address",
                        [
                          if (addressTitle.isNotEmpty)
                            addressTitle.toUpperCase(),
                          addressText,
                        ].join("\n"),
                      ),
                      if (product.storeName.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _deliveryRow("Sold by", product.storeName),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ArTryOnScreen(
                                productId: product.id,
                                productName: product.name,
                                productThumbnail: imageList.isNotEmpty
                                    ? imageList.first
                                    : null,
                              ),
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "TRY NOW",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: _isAddingToCart ? null : _addToCart,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFFBF8F5),
                            side: const BorderSide(color: Color(0xFFD3C7B8)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isAddingToCart
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: primaryColor,
                                  ),
                                )
                              : const Text(
                                  "BUY NOW",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () =>
                        showAddToComboSheet(context, productId: product.id),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: primaryColor,
                      size: 20,
                    ),
                    label: const Text(
                      "Add to combo",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _serviceBadge(
                      title: "10 day\nreturn",
                      iconAsset: "assets/icons/return.png",
                      fallbackIcon: Icons.assignment_return_outlined,
                    ),
                    _serviceBadge(
                      title: "Cash on\ndelivery",
                      iconAsset: "assets/icons/cod.png",
                      fallbackIcon: Icons.payments_outlined,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                if (description.isNotEmpty) ...[
                  const Text(
                    "Product Details",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                ],

                const Text(
                  "Ratings & Review",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                if (reviewCount > 0)
                  Row(
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                    ],
                  )
                else
                  const Text(
                    "No ratings yet",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: _showAddReviewBottomSheet,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF8F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD3C7B8)),
                    ),
                    child: const Text(
                      "Add a review",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Customer Reviews",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                if (apiReviews.isEmpty)
                  const Text(
                    "No reviews yet",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  )
                else ...[
                  for (final rev in apiReviews)
                    _reviewCard(
                      author: rev.userName,
                      title: rev.title,
                      body: rev.description,
                      rating: rev.rating,
                      isVerified: rev.isVerifiedBuyer,
                      date: _formatReviewDate(rev.createdAt),
                      isOwner:
                          _currentUserId != null && rev.user == _currentUserId,
                      onEdit: () => _showAddReviewBottomSheet(existing: rev),
                      onDelete: () => _confirmDeleteReview(rev),
                    ),
                  if (_hasMoreReviews)
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: _isLoadingMoreReviews
                            ? null
                            : _loadMoreReviews,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: const BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoadingMoreReviews
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: primaryColor,
                                ),
                              )
                            : const Text(
                                "View more reviews",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatReviewDate(String value) {
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  Widget _reviewCard({
    required String author,
    required String title,
    required String body,
    required int rating,
    required bool isVerified,
    required String date,
    bool isOwner = false,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  author,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (isOwner) ...[
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.red,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star : Icons.star_border,
                size: 16,
                color: Colors.amber,
              ),
            ),
          ),
          if (title.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
          if (body.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(body, style: const TextStyle(fontSize: 14)),
          ],
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isVerified ? "verified buyer" : "",
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton({
    IconData? icon,
    Widget? customChild,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        width: 34,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Center(
          child: customChild ?? Icon(icon, size: 18, color: Colors.black),
        ),
      ),
    );
  }

  Widget _deliveryRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ],
    );
  }

  Widget _serviceBadge({
    required String title,
    required String iconAsset,
    required IconData fallbackIcon,
  }) {
    return Column(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFBF8F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Image.asset(
              iconAsset,
              width: 24,
              height: 24,
              errorBuilder: (_, __, ___) =>
                  Icon(fallbackIcon, color: const Color(0xFF8B2E3E), size: 22),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
