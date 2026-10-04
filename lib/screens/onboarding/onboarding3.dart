import 'package:flutter/material.dart';
import 'package:kisekae/screens/getting_started.dart';

class OnBoarding3 extends StatelessWidget {
  const OnBoarding3({super.key});

  final int _pageCount = 3;
  final int _currentPage = 2;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Theme(
      data: base.copyWith(
        textTheme: base.textTheme
            .apply(fontFamily: 'sans-serif')
            .copyWith(
              headlineLarge: base.textTheme.headlineLarge?.copyWith(
                fontFamily: 'PlayfairDisplay',
                fontFamilyFallback: const ['serif'],
                fontSize: 32,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
              titleLarge: base.textTheme.titleLarge?.copyWith(
                fontFamily: 'sans-serif',
                fontSize: 20,
                height: 1.25,
                fontWeight: FontWeight.w400,
              ),
              titleMedium: base.textTheme.titleMedium?.copyWith(
                fontFamily: 'sans-serif',
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              labelLarge: base.textTheme.labelLarge?.copyWith(
                fontFamily: 'sans-serif',
                fontSize: 12,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w400,
              ),
            ),
      ),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;
          final textTheme = theme.textTheme;

          return Scaffold(
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.onSurface, width: 2),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: scheme.onSurface,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GettingStartedScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.onSurface,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text('skip', style: textTheme.titleMedium),
                ),
                const SizedBox(width: 12),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    Text(
                      'Curated,\nfor you',
                      style: textTheme.headlineLarge?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Discover styles that match\nyour vibe, preference\nand mood.',
                      style: textTheme.titleLarge?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Flexible(
                      child: SizedBox(
                        height: size.height * 0.4,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: AspectRatio(
                            aspectRatio: 4 / 5,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/images/onboarding3.png',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pageCount, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? scheme.secondary
                                : scheme.primary.withValues(alpha: 0.25),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const GettingStartedScreen(),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'CONTINUE',
                          style: textTheme.labelLarge?.copyWith(
                            color: scheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
