import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kisekae/models/ar_model.dart';
import 'package:kisekae/models/tryon_combo_model.dart';
import 'package:kisekae/screens/tryon_history.dart';
import 'package:kisekae/services/ar_service.dart';
import 'package:kisekae/services/tryon_service.dart';

const _bg = Color(0xFFEFE8DF);
const _primary = Color(0xFF8B2E3E);
const _canvas = Color(0xFFE0D8CD);
const _border = Color(0xFFD3C7B8);
const _sheetBg = Color(0xFFFFF8F0);

class ArTryOnScreen extends StatefulWidget {
  final int productId;
  final String? productName;
  final String? productThumbnail;

  const ArTryOnScreen({
    super.key,
    required this.productId,
    this.productName,
    this.productThumbnail,
  });

  @override
  State<ArTryOnScreen> createState() => _ArTryOnScreenState();
}

class _ArTryOnScreenState extends State<ArTryOnScreen> {
  final ImagePicker _picker = ImagePicker();
  final TryOnGenerationService _generationService = TryOnGenerationService();
  final TryOnService _comboService = TryOnService();
  final CancelToken _cancelToken = CancelToken();

  late final ComboItem _current;
  List<ComboItem> _garments = [];
  List<TryOnCombo> _combos = [];

  late int _selectedProductId;
  TryOnCombo? _selectedCombo;

  File? _photo;
  String? _resultUrl;
  String? _resultKey;
  bool _showResult = true;
  bool _busy = false;
  bool _saving = false;
  String _statusText = '';

  @override
  void initState() {
    super.initState();
    _current = ComboItem(
      id: 0,
      productId: widget.productId,
      productName: widget.productName ?? 'This item',
      productSlug: '',
      category: '',
      price: '0',
      currency: '',
      thumbnail: widget.productThumbnail,
    );
    _garments = [_current];
    _selectedProductId = widget.productId;
    _loadCombos();
  }

  @override
  void dispose() {
    _cancelToken.cancel('ArTryOnScreen disposed');
    super.dispose();
  }

  String get _currentKey => _selectedCombo != null
      ? 'c:${_selectedCombo!.id}'
      : 'p:$_selectedProductId';

  bool get _resultReady => _resultUrl != null && _resultKey == _currentKey;

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadCombos() async {
    try {
      final combos = await _comboService.getUserCombos(
        cancelToken: _cancelToken,
      );
      if (!mounted) return;

      final seen = <int>{widget.productId};
      final extra = <ComboItem>[];
      for (final combo in combos) {
        for (final item in combo.items) {
          if (item.productId != 0 && seen.add(item.productId)) {
            extra.add(item);
          }
        }
      }

      setState(() {
        _combos = combos;
        _garments = [_current, ...extra];
      });
    } catch (_) {}
  }

  Future<void> _chooseSource() async {
    if (_busy) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: _sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: _primary),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: _primary,
              ),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source != null) _pick(source);
  }

  Future<void> _pick(ImageSource source) async {
    if (_busy) return;
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );
      if (picked == null || !mounted) return;
      setState(() {
        _photo = File(picked.path);
        _resultUrl = null;
        _resultKey = null;
        _showResult = true;
      });
    } catch (_) {
      _snack(
        source == ImageSource.camera
            ? 'Could not open the camera. Please check app permissions.'
            : 'Could not open your gallery. Please check app permissions.',
      );
    }
  }

  void _resetAll() {
    if (_busy) return;
    setState(() {
      _photo = null;
      _resultUrl = null;
      _resultKey = null;
      _showResult = true;
    });
  }

  String _statusLabel(TryOnStatus status) {
    switch (status) {
      case TryOnStatus.pending:
        return 'Waiting in queue...';
      case TryOnStatus.processing:
        return 'Creating your look...';
      default:
        return 'Working on it...';
    }
  }

  Future<void> _tryOn() async {
    final photo = _photo;
    if (photo == null || _busy) return;

    final key = _currentKey;
    final combo = _selectedCombo;

    setState(() {
      _busy = true;
      _statusText = 'Uploading your photo...';
    });

    final result = await _generationService.safeGenerateAndWait(
      personImage: photo,
      productId: combo == null ? _selectedProductId : null,
      comboId: combo?.id,
      cancelToken: _cancelToken,
      onProgress: (r) {
        if (!mounted) return;
        setState(() => _statusText = _statusLabel(r.status));
      },
    );

    if (!mounted || result.cancelled) return;

    setState(() {
      _busy = false;
      if (result.isSuccess) {
        _resultUrl = result.resultImageUrl;
        _resultKey = key;
        _showResult = true;
      }
    });

    if (!result.isSuccess) {
      _snack(result.errorMessage ?? 'Something went wrong. Please try again.');
    }
  }

  Future<void> _saveLook() async {
    final url = _resultUrl;
    if (url == null || _saving) return;

    setState(() => _saving = true);
    try {
      final res = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
        cancelToken: _cancelToken,
      );
      final data = res.data;
      if (data == null || data.isEmpty) throw Exception('empty image');
      await Gal.putImageBytes(Uint8List.fromList(data));
      _snack('Look saved to your gallery');
    } catch (_) {
      _snack('Could not save the look. Please allow photo access and retry.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _chooseCombo() async {
    if (_busy) return;
    final combo = await showModalBottomSheet<TryOnCombo>(
      context: context,
      backgroundColor: _sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          _ComboPickerSheet(combos: _combos, selectedId: _selectedCombo?.id),
    );
    if (combo != null && mounted) {
      setState(() => _selectedCombo = combo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              Expanded(child: _buildCanvasCard()),
              const SizedBox(height: 14),
              _buildControls(),
              if (_photo != null) ...[
                const SizedBox(height: 12),
                _buildMainButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black54),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'AR Try-On',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        InkWell(
          customBorder: const CircleBorder(),
          onTap: _busy
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TryOnHistoryScreen()),
                ),
          child: Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black54),
            ),
            child: const Icon(Icons.history, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildCanvasCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        color: _canvas,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: _buildCanvasContent()),
            Positioned(
              left: 10,
              top: 10,
              bottom: 62,
              width: 56,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _garments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _buildGarmentTile(_garments[i]),
              ),
            ),
            Positioned(left: 14, bottom: 12, child: _buildComboButton()),
            if (_resultReady)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => setState(() => _showResult = !_showResult),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Text(
                      _showResult ? 'See original' : 'See result',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            if (_busy)
              Positioned.fill(
                child: Container(
                  color: Colors.black45,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 14),
                        Text(
                          _statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasContent() {
    if (_resultReady && _showResult) {
      return Image.network(
        _resultUrl!,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator(color: _primary)),
        errorBuilder: (_, __, ___) => const Center(
          child: Text(
            'Could not load the image',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    final photo = _photo;
    if (photo != null) {
      return Image.file(
        photo,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, __, ___) => const Center(
          child: Text(
            'Could not read the photo',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _chooseSource,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline, size: 96, color: Colors.black26),
            SizedBox(height: 8),
            Text(
              'Tap to Start AR Try-On',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Text(
              'Take a full-length photo of yourself',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGarmentTile(ComboItem garment) {
    final combo = _selectedCombo;
    final selected = combo != null
        ? combo.items.any((i) => i.productId == garment.productId)
        : garment.productId == _selectedProductId;
    final url = garment.thumbnail;

    return GestureDetector(
      onTap: _busy
          ? null
          : () => setState(() {
              _selectedProductId = garment.productId;
              _selectedCombo = null;
            }),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _primary : _border,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: (url == null || url.isEmpty)
            ? const Icon(Icons.checkroom_outlined, color: Colors.black38)
            : Image.network(
                url,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.checkroom_outlined, color: Colors.black38),
              ),
      ),
    );
  }

  Widget _buildComboButton() {
    final active = _selectedCombo != null;
    return GestureDetector(
      onTap: _chooseCombo,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: active ? _primary : _border, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Icon(
          Icons.layers_outlined,
          size: 20,
          color: active ? _primary : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _roundButton(
          Icons.photo_library_outlined,
          'Gallery',
          () => _pick(ImageSource.gallery),
        ),
        GestureDetector(
          onTap: _busy ? null : () => _pick(ImageSource.camera),
          child: Container(
            height: 68,
            width: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _primary, width: 3),
            ),
            child: const Icon(Icons.photo_camera, color: _primary, size: 28),
          ),
        ),
        _roundButton(Icons.refresh, 'Start over', _resetAll),
      ],
    );
  }

  Widget _roundButton(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _busy ? null : onTap,
        child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: _border),
          ),
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildMainButton() {
    final ready = _resultReady;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: (_busy || _saving) ? null : (ready ? _saveLook : _tryOn),
        child: _saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                ready ? 'Save Look' : 'Try On',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

class _ComboPickerSheet extends StatelessWidget {
  final List<TryOnCombo> combos;
  final int? selectedId;

  const _ComboPickerSheet({required this.combos, required this.selectedId});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.5;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Try a full combo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'See the whole outfit on you at once.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            if (combos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'You have no combos yet. Add products to a combo first.',
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: combos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final combo = combos[i];
                    final count = combo.itemsCount > combo.items.length
                        ? combo.itemsCount
                        : combo.items.length;
                    final enabled = count > 0;
                    final selected = combo.id == selectedId;

                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: enabled ? () => Navigator.pop(ctx, combo) : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected ? _primary : _border,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      combo.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      enabled
                                          ? '$count ${count == 1 ? 'item' : 'items'}'
                                          : 'Empty combo',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selected)
                                const Icon(Icons.check_circle, color: _primary),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
