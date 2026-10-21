import "dart:io";

import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";

class Variant {
  Variant({
    required this.color,
    required this.size,
    required this.price,
    required this.stock,
  });
  final Color color;
  final String size;
  final String price;
  final String stock;
}

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  String? _category;
  final _categories = const [
    'Tops',
    'Bottoms',
    'Dresses',
    'Footwear',
    'Accessories',
  ];

  final List<File> _images = [];
  final _picker = ImagePicker();

  final List<Color> _colors = [];
  Color? _selectedColor;
  String _selectedSize = 'M';
  final _sizes = const ['XS', 'S', 'M', 'L', 'XL'];
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final List<Variant> _variants = [];

  @override
  void initState() {
    super.initState();
    _descCtrl.addListener(() => setState(() {}));
    _priceCtrl.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_colors.isEmpty) {
      final cs = Theme.of(context).colorScheme;
      _colors.addAll([
        cs.primary,
        cs.secondary,
        cs.onSurface,
        cs.surfaceContainerHighest,
      ]);
      _selectedColor = _colors.first;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _brandCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  int get _wordCount => _descCtrl.text.trim().isEmpty
      ? 0
      : _descCtrl.text.trim().split(RegExp(r'\s+')).length;

  void _msg(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  void _goBack() {
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
    if (_currentPage == 0 && _nameCtrl.text.trim().isEmpty) {
      return _msg('Please enter a product name');
    }
    if (_currentPage == 1 && _images.isEmpty) {
      return _msg('Please add at least one image');
    }
    if (_currentPage == 2) {
      if (_variants.isEmpty && !_saveCurrentVariant()) return;
    }
    if (_currentPage < 3) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _msg('Product published');
      Navigator.pop(context);
    }
  }

  bool _saveCurrentVariant() {
    if (_priceCtrl.text.trim().isEmpty || _stockCtrl.text.trim().isEmpty) {
      _msg('Enter price and stock quantity');
      return false;
    }
    setState(() {
      _variants.add(
        Variant(
          color: _selectedColor ?? _colors.first,
          size: _selectedSize,
          price: _priceCtrl.text.trim(),
          stock: _stockCtrl.text.trim(),
        ),
      );
      _priceCtrl.clear();
      _stockCtrl.clear();
    });
    return true;
  }

  Future<void> _pickImages() async {
    final remaining = 5 - _images.length;
    if (remaining <= 0) return _msg('You can add up to 5 images');
    final picked = await _picker.pickMultiImage(
      limit: remaining < 2 ? 2 : remaining,
    );
    if (picked.isEmpty) return;
    setState(() {
      for (final x in picked) {
        if (_images.length < 5 &&
            File(x.path).lengthSync() <= 10 * 1024 * 1024) {
          _images.add(File(x.path));
        }
      }
    });
  }

  void _pickColor() {
    final cs = Theme.of(context).colorScheme;
    final options = [
      cs.primary,
      cs.secondary,
      cs.error,
      cs.onSurface,
      cs.surfaceContainerHighest,
      cs.surface,
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final c in options)
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (!_colors.contains(c)) _colors.add(c);
                    _selectedColor = c;
                  });
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: cs.primary,
                  child: CircleAvatar(radius: 17, backgroundColor: c),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLast = _currentPage == 3;
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
                        onPressed: () => _msg('Saved as draft'),
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
                        onPressed: _goToNext,
                        child: Text(
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
    const labels = ['Details', 'Media', 'Variants', 'Review'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < 4; i++) ...[
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
                    labels[i],
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

  InputDecoration _dec(String hint) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
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
                  '$_wordCount/200 words',
                  style: TextStyle(
                    color: _wordCount > 200 ? cs.error : cs.onSurface,
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
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (v) => setState(() => _category = v),
          ),
          const SizedBox(height: 16),
          _label('Brand'),
          TextField(
            controller: _brandCtrl,
            decoration: _dec('Enter the name of brand'),
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
                      'Add upto 5 images',
                      style: TextStyle(color: cs.onSurface),
                    ),
                    Text(
                      'JPG,PNG(Max 10 MB Each)',
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
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => setState(() => _images.removeAt(i)),
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
              if (_images.length < 5)
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
          _label('Colour'),
          Row(
            children: [
              for (final c in _colors)
                GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: Container(
                    margin: const EdgeInsets.only(right: 14),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == c ? cs.onSurface : cs.surface,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(radius: 9, backgroundColor: c),
                  ),
                ),
              const Spacer(),
              OutlinedButton(
                onPressed: _pickColor,
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.onSurface,
                  side: BorderSide(color: cs.primary),
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text('Add color'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _label('Size'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final s in _sizes)
                GestureDetector(
                  onTap: () => setState(() => _selectedSize = s),
                  child: Container(
                    width: 56,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _selectedSize == s
                          ? cs.surfaceContainerHighest
                          : cs.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: cs.primary,
                        width: _selectedSize == s ? 2 : 1,
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
          const SizedBox(height: 16),
          _label('Price'),
          TextField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            decoration: _dec('Enter price'),
          ),
          const SizedBox(height: 16),
          _label('Stock Quantity'),
          TextField(
            controller: _stockCtrl,
            keyboardType: TextInputType.number,
            decoration: _dec('Enter stock'),
          ),
          const SizedBox(height: 16),
          _label('Variant Preview'),
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.onSurface),
            ),
            child: Row(
              children: [
                _imageBox(
                  size: 64,
                  child: _images.isNotEmpty
                      ? Image.file(_images.first, fit: BoxFit.cover)
                      : Icon(Icons.image_outlined, color: cs.onSurface),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 7,
                            backgroundColor: _selectedColor ?? _colors.first,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Size $_selectedSize',
                            style: TextStyle(color: cs.onSurface),
                          ),
                        ],
                      ),
                      if (_priceCtrl.text.isNotEmpty)
                        Text(
                          '₹${_priceCtrl.text}',
                          style: TextStyle(color: cs.onSurface),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: TextButton(
              onPressed: _saveCurrentVariant,
              child: Text(
                _variants.isEmpty
                    ? 'Add More Variants'
                    : 'Add More Variants (${_variants.length} added)',
                style: TextStyle(color: cs.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewPage() {
    final cs = Theme.of(context).colorScheme;

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
                row('Name', _nameCtrl.text),
                row('Category', _category ?? ''),
                row('Brand', _brandCtrl.text),
                row('Description', _descCtrl.text),
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
                if (_variants.isEmpty)
                  Text('-', style: TextStyle(color: cs.onSurface)),
                for (final v in _variants)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 96,
                              child: Text(
                                'Colour',
                                style: TextStyle(color: cs.onSurface),
                              ),
                            ),
                            CircleAvatar(radius: 8, backgroundColor: v.color),
                          ],
                        ),
                        row('Size', v.size),
                        row('Price', '₹${v.price}'),
                        row('Quantity', v.stock),
                      ],
                    ),
                  ),
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
