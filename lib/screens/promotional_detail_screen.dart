import 'package:flutter/material.dart';
import 'package:kisekae/models/advertising.dart';
import 'package:kisekae/models/api_exception.dart';
import 'package:kisekae/models/seasonal_sale_seller.dart';
import 'package:kisekae/screens/season_sale_screen.dart';
import 'package:kisekae/services/format.dart';
import 'package:kisekae/services/seasonal_sale_seller_service.dart';

class PromotionDetailScreen extends StatefulWidget {
  final int storeId;
  final int saleId;
  final Future<List<PromotableProduct>> Function() loadStoreProducts;

  const PromotionDetailScreen({
    super.key,
    required this.storeId,
    required this.saleId,
    required this.loadStoreProducts,
  });

  @override
  State<PromotionDetailScreen> createState() => _PromotionDetailScreenState();
}

class _PromotionDetailScreenState extends State<PromotionDetailScreen> {
  final _ops = SeasonalSales();

  SeasonalSale? _sale;
  bool _loading = true;
  String? _error;
  int? _busyId;
  bool _enrolling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _snack(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: error ? Colors.red : Colors.green,
        ),
      );
  }

  Future<void> _load({bool spinner = true}) async {
    if (spinner) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final sale = await _ops.getSale(widget.storeId, widget.saleId);
      if (!mounted) return;
      setState(() {
        _sale = sale;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (_sale == null) {
        setState(() => _error = e.message);
      } else {
        _snack(e.message, error: true);
      }
    } catch (_) {
      if (!mounted) return;
      if (_sale == null) {
        setState(() => _error = 'Could not load this promotion');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(EnrolledProduct p, bool active) async {
    if (_busyId != null) return;
    setState(() => _busyId = p.id);
    try {
      // If this 404s, switch p.productId to p.id.
      await _ops.setProductActive(
        widget.storeId,
        widget.saleId,
        p.productId,
        active,
      );
      if (!mounted) return;
      await _load(spinner: false);
    } on ApiException catch (e) {
      _snack(e.message, error: true);
    } catch (_) {
      _snack('Something went wrong. Please try again', error: true);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _remove(EnrolledProduct p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from sale?'),
        content: Text('${p.productName} will no longer be part of this sale.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || _busyId != null) return;

    setState(() => _busyId = p.id);
    try {
      await _ops.removeProduct(widget.storeId, widget.saleId, p.productId);
      if (!mounted) return;
      _snack('Removed from sale');
      await _load(spinner: false);
    } on ApiException catch (e) {
      _snack(e.message, error: true);
    } catch (_) {
      _snack('Something went wrong. Please try again', error: true);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _addProducts() async {
    final sale = _sale;
    if (sale == null || _enrolling) return;

    final ids = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ProductPickerSheet(
        loadProducts: widget.loadStoreProducts,
        alreadyEnrolled: sale.enrolledProducts.map((e) => e.productId).toSet(),
      ),
    );
    if (ids == null || ids.isEmpty || !mounted) return;

    setState(() => _enrolling = true);
    try {
      await _ops.enrollProducts(widget.storeId, widget.saleId, ids);
      if (!mounted) return;
      _snack(
        ids.length == 1 ? 'Product added' : '${ids.length} products added',
      );
      await _load(spinner: false);
    } on ApiException catch (e) {
      _snack(e.message, error: true);
    } catch (_) {
      _snack('Something went wrong. Please try again', error: true);
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sale = _sale;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surface,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
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
        actions: [
          if (sale != null)
            IconButton(
              icon: Icon(Icons.visibility_outlined, color: cs.onSurface),
              tooltip: 'Preview Sale',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SeasonSaleScreen(
                      seasonalSale: sale,
                      title: sale.title,
                      subtitle: sale.subtitle,
                      bannerImageUrl: sale.bannerImage,
                    ),
                  ),
                );
              },
            ),
        ],
        title: Text(
          'Sale details',
          style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: cs.primary,
                onRefresh: () => _load(spinner: false),
                child: _body(cs),
              ),
            ),
            if (sale != null && !sale.hasEnded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _enrolling ? null : _addProducts,
                    icon: _enrolling
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.onPrimary,
                            ),
                          )
                        : const Icon(Icons.add, size: 20),
                    label: const Text('Add products'),
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _body(ColorScheme cs) {
    if (_loading && _sale == null) {
      return Center(child: CircularProgressIndicator(color: cs.primary));
    }

    final sale = _sale;
    if (sale == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Text(
            _error ?? 'Could not load this promotion',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: cs.onSurface),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: _load,
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.primary,
                side: BorderSide(color: cs.primary),
              ),
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        _header(cs, sale),
        const SizedBox(height: 24),
        Text(
          'Enrolled products',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (sale.enrolledProducts.isEmpty)
          _emptyProducts(cs, sale)
        else
          for (final p in sale.enrolledProducts)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ProductTile(
                product: p,
                readOnly: sale.hasEnded,
                busy: _busyId == p.id,
                onToggle: (v) => _toggle(p, v),
                onRemove: () => _remove(p),
              ),
            ),
      ],
    );
  }

  Widget _header(ColorScheme cs, SeasonalSale sale) {
    final subtle = cs.onSurface.withValues(alpha: 0.75);

    final (badgeBg, badgeFg, badgeText) = switch (sale.phase) {
      SalePhase.live => (
        const Color(0xFFE3F2E5),
        const Color(0xFF2E7D32),
        'Live',
      ),
      SalePhase.upcoming => (
        const Color(0xFFFBEFD5),
        const Color(0xFFB7791F),
        'Upcoming',
      ),
      SalePhase.ended => (
        const Color(0xFFECECEC),
        const Color(0xFF616161),
        'Ended',
      ),
    };

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6EF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 3),
            blurRadius: 8,
            color: Color(0x1F000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sale.bannerImage != null)
            Image.network(
              sale.bannerImage!,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sale.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: badgeFg,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Flat ${sale.discountLabel}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
                if (sale.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    sale.description.trim(),
                    style: TextStyle(fontSize: 13, color: subtle),
                  ),
                ],
                const SizedBox(height: 12),
                if (sale.dateRange.isNotEmpty)
                  _infoRow(
                    Icons.calendar_today_outlined,
                    sale.dateRange,
                    subtle,
                  ),
                if (sale.timingText.isNotEmpty)
                  _infoRow(Icons.schedule, sale.timingText, subtle),
                _infoRow(
                  Icons.inventory_2_outlined,
                  sale.participationText,
                  sale.isParticipating ? cs.primary : subtle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyProducts(ColorScheme cs, SeasonalSale sale) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 52,
            color: cs.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          Text(
            'No products enrolled',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sale.hasEnded
                ? 'This sale has ended.'
                : 'Add products to take part in this sale.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final EnrolledProduct product;
  final bool readOnly;
  final bool busy;
  final ValueChanged<bool> onToggle;
  final VoidCallback onRemove;

  const _ProductTile({
    required this.product,
    required this.readOnly,
    required this.busy,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final p = product;
    final subtle = cs.onSurface.withValues(alpha: 0.7);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB78876)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 60,
              height: 60,
              child: p.thumbnail == null
                  ? _placeholder(cs)
                  : Image.network(
                      p.thumbnail!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(cs),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      inr(p.discountedPrice),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      inr(p.originalPrice),
                      style: TextStyle(
                        fontSize: 12,
                        color: subtle,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${formatNumber(p.discountPercentage)}% off',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  p.stock > 0 ? 'Stock: ${p.stock}' : 'Out of stock',
                  style: TextStyle(
                    fontSize: 12,
                    color: p.stock > 0 ? subtle : cs.error,
                  ),
                ),
              ],
            ),
          ),
          if (busy)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (readOnly)
            Text(
              p.isActive ? 'Was active' : 'Inactive',
              style: TextStyle(fontSize: 12, color: subtle),
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: p.isActive,
                  onChanged: onToggle,
                  activeThumbColor: cs.primary,
                ),
                GestureDetector(
                  onTap: onRemove,
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _placeholder(ColorScheme cs) => Container(
    color: const Color(0xFFE0C3C7),
    child: Icon(Icons.checkroom, color: cs.primary),
  );
}

class _ProductPickerSheet extends StatefulWidget {
  final Future<List<PromotableProduct>> Function() loadProducts;
  final Set<int> alreadyEnrolled;

  const _ProductPickerSheet({
    required this.loadProducts,
    required this.alreadyEnrolled,
  });

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  List<PromotableProduct> _products = [];
  final Set<int> _selected = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final products = await widget.loadProducts();
      if (!mounted) return;
      setState(() {
        _products = products
            .where((p) => !widget.alreadyEnrolled.contains(p.id))
            .toList();
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load your products');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add products to this sale',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
          Expanded(child: _list(cs)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () => Navigator.pop(context, _selected.toList()),
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  _selected.isEmpty
                      ? 'Select products'
                      : 'Add ${_selected.length} '
                            '${_selected.length == 1 ? 'product' : 'products'}',
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
    );
  }

  Widget _list(ColorScheme cs) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: cs.primary));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'All your products are already in this sale.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      itemCount: _products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final p = _products[i];
        final selected = _selected.contains(p.id);

        void toggle() => setState(
          () => selected ? _selected.remove(p.id) : _selected.add(p.id),
        );

        return Material(
          color: const Color(0xFFFFF9F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: selected ? cs.primary : const Color(0xFFB78876),
              width: selected ? 2 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: toggle,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          inr(p.price),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: selected,
                    activeColor: cs.primary,
                    onChanged: (_) => toggle(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
