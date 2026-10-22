import 'package:flutter/material.dart';

import 'package:kisekae/models/api_exception.dart';
import 'package:kisekae/models/store_create.dart';
import 'package:kisekae/screens/create_store.dart';
import 'package:kisekae/screens/dashboard.dart';
import 'package:kisekae/screens/verify_business.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/email_auth.dart';
import 'package:kisekae/services/seller_invitation.dart';
import 'package:kisekae/services/store.dart';

class StoreSelectionScreen extends StatefulWidget {
  final List<Store>? initialStores;

  const StoreSelectionScreen({super.key, this.initialStores});

  @override
  State<StoreSelectionScreen> createState() => _StoreSelectionScreenState();
}

class _StoreSelectionScreenState extends State<StoreSelectionScreen> {
  final _sellerInvitation = SellerInvitation();
  final _storeOperations = StoreOperations();
  final _linkController = TextEditingController();

  late List<Store> _stores;
  late bool _isLoadingStores;

  bool _isLoading = false;
  bool _isLoggingOut = false;
  String? _storesError;

  @override
  void initState() {
    super.initState();

    if (widget.initialStores != null) {
      _stores = List.from(widget.initialStores!);
      _isLoadingStores = false;
    } else {
      _stores = [];
      _isLoadingStores = true;
      _loadStores();
    }
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  String _extractToken(String input) {
    final uri = Uri.tryParse(input);
    final queryToken = uri?.queryParameters['token'];
    if (queryToken != null && queryToken.isNotEmpty) return queryToken;

    if (uri != null && uri.pathSegments.isNotEmpty) {
      final last = uri.pathSegments.lastWhere(
        (s) => s.isNotEmpty,
        orElse: () => '',
      );
      if (last.isNotEmpty) return last;
    }
    return input;
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);

    final response = await EmailAuth().logout();
    if (!response.success) {
      await DioClient.clearSession();
    }

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _loadStores() async {
    if (!mounted) return;
    setState(() {
      _isLoadingStores = true;
      _storesError = null;
    });
    try {
      final response = await _storeOperations.getStores(pageSize: 50);
      if (!mounted) return;
      setState(() => _stores = response.results);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _storesError = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _storesError = 'Could not load your stores');
    } finally {
      if (mounted) setState(() => _isLoadingStores = false);
    }
  }

  void _openStore(Store store) {
    if (store.isBusinessVerified) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => SellerDashboardScreen(storeId: store.id),
        ),
        (route) => false,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyBusinessScreen(storeId: store.id),
        ),
      ).then((_) => _loadStores());
    }
  }

  void _openCreateStore() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateStoreScreen()),
    ).then((_) => _loadStores());
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _handleVerify() async {
    final input = _linkController.text.trim();
    if (input.isEmpty) {
      _showMessage('Please enter a joining link or token');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _sellerInvitation.acceptInvitationByToken(
        token: _extractToken(input),
      );
      if (!mounted) return;
      _linkController.clear();
      _showMessage('Successfully joined store!');
      await _loadStores();
    } on ApiException catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Something went wrong. Please try again');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surface,
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: _isLoggingOut ? null : _logout,
            icon: _isLoggingOut
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: cs.primary,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.logout, color: cs.onSurface),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'KISEKAE',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 32),
                _storesSection(cs),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _createStoreButton(cs),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'or',
                          style: TextStyle(fontSize: 16, color: cs.onSurface),
                        ),
                      ),
                      _joinStoreBox(cs),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _storesSection(ColorScheme cs) {
    if (_isLoadingStores && _stores.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(color: cs.primary, strokeWidth: 2),
        ),
      );
    }

    if (_storesError != null && _stores.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            Text(
              _storesError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurface),
            ),
            TextButton(
              onPressed: _loadStores,
              child: Text('Retry', style: TextStyle(color: cs.primary)),
            ),
          ],
        ),
      );
    }

    if (_stores.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR STORES',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          for (final store in _stores) _storeTile(cs, store),
          const SizedBox(height: 12),
          Text(
            'OR ADD ANOTHER STORE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _storeTile(ColorScheme cs, Store store) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openStore(store),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.storefront_outlined, size: 28, color: cs.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        store.isBusinessVerified
                            ? 'Verified'
                            : 'Business verification needed',
                        style: TextStyle(fontSize: 13, color: cs.onSurface),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, color: cs.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createStoreButton(ColorScheme cs) {
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _openCreateStore,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.storefront_rounded, size: 36, color: cs.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'CREATE A STORE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _joinStoreBox(ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'JOIN A STORE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: cs.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Enter joining link',
            style: TextStyle(fontSize: 14, color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _linkController,
            enabled: !_isLoading,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleVerify(),
            decoration: InputDecoration(
              hintText: 'Paste token or link...',
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 42,
              width: 110,
              child: FilledButton(
                onPressed: _isLoading ? null : _handleVerify,
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: cs.onPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Verify',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
