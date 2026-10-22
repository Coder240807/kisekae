import 'package:flutter/material.dart';
import 'package:kisekae/models/api_exception.dart';
import 'package:kisekae/screens/dashboard.dart';
import 'package:kisekae/screens/seller_start.dart';
import 'package:kisekae/screens/verify_business.dart';
import 'package:kisekae/services/store.dart';

class SellerGateScreen extends StatefulWidget {
  const SellerGateScreen({super.key});

  @override
  State<SellerGateScreen> createState() => _SellerGateScreenState();
}

class _SellerGateScreenState extends State<SellerGateScreen> {
  final _storeOperations = StoreOperations();
  String? _error;

  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    setState(() => _error = null);
    try {
      final response = await _storeOperations.getStores(pageSize: 50);
      if (!mounted) return;

      final stores = response.results;
      Widget screen;

      if (stores.length == 1) {
        final store = stores.first;
        screen = store.isBusinessVerified
            ? SellerDashboardScreen(storeId: store.id)
            : VerifyBusinessScreen(storeId: store.id);
      } else {
        screen = StoreSelectionScreen(initialStores: stores);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Something went wrong. Please try again');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Center(
          child: _error == null
              ? CircularProgressIndicator(color: cs.primary)
              : Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: cs.onSurface),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _route,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.primary,
                          side: BorderSide(color: cs.primary),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
