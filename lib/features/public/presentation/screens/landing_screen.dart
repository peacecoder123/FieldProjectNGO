import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/features/auth/presentation/screens/login_screen.dart';
import 'package:ngo_volunteer_management/features/public/presentation/widgets/donation_dialog.dart'; 

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {

  void _navigateToLogin() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
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
                            ],
                          ),
                        ),
                        // Actions
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: isDark ? Colors.yellow.shade400 : AppColors.slate600),
                              style: IconButton.styleFrom(
                                backgroundColor: isDark ? AppColors.slate800 : Colors.white,
                                padding: const EdgeInsets.all(8),
                                minimumSize: const Size(36, 36),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: isDark ? AppColors.slate700 : AppColors.slate200)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () => DonationDialog.show(context),
                              icon: const Icon(Icons.favorite_rounded, size: 16),
                              label: const Text('Donate'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.rose500,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _navigateToLogin,
                              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                              label: const Text('Login'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.navy500,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                textStyle: const TextStyle(fontSize: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            )
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
    return Container(
      padding: const EdgeInsets.only(top: 120, bottom: 60, left: 24, right: 24),
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
                  style: TextStyle(fontSize: isWide ? 48 : 36, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900, height: 1.2),
                  children: const [
                    TextSpan(text: 'Empowering Communities Through '),
                    TextSpan(text: 'Compassion', style: TextStyle(color: AppColors.navy500)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Join us in creating lasting change. Jayashree Foundation brings together passionate volunteers to serve communities, provide education, healthcare, and hope to those who need it most.',
                style: TextStyle(fontSize: 16, color: isDark ? AppColors.slate400 : AppColors.slate600, height: 1.5),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16, runSpacing: 16,
                children: [
                  ElevatedButton.icon(
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
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : AppColors.slate900,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      side: BorderSide(color: isDark ? AppColors.slate700 : AppColors.slate200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Learn More'),
                  ),
                ],
              ),
            ],
          );

          final imageSection = Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  'https://images.unsplash.com/photo-1761666507437-9fb5a6ef7b0a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx2b2x1bnRlZXIlMjBjb21tdW5pdHklMjBoZWxwaW5nfGVufDF8fHx8MTc3NDUzMDIxOXww&ixlib=rb-4.1.0&q=80&w=1080',
                  height: 500, width: double.infinity, fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: -24, left: -24,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate800 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.navy500, AppColors.navy700]), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.people_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('500+', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)),
                          Text('Active Volunteers', style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
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
                Expanded(flex: 1, child: imageSection),
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
    { 'title': 'Education for All Initiative', 'category': 'Education', 'date': 'March 2026', 'image': 'https://images.unsplash.com/photo-1573288880964-292771cdff84?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjaGlsZHJlbiUyMGVkdWNhdGlvbiUyMGNoYXJpdHl8ZW58MXx8fHwxNzc0NDk3MDE5fDA&ixlib=rb-4.1.0&q=80&w=1080', 'desc': 'Provided quality education materials and tutoring to over 500 underprivileged children across 12 villages.' },
    { 'title': 'Community Food Distribution', 'category': 'Relief', 'date': 'February 2026', 'image': 'https://images.unsplash.com/photo-1628717341663-0007b0ee2597?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmb29kJTIwZGlzdHJpYnV0aW9uJTIwdm9sdW50ZWVyfGVufDF8fHx8MTc3NDUzMDIyMHww&ixlib=rb-4.1.0&q=80&w=1080', 'desc': 'Distributed meals to 1,200 families affected by seasonal unemployment in rural areas.' },
    { 'title': 'Free Medical Health Camp', 'category': 'Healthcare', 'date': 'January 2026', 'image': 'https://images.unsplash.com/photo-1741597727884-1ecd051cadb4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtZWRpY2FsJTIwaGVhbHRoJTIwY2FtcHxlbnwxfHx8fDE3NzQ1MzAyMjB8MA&ixlib=rb-4.1.0&q=80&w=1080', 'desc': 'Organized comprehensive health checkups and free medicines for 800+ patients in underserved communities.' },
    { 'title': 'Green Earth Tree Plantation', 'category': 'Environment', 'date': 'December 2025', 'image': 'https://images.unsplash.com/photo-1703012349431-95c3304d098f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxlbnZpcm9ubWVudCUyMHRyZWUlMjBwbGFudGluZ3xlbnwxfHx8fDE3NzQ1MzAyMjB8MA&ixlib=rb-4.1.0&q=80&w=1080', 'desc': 'Planted 5,000 saplings with volunteers and local communities to combat climate change.' },
  ];

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = screenWidth > 1024 ? 4 : (screenWidth > 600 ? 2 : 1);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: isDark ? AppColors.slate900 : Colors.white,
      child: Column(
        children: [
          Text('Our Recent Works', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)),
          const SizedBox(height: 16),
          Text('Discover the latest initiatives and projects making a real difference in communities across the country', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: isDark ? AppColors.slate400 : AppColors.slate600)),
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
                    child: _WorkCard(isDark: isDark, work: work, cardWidth: cardWidth),
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
              Image.network(work['image']!, height: 150, width: double.infinity, fit: BoxFit.cover),
              Positioned(top: 8, left: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: isDark ? AppColors.slate900.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(12)), child: Text(work['category']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 11, color: isDark ? AppColors.slate400 : AppColors.slate500),
                    const SizedBox(width: 4),
                    Text(work['date']!, style: TextStyle(fontSize: 11, color: isDark ? AppColors.slate400 : AppColors.slate500)),
                  ],
                ),
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
    {'icon': Icons.people_rounded, 'num': '25,000+', 'label': 'Lives Impacted', 'colors': [AppColors.navy500, AppColors.cyan500]},
    {'icon': Icons.emoji_events_rounded, 'num': '15+', 'label': 'Awards Won', 'colors': [AppColors.violet600, AppColors.purple600]},
    {'icon': Icons.favorite_rounded, 'num': '500+', 'label': 'Active Volunteers', 'colors': [AppColors.orange500, AppColors.rose500]},
    {'icon': Icons.trending_up_rounded, 'num': '200+', 'label': 'Projects Completed', 'colors': [AppColors.emerald500, AppColors.teal500]},
  ];

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = screenWidth > 1024 ? 4 : (screenWidth > 600 ? 2 : 1);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
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
          Text('Our Achievements', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)),
          const SizedBox(height: 16),
          Text('Milestones that reflect our commitment to creating positive change', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: isDark ? AppColors.slate400 : AppColors.slate600)),
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
                            child: Icon(stat['icon'] as IconData, color: Colors.white, size: 32),
                          ),
                          const SizedBox(height: 16),
                          Text(stat['num'] as String, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(stat['label'] as String, style: TextStyle(fontSize: 14, color: isDark ? AppColors.slate400 : AppColors.slate600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: isDark ? AppColors.slate900 : Colors.white,
      child: Container(
        padding: const EdgeInsets.all(40),
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
                color: AppColors.rose500.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded, color: AppColors.rose500, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Make a Difference Today',
              style: TextStyle(
                fontSize: 32,
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
                fontSize: 16,
                color: isDark ? AppColors.slate300 : AppColors.slate600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => DonationDialog.show(context),
              icon: const Icon(Icons.volunteer_activism_rounded, size: 20),
              label: const Text('Donate via Razorpay'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rose500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: AppColors.rose500.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_rounded, size: 16, color: isDark ? AppColors.slate400 : AppColors.slate500),
                const SizedBox(width: 6),
                Text(
                  '100% Secure Payments • 80G Tax Benefits Available',
                  style: TextStyle(
                    fontSize: 12,
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
    { 'title': 'Jayashree Foundation Wins National NGO Excellence Award 2026', 'source': 'National Daily', 'date': 'March 15, 2026', 'image': 'https://images.unsplash.com/photo-1762345127396-ac4a970436c3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhd2FyZCUyMGFjaGlldmVtZW50JTIwdHJvcGh5fGVufDF8fHx8MTc3NDUzMDIyMXww&ixlib=rb-4.1.0&q=80&w=1080', 'desc': 'Recognized for outstanding contribution to community development and volunteer mobilization across India.' },
    { 'title': 'Volunteers Rally Together for Rural Healthcare', 'source': 'Health Today', 'date': 'March 10, 2026', 'image': 'https://images.unsplash.com/photo-1751666526244-40239a251eae?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb21tdW5pdHklMjBzZXJ2aWNlJTIwdm9sdW50ZWVyfGVufDF8fHx8MTc3NDUzMDIyMXww&ixlib=rb-4.1.0&q=80&w=1080', 'desc': 'Jayashree Foundation volunteers conducted medical camps reaching remote villages with essential healthcare services.' },
    { 'title': 'Partnership with Global Charity Network Announced', 'source': 'Education Weekly', 'date': 'February 28, 2026', 'image': 'https://images.unsplash.com/photo-1593113702251-272b1bc414a9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjaGFyaXR5JTIwZG9uYXRpb24lMjBoZWxwaW5nfGVufDF8fHx8MTc3NDQ1NjEwN3ww&ixlib=rb-4.1.0&q=80&w=1080', 'desc': 'Strategic collaboration to expand educational programs and provide scholarships to 2,000 students.' },
  ];

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = screenWidth > 800 ? 3 : (screenWidth > 600 ? 2 : 1);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: isDark ? AppColors.slate900 : Colors.white,
      child: Column(
        children: [
          Text('Latest News', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)),
          const SizedBox(height: 16),
          Text('Stay updated with our latest activities and media coverage', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: isDark ? AppColors.slate400 : AppColors.slate600)),
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
                    child: _NewsCard(isDark: isDark, item: item),
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
          Image.network(item['image']!, height: 140, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text(item['source']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.navy500), overflow: TextOverflow.ellipsis)),
                    Flexible(child: Text(item['date']!, style: TextStyle(fontSize: 10, color: isDark ? AppColors.slate400 : AppColors.slate500), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(item['title']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.slate900), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(item['desc']!, style: TextStyle(fontSize: 11, color: isDark ? AppColors.slate400 : AppColors.slate600, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('Read More', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.navy500)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 12, color: isDark ? AppColors.navy400 : AppColors.navy500),
                  ],
                )
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
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
              Text('About Jayashree Foundation', style: TextStyle(fontSize: isWide ? 32 : 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)),
              const SizedBox(height: 16),
              Text('Founded in 2015, Jayashree Foundation is a non-profit organization dedicated to transforming lives through community service, education, healthcare, and environmental initiatives. We believe in the power of collective action and the difference passionate individuals can make.', style: TextStyle(fontSize: isWide ? 16 : 14, color: isDark ? AppColors.slate400 : AppColors.slate600, height: 1.6)),
              const SizedBox(height: 12),
              Text('Our mission is to create sustainable change by empowering communities, supporting underprivileged families, and mobilizing volunteers who share our vision of a better tomorrow.', style: TextStyle(fontSize: isWide ? 16 : 14, color: isDark ? AppColors.slate400 : AppColors.slate600, height: 1.6)),
              const SizedBox(height: 12),
              Text('With a dedicated team of volunteers and partners across India, we continue to expand our reach and impact, touching thousands of lives every year.', style: TextStyle(fontSize: isWide ? 16 : 14, color: isDark ? AppColors.slate400 : AppColors.slate600, height: 1.6)),
            ],
          );

          final contactCard = Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: isDark ? AppColors.slate800 : Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDark ? AppColors.slate700 : AppColors.slate200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Get In Touch', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)),
                const SizedBox(height: 24),
                _ContactRow(isDark: isDark, icon: Icons.location_on_rounded, title: 'Address', detail: '123 Hope Street, Community Center\nMumbai, Maharashtra 400001, India'),
                const SizedBox(height: 16),
                _ContactRow(isDark: isDark, icon: Icons.phone_rounded, title: 'Phone', detail: '+91 22 1234 5678'),
                const SizedBox(height: 16),
                _ContactRow(isDark: isDark, icon: Icons.mail_rounded, title: 'Email', detail: 'contact@jayashreefoundation.org'),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),
                Text('Follow Us', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _SocialButton(isDark: isDark, icon: Icons.facebook_rounded),
                    const SizedBox(width: 12),
                    _SocialButton(isDark: isDark, icon: Icons.chat_bubble_rounded),
                    const SizedBox(width: 12),
                    _SocialButton(isDark: isDark, icon: Icons.camera_alt_rounded),
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

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.isDark, required this.icon});
  final bool isDark;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: isDark ? Colors.blue.shade900.withValues(alpha: 0.3) : AppColors.navy50, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 20, color: isDark ? AppColors.navy400 : AppColors.navy500),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      color: isDark ? AppColors.slate950 : AppColors.slate900,
      child: Row(
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