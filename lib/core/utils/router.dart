import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_on/presentation/providers/auth_provider.dart';
import 'package:quest_on/presentation/screens/auth/login_screen.dart';
import 'package:quest_on/presentation/screens/auth/signup_screen.dart';
import 'package:quest_on/presentation/screens/vision/vision_survey_screen.dart';
import 'package:quest_on/presentation/screens/vision/vision_coaching_screen.dart';
import 'package:quest_on/presentation/screens/vision/vision_roadmap_screen.dart';

/// GoRouter 설정
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      // 인증 상태에 따른 리다이렉트
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/signup';

      // 로그인되지 않은 상태에서 보호된 페이지 접근 시 로그인 페이지로
      if (!isLoggedIn && !isLoggingIn && !isSigningUp) {
        return '/login';
      }

      // 로그인된 상태에서 로그인/회원가입 페이지 접근 시 홈으로
      if (isLoggedIn && (isLoggingIn || isSigningUp)) {
        return '/';
      }

      return null;
    },
    routes: [
      // 로그인
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // 회원가입
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // 비전 설문
      GoRoute(
        path: '/vision/survey',
        builder: (context, state) => const VisionSurveyScreen(),
      ),

      // AI 코칭 생성
      GoRoute(
        path: '/vision/coaching',
        builder: (context, state) => const VisionCoachingScreen(),
      ),

      // 로드맵 생성
      GoRoute(
        path: '/vision/roadmap',
        builder: (context, state) => const VisionRoadmapScreen(),
      ),

      // 홈 (임시)
      GoRoute(
        path: '/',
        builder: (context, state) => const _TempHomeScreen(),
      ),
    ],
  );
});

/// 임시 홈 화면
class _TempHomeScreen extends ConsumerWidget {
  const _TempHomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quest ON'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: authStateAsync.when(
          data: (user) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 100,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              Text(
                '로그인 성공! 🎉',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 16),
              Text(
                user?.email ?? 'Unknown',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (user?.name != null) ...[
                const SizedBox(height: 8),
                Text(
                  user!.name!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/vision/survey');
                },
                icon: const Icon(Icons.rocket_launch),
                label: const Text('비전 설문 시작하기'),
              ),
              const SizedBox(height: 16),
              const Text(
                '목표 설정부터 시작해보세요!',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('오류: $error'),
        ),
      ),
    );
  }
}
