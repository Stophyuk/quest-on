# Test Implementation Guide

## 테스트 개요

Quest ON 앱의 테스트 전략 및 구현 상황을 정리한 문서입니다.

## 테스트 구조

```
test/
├── presentation/
│   └── widgets/
│       ├── error_view_test.dart          # 에러 표시 위젯 테스트
│       ├── loading_view_test.dart         # 로딩 표시 위젯 테스트
│       ├── level_up_modal_test.dart       # 레벨업 모달 테스트
│       └── ai_quest_suggestions_modal_test.dart  # AI 추천 모달 테스트
└── widget_test.dart                       # 기본 앱 테스트
```

## 구현된 테스트

### 1. ErrorView 테스트 (error_view_test.dart)

**테스트 범위:**
- `ErrorView.getFriendlyMessage()` 정적 메서드
  - 네트워크 에러 메시지 변환
  - 타임아웃 에러 메시지 변환
  - 인증 에러 메시지 변환
  - Invalid Credentials 에러 메시지 변환
  - 서버 에러 메시지 변환
  - 일반 에러 메시지 변환
  - 문자열 에러 처리

- `ErrorView` 위젯
  - 기본 에러 표시
  - 재시도 버튼 탭 동작
  - 커스텀 메시지 표시

- `ErrorCard` 위젯
  - 컴팩트 에러 카드 표시
  - 재시도 버튼 탭 동작

**실행 방법:**
```bash
flutter test test/presentation/widgets/error_view_test.dart
```

### 2. LoadingView 테스트 (loading_view_test.dart)

**테스트 범위:**
- `LoadingView` 위젯
  - 기본 로딩 표시
  - 커스텀 메시지 표시

- `SmallLoadingIndicator` 위젯
  - 작은 로딩 표시 (24x24)

- `SkeletonCard` 위젯
  - 스켈레톤 카드 렌더링
  - 애니메이션 동작
  - 커스텀 높이 설정

- `SkeletonList` 위젯
  - 기본 개수(3개) 스켈레톤 카드 표시
  - 커스텀 개수 스켈레톤 카드 표시
  - ListView로 렌더링

**실행 방법:**
```bash
flutter test test/presentation/widgets/loading_view_test.dart
```

### 3. LevelUpModal 테스트 (level_up_modal_test.dart)

**테스트 범위:**
- 레벨업 모달 표시
- 확인 버튼으로 모달 닫기
- 애니메이션 동작 확인 (FadeTransition, ScaleTransition)
- 다양한 레벨 표시 (1, 50, 99)

**실행 방법:**
```bash
flutter test test/presentation/widgets/level_up_modal_test.dart
```

### 4. AI Quest Suggestions Modal 테스트 (ai_quest_suggestions_modal_test.dart)

**테스트 범위:**
- AI 추천 모달 표시 (헤더, 아이콘, 닫기 버튼)
- 추천 퀘스트 목록 표시
- 난이도 배지 표시 (쉬움, 보통, 어려움)
- 예상 시간 표시
- 추천 이유 표시
- 습관 쌓기 팁 표시
- 퀘스트 선택 콜백 호출
- 닫기 버튼으로 모달 닫기
- DraggableScrollableSheet 동작

**실행 방법:**
```bash
flutter test test/presentation/widgets/ai_quest_suggestions_modal_test.dart
```

## 테스트 실행

### 전체 테스트 실행
```bash
flutter test
```

### 특정 테스트 파일 실행
```bash
flutter test test/presentation/widgets/error_view_test.dart
```

### 커버리지 리포트 생성
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 다음 단계

### 추가 필요한 테스트

1. **Data Source 테스트**
   - `AiRemoteDataSource` 테스트
   - Supabase 클라이언트 mocking

2. **통합 테스트**
   - 인증 플로우 테스트
   - AI 퀘스트 추천 E2E 테스트

3. **Provider 테스트**
   - `AuthNotifier` 테스트
   - `QuestNotifier` 테스트
   - `UserStatsNotifier` 테스트

4. **Edge Function 테스트**
   - `suggest-quests` function 테스트
   - `generate-vision-note` function 테스트
   - `generate-goal-tree` function 테스트

## 테스트 모범 사례

1. **명확한 테스트 이름**
   - 한글로 작성하여 이해하기 쉽게
   - 테스트 대상과 예상 동작을 명확히 표현

2. **AAA 패턴 사용**
   - Arrange (준비): 테스트 환경 설정
   - Act (실행): 테스트 대상 실행
   - Assert (검증): 결과 확인

3. **독립적인 테스트**
   - 각 테스트는 서로 독립적으로 실행 가능
   - 테스트 간 상태 공유 금지

4. **Mock 사용**
   - 외부 의존성은 mock으로 대체
   - `mockito` 패키지 활용

## 테스트 커버리지 목표

- **목표 커버리지**: 80% 이상
- **핵심 비즈니스 로직**: 100%
- **UI 위젯**: 70% 이상

## 참고 자료

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [flutter_test Documentation](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html)
