import 'package:flutter/material.dart';
import 'package:kisekae/models/api_exception.dart';
import 'package:kisekae/models/store_invitation.dart';
import 'package:kisekae/screens/seller_gate_screen.dart';
import 'package:kisekae/services/account_service.dart';
import 'package:kisekae/services/store_invitation.dart';

class JoinStoreScreen extends StatefulWidget {
  const JoinStoreScreen({super.key});

  @override
  State<JoinStoreScreen> createState() => _JoinStoreScreenState();
}

class _JoinStoreScreenState extends State<JoinStoreScreen> {
  final _storeInvitations = StoreInvitations();

  List<StoreInvitation> _invitations = [];
  bool _loading = true;
  String? _error;
  int? _busyId;
  bool _accepting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _showMessage(String text, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: error ? Colors.red : null,
        ),
      );
  }

  Future<List<StoreInvitation>> _fetchInvitations() async {
    try {
      return await _storeInvitations.getInvitations();
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
        return await _storeInvitations.getInvitations();
      }
      rethrow;
    }
  }

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final invitations = await _fetchInvitations();
      if (!mounted) return;
      setState(() {
        _invitations = invitations
            .where((invitation) => invitation.status == 'PENDING')
            .toList();
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Something went wrong. Please try again');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _respond(
    StoreInvitation invitation, {
    required bool accept,
  }) async {
    if (_busyId != null) return;
    setState(() {
      _busyId = invitation.id;
      _accepting = accept;
    });

    try {
      if (accept) {
        await _storeInvitations.acceptInvitation(invitation.id);
        if (!mounted) return;
        _showMessage('You joined ${invitation.storeName}');
        final Widget next = SellerGateScreen(openStoreId: invitation.storeId);
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => next),
          (route) => false,
        );
        return;
      }

      await _storeInvitations.declineInvitation(invitation.id);
      if (!mounted) return;
      setState(() {
        _invitations = _invitations
            .where((item) => item.id != invitation.id)
            .toList();
      });
      _showMessage('Invitation declined');
    } on ApiException catch (e) {
      if (!mounted) return;
      _showMessage(e.message, error: true);
      if (e.statusCode == 400 || e.statusCode == 404) {
        _load(showSpinner: false);
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage('Something went wrong. Please try again', error: true);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Widget _centered(ColorScheme cs, List<Widget> children) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        ...children,
      ],
    );
  }

  Widget _body(ColorScheme cs) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: cs.primary));
    }

    if (_error != null) {
      return _centered(cs, [
        Text(
          _error!,
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
      ]);
    }

    if (_invitations.isEmpty) {
      return _centered(cs, [
        Icon(Icons.mail_outline, size: 56, color: cs.primary.withOpacity(0.7)),
        const SizedBox(height: 16),
        Text(
          'No pending invitations',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ask the store owner to invite you using your account email.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: cs.onSurface.withOpacity(0.7)),
        ),
      ]);
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _invitations.length + 1,
      separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 24 : 16),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(
            'You have invites from the following stores.\nChoose one to join and start managing products',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: cs.onSurface),
          );
        }
        final invitation = _invitations[index - 1];
        final bool busy = _busyId == invitation.id;
        return _InvitationCard(
          invitation: invitation,
          disabled: _busyId != null,
          acceptLoading: busy && _accepting,
          declineLoading: busy && !_accepting,
          onAccept: () => _respond(invitation, accept: true),
          onDecline: () => _respond(invitation, accept: false),
        );
      },
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
          onPressed: _busyId != null ? null : () => Navigator.pop(context),
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
          'Join a Store',
          style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: cs.primary,
          onRefresh: () => _load(showSpinner: false),
          child: _body(cs),
        ),
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final StoreInvitation invitation;
  final bool disabled;
  final bool acceptLoading;
  final bool declineLoading;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _InvitationCard({
    required this.invitation,
    required this.disabled,
    required this.acceptLoading,
    required this.declineLoading,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
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
        children: [
          Row(
            children: [
              _StoreAvatar(
                name: invitation.storeName,
                logoUrl: invitation.storeLogoUrl,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  invitation.storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: disabled ? null : onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.primary,
                      side: BorderSide(color: cs.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: declineLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: cs.primary,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Decline'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: FilledButton(
                    onPressed: disabled ? null : onAccept,
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: acceptLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: cs.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Accept'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoreAvatar extends StatelessWidget {
  final String name;
  final String? logoUrl;

  const _StoreAvatar({required this.name, required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    final Widget fallback = Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );

    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE0C3C7),
      ),
      clipBehavior: Clip.antiAlias,
      child: logoUrl == null
          ? fallback
          : Image.network(
              logoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback,
            ),
    );
  }
}
