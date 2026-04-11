import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/constants/app_constants.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/features/auth/domain/entities/user_entity.dart';

// --- UPDATED IMPORT HERE ---
import 'package:ngo_volunteer_management/features/public/presentation/screens/landing_screen.dart';
// ---------------------------

import '../features/auth/presentation/screens/login_screen.dart';
import 'package:ngo_volunteer_management/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:ngo_volunteer_management/features/member/presentation/screens/member_dashboard_screen.dart';
import 'package:ngo_volunteer_management/features/volunteer/presentation/screens/volunteer_dashboard_screen.dart';
import '../shared/providers/app_providers.dart';

part 'router.g.dart';

// ── Router provider ───────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  // Re-evaluate the redirect whenever auth state changes
  final authState = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (BuildContext context, GoRouterState state) {
      return _redirect(authState, state);
    },
    routes: [
      GoRoute(
        path: '/',
        name: AppRoutes.landing,
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/superadmin',
        name: AppRoutes.superAdmin,
        builder: (context, state) => const AdminDashboardScreen(
          isSuperAdmin: true,
        ),
        redirect: (context, state) => _requireRole(
          authState,
          const [UserRole.superAdmin],
        ),
      ),
      GoRoute(
        path: '/admin',
        name: AppRoutes.admin,
        builder: (context, state) => const AdminDashboardScreen(
          isSuperAdmin: false,
        ),
        redirect: (context, state) {
          // SuperAdmin should always use /superadmin route (not /admin)
          if (authState?.role == UserRole.superAdmin) return '/superadmin';
          return _requireRole(authState, const [UserRole.admin]);
        },
      ),
      GoRoute(
        path: '/member',
        name: AppRoutes.member,
        builder: (context, state) => const MemberDashboardScreen(),
        redirect: (context, state) => _requireRole(
          authState,
          const [UserRole.member],
        ),
      ),
      GoRoute(
        path: '/volunteer',
        name: AppRoutes.volunteer,
        builder: (context, state) => const VolunteerDashboardScreen(),
        redirect: (context, state) => _requireRole(
          authState,
          const [UserRole.volunteer],
        ),
      ),
    ],
    errorBuilder: (context, state) => const _NotFoundScreen(),
  );
}

// ── Private redirect helpers ──────────────────────────────────────────────────

/// Top-level redirect: push logged-in users away from landing/login.
String? _redirect(UserEntity? user, GoRouterState state) {
  final onPublicPage = state.matchedLocation == '/' ||
      state.matchedLocation == '/login';

  if (user != null && onPublicPage) {
    return user.role.routePath;
  }
  return null; // no redirect
}

/// Per-route guard: unauthenticated → login, wrong role → their dashboard.
String? _requireRole(UserEntity? user, List<UserRole> allowed) {
  if (user == null) return '/login';
  if (!allowed.contains(user.role)) return user.role.routePath;
  return null;
}

// ── 404 screen ────────────────────────────────────────────────────────────────

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    );
  }
}