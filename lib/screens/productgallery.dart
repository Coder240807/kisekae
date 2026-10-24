import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kisekae/models/seller_product.dart';
import 'package:kisekae/services/seller_product.dart';

class ProductGalleryScreen extends StatefulWidget {
  final int storeId;
  final int productId;
  final String? initialPrimaryImageUrl;

  const ProductGalleryScreen({
    super.key,
    required this.storeId,
    required this.productId,
    this.initialPrimaryImageUrl,
  });

  @override
  State<ProductGalleryScreen> createState() => _ProductGalleryScreenState();
}

class _ProductGalleryScreenState extends State<ProductGalleryScreen> {
  final HandleProduct _productService = HandleProduct();
  final ImagePicker _picker = ImagePicker();

  String? _primaryImageUrl;
  List<ProductImage> _galleryImages = [];

  bool _isLoadingGallery = true;
  bool _isUploadingPrimary = false;
  bool _isDeletingPrimary = false;
  bool _isUploadingGallery = false;
  final Set<int> _deletingImageIds = {};

  @override
  void initState() {
    super.initState();
    _primaryImageUrl = widget.initialPrimaryImageUrl;
    _fetchGalleryImages();
  }

  Future<void> _fetchGalleryImages() async {
    setState(() => _isLoadingGallery = true);
    try {
      final images = await _productService.getProductImages(
        storeId: widget.storeId,
        productId: widget.productId,
      );
      if (mounted) {
        setState(() {
          _galleryImages = images;
          _isLoadingGallery = false;
        });
      }
    } catch (e) {
      if (mounted && e is! DioException) {
        setState(() => _isLoadingGallery = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load gallery: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickAndUploadPrimaryImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _isUploadingPrimary = true);
    try {
      final updatedProduct = await _productService.uploadProductPrimaryImage(
        storeId: widget.storeId,
        productId: widget.productId,
        imageFile: File(picked.path),
      );

      if (mounted) {
        setState(() {
          _primaryImageUrl = updatedProduct.imageUrl;
          _isUploadingPrimary = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Primary image updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPrimary = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload primary image: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _removePrimaryImage() async {
    final confirm = await _showConfirmDialog(
      title: "Remove Primary Image?",
      content: "This will remove the main thumbnail image of the product.",
    );
    if (confirm != true) return;

    setState(() => _isDeletingPrimary = true);
    try {
      await _productService.deleteProductPrimaryImage(
        storeId: widget.storeId,
        productId: widget.productId,
      );

      if (mounted) {
        setState(() {
          _primaryImageUrl = null;
          _isDeletingPrimary = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Primary image removed')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeletingPrimary = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove primary image: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadGalleryImages() async {
    final int availableSlots = 10 - _galleryImages.length;
    if (availableSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 10 gallery images allowed.')),
      );
      return;
    }

    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      imageQuality: 85,
    );
    if (pickedFiles.isEmpty) return;

    if (pickedFiles.length > availableSlots) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You can only select up to $availableSlots more image(s).',
          ),
        ),
      );
      return;
    }

    setState(() => _isUploadingGallery = true);

    try {
      final files = pickedFiles.map((x) => File(x.path)).toList();
      final updatedList = await _productService.uploadProductImages(
        storeId: widget.storeId,
        productId: widget.productId,
        imageFiles: files,
      );

      if (mounted) {
        setState(() {
          _galleryImages = updatedList;
          _isUploadingGallery = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${pickedFiles.length} image(s) uploaded successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingGallery = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload images: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteGalleryImage(int imageId) async {
    final confirm = await _showConfirmDialog(
      title: "Delete Image?",
      content: "Are you sure you want to delete this gallery photo?",
    );
    if (confirm != true) return;

    setState(() => _deletingImageIds.add(imageId));

    try {
      await _productService.deleteProductImage(
        storeId: widget.storeId,
        productId: widget.productId,
        imageId: imageId,
      );

      if (mounted) {
        setState(() {
          _galleryImages.removeWhere((img) => img.id == imageId);
          _deletingImageIds.remove(imageId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _deletingImageIds.remove(imageId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete image: ${e.toString()}')),
        );
      }
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8F0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "CANCEL",
              style: TextStyle(color: Colors.black54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "DELETE",
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFEFE8DF);
    const primaryColor = Color(0xFF8B2E3E);
    const cardBackgroundColor = Color(0xFFFFF8F0);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: const Text(
          "Product Media",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Primary Product Image",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5DDD2)),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _isUploadingPrimary
                        ? Container(
                            height: 180,
                            width: double.infinity,
                            color: const Color(0xFFE5DDD2),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            ),
                          )
                        : _primaryImageUrl != null &&
                              _primaryImageUrl!.isNotEmpty
                        ? Image.network(
                            _primaryImageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 180,
                              width: double.infinity,
                              color: const Color(0xFFE5DDD2),
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            height: 180,
                            width: double.infinity,
                            color: const Color(0xFFE5DDD2),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "No primary image set",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isUploadingPrimary
                              ? null
                              : _pickAndUploadPrimaryImage,
                          icon: const Icon(
                            Icons.upload,
                            color: primaryColor,
                            size: 18,
                          ),
                          label: Text(
                            _primaryImageUrl == null
                                ? "Upload Primary"
                                : "Replace Primary",
                            style: const TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      if (_primaryImageUrl != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _isDeletingPrimary
                              ? null
                              : _removePrimaryImage,
                          icon: _isDeletingPrimary
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFE53935),
                                  ),
                                )
                              : const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFFE53935),
                                ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Gallery Images",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "${_galleryImages.length} of 10 uploaded",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                if (_galleryImages.length < 10)
                  TextButton.icon(
                    onPressed: _isUploadingGallery
                        ? null
                        : _pickAndUploadGalleryImages,
                    icon: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: primaryColor,
                      size: 20,
                    ),
                    label: const Text(
                      "Add Photos",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Gallery Grid
            _isLoadingGallery
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5DDD2)),
                    ),
                    child: Column(
                      children: [
                        if (_isUploadingGallery) ...[
                          const LinearProgressIndicator(color: primaryColor),
                          const SizedBox(height: 12),
                        ],
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1.0,
                              ),
                          itemCount:
                              _galleryImages.length +
                              (_galleryImages.length < 10 ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _galleryImages.length) {
                              return GestureDetector(
                                onTap: _isUploadingGallery
                                    ? null
                                    : _pickAndUploadGalleryImages,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5DDD2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: primaryColor.withOpacity(0.5),
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_rounded,
                                        color: primaryColor,
                                        size: 28,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Add More",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final image = _galleryImages[index];
                            final isDeleting = _deletingImageIds.contains(
                              image.id,
                            );

                            return Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      image.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: const Color(0xFFE5DDD2),
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: isDeleting
                                        ? null
                                        : () => _deleteGalleryImage(image.id),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: isDeleting
                                          ? const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.close_rounded,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
