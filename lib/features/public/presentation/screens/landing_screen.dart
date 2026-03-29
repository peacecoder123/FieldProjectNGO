import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';
import 'package:ngo_volunteer_management/features/auth/presentation/screens/login_screen.dart'; 

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

    return Scaffold(
      backgroundColor: isDark ? AppColors.slate900 : Colors.white,
      body: Stack(
        children: [
          // Main Scrollable Content
          SingleChildScrollView(
            child: Column(
              children: [
                _HeroSection(isDark: isDark, onLoginTap: _navigateToLogin),
                _RecentWorksSection(isDark: isDark, screenWidth: screenWidth),
                _AchievementsSection(isDark: isDark, screenWidth: screenWidth),
                _NewsSection(isDark: isDark, screenWidth: screenWidth),
                _AboutSection(isDark: isDark, screenWidth: screenWidth),
                _Footer(isDark: isDark),
              ],
            ),
          ),
          
          // Sticky Glassmorphism NavBar
          Positioned(
            top: 0, left: 0, right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate900.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
                    border: Border(bottom: BorderSide(color: isDark ? AppColors.slate800 : AppColors.slate200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppColors.blue600, AppColors.indigo600]),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: AppColors.blue500.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                            ),
                            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Jayashree Foundation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : AppColors.slate900)),
                              Text('NGO', style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {}, 
                            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: isDark ? Colors.yellow.shade400 : AppColors.slate600),
                            style: IconButton.styleFrom(
                              backgroundColor: isDark ? AppColors.slate800 : Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: isDark ? AppColors.slate700 : AppColors.slate200)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _navigateToLogin,
                            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                            label: const Text('Login'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue600,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
            : [AppColors.slate50, AppColors.blue50.withValues(alpha: 0.3), Colors.indigo.shade50.withValues(alpha: 0.4)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          final content = [
            Expanded(
              flex: isWide ? 1 : 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: isDark ? Colors.blue.shade900.withValues(alpha: 0.3) : AppColors.blue50, borderRadius: BorderRadius.circular(30)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_rounded, size: 14, color: isDark ? AppColors.blue400 : AppColors.blue600),
                        const SizedBox(width: 8),
                        Text('Making a Difference Together', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.blue400 : AppColors.blue700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: isWide ? 48 : 36, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900, height: 1.2),
                      children: const [
                        TextSpan(text: 'Empowering Communities Through '),
                        TextSpan(text: 'Compassion', style: TextStyle(color: AppColors.blue600)),
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
                          backgroundColor: AppColors.blue600, foregroundColor: Colors.white,
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
              ),
            ),
            if (isWide) const SizedBox(width: 48) else const SizedBox(height: 48),
            Expanded(
              flex: isWide ? 1 : 0,
              child: Stack(
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
                            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.blue600, AppColors.indigo600]), borderRadius: BorderRadius.circular(8)),
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
              ),
            ),
          ];

          return isWide 
            ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: content)
            : Column(children: content);
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, crossAxisSpacing: 24, mainAxisSpacing: 24, childAspectRatio: 0.75),
            itemCount: recentWorks.length,
            itemBuilder: (context, index) {
              final work = recentWorks[index];
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
                        Image.network(work['image']!, height: 180, width: double.infinity, fit: BoxFit.cover),
                        Positioned(top: 12, left: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isDark ? AppColors.slate900.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(20)), child: Text(work['category']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)))),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [Icon(Icons.calendar_today_rounded, size: 14, color: isDark ? AppColors.slate400 : AppColors.slate500), const SizedBox(width: 8), Text(work['date']!, style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500))]),
                          const SizedBox(height: 12),
                          Text(work['title']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          Text(work['desc']!, style: TextStyle(fontSize: 14, color: isDark ? AppColors.slate400 : AppColors.slate600), maxLines: 3, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          )
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
    {'icon': Icons.people_rounded, 'num': '25,000+', 'label': 'Lives Impacted', 'colors': [AppColors.blue600, AppColors.cyan500]},
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
            : [AppColors.slate50, AppColors.blue50.withValues(alpha: 0.3), Colors.indigo.shade50.withValues(alpha: 0.4)],
        ),
      ),
      child: Column(
        children: [
          Text('Our Achievements', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)),
          const SizedBox(height: 16),
          Text('Milestones that reflect our commitment to creating positive change', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: isDark ? AppColors.slate400 : AppColors.slate600)),
          const SizedBox(height: 48),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, crossAxisSpacing: 24, mainAxisSpacing: 24, childAspectRatio: 1.2),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              return Container(
                padding: const EdgeInsets.all(32),
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
                    Text(stat['num'] as String, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)),
                    const SizedBox(height: 4),
                    Text(stat['label'] as String, style: TextStyle(fontSize: 14, color: isDark ? AppColors.slate400 : AppColors.slate600)),
                  ],
                ),
              );
            },
          )
        ],
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
    int crossAxisCount = screenWidth > 800 ? 3 : 1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: isDark ? AppColors.slate900 : Colors.white,
      child: Column(
        children: [
          Text('Latest News', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)),
          const SizedBox(height: 16),
          Text('Stay updated with our latest activities and media coverage', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: isDark ? AppColors.slate400 : AppColors.slate600)),
          const SizedBox(height: 48),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, crossAxisSpacing: 24, mainAxisSpacing: 24, childAspectRatio: 0.8),
            itemCount: news.length,
            itemBuilder: (context, index) {
              final item = news[index];
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
                    Image.network(item['image']!, height: 200, width: double.infinity, fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item['source']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.blue400 : AppColors.blue600)),
                              Text(item['date']!, style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate500)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(item['title']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 12),
                          Text(item['desc']!, style: TextStyle(fontSize: 14, color: isDark ? AppColors.slate400 : AppColors.slate600), maxLines: 3, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text('Read More', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.blue400 : AppColors.blue600)),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 16, color: isDark ? AppColors.blue400 : AppColors.blue600),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          )
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
            : [AppColors.slate50, AppColors.blue50.withValues(alpha: 0.3), Colors.indigo.shade50.withValues(alpha: 0.4)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          final content = [
            Expanded(
              flex: isWide ? 1 : 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About Jayashree Foundation', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900)),
                  const SizedBox(height: 24),
                  Text('Founded in 2015, Jayashree Foundation is a non-profit organization dedicated to transforming lives through community service, education, healthcare, and environmental initiatives. We believe in the power of collective action and the difference passionate individuals can make.', style: TextStyle(fontSize: 16, color: isDark ? AppColors.slate400 : AppColors.slate600, height: 1.6)),
                  const SizedBox(height: 16),
                  Text('Our mission is to create sustainable change by empowering communities, supporting underprivileged families, and mobilizing volunteers who share our vision of a better tomorrow.', style: TextStyle(fontSize: 16, color: isDark ? AppColors.slate400 : AppColors.slate600, height: 1.6)),
                  const SizedBox(height: 16),
                  Text('With a dedicated team of volunteers and partners across India, we continue to expand our reach and impact, touching thousands of lives every year.', style: TextStyle(fontSize: 16, color: isDark ? AppColors.slate400 : AppColors.slate600, height: 1.6)),
                ],
              ),
            ),
            if (isWide) const SizedBox(width: 48) else const SizedBox(height: 48),
            Expanded(
              flex: isWide ? 1 : 0,
              child: Container(
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
              ),
            )
          ];

          return isWide ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: content) : Column(children: content);
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
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isDark ? Colors.blue.shade900.withValues(alpha: 0.3) : AppColors.blue50, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 20, color: isDark ? AppColors.blue400 : AppColors.blue600)),
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
      decoration: BoxDecoration(color: isDark ? Colors.blue.shade900.withValues(alpha: 0.3) : AppColors.blue50, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 20, color: isDark ? AppColors.blue400 : AppColors.blue600),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      color: isDark ? AppColors.slate950 : AppColors.slate900,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.blue600, AppColors.indigo600]), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.favorite_rounded, size: 14, color: Colors.white)),
              const SizedBox(width: 12),
              const Text('© 2026 Jayashree Foundation. All rights reserved.', style: TextStyle(color: AppColors.slate400, fontSize: 14)),
            ],
          ),
          const Text('Making a Difference Together', style: TextStyle(color: AppColors.slate500, fontSize: 12)),
        ],
      ),
    );
  }
}