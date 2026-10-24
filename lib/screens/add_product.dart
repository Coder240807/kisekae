import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:image_picker/image_picker.dart";
import "package:kisekae/models/api_exception.dart";
import "package:kisekae/models/seller_product.dart";
import "package:kisekae/services/seller_product.dart";

class AddProductScreen extends StatefulWidget {
  final int storeId;

  const AddProductScreen({super.key, required this.storeId});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  static const _stepLabels = ['Details', 'Media', 'Variants', 'Review'];
  static const _wordLimit = 200;
  static const _maxImages = 10;
  static const _maxImageBytes = 5 * 1024 * 1024;
  static const _allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];

  static const _categories = <(String, String)>[
    ('Top', 'TOP'),
    ('Bottom', 'BOTTOM'),
    ('One-Piece', 'ONE_PIECE'),
    ('Footwear', 'FOOTWEAR'),
  ];
  static const _sizes = ['XS', 'S', 'M', 'L', 'XL'];

  static final _nameRegex = RegExp(
    r"^[\p{L}\p{N}][\p{L}\p{N} &'.,\-()/]*$",
    unicode: true,
  );
  static final _skuRegex = RegExp(r'^[A-Za-z0-9\-_]{3,30}$');
  static final _colourRegex = RegExp(r'^\p{L}[\p{L} ]{0,29}$', unicode: true);
  static final _priceRegex = RegExp(r'^\d{1,8}(\.\d{1,2})?$');
  static final _stockRegex = RegExp(r'^\d{1,6}$');

  final HandleProduct _productService = HandleProduct();
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  int? _createdProductId;
  String? _createdStatus;
  bool _primaryUploaded = false;
  bool _galleryUploaded = false;

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  String? _category;

  final List<File> _images = [];
  final _picker = ImagePicker();

  final _colourCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _mrpCtrl = TextEditingController();
  final Set<String> _selectedSizes = {};
  final Map<String, TextEditingController> _stockCtrls = {
    for (final s in _sizes) s: TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _descCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _skuCtrl.dispose();
    _colourCtrl.dispose();
    _priceCtrl.dispose();
    _mrpCtrl.dispose();
    for (final c in _stockCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  int get _wordCount => _descCtrl.text.trim().isEmpty
      ? 0
      : _descCtrl.text.trim().split(RegExp(r'\s+')).length;

  List<String> get _chosenSizes => [
    for (final s in _sizes)
      if (_selectedSizes.contains(s)) s,
  ];

  int get _totalStock => _chosenSizes.fold(
    0,
    (sum, s) => sum + (int.tryParse(_stockCtrls[s]!.text.trim()) ?? 0),
  );

  void _msg(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  String? _validateDetails() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return 'Please enter a product name';
    if (name.length < 3) return 'Product name must be at least 3 characters';
    if (!_nameRegex.hasMatch(name)) {
      return "Name can use letters, numbers, spaces and & ' . , - ( ) /";
    }
    if (_category == null) return 'Please select a category';
    if (_wordCount > _wordLimit) {
      return 'Description cannot be more than $_wordLimit words';
    }
    final sku = _skuCtrl.text.trim();
    if (sku.isNotEmpty && !_skuRegex.hasMatch(sku)) {
      return 'SKU must be 3-30 letters, numbers, - or _';
    }
    return null;
  }

  String? _validateMedia() {
    if (_images.isEmpty) return 'Please add at least one image';
    return null;
  }

  String? _validateVariants() {
    final colour = _colourCtrl.text.trim();
    if (colour.isNotEmpty && !_colourRegex.hasMatch(colour)) {
      return 'Colour can only contain letters (max 30)';
    }
    if (_selectedSizes.isEmpty) return 'Select at least one size';
    for (final s in _chosenSizes) {
      final stock = _stockCtrls[s]!.text.trim();
      if (!_stockRegex.hasMatch(stock))
        return 'Enter stock quantity for size $s';
    }
    final price = _priceCtrl.text.trim();
    if (!_priceRegex.hasMatch(price) || double.parse(price) <= 0) {
      return 'Enter a valid price';
    }
    final mrp = _mrpCtrl.text.trim();
    if (mrp.isNotEmpty) {
      if (!_priceRegex.hasMatch(mrp)) return 'Enter a valid MRP';
      if (double.parse(mrp) < double.parse(price)) {
        return 'MRP cannot be less than the price';
      }
    }
    return null;
  }

  void _goBack() {
    if (_isSubmitting) return;
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _goToNext() {
    final error = switch (_currentPage) {
      0 => _validateDetails(),
      1 => _validateMedia(),
      2 => _validateVariants(),
      _ => null,
    };
    if (error != null) return _msg(error);

    FocusScope.of(context).unfocus();
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _isValidImage(File file) {
    final path = file.path.toLowerCase();
    return _allowedExtensions.any(path.endsWith) &&
        file.lengthSync() <= _maxImageBytes;
  }

  Future<void> _pickImages() async {
    if (_createdProductId != null) {
      return _msg('The product is already created, images cannot be changed');
    }
    final remaining = _maxImages - _images.length;
    if (remaining <= 0) return _msg('You can add up to $_maxImages images');

    final picked = await _picker.pickMultiImage(
      limit: remaining < 2 ? 2 : remaining,
    );
    if (picked.isEmpty) return;

    var skipped = 0;
    setState(() {
      for (final x in picked) {
        final file = File(x.path);
        if (_images.length < _maxImages && _isValidImage(file)) {
          _images.add(file);
        } else {
          skipped++;
        }
      }
    });
    if (skipped > 0) {
      _msg('$skipped image(s) skipped. Use JPG, PNG or WEBP up to 5 MB each');
    }
  }

  void _removeImage(int index) {
    if (_createdProductId != null) {
      return _msg('The product is already created, images cannot be changed');
    }
    setState(() => _images.removeAt(index));
  }

  Future<void> _submit(String status) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      var productId = _createdProductId;

      if (productId == null) {
        final colour = _colourCtrl.text.trim();
        final description = _descCtrl.text.trim();
        final sku = _skuCtrl.text.trim();
        final mrp = _mrpCtrl.text.trim();

        final request = CreateProductRequest(
          name: _nameCtrl.text.trim(),
          category: _category!,
          color: colour.isEmpty ? null : colour,
          description: description.isEmpty ? null : description,
          price: _priceCtrl.text.trim(),
          compareAtPrice: mrp.isEmpty ? null : mrp,
          sku: sku.isEmpty ? null : sku,
          stock: _totalStock,
          sizes: [
            for (final s in _chosenSizes)
              ProductSizeInput(
                size: s,
                stock: int.parse(_stockCtrls[s]!.text.trim()),
              ),
          ],
          status: status,
        );

        final created = await _productService.createProduct(
          storeId: widget.storeId,
          request: request,
        );
        productId = created.id;
        _createdProductId = productId;
        _createdStatus = status;
      }

      if (!_primaryUploaded) {
        await _productService.uploadProductPrimaryImage(
          storeId: widget.storeId,
          productId: productId,
          imageFile: _images.first,
        );
        _primaryUploaded = true;
      }

      final gallery = _images.skip(1).toList();
      if (gallery.isNotEmpty && !_galleryUploaded) {
        await _productService.uploadProductImages(
          storeId: widget.storeId,
          productId: productId,
          imageFiles: gallery,
        );
        _galleryUploaded = true;
      }

      if (!mounted) return;
      _msg(
        _createdStatus == 'ACTIVE'
            ? 'Product published'
            : 'Product saved as draft',
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      _msg(_failureMessage(e.message));
    } catch (_) {
      if (!mounted) return;
      _msg(_failureMessage('Something went wrong. Please try again'));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _failureMessage(String reason) {
    if (_createdProductId == null) return reason;
    return 'Product saved, but the images were not uploaded: $reason. '
        'Tap the button again to retry.';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLast = _currentPage == _stepLabels.length - 1;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surface,
        leading: IconButton(
          onPressed: _goBack,
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: cs.onSurface, width: 2),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: cs.onSurface,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          "Add Products",
          style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _stepper(),
              const SizedBox(height: 20),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (v) => setState(() => _currentPage = v),
                  children: [
                    _detailsPage(),
                    _mediaPage(),
                    _variantsPage(),
                    _reviewPage(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (isLast) ...[
                    SizedBox(
                      height: 48,
                      width: 72,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.primary,
                          backgroundColor: cs.surfaceContainerHighest,
                          padding: EdgeInsets.zero,
                          side: BorderSide(color: cs.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : () => _submit('DRAFT'),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bookmark, size: 20),
                            Text('Save', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : isLast
                            ? () => _submit('ACTIVE')
                            : _goToNext,
                        child: _isSubmitting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: cs.onPrimary,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isLast ? 'PUBLISH PRODUCT' : 'CONTINUE',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepper() {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _stepLabels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 22),
                child: Divider(color: cs.primary, thickness: 1.5, height: 1),
              ),
            ),
          Column(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: cs.primary,
                child: CircleAvatar(
                  radius: 21,
                  backgroundColor: i < _currentPage
                      ? cs.primary
                      : i == _currentPage
                      ? cs.surfaceContainerHighest
                      : cs.surface,
                  child: i < _currentPage
                      ? Icon(Icons.check, color: cs.onPrimary, size: 20)
                      : Text(
                          '${i + 1}',
                          style: TextStyle(fontSize: 20, color: cs.onSurface),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 44,
                height: 20,
                child: OverflowBox(
                  maxWidth: 100,
                  child: Text(
                    _stepLabels[i],
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  InputDecoration _dec(String hint, {String? prefixText}) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.onSurface),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.onSurface),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      t,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    ),
  );

  Widget _imageBox({required Widget child, double? size}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.onSurface),
      ),
      child: child,
    );
  }

  Widget _detailsPage() {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Product Name'),
          TextField(
            controller: _nameCtrl,
            inputFormatters: [LengthLimitingTextInputFormatter(100)],
            decoration: _dec('Enter product name'),
          ),
          const SizedBox(height: 16),
          _label('Description'),
          Stack(
            children: [
              TextField(
                controller: _descCtrl,
                maxLines: 6,
                decoration: _dec('Tell us about your product').copyWith(
                  contentPadding: const EdgeInsets.fromLTRB(12, 14, 12, 32),
                ),
              ),
              Positioned(
                right: 12,
                bottom: 8,
                child: Text(
                  '$_wordCount/$_wordLimit words',
                  style: TextStyle(
                    color: _wordCount > _wordLimit ? cs.error : cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _label('Category'),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: _dec('Select category'),
            dropdownColor: cs.surfaceContainerHighest,
            items: [
              for (final c in _categories)
                DropdownMenuItem(value: c.$2, child: Text(c.$1)),
            ],
            onChanged: (v) => setState(() => _category = v),
          ),
          const SizedBox(height: 16),
          _label('SKU (optional)'),
          TextField(
            controller: _skuCtrl,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-_]')),
              LengthLimitingTextInputFormatter(30),
            ],
            decoration: _dec('Enter product code'),
          ),
        ],
      ),
    );
  }

  Widget _mediaPage() {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Images',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Upload high quality images of your product',
            style: TextStyle(color: cs.onSurface),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickImages,
            child: CustomPaint(
              painter: _DashedBorderPainter(color: cs.onSurface),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Column(
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      color: cs.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to Upload',
                      style: TextStyle(fontSize: 16, color: cs.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add up to $_maxImages images',
                      style: TextStyle(color: cs.onSurface),
                    ),
                    Text(
                      'JPG, PNG, WEBP (Max 5 MB Each)',
                      style: TextStyle(color: cs.onSurface),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Uploaded Images',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          if (_images.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'The first image is the main product image',
              style: TextStyle(fontSize: 13, color: cs.onSurface),
            ),
          ],
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < _images.length; i++)
                Stack(
                  children: [
                    Positioned.fill(
                      child: _imageBox(
                        child: Image.file(_images[i], fit: BoxFit.cover),
                      ),
                    ),
                    if (i == 0)
                      Positioned(
                        left: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Main',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: cs.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => _removeImage(i),
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: cs.primary,
                          child: Icon(
                            Icons.close,
                            size: 12,
                            color: cs.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_images.length < _maxImages)
                GestureDetector(
                  onTap: _pickImages,
                  child: _imageBox(
                    child: Center(
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: cs.onSurface,
                        child: Icon(Icons.add, color: cs.surface, size: 18),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _variantsPage() {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Colour (optional)'),
          TextField(
            controller: _colourCtrl,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[\p{L} ]', unicode: true),
              ),
              LengthLimitingTextInputFormatter(30),
            ],
            decoration: _dec('e.g. Maroon'),
          ),
          const SizedBox(height: 16),
          _label('Size'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final s in _sizes)
                GestureDetector(
                  onTap: () => setState(() {
                    if (!_selectedSizes.remove(s)) _selectedSizes.add(s);
                  }),
                  child: Container(
                    width: 56,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _selectedSizes.contains(s)
                          ? cs.surfaceContainerHighest
                          : cs.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: cs.primary,
                        width: _selectedSizes.contains(s) ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(fontSize: 16, color: cs.onSurface),
                    ),
                  ),
                ),
            ],
          ),
          if (_selectedSizes.isNotEmpty) ...[
            const SizedBox(height: 16),
            _label('Stock Quantity'),
            for (final s in _chosenSizes)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _stockCtrls[s],
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: _dec('Enter stock for size $s'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 4),
          _label('Price'),
          TextField(
            controller: _priceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              LengthLimitingTextInputFormatter(11),
            ],
            decoration: _dec('Enter price', prefixText: '₹ '),
          ),
          const SizedBox(height: 16),
          _label('MRP (optional)'),
          TextField(
            controller: _mrpCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              LengthLimitingTextInputFormatter(11),
            ],
            decoration: _dec('Enter MRP', prefixText: '₹ '),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _reviewPage() {
    final cs = Theme.of(context).colorScheme;
    final categoryLabel = _categories
        .where((c) => c.$2 == _category)
        .map((c) => c.$1)
        .join();

    Widget heading(String t) => Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        t,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
      ),
    );
    Widget row(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(k, style: TextStyle(color: cs.onSurface)),
          ),
          Expanded(
            child: Text(
              v.isEmpty ? '-' : v,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review  & Publish',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_images.isNotEmpty)
                  _imageBox(
                    size: 72,
                    child: Image.file(_images.first, fit: BoxFit.cover),
                  ),
                heading('Basic Details'),
                row('Name', _nameCtrl.text.trim()),
                row('Category', categoryLabel),
                row('SKU', _skuCtrl.text.trim()),
                row('Description', _descCtrl.text.trim()),
                heading('Images'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final f in _images)
                      _imageBox(
                        size: 64,
                        child: Image.file(f, fit: BoxFit.cover),
                      ),
                  ],
                ),
                heading('Variants'),
                row('Colour', _colourCtrl.text.trim()),
                row(
                  'Price',
                  _priceCtrl.text.trim().isEmpty
                      ? ''
                      : '₹${_priceCtrl.text.trim()}',
                ),
                row(
                  'MRP',
                  _mrpCtrl.text.trim().isEmpty
                      ? ''
                      : '₹${_mrpCtrl.text.trim()}',
                ),
                heading('Stock'),
                for (final s in _chosenSizes)
                  row('Size $s', _stockCtrls[s]!.text.trim()),
                row('Total', _totalStock.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(20)),
      );
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 4), paint);
        d += 8;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) => old.color != color;
}
