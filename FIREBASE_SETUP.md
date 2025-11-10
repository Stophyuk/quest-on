# Firebase & Google Analytics 설정 가이드

이 문서는 Quest ON 앱에 Firebase와 Google Analytics를 설정하는 방법을 안내합니다.

## 1. Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com)에 접속
2. "프로젝트 추가" 클릭
3. 프로젝트 이름 입력: `quest-on` (또는 원하는 이름)
4. Google Analytics 사용 설정 (권장)
5. 프로젝트 생성 완료

## 2. Android 앱 추가

### 2.1 Firebase Console에서:
1. 프로젝트 개요 페이지에서 Android 아이콘 클릭
2. 앱 등록:
   - **Android 패키지 이름**: `com.queston.quest_on_flutter`
   - **앱 닉네임** (선택사항): Quest ON
   - **디버그 서명 인증서 SHA-1** (선택사항):
     ```
     F3:8A:FB:36:BF:75:F1:87:30:0D:5D:E6:52:F9:A1:E6:08:F7:41:AC
     ```
     *(Google 로그인을 사용하므로 SHA-1 필요)*

3. `google-services.json` 파일 다운로드

### 2.2 프로젝트에 google-services.json 추가:
다운로드한 `google-services.json` 파일을:
```
C:\project\my-life-quest\android\app\google-services.json
```
위치에 복사

### 2.3 Android 빌드 설정 업데이트:

**파일**: `android/build.gradle.kts` (루트 레벨)

다음 내용을 `plugins` 블록에 추가:
```kotlin
plugins {
    id("com.android.application") version "8.7.3" apply false
    id("com.android.library") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false  // 추가
}
```

**파일**: `android/app/build.gradle.kts`

plugins 블록의 **끝**에 다음 추가:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // 추가 (맨 마지막에)
}
```

## 3. iOS 앱 추가 (선택사항)

1. Firebase Console에서 iOS 아이콘 클릭
2. 번들 ID 입력: `com.queston.quest-on-flutter`
3. `GoogleService-Info.plist` 파일 다운로드
4. Xcode에서 `ios/Runner` 폴더에 파일 추가

## 4. Firebase Analytics 활성화

Firebase Console에서:
1. 왼쪽 메뉴 > Analytics > 대시보드
2. Google Analytics 연결 확인
3. 데이터 스트림 설정 확인

## 5. 패키지 설치

터미널에서 실행:
```bash
flutter pub get
```

## 6. 앱 실행 및 확인

1. 앱 빌드 및 실행:
   ```bash
   flutter run
   ```

2. Firebase Console에서 실시간 이벤트 확인:
   - Analytics > 대시보드 > 실시간
   - `first_open` 이벤트가 표시되면 성공

## 주의사항

- `google-services.json` 파일은 민감한 정보를 포함하므로 Git에 커밋하지 마세요
- `.gitignore`에 이미 추가되어 있습니다:
  ```
  **/android/app/google-services.json
  **/ios/Runner/GoogleService-Info.plist
  ```

## 문제 해결

### 빌드 오류 발생 시:
```bash
flutter clean
flutter pub get
flutter run
```

### Google 로그인 오류 시:
- SHA-1 인증서가 Firebase Console에 정확히 등록되었는지 확인
- `google-services.json` 파일이 올바른 위치에 있는지 확인

## 추가 리소스

- [Firebase Flutter 문서](https://firebase.google.com/docs/flutter/setup)
- [Firebase Analytics 문서](https://firebase.google.com/docs/analytics/get-started?platform=flutter)
