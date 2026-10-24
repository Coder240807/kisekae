import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kisekae/models/api_exception.dart';
import 'package:kisekae/models/tryon_combo_model.dart';
import 'package:kisekae/services/tryon_service.dart';
import 'package:kisekae/widgets/combo_helper.dart';

const _primary = Color(0xFF8B2E3E);
const _sheetBg = Color(0xFFFFF8F0);
const _border = Color(0xFFD3C7B8);

Future<void> showAddToComboSheet(
  BuildContext context, {
  required int productId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: _sheetBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _AddToComboSheet(productId: productId),
  );
}

class _AddToComboSheet extends StatefulWidget {
  final int productId;
  const _AddToComboSheet({required this.productId});

  @override
  State<_AddToComboSheet> createState() => _AddToComboSheetState();
}

class _AddToComboSheetState extends State<_AddToComboSheet> {
  final TryOnService _service = TryOnService();
  final CancelToken _cancelToken = CancelToken();

  List<TryOnCombo> _combos = [];
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _cancelToken.cancel('sheet closed');
    super.dispose();
  }

  String _msg(Object e, String fallback) =>
      e is ApiException ? e.message : fallback;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final combos = await _service.getUserCombos(cancelToken: _cancelToken);
      if (!mounted) return;
      setState(() {
        _combos = combos;
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

  Future<void> _addToExisting(TryOnCombo combo) async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (combo.containsProduct(widget.productId)) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('Already in "${combo.name}"')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      await _service.addItemToCombo(
        comboId: combo.id,
        productId: widget.productId,
      );
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('Added to "${combo.name}"')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(
        SnackBar(content: Text(_msg(e, 'Could not add to combo'))),
      );
    }
  }

  Future<void> _createNew() async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _NameDialog(),
    );
    if (name == null || name.isEmpty || !mounted) return;

    setState(() => _busy = true);
    try {
      await _service.createCombo(name: name, productIds: [widget.productId]);
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('Created "$name" with this item')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(
        SnackBar(content: Text(_msg(e, 'Could not create combo'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxListHeight = MediaQuery.of(context).size.height * 0.4;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add to combo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            // Create new
            _OptionTile(
              leading: const CircleAvatar(
                radius: 18,
                backgroundColor: _primary,
                child: Icon(Icons.add, color: Colors.white, size: 20),
              ),
              title: 'Create a new combo',
              onTap: _busy ? null : _createNew,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'OR ADD TO EXISTING',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45,
                ),
              ),
            ),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(color: _primary),
                ),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              )
            else if (_combos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'You have no combos yet.',
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxListHeight),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _combos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final combo = _combos[i];
                    final already = combo.containsProduct(widget.productId);
                    return _OptionTile(
                      leading: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFE5DDD2),
                        child: Icon(
                          Icons.checkroom_outlined,
                          color: _primary,
                          size: 18,
                        ),
                      ),
                      title: combo.name,
                      subtitle: already
                          ? 'Already added'
                          : '${combo.itemCount} '
                                '${combo.itemCount == 1 ? 'item' : 'items'}',
                      trailing: already
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: _busy ? null : () => _addToExisting(combo),
                    );
                  },
                ),
              ),

            if (_busy)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: LinearProgressIndicator(
                  color: _primary,
                  backgroundColor: Color(0xFFE5DDD2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
              trailing ??
                  const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog();

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _sheetBg,
      title: const Text('Name your combo'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 50,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: 'e.g. Weekend brunch',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _border),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text(
            'Create',
            style: TextStyle(color: _primary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
