# Quest ON - 배포 전 이슈 및 수정 사항 (2025-11-11)

## 📊 검토 결과 요약

전체 코드베이스 검토 결과:
- **총 이슈**: 20개
- **Critical 🔴**: 5개 (즉시 수정 필요)
- **High 🟠**: 5개 (배포 전 권장)
- **Medium 🟡**: 5개 (다음 버전)
- **Low 🟢**: 5개 (개선 사항)

---

## 🔴 Critical Issues (즉시 수정 필요)

### 1. OpenAI API 키 Git 노출 ⚠️ **최고 위험**
- **위치**: `.env:2`
- **문제**: `OPENAI_API_KEY=sk-proj-m_eWtFqAlXmNXT...` Git에 커밋됨
- **영향**: API 요금 폭탄 위험
- **즉시 조치**:
  ```bash
  # 1. OpenAI API 키 재발급
  # https://platform.openai.com/api-keys → Revoke 후 새 키 생성

  # 2. Git 히스토리 제거
  git filter-repo --path .env --invert-paths --force
  git push origin --force --all

  # 3. Supabase Edge Function에 새 키 설정
  # Dashboard → Settings → Edge Functions → Secrets
  # Key: OPENAI_API_KEY, Value: 새키
  ```

### 2. AdMob 테스트 ID 사용 중
- **위치**: `lib/data/services/ad_service.dart:16-26`
- **문제**: 광고 ID가 모두 `ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY`
- **영향**: 광고 수익 0원
- **조치**: Google AdMob Console에서 실제 광고 단위 ID 발급 필요

### 3. Android Release Keystore 미설정
- **위치**: `android/app/build.gradle.kts:37`
- **문제**: `signingConfig = signingConfigs.getByName("debug")` // 프로덕션 불가
- **영향**: Play Store 업로드 불가
- **조치**:
  ```bash
  # Keystore 생성
  keytool -genkey -v -keystore android/app/release-keystore.jks \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias quest-on-release

  # key.properties 생성 (.gitignore됨)
  # android/key.properties
  # storePassword=...
  # keyPassword=...
  # keyAlias=quest-on-release
  # storeFile=app/release-keystore.jks
  ```

### 4. Google OAuth Client ID 하드코딩
- **위치**: `lib/data/datasources/remote/auth_remote_datasource.dart:123`
- **문제**: `serverClientId: '884314617277-uq8ko8h9...'`
- **영향**: 소스 코드 노출 시 위험
- **조치**: 환경변수로 이동 (`--dart-define=GOOGLE_CLIENT_ID`)

### 5. 경험치 이중 지급 버그
- **위치**: `lib/presentation/providers/quest_provider.dart:133-179`
- **문제**: `incrementQuestProgress`와 `completeQuest` 모두 경험치 지급
- **영향**: 게임 밸런스 붕괴
- **상태**: ✅ **수정 완료** (이미 완료된 퀘스트는 경험치 재지급 안 함)

---

## 🟠 High Priority (배포 전 강력 권장)

### 6. Firebase google-services.json 누락
- **문제**: .gitignore되어 있어 다른 환경에서 빌드 불가
- **조치**: Firebase Console에서 다운로드 후 `android/app/` 에 배치

### 7. 인앱 구매 서버 검증 미구현
- **위치**: `lib/data/services/purchase_service.dart:148-161`
- **문제**: 로컬에서 영수증 검증 → 해킹 가능
- **조치**: Supabase Edge Function으로 Google Play 영수증 검증 구현

### 8. 비밀번호 찾기 미구현
- **위치**: `lib/presentation/screens/auth/login_screen.dart:221-227`
- **문제**: "기능 구현 예정" 메시지만 표시
- **조치**: Supabase `resetPasswordForEmail()` 호출하는 다이얼로그 추가

### 9. 프로덕션 로그 정리 필요
- **문제**: `print()` 문 159개 존재 → 성능 저하 및 민감 정보 노출
- **조치**: `kDebugMode` 가드 또는 `debugPrint()` 사용

### 10. Visions 테이블 RLS 확인
- **문제**: `visions`, `goals` 테이블 RLS 정책 재확인 필요
- **조치**: Supabase Dashboard에서 모든 테이블 RLS 활성화 확인

---

## ✅ 수정 완료 사항

### 경험치 이중 지급 버그 (Critical #5)
**파일**: `lib/presentation/providers/quest_provider.dart:156-186`

**수정 내용**:
```dart
Future<Quest> completeQuest(String questId) async {
  // 완료 전 퀘스트 상태 확인
  final quests = state.value ?? [];
  final questBefore = quests.firstWhere((q) => q.id == questId);
  final wasAlreadyCompleted = questBefore.isCompleted;

  final completedQuest = await _repository.completeQuest(questId);

  // 이미 완료된 퀘스트가 아닐 때만 경험치 지급 (이중 지급 방지)
  if (!wasAlreadyCompleted && completedQuest.isCompleted) {
    final expToAdd = completedQuest.difficulty.baseExp;
    await _ref.read(userStatsNotifierProvider.notifier).addExp(expToAdd);
  }

  // 상태 갱신
  if (_currentUserId != null) {
    await loadQuests(_currentUserId!);
  }

  return completedQuest;
}
```

**효과**: 퀘스트 중복 완료 시 경험치 재지급 방지

---

## 📦 배포 빌드 명령어

### Production Release (Play Store 업로드용)
```bash
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=https://ufbajyakzsrumrnehthq.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_REAL_KEY_HERE \
  --dart-define=GOOGLE_CLIENT_ID=884314617277-uq8ko8h9... \
  --dart-define=ADMOB_BANNER_ID=ca-app-pub-REAL_ID/BANNER \
  --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-REAL_ID/INTERSTITIAL \
  --dart-define=ADMOB_REWARDED_ID=ca-app-pub-REAL_ID/REWARDED

# 결과: build/app/outputs/bundle/release/app-release.aab
```

---

## 📋 배포 전 최종 체크리스트

### 필수 (Critical)
- [ ] OpenAI API 키 재발급 및 Git 히스토리 제거
- [ ] AdMob 실제 광고 ID 설정
- [ ] Android Release keystore 생성
- [ ] Google OAuth Client ID 환경변수화
- [x] 경험치 이중 지급 버그 수정

### 권장 (High Priority)
- [ ] Firebase google-services.json 추가
- [ ] 인앱 구매 서버 검증 구현
- [ ] 비밀번호 찾기 기능 구현
- [ ] 프로덕션 로그 정리
- [ ] RLS 정책 검증

### 문서
- [x] 배포 이슈 리포트 작성
- [ ] Play Store 설명 작성
- [ ] 스크린샷 준비 (8장)
- [ ] 개인정보 처리방침 준비

---

## 📞 문제 해결 가이드

### Q: Git 히스토리에서 .env 제거가 안 돼요
**A**: `git-filter-repo` 설치 필요
```bash
pip install git-filter-repo
git filter-repo --path .env --invert-paths --force
```

### Q: Keystore 생성 시 오류가 나요
**A**: JDK 설치 확인
```bash
java -version  # JDK 8 이상 필요
keytool -version
```

### Q: AdMob 광고가 테스트 모드에서만 나와요
**A**: 실제 디바이스에서 테스트 필요. 에뮬레이터는 테스트 광고만 표시됨

---

## 🎯 다음 단계

1. **즉시 조치** (오늘)
   - OpenAI API 키 재발급
   - Git 히스토리 정리
   - Release keystore 생성

2. **배포 준비** (1-2일)
   - AdMob 광고 ID 설정
   - Firebase google-services.json 추가
   - Release 빌드 테스트

3. **Play Store 제출** (3-5일)
   - 스크린샷 및 설명 작성
   - 개인정보 처리방침 URL 준비
   - AAB 파일 업로드

---

**작성일**: 2025-11-11
**검토자**: Claude Code + Stophyuk
**버전**: 2.0.0
