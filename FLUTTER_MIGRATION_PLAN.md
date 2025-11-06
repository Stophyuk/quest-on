# Flutter 마이그레이션 계획

## 📋 목차
1. [마이그레이션 개요](#마이그레이션-개요)
2. [기술 스택 비교](#기술-스택-비교)
3. [프로젝트 구조](#프로젝트-구조)
4. [기능별 마이그레이션 계획](#기능별-마이그레이션-계획)
5. [패키지 매핑](#패키지-매핑)
6. [개발 일정](#개발-일정)
7. [위험 요소 및 대응 방안](#위험-요소-및-대응-방안)

---

## 마이그레이션 개요

### 목적
- **모바일 퍼스트**: Android/iOS 네이티브 성능 극대화
- **수익화**: 광고 및 구독 모델 최적화
- **고급 기능**: 위젯, 알림, 오프라인 동기화 쉽게 구현

### 범위
- ✅ Vue 3 + Capacitor → Flutter 3.x 전환
- ✅ Pinia → Riverpod/Provider 상태관리
- ✅ Supabase 백엔드 유지 (변경 없음)
- ✅ 모든 UI/UX 재구현
- ✅ Android 위젯, 알림, 오프라인 기능 추가

---

## 기술 스택 비교

| 영역 | Vue + Capacitor | Flutter |
|------|----------------|---------|
| **언어** | JavaScript | Dart |
| **상태관리** | Pinia | Riverpod / Provider |
| **라우팅** | Vue Router | GoRouter / Navigator 2.0 |
| **HTTP** | Axios | http / dio |
| **로컬 저장소** | localStorage | SharedPreferences / Hive |
| **오프라인 DB** | IndexedDB | SQLite / Drift |
| **알림** | @capacitor/local-notifications | flutter_local_notifications |
| **백엔드** | Supabase JS | Supabase Flutter |
| **에러 트래킹** | Sentry JS | Sentry Flutter |
| **광고** | - | google_mobile_ads |
| **결제** | - | in_app_purchase |

---

## 프로젝트 구조

### Flutter 프로젝트 구조 (Clean Architecture)

```
lib/
├── core/                       # 공통 유틸리티
│   ├── constants/             # 상수
│   ├── theme/                 # 테마 설정
│   ├── utils/                 # 유틸 함수
│   └── errors/                # 에러 처리
│
├── data/                       # 데이터 계층
│   ├── models/                # 데이터 모델
│   ├── repositories/          # Repository 구현
│   ├── datasources/
│   │   ├── remote/            # Supabase API
│   │   └── local/             # SQLite/Hive
│   └── services/              # 외부 서비스
│
├── domain/                     # 도메인 계층
│   ├── entities/              # 비즈니스 엔티티
│   ├── repositories/          # Repository 인터페이스
│   └── usecases/              # 비즈니스 로직
│
├── presentation/               # UI 계층
│   ├── providers/             # Riverpod Providers
│   ├── screens/               # 화면
│   │   ├── home/
│   │   ├── quests/
│   │   ├── vision/
│   │   ├── profile/
│   │   └── auth/
│   └── widgets/               # 공통 위젯
│
└── main.dart                   # 앱 진입점
```

---

## 기능별 마이그레이션 계획

### 1. 인증 시스템 (Authentication)

**Vue 코드 위치:**
- `src/services/auth.js`
- `src/stores/auth.js`
- `src/views/Login.vue`, `src/views/Signup.vue`

**Flutter 구현:**
```dart
// data/datasources/remote/auth_remote_datasource.dart
class AuthRemoteDataSource {
  final SupabaseClient supabase;

  Future<User> signInWithEmail(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user!;
  }

  Future<User> signUp(String email, String password) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    return response.user!;
  }
}

// presentation/providers/auth_provider.dart
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
```

**필요한 패키지:**
- `supabase_flutter: ^2.0.0`

---

### 2. 비전 설문 및 AI 코칭

**Vue 코드 위치:**
- `src/components/vision/VisionSurveyModal.vue`
- `src/components/vision/VisionNoteGenerator.vue`
- `src/services/visionApi.js`

**Flutter 구현:**
```dart
// presentation/screens/vision/vision_survey_screen.dart
class VisionSurveyScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<VisionSurveyScreen> createState() => _VisionSurveyScreenState();
}

class _VisionSurveyScreenState extends ConsumerState<VisionSurveyScreen> {
  int currentStep = 0;
  final ProfileModel profile = ProfileModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          _buildNameStep(),
          _buildValuesStep(),
          _buildGoalStep(),
          _buildReasonsStep(),
        ],
      ),
    );
  }

  Widget _buildValuesStep() {
    return Column(
      children: [
        Text('당신이 중요하게 생각하는 가치는?'),
        Wrap(
          children: [
            ChoiceChip(label: Text('성장'), selected: profile.values.contains('성장')),
            ChoiceChip(label: Text('관계'), selected: profile.values.contains('관계')),
            // 기타 직접입력
            if (showCustomValue)
              TextField(
                maxLength: 10,
                decoration: InputDecoration(labelText: '직접 입력'),
              ),
          ],
        ),
      ],
    );
  }
}

// domain/usecases/generate_vision_note_usecase.dart
class GenerateVisionNoteUsecase {
  final VisionRepository repository;

  Future<String> call(ProfileModel profile) async {
    return await repository.generateVisionNote(profile);
  }
}
```

**필요한 패키지:**
- Material 3 기본 제공 (ChoiceChip, TextField)

---

### 3. 퀘스트 관리 시스템

**Vue 코드 위치:**
- `src/stores/quest.js`
- `src/views/Quests.vue`
- `src/components/quest/QuestModal.vue`

**Flutter 구현:**
```dart
// data/models/quest_model.dart
class QuestModel {
  final String id;
  final String title;
  final String? description;
  final String category;
  final int difficulty;
  final int condition; // 1: 최상, 2: 좋음, 3: 보통, 4: 나쁨, 5: 최악
  final bool isCompleted;
  final DateTime createdAt;

  QuestModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.difficulty,
    required this.condition,
    this.isCompleted = false,
    required this.createdAt,
  });

  factory QuestModel.fromJson(Map<String, dynamic> json) {
    return QuestModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      difficulty: json['difficulty'],
      condition: json['condition'],
      isCompleted: json['is_completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// presentation/providers/quest_provider.dart
final questProvider = StateNotifierProvider<QuestNotifier, AsyncValue<List<QuestModel>>>((ref) {
  return QuestNotifier(ref.read(questRepositoryProvider));
});

class QuestNotifier extends StateNotifier<AsyncValue<List<QuestModel>>> {
  final QuestRepository repository;

  QuestNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadQuests();
  }

  Future<void> loadQuests() async {
    state = const AsyncValue.loading();
    try {
      final quests = await repository.getQuests();
      state = AsyncValue.data(quests);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeQuest(String questId, int condition) async {
    // 낙관적 업데이트
    final currentQuests = state.value ?? [];
    final updatedQuests = currentQuests.map((q) {
      if (q.id == questId) {
        return QuestModel(
          id: q.id,
          title: q.title,
          description: q.description,
          category: q.category,
          difficulty: q.difficulty,
          condition: condition,
          isCompleted: true,
          createdAt: q.createdAt,
        );
      }
      return q;
    }).toList();

    state = AsyncValue.data(updatedQuests);

    // 서버 업데이트
    try {
      await repository.completeQuest(questId, condition);
    } catch (e) {
      // 실패시 롤백
      state = AsyncValue.data(currentQuests);
      rethrow;
    }
  }
}

// presentation/screens/quests/quests_screen.dart
class QuestsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(questProvider);

    return Scaffold(
      appBar: AppBar(title: Text('퀘스트')),
      body: questsAsync.when(
        data: (quests) => ListView.builder(
          itemCount: quests.length,
          itemBuilder: (context, index) {
            final quest = quests[index];
            return QuestCard(quest: quest);
          },
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('오류 발생: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuestModal(context, ref),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

**필요한 패키지:**
- `riverpod: ^2.4.0`
- `flutter_riverpod: ^2.4.0`

---

### 4. 오프라인 동기화

**구현 전략: Offline-First Architecture**

```dart
// data/datasources/local/local_database.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'local_database.g.dart';

class Quests extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text()();
  IntColumn get difficulty => integer()();
  IntColumn get condition => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Quests])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;
}

// data/repositories/quest_repository_impl.dart
class QuestRepositoryImpl implements QuestRepository {
  final QuestRemoteDataSource remoteDataSource;
  final AppDatabase localDatabase;
  final Connectivity connectivity;

  @override
  Future<List<QuestModel>> getQuests() async {
    // 1. 로컬 데이터 먼저 반환
    final localQuests = await localDatabase.select(localDatabase.quests).get();

    // 2. 온라인이면 백그라운드 동기화
    final isOnline = await connectivity.checkConnectivity() != ConnectivityResult.none;
    if (isOnline) {
      _syncInBackground();
    }

    return localQuests.map((q) => QuestModel.fromDrift(q)).toList();
  }

  Future<void> _syncInBackground() async {
    // 1. 서버에서 최신 데이터 가져오기
    final remoteQuests = await remoteDataSource.getQuests();
    await localDatabase.batch((batch) {
      batch.insertAll(
        localDatabase.quests,
        remoteQuests.map((q) => q.toDrift()).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });

    // 2. 로컬에서 미동기화 데이터 업로드
    final unsyncedQuests = await (localDatabase.select(localDatabase.quests)
      ..where((tbl) => tbl.isSynced.equals(false))).get();

    for (final quest in unsyncedQuests) {
      try {
        await remoteDataSource.updateQuest(QuestModel.fromDrift(quest));
        await (localDatabase.update(localDatabase.quests)
          ..where((tbl) => tbl.id.equals(quest.id)))
          .write(QuestsCompanion(isSynced: Value(true)));
      } catch (e) {
        // 동기화 실패는 무시 (다음에 재시도)
      }
    }
  }

  @override
  Future<void> completeQuest(String questId, int condition) async {
    // 1. 로컬 먼저 업데이트 (즉각 반영)
    await (localDatabase.update(localDatabase.quests)
      ..where((tbl) => tbl.id.equals(questId)))
      .write(QuestsCompanion(
        isCompleted: Value(true),
        condition: Value(condition),
        isSynced: Value(false),
        updatedAt: Value(DateTime.now()),
      ));

    // 2. 온라인이면 서버 업데이트
    final isOnline = await connectivity.checkConnectivity() != ConnectivityResult.none;
    if (isOnline) {
      try {
        await remoteDataSource.completeQuest(questId, condition);
        await (localDatabase.update(localDatabase.quests)
          ..where((tbl) => tbl.id.equals(questId)))
          .write(QuestsCompanion(isSynced: Value(true)));
      } catch (e) {
        // 실패해도 로컬 변경은 유지 (나중에 동기화)
      }
    }
  }
}
```

**필요한 패키지:**
- `drift: ^2.13.0` (SQLite ORM)
- `connectivity_plus: ^5.0.0` (네트워크 상태)

---

### 5. Android 위젯

**구현: Home Screen Widget**

```dart
// android/app/src/main/kotlin/com/queston/app/QuestWidget.kt
package com.queston.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.content.SharedPreferences

class QuestWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val prefs = context.getSharedPreferences("quest_widget", Context.MODE_PRIVATE)
        val completedCount = prefs.getInt("completed_count", 0)
        val totalCount = prefs.getInt("total_count", 0)
        val level = prefs.getInt("level", 1)

        val views = RemoteViews(context.packageName, R.layout.quest_widget)
        views.setTextViewText(R.id.widget_title, "Quest ON")
        views.setTextViewText(R.id.widget_progress, "$completedCount/$totalCount 완료")
        views.setTextViewText(R.id.widget_level, "Lv.$level")
        views.setProgressBar(R.id.widget_progressbar, totalCount, completedCount, false)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}

// lib/presentation/services/widget_service.dart
import 'package:home_widget/home_widget.dart';

class WidgetService {
  static Future<void> updateWidget({
    required int completedCount,
    required int totalCount,
    required int level,
  }) async {
    await HomeWidget.saveWidgetData<int>('completed_count', completedCount);
    await HomeWidget.saveWidgetData<int>('total_count', totalCount);
    await HomeWidget.saveWidgetData<int>('level', level);
    await HomeWidget.updateWidget(
      name: 'QuestWidget',
      androidName: 'QuestWidget',
    );
  }
}
```

**위젯 레이아웃:**
```xml
<!-- android/app/src/main/res/layout/quest_widget.xml -->
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="16dp"
    android:background="@drawable/widget_background">

    <TextView
        android:id="@+id/widget_title"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Quest ON"
        android:textSize="18sp"
        android:textStyle="bold" />

    <TextView
        android:id="@+id/widget_level"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Lv.1"
        android:textSize="14sp" />

    <ProgressBar
        android:id="@+id/widget_progressbar"
        style="?android:attr/progressBarStyleHorizontal"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="8dp" />

    <TextView
        android:id="@+id/widget_progress"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="0/5 완료"
        android:textSize="12sp" />
</LinearLayout>
```

**필요한 패키지:**
- `home_widget: ^0.5.0`

---

### 6. 로컬 알림

**구현: 스케줄 알림 + Ongoing Notification**

```dart
// presentation/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  // 매일 아침 9시 알림
  static Future<void> scheduleDailyReminder() async {
    await _notifications.zonedSchedule(
      0,
      '오늘의 퀘스트를 확인하세요!',
      '새로운 하루, 새로운 목표가 기다리고 있어요',
      _nextInstanceOf9AM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          '일일 알림',
          channelDescription: '매일 아침 퀘스트 알림',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOf9AM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // Ongoing Notification (고정 알림)
  static Future<void> showOngoingProgress({
    required int completed,
    required int total,
  }) async {
    await _notifications.show(
      999,
      'Quest ON',
      '오늘 $completed/$total 완료',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'ongoing_progress',
          '진행 상황',
          channelDescription: '오늘의 퀘스트 진행 상황',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true, // 스와이프로 삭제 불가
          autoCancel: false,
          showProgress: true,
          maxProgress: total,
          progress: completed,
        ),
      ),
    );
  }

  // 퀘스트 완료 알림
  static Future<void> showCompletionNotification({
    required String title,
    required int exp,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '🎉 퀘스트 완료!',
      '$title (+$exp EXP)',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'quest_completion',
          '퀘스트 완료',
          channelDescription: '퀘스트 완료 알림',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
```

**필요한 패키지:**
- `flutter_local_notifications: ^16.0.0`
- `timezone: ^0.9.2`

---

### 7. 광고 및 수익화

**구현: AdMob + In-App Purchase**

```dart
// presentation/services/ad_service.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static BannerAd? _bannerAd;
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;

  // 배너 광고
  static Future<BannerAd?> loadBannerAd() async {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // 테스트 ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => print('배너 광고 로드됨'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('배너 광고 로드 실패: $error');
        },
      ),
    );

    await _bannerAd!.load();
    return _bannerAd;
  }

  // 전면 광고 (퀘스트 완료 후)
  static Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('전면 광고 로드 실패: $error');
        },
      ),
    );
  }

  static void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      loadInterstitialAd(); // 다음 광고 미리 로드
    }
  }

  // 리워드 광고 (포인트 획득)
  static Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('리워드 광고 로드 실패: $error');
        },
      ),
    );
  }

  static Future<int?> showRewardedAd() async {
    if (_rewardedAd == null) return null;

    int? rewardAmount;
    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewardAmount = reward.amount.toInt();
      },
    );

    _rewardedAd = null;
    loadRewardedAd();
    return rewardAmount;
  }
}

// presentation/services/subscription_service.dart
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionService {
  static const String plusMonthly = 'quest_on_plus_monthly';
  static const String proMonthly = 'quest_on_pro_monthly';

  static Future<void> purchaseSubscription(String productId) async {
    final InAppPurchase iap = InAppPurchase.instance;

    final ProductDetailsResponse response = await iap.queryProductDetails({productId});
    if (response.productDetails.isEmpty) {
      throw Exception('구독 상품을 찾을 수 없습니다');
    }

    final ProductDetails productDetails = response.productDetails.first;
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

    await iap.buyNonConsumable(purchaseParam: purchaseParam);
  }
}
```

**필요한 패키지:**
- `google_mobile_ads: ^4.0.0`
- `in_app_purchase: ^3.1.0`

---

## 패키지 매핑

### 핵심 패키지

| 기능 | 패키지 | 버전 |
|------|--------|------|
| 상태관리 | `riverpod` | ^2.4.0 |
| 라우팅 | `go_router` | ^12.0.0 |
| HTTP | `dio` | ^5.4.0 |
| Supabase | `supabase_flutter` | ^2.0.0 |
| 로컬 DB | `drift` | ^2.13.0 |
| 로컬 저장 | `shared_preferences` | ^2.2.0 |
| 네트워크 | `connectivity_plus` | ^5.0.0 |
| 알림 | `flutter_local_notifications` | ^16.0.0 |
| 위젯 | `home_widget` | ^0.5.0 |
| 광고 | `google_mobile_ads` | ^4.0.0 |
| 구독 | `in_app_purchase` | ^3.1.0 |
| 에러 추적 | `sentry_flutter` | ^7.0.0 |
| 타임존 | `timezone` | ^0.9.2 |

### pubspec.yaml

```yaml
name: quest_on
description: 컨디션 기반 퀘스트 관리 앱
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # 상태관리
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # 라우팅
  go_router: ^12.0.0

  # 백엔드
  supabase_flutter: ^2.0.0
  dio: ^5.4.0

  # 로컬 저장소
  drift: ^2.13.0
  sqlite3_flutter_libs: ^0.5.0
  shared_preferences: ^2.2.0

  # 네트워크
  connectivity_plus: ^5.0.0

  # 알림 & 위젯
  flutter_local_notifications: ^16.0.0
  timezone: ^0.9.2
  home_widget: ^0.5.0

  # 수익화
  google_mobile_ads: ^4.0.0
  in_app_purchase: ^3.1.0

  # 에러 추적
  sentry_flutter: ^7.0.0

  # UI
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  riverpod_generator: ^2.3.0
  build_runner: ^2.4.0
  drift_dev: ^2.13.0
```

---

## 개발 일정

### Phase 1: 기본 인프라 (1주)
- [x] Flutter 프로젝트 초기화
- [ ] Supabase 연동
- [ ] 상태관리 (Riverpod) 설정
- [ ] 라우팅 설정
- [ ] 테마 및 디자인 시스템
- [ ] 에러 처리 및 Sentry 연동

### Phase 2: 인증 시스템 (3일)
- [ ] 로그인/회원가입 UI
- [ ] Supabase Auth 연동
- [ ] 프로필 관리

### Phase 3: 비전 시스템 (5일)
- [ ] 비전 설문 UI (4단계)
- [ ] AI 코칭 생성 (Supabase Edge Function)
- [ ] 로드맵 생성

### Phase 4: 퀘스트 시스템 (1주)
- [ ] 퀘스트 목록 UI
- [ ] 퀘스트 생성/수정/삭제
- [ ] 컨디션별 자동 조정
- [ ] 완료 체크 및 경험치 시스템
- [ ] 레벨업 애니메이션

### Phase 5: 오프라인 동기화 (5일)
- [ ] Drift 로컬 DB 설정
- [ ] Sync Manager 구현
- [ ] 충돌 해결 로직
- [ ] 네트워크 상태 감지

### Phase 6: 알림 시스템 (3일)
- [ ] 일일 알림 스케줄
- [ ] Ongoing Notification
- [ ] 퀘스트 완료 알림
- [ ] 연속 달성 알림

### Phase 7: Android 위젯 (1주)
- [ ] 위젯 레이아웃 디자인
- [ ] Kotlin 코드 작성
- [ ] Flutter ↔ Native 데이터 연동
- [ ] 위젯 업데이트 로직

### Phase 8: 수익화 (5일)
- [ ] AdMob 연동
- [ ] 배너 광고 배치
- [ ] 전면 광고 (퀘스트 완료 후)
- [ ] 리워드 광고 (포인트 획득)
- [ ] In-App Purchase 연동
- [ ] 구독 관리 페이지

### Phase 9: 최종 마무리 (1주)
- [ ] 통계 페이지
- [ ] 주간 리포트
- [ ] 악세서리 상점
- [ ] 온보딩 튜토리얼
- [ ] 버그 수정 및 최적화
- [ ] 성능 테스트

**총 예상 기간: 6~7주**

---

## 위험 요소 및 대응 방안

### 위험 1: Dart 언어 학습 곡선
**영향**: 개발 속도 저하
**대응**:
- Dart 공식 문서 학습 (2~3일)
- JavaScript와 유사한 문법 활용
- ChatGPT/Claude로 코드 변환 지원

### 위험 2: 네이티브 코드 (Kotlin) 복잡도
**영향**: 위젯 구현 지연
**대응**:
- `home_widget` 패키지로 대부분 자동화
- 필요시 Android 개발자 자문
- 최소 기능부터 구현 (점진적 확장)

### 위험 3: 오프라인 동기화 충돌
**영향**: 데이터 손실
**대응**:
- Last Write Wins 전략 우선 적용 (간단)
- 충돌 발생률 모니터링
- 필요시 Manual Resolution 추가

### 위험 4: 광고 수익 최적화 실패
**영향**: 수익성 저하
**대응**:
- A/B 테스트로 광고 위치 최적화
- 리워드 광고 비중 증가 (사용자 경험 개선)
- 구독 전환율 모니터링 (Firebase Analytics)

### 위험 5: 개발 일정 초과
**영향**: 출시 지연
**대응**:
- MVP 기능 우선순위 설정 (위젯 없이도 출시 가능)
- 주간 진행률 체크
- 필요시 일부 기능 연기 (v1.1 업데이트)

---

## 다음 단계

1. ✅ **Vue 코드 백업 완료** (`vue-capacitor-backup` 브랜치)
2. ⏳ **Flutter 프로젝트 초기화**
3. ⏳ **Supabase 연동 테스트**
4. ⏳ **기본 UI 구조 구현**

---

**작성일**: 2025-11-06
**작성자**: Claude Code
**버전**: 1.0
