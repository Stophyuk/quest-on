import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_on/presentation/providers/auth_provider.dart';
import 'package:quest_on/presentation/screens/auth/login_screen.dart';
import 'package:quest_on/presentation/screens/auth/signup_screen.dart';
import 'package:quest_on/presentation/screens/vision/vision_survey_screen.dart';
import 'package:quest_on/presentation/screens/vision/vision_coaching_screen.dart';
import 'package:quest_on/presentation/screens/vision/vision_roadmap_screen.dart';
import 'package:quest_on/presentation/screens/quest/quest_list_screen.dart';
import 'package:quest_on/presentation/screens/quest/quest_add_screen.dart';

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

      // 퀘스트 목록 (홈)
      GoRoute(
        path: '/',
        builder: (context, state) => const QuestListScreen(),
      ),

      // 퀘스트 추가
      GoRoute(
        path: '/quest/add',
        builder: (context, state) => const QuestAddScreen(),
      ),
    ],
  );
});