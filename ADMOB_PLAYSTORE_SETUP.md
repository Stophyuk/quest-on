# Google AdMob 및 Play Console 설정 가이드

Quest ON 앱에 광고와 인앱 구독을 추가하기 위한 설정 가이드입니다.

## 목차
1. [Google AdMob 설정](#1-google-admob-설정)
2. [Google Play Console 인앱 상품 설정](#2-google-play-console-인앱-상품-설정)
3. [코드에 실제 ID 적용](#3-코드에-실제-id-적용)
4. [테스트 방법](#4-테스트-방법)

---

## 1. Google AdMob 설정

### 1-1. AdMob 계정 생성 및 앱 추가

1. **AdMob 콘솔 접속**
   - https://apps.admob.google.com/ 접속
   - Google 계정으로 로그인
   - 이용약관 동의 및 국가 선택

2. **앱 추가하기**
   - 왼쪽 메뉴에서 "앱" 클릭
   - "앱 추가" 버튼 클릭
   - "이미 게시된 앱입니까?" → **"아니요"** 선택 (아직 Play Store에 미출시)
   - 플랫폼: **Android** 선택
   - 앱 이름: **Quest ON** 입력
   - "앱 추가" 클릭

3. **앱 ID 확인**
   - 앱이 생성되면 **앱 ID**가 표시됩니다 (예: `ca-app-pub-1234567890123456~1234567890`)
   - 이 ID를 메모해둡니다

### 1-2. 광고 단위 생성

Quest ON 앱에서 사용할 3가지 광고 단위를 생성합니다.

#### 배너 광고 단위

1. 앱 상세 페이지에서 "광고 단위" 탭 클릭
2. "광고 단위 추가" → "배너" 선택
3. 설정:
   - 광고 단위 이름: `Quest ON Banner`
   - 광고 형식: **배너** (320x50)
4. "광고 단위 만들기" 클릭
5. **광고 단위 ID** 복사 (예: `ca-app-pub-1234567890123456/1234567890`)

#### 전면 광고 단위

1. "광고 단위 추가" → "전면 광고" 선택
2. 설정:
   - 광고 단위 이름: `Quest ON Interstitial`
3. "광고 단위 만들기" 클릭
4. **광고 단위 ID** 복사

#### 보상형 광고 단위

1. "광고 단위 추가" → "보상형" 선택
2. 설정:
   - 광고 단위 이름: `Quest ON Rewarded`
   - 보상 항목: `포인트`
   - 보상 금액: `100`
3. "광고 단위 만들기" 클릭
4. **광고 단위 ID** 복사

### 1-3. app-ads.txt 설정 (선택사항)

Play Store 출시 후 앱이 승인되면:

1. AdMob 콘솔에서 "앱" → 앱 선택 → "app-ads.txt" 탭
2. app-ads.txt 내용 확인
3. 웹사이트가 있다면 루트 디렉토리에 app-ads.txt 파일 업로드

---

## 2. Google Play Console 인앱 상품 설정

### 2-1. Play Console 접속 및 앱 생성

1. **Play Console 접속**
   - https://play.google.com/console 접속
   - Google 계정으로 로그인
   - 개발자 등록이 안 되어 있다면 등록 진행 (등록비 $25 1회 지불)

2. **앱 만들기**
   - "앱 만들기" 버튼 클릭
   - 앱 이름: **Quest ON**
   - 기본 언어: **한국어**
   - 앱 또는 게임: **앱**
   - 무료 또는 유료: **무료**
   - 선언문 체크 후 "앱 만들기"

### 2-2. 인앱 상품 생성

#### 구독 상품 생성 준비

1. 왼쪽 메뉴에서 "수익 창출" → "제품" → "구독" 클릭
2. 처음이라면 "구독 만들기" 버튼 표시

#### 월간 구독 상품

1. "구독 만들기" 클릭
2. **기본 세부정보**:
   - 제품 ID: `quest_on_premium_monthly`
   - 이름: `프리미엄 월간 구독`
   - 설명: `Quest ON 프리미엄 기능을 한 달 동안 이용할 수 있습니다`

3. **혜택**:
   - 혜택 추가:
     - "광고 제거"
     - "프리미엄 테마"
     - "클라우드 백업"
     - "우선 지원"

4. **기본 요금제 추가**:
   - "기본 요금제 추가" 클릭
   - 청구 기간: **매월**
   - 가격 설정:
     - 국가: **대한민국**
     - 가격: **₩4,900** (또는 원하는 가격)
     - "가격 추가" 클릭
   - 무료 체험: 선택사항 (예: 7일)
   - "저장" 클릭

5. "활성화" 클릭

#### 연간 구독 상품

1. "구독 만들기" 클릭
2. **기본 세부정보**:
   - 제품 ID: `quest_on_premium_yearly`
   - 이름: `프리미엄 연간 구독`
   - 설명: `Quest ON 프리미엄 기능을 1년 동안 이용할 수 있습니다 (최대 33% 절약)`

3. **혜택**: 월간 구독과 동일

4. **기본 요금제 추가**:
   - 청구 기간: **매년**
   - 가격: **₩39,000** (월간 대비 약 33% 할인)
   - 무료 체험: 선택사항

5. "활성화" 클릭

#### 일회성 구매 상품 (광고 제거)

1. 왼쪽 메뉴에서 "수익 창출" → "제품" → "인앱 상품" 클릭
2. "상품 만들기" 클릭
3. **세부정보**:
   - 제품 ID: `quest_on_remove_ads`
   - 이름: `광고 영구 제거`
   - 설명: `한 번만 구매하면 평생 광고가 표시되지 않습니다`
   - 상태: **활성**

4. **가격 설정**:
   - "가격 설정" 클릭
   - 기본 가격: **₩9,900**
   - "가격 적용" 클릭

5. "저장" 클릭

### 2-3. 라이선스 테스터 추가

테스트 구매를 위해 테스터 계정 추가:

1. 왼쪽 메뉴에서 "설정" → "라이선스 테스트" 클릭
2. "라이선스 테스터" 섹션에서 "테스터 추가" 클릭
3. 테스트용 Gmail 주소 입력 (쉼표로 구분하여 여러 개 추가 가능)
4. "저장" 클릭

---

## 3. 코드에 실제 ID 적용

### 3-1. AdMob 앱 ID 적용

`android/app/src/main/AndroidManifest.xml` 파일 수정:

```xml
<!-- 기존 테스트 ID -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>

<!-- 실제 AdMob 앱 ID로 교체 -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
```

### 3-2. 광고 단위 ID 적용

`lib/data/services/ad_service.dart` 파일 수정:

```dart
class AdService {
  // 테스트 광고 단위 ID (실제 배포 시 변경 필요)
  static const String _bannerAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111' // 테스트 ID
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // ← 실제 배너 광고 단위 ID

  static const String _interstitialAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712' // 테스트 ID
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // ← 실제 전면 광고 단위 ID

  static const String _rewardedAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917' // 테스트 ID
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // ← 실제 보상형 광고 단위 ID

  // ... 나머지 코드
}
```

### 3-3. 인앱 상품 ID 확인

`lib/data/services/purchase_service.dart` 파일에서 상품 ID 확인:

```dart
class PurchaseService {
  // 상품 ID (Google Play Console에서 생성한 ID와 일치해야 함)
  static const String premiumMonthly = 'quest_on_premium_monthly';  // ✓
  static const String premiumYearly = 'quest_on_premium_yearly';    // ✓
  static const String removeAds = 'quest_on_remove_ads';            // ✓

  // ... 나머지 코드
}
```

**Play Console에서 생성한 제품 ID와 정확히 일치하는지 확인하세요!**

---

## 4. 테스트 방법

### 4-1. 광고 테스트

#### 디버그 모드 테스트 (테스트 광고)

```bash
flutter run
```

- 디버그 모드에서는 자동으로 테스트 광고가 표시됩니다
- 테스트 광고는 "Test Ad" 라벨이 표시됩니다
- 실제 수익은 발생하지 않습니다

#### 릴리스 모드 테스트 (실제 광고)

⚠️ **중요**: 자신의 광고를 클릭하면 AdMob 계정이 정지될 수 있습니다!

1. **테스트 기기 등록**:
   - AdMob 콘솔 → "설정" → "테스트 기기"
   - "테스트 기기 추가" 클릭
   - 기기 이름 및 광고 ID 입력
   - 광고 ID 확인 방법:
     ```bash
     adb logcat | grep "Use RequestConfiguration"
     ```

2. **릴리스 빌드로 테스트**:
   ```bash
   flutter build apk --release
   flutter install
   ```

### 4-2. 인앱 구매 테스트

#### 내부 테스트 트랙 설정

1. Play Console → "테스트" → "내부 테스트" 클릭
2. "새 버전 만들기" 클릭
3. APK 업로드:
   ```bash
   flutter build appbundle
   ```
4. 버전 이름 및 출시 노트 작성
5. "검토" → "출시 시작"

#### 테스터 추가

1. "내부 테스트" 페이지에서 "테스터" 탭
2. "테스터 목록 만들기" 또는 기존 목록 선택
3. Gmail 주소 추가
4. "변경사항 저장"
5. 테스터에게 옵트인 URL 전송

#### 구매 테스트

1. 테스터는 옵트인 URL로 테스트 참여
2. Play Store에서 앱 다운로드
3. 앱에서 구매 시도
4. **라이선스 테스터로 등록된 계정은 실제 결제 없이 구매 가능**
5. 구매 취소는 Play Console → "주문 관리"에서 가능

### 4-3. 구독 취소 테스트

1. Play Store 앱 열기
2. 프로필 아이콘 → "결제 및 정기 결제"
3. 정기 결제 선택 → "해지"

---

## 5. 자주 묻는 질문 (FAQ)

### Q1. 광고가 표시되지 않아요

**A**: 다음 사항을 확인하세요:
- AdMob에서 광고 단위가 활성화되었는지 (신규 광고 단위는 활성화까지 최대 24시간 소요)
- AndroidManifest.xml의 앱 ID가 올바른지
- 인터넷 연결 상태 확인
- Logcat에서 에러 메시지 확인:
  ```bash
  adb logcat | grep "Ads"
  ```

### Q2. 인앱 구매가 작동하지 않아요

**A**: 다음 사항을 확인하세요:
- Play Console에서 인앱 상품이 "활성" 상태인지
- 제품 ID가 코드와 정확히 일치하는지
- 테스터 계정이 라이선스 테스터로 등록되었는지
- 앱이 내부 테스트 트랙에 업로드되었는지
- 앱의 패키지명이 일치하는지 (`com.queston.quest_on_flutter`)

### Q3. 구독 갱신은 어떻게 테스트하나요?

**A**: 테스트 구매의 경우:
- 월간 구독 → 5분마다 갱신
- 연간 구독 → 30분마다 갱신
- 최대 6회까지만 갱신됨

### Q4. 프로덕션 배포 전 체크리스트

✅ **AdMob**:
- [ ] AndroidManifest.xml에 실제 AdMob 앱 ID 적용
- [ ] ad_service.dart에 실제 광고 단위 ID 적용
- [ ] 자신의 광고를 클릭하지 않도록 주의
- [ ] app-ads.txt 설정 (웹사이트가 있는 경우)

✅ **인앱 구매**:
- [ ] Play Console에서 모든 상품이 "활성" 상태
- [ ] 상품 설명 및 가격이 올바른지 확인
- [ ] 테스트 계정으로 구매 플로우 테스트 완료
- [ ] 구매 복원 기능 테스트 완료

✅ **법적 요구사항**:
- [ ] 개인정보처리방침 URL 등록
- [ ] 이용약관 URL 등록 (선택사항)
- [ ] 구독 취소 정책 명시

---

## 6. 참고 자료

- **AdMob 공식 문서**: https://developers.google.com/admob
- **Flutter AdMob 플러그인**: https://pub.dev/packages/google_mobile_ads
- **Play Console 인앱 상품 가이드**: https://support.google.com/googleplay/android-developer/answer/1153481
- **Flutter 인앱 구매**: https://pub.dev/packages/in_app_purchase

---

## 7. 지원

문제가 발생하면:
1. Logcat 로그 확인: `adb logcat`
2. AdMob 포럼: https://groups.google.com/g/google-admob-ads-sdk
3. Play Console 지원: https://support.google.com/googleplay/android-developer

---

**작성일**: 2025-11-10
**앱 버전**: Quest ON v1.0.0
**패키지명**: com.queston.quest_on_flutter
