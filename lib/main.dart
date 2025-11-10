import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quest_on/core/theme/app_theme.dart';
import 'package:quest_on/core/constants/app_constants.dart';
import 'package:quest_on/core/constants/env.dart';
import 'package:quest_on/core/utils/router.dart';
import 'package:quest_on/data/services/quest_widget_service.dart';
import 'package:quest_on/data/services/analytics_service.dart';
import 'package:quest_on/data/services/ad_service.dart';
import 'package:quest_on/data/services/purchase_service.dart';
import 'package:quest_on/data/services/ai/openai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: '.env');

  // Supabase 초기화
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // OpenAI 서비스 초기화
  try {
    await OpenAIService().initialize();
    print('[Main] OpenAI 서비스 초기화 완료');
  } catch (e) {
    print('[Main] OpenAI 서비스 초기화 실패: $e');
  }

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

  // 광고 서비스 초기화
  try {
    await AdService().initialize();
  } catch (e) {
    print('[Main] 광고 서비스 초기화 실패: $e');
  }

  // 인앱 구매 서비스 초기화
  try {
    await PurchaseService().initialize();
  } catch (e) {
    print('[Main] 인앱 구매 서비스 초기화 실패: $e');
  }

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
