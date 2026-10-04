import 'package:flutter/material.dart';
import 'package:kisekae/screens/getting_started.dart';
import 'package:kisekae/screens/onboarding/onboarding2.dart';

class OnBoarding1 extends StatelessWidget {
  const OnBoarding1({super.key, this.onThemeChanged});

  final ValueChanged<bool>? onThemeChanged;
  final int _pageCount = 3;
  final int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final base = Theme.of(context);
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
                fontWeight: FontWeight.w400,
              ),
            ),
      ),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;
          final textTheme = theme.textTheme;
          final isDark = theme.brightness == Brightness.dark;

          return Scaffold(
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              actions: [
                _ThemeToggle(isDark: isDark, onChanged: onThemeChanged),
                const SizedBox(width: 16),
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
                    const SizedBox(height: 24),
                    Text(
                      'Your style,\nnow in AR',
                      style: textTheme.headlineLarge?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Try on outfits ,see the fit,\nfeel the confidence -\nbefore you buy.',
                      style: textTheme.titleLarge?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Flexible(
                      child: SizedBox(
                        height: size.height * 0.4,
                        child: Center(
                          child: Image.asset(
                            'assets/images/onboarding1.png',
                            fit: BoxFit.contain,
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
                              builder: (context) => const OnBoarding2(),
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

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.isDark, this.onChanged});

  final bool isDark;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const double width = 64;
    const double height = 30;
    const double thumb = 24;

    return GestureDetector(
      onTap: () => onChanged?.call(!isDark),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(height),
          border: Border.all(color: scheme.onSurface, width: 1.2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: thumb,
                  child: Icon(
                    Icons.wb_sunny_rounded,
                    size: 14,
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(
                  width: thumb,
                  child: Icon(
                    Icons.nightlight_round,
                    size: 14,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: thumb,
                height: thumb,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary,
                ),
                child: Icon(
                  isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  size: 14,
                  color: scheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
