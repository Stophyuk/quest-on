import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_on/presentation/widgets/error_view.dart';

void main() {
  group('ErrorView.getFriendlyMessage', () {
    test('네트워크 에러 메시지 변환', () {
      final networkError = Exception('Network error occurred');
      final message = ErrorView.getFriendlyMessage(networkError);
      expect(message, '인터넷 연결을 확인해주세요');
    });

    test('타임아웃 에러 메시지 변환', () {
      final timeoutError = Exception('Request timeout');
      final message = ErrorView.getFriendlyMessage(timeoutError);
      expect(message, '요청 시간이 초과되었습니다');
    });

    test('인증 에러 메시지 변환', () {
      final authError = Exception('Authentication failed');
      final message = ErrorView.getFriendlyMessage(authError);
      expect(message, '인증에 실패했습니다');
    });

    test('Invalid Credentials 에러 메시지 변환', () {
      final credentialsError = Exception('Invalid login credentials');
      final message = ErrorView.getFriendlyMessage(credentialsError);
      expect(message, '이메일 또는 비밀번호가 올바르지 않습니다');
    });

    test('서버 에러 메시지 변환', () {
      final serverError = Exception('Internal server error');
      final message = ErrorView.getFriendlyMessage(serverError);
      expect(message, '서버 오류가 발생했습니다');
    });

    test('일반 에러 메시지 변환', () {
      final genericError = Exception('Something went wrong');
      final message = ErrorView.getFriendlyMessage(genericError);
      expect(message, '오류가 발생했습니다. 다시 시도해주세요');
    });

    test('문자열 에러 처리', () {
      const stringError = 'Simple error';
      final message = ErrorView.getFriendlyMessage(stringError);
      expect(message, '오류가 발생했습니다. 다시 시도해주세요');
    });
  });

  group('ErrorView Widget', () {
    testWidgets('기본 에러 표시', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: '오류가 발생했습니다',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('오류가 발생했습니다'), findsOneWidget);
    });

    testWidgets('재시도 버튼 탭 동작', (WidgetTester tester) async {
      var retryCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: '오류가 발생했습니다',
              onRetry: () {
                retryCount++;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('다시 시도'));
      expect(retryCount, 1);
    });

    testWidgets('커스텀 메시지 표시', (WidgetTester tester) async {
      const customMessage = '커스텀 에러 메시지';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: customMessage,
            ),
          ),
        ),
      );

      expect(find.text(customMessage), findsOneWidget);
    });
  });

  group('ErrorCard Widget', () {
    testWidgets('컴팩트 에러 카드 표시', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorCard(
              message: '인터넷 연결을 확인해주세요',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('인터넷 연결을 확인해주세요'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('재시도 버튼 탭 동작', (WidgetTester tester) async {
      var retryCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorCard(
              message: '오류가 발생했습니다',
              onRetry: () {
                retryCount++;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.refresh));
      expect(retryCount, 1);
    });
  });
}
