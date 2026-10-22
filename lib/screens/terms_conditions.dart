import 'package:flutter/material.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key, this.initiallyAgreed = false});

  final bool initiallyAgreed;

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  static const _lastUpdated = '2 oct 2026';
  static const _contactEmail = 'support@kisekae.live';

  static const _intro =
      'Welcome to Kisekae. By creating an account or using the Kisekae app, '
      'you agree to these Terms & Conditions. Please read them carefully '
      'before using our services.';

  static const _sections = <(String, String)>[
    (
      '1. Account',
      'Please provide accurate information when creating your account. You '
          'are responsible for keeping your account and login details secure.',
    ),
    (
      '2. Products & Orders',
      'Product prices, availability, sizes, colours, and details may change. '
          'Orders are confirmed only after successful payment and order '
          'confirmation.',
    ),
    (
      '3. AR Virtual Try-On',
      'AR Try-On is provided for visualization purposes. The actual fit, '
          'colour, size, and appearance of a product may vary from the '
          'virtual representation.',
    ),
    (
      '4. Payments',
      'All payments must be made through the payment methods available on '
          'Kisekae. Additional applicable taxes or charges will be shown at '
          'checkout.',
    ),
    (
      '5. Returns & Refunds',
      'Returns, exchanges, cancellations, and refunds are subject to our '
          'Return & Refund Policy and applicable product conditions.',
    ),
    (
      '6. User Content',
      'You are responsible for any photos or other content you upload while '
          'using Kisekae. Do not upload content without the necessary rights '
          'or permission.',
    ),
    (
      '7. Privacy',
      'Your personal information is handled according to our Privacy Policy.',
    ),
    (
      '8. Changes to Terms',
      'Kisekae may update these Terms & Conditions when necessary. Continued '
          'use of the app means you accept the updated terms.',
    ),
  ];

  late bool _agreed = widget.initiallyAgreed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bodyStyle = TextStyle(
      fontSize: 14,
      height: 1.35,
      color: cs.onSurface,
    );
    final titleStyle = bodyStyle.copyWith(fontWeight: FontWeight.w700);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, _agreed);
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: cs.surface,
          surfaceTintColor: cs.surface,
          leading: IconButton(
            onPressed: () => Navigator.pop(context, _agreed),
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
            'Terms and conditions',
            style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Last updated: $_lastUpdated', style: bodyStyle),
                      Text(_intro, style: bodyStyle),
                      const SizedBox(height: 16),
                      for (final section in _sections) ...[
                        Text(section.$1, style: titleStyle),
                        Text(section.$2, style: bodyStyle),
                        const SizedBox(height: 16),
                      ],
                      Text.rich(
                        TextSpan(
                          style: bodyStyle,
                          children: [
                            TextSpan(text: 'Contact: ', style: titleStyle),
                            TextSpan(
                              text: _contactEmail,
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
                child: Row(
                  children: [
                    Checkbox(
                      value: _agreed,
                      activeColor: cs.primary,
                      checkColor: cs.onPrimary,
                      onChanged: (value) =>
                          setState(() => _agreed = value ?? false),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _agreed = !_agreed),
                        child: Text(
                          'I agree to the Terms & Conditions and Privacy '
                          'Policy',
                          style: bodyStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
