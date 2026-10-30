import 'dart:io';
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kisekae/models/api_exception.dart';
import 'package:kisekae/services/account_service.dart';
import 'package:kisekae/services/store.dart';

import 'verify_business.dart';

class CreateStoreScreen extends StatefulWidget {
  const CreateStoreScreen({super.key});

  @override
  State<CreateStoreScreen> createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends State<CreateStoreScreen> {
  static const _nameMax = 50;
  static const _descriptionMax = 200;
  static const _linkMax = 200;

  static final _nameRegex = RegExp(
    r"^[\p{L}\p{N}][\p{L}\p{N} &'.\-]*$",
    unicode: true,
  );

  final _storeOperations = StoreOperations();
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _socialController = TextEditingController();

  File? _banner;
  File? _logo;
  bool _showImageErrors = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _socialController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter your brand name';
    if (name.length < 3) return 'Must be at least 3 characters';
    if (!_nameRegex.hasMatch(name)) {
      return "Letters, numbers, spaces and & ' . - only";
    }
    return null;
  }

  String? _validateDescription(String? value) {
    final description = value?.trim() ?? '';
    if (description.isEmpty) return 'Enter a short description';
    if (description.length < 10) return 'Must be at least 10 characters';
    return null;
  }

  String? _validateOptionalLink(String? value) {
    final link = value?.trim() ?? '';
    if (link.isEmpty) return null;
    final uri = Uri.tryParse(link.contains('://') ? link : 'https://$link');
    if (uri == null || !uri.hasAuthority || !uri.host.contains('.')) {
      return 'Enter a valid link';
    }
    return null;
  }

  String? _normalizeLink(String value) {
    final link = value.trim();
    if (link.isEmpty) return null;
    return link.contains('://') ? link : 'https://$link';
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _pickImage({required bool isBanner}) async {
    if (_isLoading) return;
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      setState(() {
        if (isBanner) {
          _banner = File(picked.path);
        } else {
          _logo = File(picked.path);
        }
      });
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not open your gallery. Please try again');
    }
  }

  Future<T> _createOrUpgrade<T>(Future<T> Function() create) async {
    try {
      return await create();
    } on ApiException catch (e) {
      if (e.statusCode == 403 && e.code == 'NOT_A_SELLER') {
        final upgraded = await AccountService().becomeSeller();
        if (!upgraded.success) {
          throw ApiException(
            statusCode: 403,
            success: false,
            message: upgraded.message,
          );
        }
        return await create();
      }
      rethrow;
    }
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    final formValid = _formKey.currentState!.validate();
    final imagesValid = _banner != null && _logo != null;
    if (!imagesValid) setState(() => _showImageErrors = true);
    if (!formValid || !imagesValid) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);
    try {
      final store = await _createOrUpgrade(
        () => _storeOperations.createStore(
          name: _nameController.text.trim(),
          description: _descriptionController.text
              .trim()
              .replaceAll(RegExp(r'[ \t]+'), ' ')
              .replaceAll(RegExp(r'\n{3,}'), '\n\n'),
          logo: _logo!,
          banner: _banner!,
          websiteLink: _normalizeLink(_websiteController.text),
          instagramLink: _normalizeLink(_socialController.text),
        ),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyBusinessScreen(storeId: store.id),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
    } catch (e, st) {
      print('CREATE STORE ERROR: $e\n$st');
      if (!mounted) return;
      _showMessage('Something went wrong. Please try again');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _label(String text, {bool required = false, bool optional = false}) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: cs.onSurface,
          ),
          children: [
            if (required)
              TextSpan(
                text: '*',
                style: TextStyle(color: cs.error),
              ),
            if (optional)
              const TextSpan(
                text: '(Optional)',
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
          ],
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    int? maxLength,
    double minHeight = 0,
  }) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      enabled: !_isLoading,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      minLines: maxLines > 1 ? maxLines : null,
      maxLines: maxLines,
      maxLength: maxLength,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        errorMaxLines: 2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: _border(Colors.transparent),
        enabledBorder: _border(Colors.transparent),
        disabledBorder: _border(Colors.transparent),
        focusedBorder: _border(cs.primary, width: 1.5),
        errorBorder: _border(cs.error),
        focusedErrorBorder: _border(cs.error, width: 1.5),
      ),
    );
  }

  Widget _verificationCard(ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Verification',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your business verification to unlock more features, increase trust and get higher visibility on the platform.',
            style: TextStyle(fontSize: 13, color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'What you will need -',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          Text(
            'Business PAN or GST Number',
            style: TextStyle(fontSize: 13, color: cs.onSurface),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: FilledButton(
              onPressed: _isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: cs.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Verify business'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surface,
        leading: IconButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
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
          'Create Store',
          style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9F2),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 2),
                  blurRadius: 8,
                  color: Color(0x14000000),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Store Banner'),
                  _UploadBox(
                    file: _banner,
                    hint: 'Upload banner recommended size(1200×400)',
                    height: 110,
                    hasError: _showImageErrors && _banner == null,
                    enabled: !_isLoading,
                    onTap: () => _pickImage(isBanner: true),
                  ),
                  const SizedBox(height: 16),
                  _label('Store Logo'),
                  _UploadBox(
                    file: _logo,
                    hint: 'Upload logo recommended size(512×512)',
                    height: 110,
                    hasError: _showImageErrors && _logo == null,
                    enabled: !_isLoading,
                    onTap: () => _pickImage(isBanner: false),
                  ),
                  const SizedBox(height: 16),
                  _label('Brand Name', required: true),
                  _input(
                    controller: _nameController,
                    validator: _validateName,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(_nameMax),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _label('Brand Description'),
                  _input(
                    controller: _descriptionController,
                    validator: _validateDescription,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    maxLength: _descriptionMax,
                  ),
                  const SizedBox(height: 8),
                  _label('Brand Website', optional: true),
                  _input(
                    controller: _websiteController,
                    validator: _validateOptionalLink,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      LengthLimitingTextInputFormatter(_linkMax),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _label('Social Media links', optional: true),
                  _input(
                    controller: _socialController,
                    validator: _validateOptionalLink,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      LengthLimitingTextInputFormatter(_linkMax),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _verificationCard(cs),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  final File? file;
  final String hint;
  final double height;
  final bool hasError;
  final bool enabled;
  final VoidCallback onTap;

  const _UploadBox({
    required this.file,
    required this.hint,
    required this.height,
    required this.hasError,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color borderColor = hasError ? cs.error : const Color(0xFF9A9A9A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: CustomPaint(
            foregroundPainter: _DottedBorderPainter(color: borderColor),
            child: Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCF8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: file != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(file!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFEFDDE0),
                          ),
                          child: Icon(
                            Icons.photo_camera_outlined,
                            size: 20,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            hint,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: cs.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'Please upload an image',
              style: TextStyle(fontSize: 12, color: cs.error),
            ),
          ),
      ],
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;

  _DottedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)),
      );

    const dash = 3.0;
    const gap = 3.0;
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
