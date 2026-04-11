import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/features/public/presentation/widgets/donation_dialog.dart';
import 'package:ngo_volunteer_management/shared/providers/app_providers.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {

  void _navigateToLogin() {
    context.push('/login');
  }

  Future<void> _showExitConfirmation() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.slate800 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Exit App', style: TextStyle(color: isDark ? Colors.white : AppColors.slate900)),
        content: Text(
          'Are you sure you want to exit?',
          style: TextStyle(color: isDark ? AppColors.slate300 : AppColors.slate600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rose500,
              foregroundColor: Colors.white,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    if (shouldExit == true && mounted) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.paddingOf(context).top;
    final isNarrow = screenWidth < 600;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _showExitConfirmation();
      },
      child: Scaffold(
      backgroundColor: isDark ? AppColors.slate900 : Colors.white,
      body: Stack(
        children: [
          // Main Scrollable Content — respect status bar padding
          SingleChildScrollView(
            padding: EdgeInsets.only(top: topPadding + 70),
            child: Column(
              children: [
                _HeroSection(isDark: isDark, onLoginTap: _navigateToLogin),
                _RecentWorksSection(isDark: isDark, screenWidth: screenWidth),
                _AchievementsSection(isDark: isDark, screenWidth: screenWidth),
                _DonationSection(isDark: isDark, screenWidth: screenWidth),
                _NewsSection(isDark: isDark, screenWidth: screenWidth),
                _AboutSection(isDark: isDark, screenWidth: screenWidth),
                _Footer(isDark: isDark),
              ],
            ),
          ),

          // Sticky Glassmorphism NavBar — pinned to top with status bar padding
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: topPadding),
              color: isDark ? AppColors.slate900 : Colors.white,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.slate900.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
                      border: Border(bottom: BorderSide(color: isDark ? AppColors.slate800 : AppColors.slate200)),
                    ),
                    child: Row(
                      children: [
                        // Logo and title
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset('assets/images/logo.png', width: 36, height: 36, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 12),
                              if (!isNarrow)
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Jayashree Foundation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : AppColors.slate900), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      Text('NGO', style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
                                    ],
                                  ),
                                )
                              else
                                Expanded(
                                  child: Text('Jayashree', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppColors.slate900), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                            ],
                          ),
                        ),
                        // Actions — responsive
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Theme toggle
                            _HoverIconButton(
                              onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
                              icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: isDark ? Colors.yellow.shade400 : AppColors.slate600),
                              style: IconButton.styleFrom(
                                backgroundColor: isDark ? AppColors.slate800 : Colors.white,
                                padding: const EdgeInsets.all(8),
                                minimumSize: const Size(36, 36),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: isDark ? AppColors.slate700 : AppColors.slate200)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Donate button
                            _HoverButton(
                              onPressed: () => DonationDialog.show(context),
                              icon: isNarrow ? null : const Icon(Icons.favorite_rounded, size: 16),
                              label: isNarrow ? const Icon(Icons.favorite_rounded, size: 18, color: Colors.white) : const Text('Donate'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.rose500,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                padding: isNarrow
                                    ? const EdgeInsets.all(10)
                                    : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              isIconOnly: isNarrow,
                            ),
                            const SizedBox(width: 8),
                            // Login button
                            _HoverButton(
                              onPressed: _navigateToLogin,
                              icon: isNarrow ? null : const Icon(Icons.arrow_forward_rounded, size: 16),
                              label: isNarrow ? const Icon(Icons.login_rounded, size: 18, color: Colors.white) : const Text('Login'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.navy500,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                padding: isNarrow
                                    ? const EdgeInsets.all(10)
                                    : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                textStyle: const TextStyle(fontSize: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              isIconOnly: isNarrow,
                            ),
                          ],
                        )
                      ],
                    ),
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
}

// ── Hover-aware button wrappers ─────────────────────────────────────────────

class _HoverIconButton extends StatefulWidget {
  const _HoverIconButton({required this.onPressed, required this.icon, required this.style});
  final VoidCallback onPressed;
  final Widget icon;
  final ButtonStyle style;

  @override
  State<_HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<_HoverIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: IconButton(
          onPressed: widget.onPressed,
          icon: widget.icon,
          style: widget.style,
        ),
      ),
    );
  }
}

class _HoverButton extends StatefulWidget {
  const _HoverButton({required this.onPressed, this.icon, required this.label, required this.style, this.isIconOnly = false});
  final VoidCallback onPressed;
  final Widget? icon;
  final Widget label;
  final ButtonStyle style;
  final bool isIconOnly;

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: widget.isIconOnly
            ? ElevatedButton(
                onPressed: widget.onPressed,
                style: widget.style,
                child: widget.label,
              )
            : ElevatedButton.icon(
                onPressed: widget.onPressed,
                icon: widget.icon,
                label: widget.label,
                style: widget.style,
              ),
      ),
    );
  }
}

// ── Hover card wrapper (reused across all cards) ────────────────────────────

class _HoverCard extends StatefulWidget {
  const _HoverCard({required this.child});
  final Widget child;

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0.0, _hovered ? -6.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            boxShadow: _hovered
                ? [BoxShadow(color: AppColors.navy500.withValues(alpha: 0.15), blurRadius: 24, offset: const Offset(0, 8))]
                : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: widget.child,
      ),
    );
  }
}

// --- SECTIONS ---

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isDark, required this.onLoginTap});
  final bool isDark;
  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 600;

    return Container(
      padding: EdgeInsets.only(top: isNarrow ? 60 : 120, bottom: isNarrow ? 40 : 60, left: 24, right: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: isDark 
            ? [AppColors.slate900, AppColors.slate900] 
            : [AppColors.slate50, AppColors.navy50.withValues(alpha: 0.3), Colors.indigo.shade50.withValues(alpha: 0.4)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;

          final leftColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: isDark ? AppColors.navy700.withValues(alpha: 0.3) : AppColors.navy50, borderRadius: BorderRadius.circular(30)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_rounded, size: 14, color: isDark ? AppColors.navy400 : AppColors.navy500),
                    const SizedBox(width: 8),
                    Text('Making a Difference Together', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.navy400 : AppColors.navy700)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: isWide ? 48 : (isNarrow ? 28 : 36), fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900, height: 1.2),
                  children: const [
                    TextSpan(text: 'Welcome to \n'),
                    TextSpan(text: 'Jayashree Foundation', style: TextStyle(color: AppColors.navy500)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'A public charitable trust working for the benefit of all persons regardless of gender, caste, creed, or religion. Empowering Communities Since 2019.',
                style: TextStyle(fontSize: isNarrow ? 14 : 16, color: isDark ? AppColors.slate400 : AppColors.slate600, height: 1.5),
              ),
              const SizedBox(height: 32),
              // Only "Get Started" button — "Learn More" removed
              _HoverButton(
                onPressed: onLoginTap,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Get Started'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy500, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          );

          final imageHeight = isNarrow ? screenHeight * 0.35 : (isWide ? 500.0 : 400.0);

          final imageSection = Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?auto=format&fit=crop&w=1080&q=80',
                  height: imageHeight, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: imageHeight,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.slate800 : AppColors.slate100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(child: Icon(Icons.image_rounded, size: 64, color: AppColors.slate400)),
                  ),
                ),
              ),
              Positioned(
                bottom: isNarrow ? -16 : -24, left: isNarrow ? -8 : -24,
                child: Container(
                  padding: EdgeInsets.all(isNarrow ? 12 : 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate800 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isNarrow ? 8 : 12),
                        decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.navy500, AppColors.navy700]), borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.favorite_rounded, color: Colors.white, size: isNarrow ? 18 : 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('1,000+', style: TextStyle(fontSize: isNarrow ? 18 : 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)),
                          Text('Lives Impacted', style: TextStyle(fontSize: isNarrow ? 10 : 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 1, child: leftColumn),
                const SizedBox(width: 48),
                Expanded(flex: 1, child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 500), child: imageSection))),
              ],
            );
          }
          return Column(
            children: [leftColumn, const SizedBox(height: 48), imageSection],
          );
        },
      ),
    );
  }
}

class _RecentWorksSection extends StatelessWidget {
  const _RecentWorksSection({required this.isDark, required this.screenWidth});
  final bool isDark;
  final double screenWidth;

  final recentWorks = const [
    { 'title': 'Sponsored Education', 'category': 'Education', 'date': 'Latest', 'image': 'assets/images/sponsored_education.jpg', 'desc': 'We sponsored the education of students who were unable to pay their school fees.' },
    { 'title': 'Tree Plantation Drive', 'category': 'Environment', 'date': 'Latest', 'image': 'assets/images/tree_plantation.jpg', 'desc': 'We conducted Tree plantation because tree plantation is very necessary to counter Global warming.' },
    { 'title': 'Mask Distribution', 'category': 'Relief', 'date': 'Latest', 'image': 'assets/images/mask_distribution.png', 'desc': 'We distributed masks to the poor people in order to stop the spread of covid-19.' },
  ];

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = screenWidth > 800 ? 3 : (screenWidth > 600 ? 2 : 1);

    return Container(
      padding: EdgeInsets.symmetric(vertical: screenWidth < 600 ? 48 : 80, horizontal: screenWidth < 600 ? 16 : 24),
      color: isDark ? AppColors.slate900 : Colors.white,
      child: Column(
        children: [
          Text('Our Recent Works', style: TextStyle(fontSize: screenWidth < 600 ? 24 : 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)),
          const SizedBox(height: 16),
          Text('Discover the latest initiatives and projects making a real difference in communities across the country', textAlign: TextAlign.center, style: TextStyle(fontSize: screenWidth < 600 ? 14 : 16, color: isDark ? AppColors.slate400 : AppColors.slate600)),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (ctx, constraints) {
              final cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * 24) / crossAxisCount;
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: List.generate(recentWorks.length, (index) {
                  final work = recentWorks[index];
                  return SizedBox(
                    width: cardWidth,
                    child: _HoverCard(
                      child: _WorkCard(isDark: isDark, work: work, cardWidth: cardWidth),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WorkCard extends StatelessWidget {
  const _WorkCard({required this.isDark, required this.work, required this.cardWidth});
  final bool isDark;
  final Map work;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.asset(work['image']!, height: 180, width: double.infinity, fit: BoxFit.cover),
              Positioned(top: 8, left: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: isDark ? AppColors.slate900.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(12)), child: Text(work['category']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(work['title']!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(work['desc']!, style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate600, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection({required this.isDark, required this.screenWidth});
  final bool isDark;
  final double screenWidth;

  final stats = const [
    {'icon': Icons.favorite_rounded, 'num': '6,983+', 'label': 'Beneficiaries', 'colors': [AppColors.navy500, AppColors.cyan500]},
    {'icon': Icons.timer_rounded, 'num': '43,099+', 'label': 'Volunteer Hours', 'colors': [AppColors.violet600, AppColors.purple600]},
    {'icon': Icons.book_rounded, 'num': '5,538+', 'label': 'Books Distributed', 'colors': [AppColors.orange500, AppColors.rose500]},
    {'icon': Icons.computer_rounded, 'num': '45+', 'label': 'E-Classes Conducted', 'colors': [AppColors.emerald500, AppColors.teal500]},
  ];

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = screenWidth > 1024 ? 4 : (screenWidth > 600 ? 2 : 2);

    return Container(
      padding: EdgeInsets.symmetric(vertical: screenWidth < 600 ? 48 : 80, horizontal: screenWidth < 600 ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: isDark
            ? [AppColors.slate900, AppColors.slate900]
            : [AppColors.slate50, AppColors.navy50.withValues(alpha: 0.3), Colors.indigo.shade50.withValues(alpha: 0.4)],
        ),
      ),
      child: Column(
        children: [
          Text('Our Achievements', style: TextStyle(fontSize: screenWidth < 600 ? 24 : 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)),
          const SizedBox(height: 16),
          Text('Milestones that reflect our commitment to creating positive change', textAlign: TextAlign.center, style: TextStyle(fontSize: screenWidth < 600 ? 14 : 16, color: isDark ? AppColors.slate400 : AppColors.slate600)),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (ctx, constraints) {
              final cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * 24) / crossAxisCount;
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: List.generate(stats.length, (index) {
                  final stat = stats[index];
                  return SizedBox(
                    width: cardWidth,
                    child: _HoverCard(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.slate800 : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(gradient: LinearGradient(colors: stat['colors'] as List<Color>), borderRadius: BorderRadius.circular(16)),
                              child: Icon(stat['icon'] as IconData, color: Colors.white, size: screenWidth < 600 ? 24 : 32),
                            ),
                            const SizedBox(height: 16),
                            Text(stat['num'] as String, style: TextStyle(fontSize: screenWidth < 600 ? 22 : 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(stat['label'] as String, style: TextStyle(fontSize: screenWidth < 600 ? 12 : 14, color: isDark ? AppColors.slate400 : AppColors.slate600), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DonationSection extends StatelessWidget {
  const _DonationSection({required this.isDark, required this.screenWidth});
  final bool isDark;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final isNarrow = screenWidth < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isNarrow ? 48 : 80, horizontal: isNarrow ? 16 : 24),
      color: isDark ? AppColors.slate900 : Colors.white,
      child: Container(
        padding: EdgeInsets.all(isNarrow ? 24 : 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.navy700.withValues(alpha: 0.4), AppColors.indigo600.withValues(alpha: 0.4)]
                : [AppColors.blue50, AppColors.blue50],
          ),
          border: Border.all(
            color: isDark ? AppColors.blue500.withValues(alpha: 0.2) : AppColors.blue100,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.rose500.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded, color: AppColors.rose500, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Make a Difference Today',
              style: TextStyle(
                fontSize: isNarrow ? 24 : 32,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.slate900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your contribution helps us continue our mission of providing healthcare, education, and support to communities in need. Every rupee counts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isNarrow ? 14 : 16,
                color: isDark ? AppColors.slate300 : AppColors.slate600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _HoverButton(
              onPressed: () => DonationDialog.show(context),
              icon: const Icon(Icons.volunteer_activism_rounded, size: 20),
              label: const Text('Donate via Razorpay'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rose500,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: isNarrow ? 20 : 32, vertical: 16),
                textStyle: TextStyle(fontSize: isNarrow ? 15 : 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: AppColors.rose500.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(Icons.shield_rounded, size: 16, color: isDark ? AppColors.slate400 : AppColors.slate500),
                const SizedBox(width: 6),
                Text(
                  '100% Secure Payments • 80G Tax Benefits Available',
                  style: TextStyle(
                    fontSize: isNarrow ? 11 : 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.slate400 : AppColors.slate500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsSection extends StatelessWidget {
  const _NewsSection({required this.isDark, required this.screenWidth});
  final bool isDark;
  final double screenWidth;

  final news = const [
    { 'title': 'Education Initiatives', 'source': 'Focus Area', 'date': '', 'image': 'https://images.unsplash.com/photo-1511629091441-ee46146481b6?auto=format&fit=crop&w=1080&q=80', 'desc': 'Holistic education and quality skill development of rural masses & women. We provide necessary support.' },
    { 'title': 'Health & Wellbeing', 'source': 'Focus Area', 'date': '', 'image': 'assets/images/health_wellbeing.png', 'desc': 'Awareness & Guidance on Menstrual Health and Puberty amongst the masses to ensure better living.' },
    { 'title': 'Environment Protection', 'source': 'Focus Area', 'date': '', 'image': 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&w=1080&q=80', 'desc': 'Mentoring, Guiding and creating the entrepreneurial and self-reliance mindset while protecting nature.' },
  ];

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = screenWidth > 800 ? 3 : (screenWidth > 600 ? 2 : 1);

    return Container(
      padding: EdgeInsets.symmetric(vertical: screenWidth < 600 ? 48 : 80, horizontal: screenWidth < 600 ? 16 : 24),
      color: isDark ? AppColors.slate900 : Colors.white,
      child: Column(
        children: [
          Text('Our Focus Areas', style: TextStyle(fontSize: screenWidth < 600 ? 24 : 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)),
          const SizedBox(height: 16),
          Text('The key pillars of our mission', textAlign: TextAlign.center, style: TextStyle(fontSize: screenWidth < 600 ? 14 : 16, color: isDark ? AppColors.slate400 : AppColors.slate600)),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (ctx, constraints) {
              final cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * 24) / crossAxisCount;
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: List.generate(news.length, (index) {
                  final item = news[index];
                  return SizedBox(
                    width: cardWidth,
                    child: _HoverCard(
                      child: _NewsCard(isDark: isDark, item: item),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.isDark, required this.item});
  final bool isDark;
  final Map item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          item['image']!.toString().startsWith('http') 
              ? Image.network(
                  item['image']!, height: 140, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140, color: isDark ? AppColors.slate700 : AppColors.slate100,
                    child: const Center(child: Icon(Icons.image_rounded, size: 40, color: AppColors.slate400)),
                  ),
                )
              : Image.asset(item['image']!, height: 140, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title']!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(item['desc']!, style: TextStyle(fontSize: 11, color: isDark ? AppColors.slate400 : AppColors.slate600, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.isDark, required this.screenWidth});
  final bool isDark;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final isNarrow = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(vertical: isNarrow ? 48 : 80, horizontal: isNarrow ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: isDark 
            ? [AppColors.slate900, AppColors.slate900] 
            : [AppColors.slate50, AppColors.navy50.withValues(alpha: 0.3), Colors.indigo.shade50.withValues(alpha: 0.4)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;

          final aboutColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About Jayashree Foundation', style: TextStyle(fontSize: isWide ? 32 : (isNarrow ? 22 : 24), fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)),
              const SizedBox(height: 16),
              Text('Jayashree Foundation is a Mumbai based Indian not-for-profit organization registered as a section 8 of The Companies Act 2013 in India started in 2019 and this NGO is led by Vaibhav Jadhav. We have projects all over India for education, health & development.', style: TextStyle(fontSize: isNarrow ? 13 : (isWide ? 16 : 14), color: isDark ? AppColors.slate400 : AppColors.slate600, height: 1.6)),
              const SizedBox(height: 12),
              Text('It is an initiative of like-minded people and various well-wishers who believe, "Goodness is the only investment that never fails" and at Jayashree foundation we believe in doing good.', style: TextStyle(fontSize: isNarrow ? 13 : (isWide ? 16 : 14), color: isDark ? AppColors.slate400 : AppColors.slate600, height: 1.6)),
              const SizedBox(height: 12),
              Text('Be it big or small, efforts will make a difference. We are passionate about social work and you can start your journey too!', style: TextStyle(fontSize: isNarrow ? 13 : (isWide ? 16 : 14), color: isDark ? AppColors.slate400 : AppColors.slate600, height: 1.6)),
            ],
          );

          final contactCard = Container(
            padding: EdgeInsets.all(isNarrow ? 20 : 32),
            decoration: BoxDecoration(color: isDark ? AppColors.slate800 : Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Get In Touch', style: TextStyle(fontSize: isNarrow ? 20 : 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)),
                const SizedBox(height: 24),
                _ContactRow(isDark: isDark, icon: Icons.location_on_rounded, title: 'Address', detail: 'Room No -17, Plot No. 46, Sahyadri Society\nSector 16 A, Nerul West, Navi Mumbai\nMaharashtra 400706'),
                const SizedBox(height: 16),
                _ContactRow(isDark: isDark, icon: Icons.phone_rounded, title: 'Phone', detail: '+91 9876543210'),
                const SizedBox(height: 16),
                _ContactRow(isDark: isDark, icon: Icons.mail_rounded, title: 'Email', detail: 'contact@jayashreefoundation.org'),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),
                Text('Follow Us', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _SocialButton(isDark: isDark, icon: FontAwesomeIcons.facebook, url: 'https://www.facebook.com/people/Jayashree-Foundation/100080648706671/?mibextid=LQQJ4d'),
                    const SizedBox(width: 12),
                    _SocialButton(isDark: isDark, icon: FontAwesomeIcons.instagram, url: 'https://www.instagram.com/jayashree_foundation/?igshid=MzRlODBiNWFlZA%3D%3D'),
                  ],
                )
              ],
            ),
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: aboutColumn),
                const SizedBox(width: 48),
                Expanded(flex: 1, child: contactCard),
              ],
            );
          }
          return Column(
            children: [aboutColumn, const SizedBox(height: 48), contactCard],
          );
        },
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.isDark, required this.icon, required this.title, required this.detail});
  final bool isDark;
  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isDark ? Colors.blue.shade900.withValues(alpha: 0.3) : AppColors.navy50, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 20, color: isDark ? AppColors.navy400 : AppColors.navy500)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)), const SizedBox(height: 4), Text(detail, style: TextStyle(fontSize: 14, color: isDark ? AppColors.slate400 : AppColors.slate600))])),
      ],
    );
  }
}

class _SocialButton extends StatefulWidget {
  const _SocialButton({required this.isDark, required this.icon, this.url});
  final bool isDark;
  final IconData icon;
  final String? url;

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _hovered = false;

  Future<void> _openUrl() async {
    if (widget.url != null) {
      final uri = Uri.parse(widget.url!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openUrl,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedScale(
          scale: _hovered ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 44, height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _hovered
                  ? (widget.isDark ? AppColors.navy700 : AppColors.navy100)
                  : (widget.isDark ? Colors.blue.shade900.withValues(alpha: 0.3) : AppColors.navy50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FaIcon(widget.icon, size: 20, color: widget.isDark ? AppColors.navy400 : AppColors.navy500),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: isNarrow ? 12 : 16),
      color: isDark ? AppColors.slate950 : AppColors.slate900,
      child: isNarrow
          ? Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.navy500, AppColors.navy700]), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.favorite_rounded, size: 14, color: Colors.white)),
                    const SizedBox(width: 12),
                    const Text('Jayashree Foundation', style: TextStyle(color: AppColors.slate300, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('© 2026 All rights reserved.', style: TextStyle(color: isDark ? AppColors.slate500 : AppColors.slate400, fontSize: 11)),
                const SizedBox(height: 4),
                const Text('Making a Difference Together', style: TextStyle(color: AppColors.slate500, fontSize: 11)),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.navy500, AppColors.navy700]), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.favorite_rounded, size: 14, color: Colors.white)),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text('© 2026 Jayashree Foundation. All rights reserved.', style: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate400, fontSize: 12), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                const Flexible(
                  child: Text('Making a Difference Together', style: TextStyle(color: AppColors.slate500, fontSize: 11), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
    );
  }
}