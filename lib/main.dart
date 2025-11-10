import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quest_on/core/theme/app_theme.dart';
import 'package:quest_on/core/constants/app_constants.dart';
import 'package:quest_on/core/constants/env.dart';
import 'package:quest_on/core/utils/router.dart';
import 'package:quest_on/data/services/quest_widget_service.dart';
import 'package:quest_on/data/services/analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase 초기화
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // Firebase Analytics 초기화
  // NOTE: Firebase 설정이 완료되면 자동으로 활성화됩니다
  // FIREBASE_SETUP.md 파일을 참고하여 Firebase Console에서 프로젝트를 생성하고
  // google-services.json 파일을 추가하세요
  try {
    await AnalyticsService().initialize();
  } catch (e) {
    print('[Main] Firebase Analytics 초기화 실패 (설정 파일 없음): $e');
    // Firebase 미설정 시에도 앱은 정상 작동
  }

  // 위젯 서비스 초기화
  await QuestWidgetService.initialize();

  runApp(
    const ProviderScope(
      child: QuestOnApp(),
    ),
  );
}

class QuestOnApp extends ConsumerWidget {
  const QuestOnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
