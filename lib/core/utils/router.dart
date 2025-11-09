import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_on/presentation/providers/auth_provider.dart';
import 'package:quest_on/presentation/providers/user_stats_provider.dart';
import 'package:quest_on/presentation/screens/auth/login_screen.dart';
import 'package:quest_on/presentation/screens/auth/signup_screen.dart';
import 'package:quest_on/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:quest_on/presentation/screens/main/main_screen.dart';
import 'package:quest_on/presentation/screens/vision/vision_screen.dart';
import 'package:quest_on/presentation/screens/vision/vision_survey_screen.dart';
import 'package:quest_on/presentation/screens/vision/vision_coaching_screen.dart';
import 'package:quest_on/presentation/screens/vision/vision_roadmap_generator_screen.dart';
import 'package:quest_on/presentation/screens/quest/quest_list_screen.dart';
import 'package:quest_on/presentation/screens/quest/quest_add_screen.dart';
import 'package:quest_on/domain/entities/quest.dart';

/// GoRouter 설정
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userStatsState = ref.watch(userStatsNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final location = state.matchedLocation;

      // 인증 상태
      final user = authState.value;
      final isLoggedIn = user != null;
      final isLoggingIn = location == '/login';
      final isSigningUp = location == '/signup';
      final isOnboarding = location == '/onboarding';

      print('🔀 Router redirect - location: $location, isLoggedIn: $isLoggedIn, user: ${user?.id}');

      // 로그인되지 않은 상태에서 보호된 페이지 접근 시 로그인 페이지로
      if (!isLoggedIn && !isLoggingIn && !isSigningUp) {
        print('  → 로그인 필요, /login으로 리다이렉트');
        return '/login';
      }

      // 온보딩 페이지는 항상 접근 허용 (무한 루프 방지)
      if (isOnboarding) {
        print('  → 온보딩 페이지, 리다이렉트 없음');
        return null;
      }

      // 로그인 완료 후 온보딩 완료 여부 체크
      if (isLoggedIn) {
        print('  ✓ 로그인됨 - userStatsState: loading=${userStatsState.isLoading}, value=${userStatsState.value != null}, error=${userStatsState.hasError}');

        // UserStats가 로드 중이면 대기
        if (userStatsState.isLoading) {
          print('  ⏳ UserStats 로딩 중, 대기');
          return null;
        }

        // UserStats에 에러가 있으면 로그 출력
        if (userStatsState.hasError) {
          print('  ❌ UserStats 로드 에러: ${userStatsState.error}');
        }

        // UserStats 존재 여부로 온보딩 완료 판단
        final hasCompletedOnboarding = userStatsState.value != null;
        print('  📊 온보딩 완료 여부: $hasCompletedOnboarding (userStats: ${userStatsState.value?.nickname})');

        // 온보딩 미완료 시 온보딩으로
        if (!hasCompletedOnboarding) {
          print('  → 온보딩 미완료, /onboarding으로 리다이렉트');
          return '/onboarding';
        }

        // 온보딩 완료 상태에서 로그인/회원가입 페이지 접근 시 홈으로
        if (hasCompletedOnboarding && (isLoggingIn || isSigningUp)) {
          print('  → 온보딩 완료 + 로그인/회원가입 페이지, /로 리다이렉트');
          return '/';
        }
      }

      print('  → 리다이렉트 없음');
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

      // 온보딩
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // 비전 메인 화면
      GoRoute(
        path: '/vision',
        builder: (context, state) => const VisionScreen(),
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
        builder: (context, state) => const VisionRoadmapGeneratorScreen(),
      ),

      // 메인 화면 (하단 네비게이션 포함)
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScreen(),
      ),

      // 퀘스트 추가/편집
      GoRoute(
        path: '/quest/add',
        builder: (context, state) {
          final quest = state.extra as Quest?;
          return QuestAddScreen(quest: quest);
        },
      ),
    ],
  );
});