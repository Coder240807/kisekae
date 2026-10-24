import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kisekae/models/api_exception.dart';
import 'package:kisekae/models/tryon_combo_model.dart';
import 'package:kisekae/screens/product_screen.dart';
import 'package:kisekae/services/tryon_service.dart';
import 'package:kisekae/widgets/combo_helper.dart';

const _bg = Color(0xFFEFE8DF);
const _primary = Color(0xFF8B2E3E);
const _card = Color(0xFFFBF8F5);
const _border = Color(0xFFD3C7B8);

class CombosScreen extends StatefulWidget {
  const CombosScreen({super.key});

  @override
  State<CombosScreen> createState() => _CombosScreenState();
}

class _CombosScreenState extends State<CombosScreen> {
  final TryOnService _service = TryOnService();
  final CancelToken _cancelToken = CancelToken();

  List<TryOnCombo> _combos = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _cancelToken.cancel('CombosScreen disposed');
    super.dispose();
  }

  String _msg(Object e, String fallback) =>
      e is ApiException ? e.message : fallback;

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) setState(() => _loading = true);
    try {
      final combos = await _service.getUserCombos(cancelToken: _cancelToken);
      if (!mounted) return;
      setState(() {
        _combos = combos;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || (e is DioException && CancelToken.isCancel(e))) return;
      setState(() {
        _loading = false;
        _error = _msg(e, 'Could not load your combos');
      });
    }
  }

  Future<void> _confirmDelete(TryOnCombo combo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8F0),
        title: const Text('Delete combo?'),
        content: Text(
          '"${combo.name}" will be removed. This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await _service.deleteCombo(comboId: combo.id, cancelToken: _cancelToken);
      if (!mounted) return;
      setState(() => _combos.removeWhere((c) => c.id == combo.id));
      messenger.showSnackBar(const SnackBar(content: Text('Combo deleted')));
    } catch (e) {
      if (!mounted || (e is DioException && CancelToken.isCancel(e))) return;
      messenger.showSnackBar(
        SnackBar(content: Text(_msg(e, 'Could not delete combo'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'My Combos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }

    if (_error != null && _combos.isEmpty) {
      return _Message(
        icon: Icons.error_outline,
        title: _error!,
        actionLabel: 'Try again',
        onAction: _load,
      );
    }

    if (_combos.isEmpty) {
      return const _Message(
        icon: Icons.checkroom_outlined,
        title: 'No combos yet',
        subtitle: 'Open any product and tap "Add to combo" to start putting outfits together.',
      );
    }

    return RefreshIndicator(
      color: _primary,
      onRefresh: () => _load(showSpinner: false),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _combos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _ComboCard(
          combo: _combos[i],
          onDelete: () => _confirmDelete(_combos[i]),
        ),
      ),
    );
  }
}

class _ComboCard extends StatelessWidget {
  final TryOnCombo combo;
  final VoidCallback onDelete;

  const _ComboCard({required this.combo, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final items = combo.itemViews;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete combo',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Text(
              'This combo is empty',
              style: TextStyle(fontSize: 13, color: Colors.black45),
            )
          else
            SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) => _ItemThumb(
                  item: items[i],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailsScreen(productId: items[i].productId),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ItemThumb extends StatelessWidget {
  final ComboItemView item;
  final VoidCallback onTap;

  const _ItemThumb({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final url = item.imageUrl;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 72,
          height: 84,
          color: const Color(0xFFE0D8CD),
          child: (url == null || url.isEmpty)
              ? const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.black38,
                )
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.black38,
                  ),
                ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _Message({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: _primary.withOpacity(0.6)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _primary),
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
